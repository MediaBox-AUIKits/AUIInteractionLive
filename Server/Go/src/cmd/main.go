package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"ApsaraLive/docs"
	"ApsaraLive/internal/auth"
	"ApsaraLive/pkg/alicloud/im"
	"ApsaraLive/pkg/config"
	"ApsaraLive/pkg/handler"
	"ApsaraLive/pkg/service/default"
	"ApsaraLive/pkg/storage"
	"ApsaraLive/pkg/storage/database"
	"ApsaraLive/pkg/storage/mock"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

const (
	XHeaderAk       = "x-fc-access-key-id"
	XHeaderSk       = "x-fc-access-key-secret"
	XHeaderStsToken = "x-fc-security-token"

	EnvPasswordName = "ADMIN_PASSWORD"
	SwaggerUserName = "admin"
)

func main() {
	docs.SwaggerInfo.Title = "Swagger Example API"
	docs.SwaggerInfo.Description = "This is a sample server."
	docs.SwaggerInfo.Version = "1.0"
	docs.SwaggerInfo.Host = "example.com"
	docs.SwaggerInfo.BasePath = "/api/v1/live"
	docs.SwaggerInfo.Schemes = []string{"http", "https"}

	runServer()
}

func runServer() {
	appConfig, err := config.LoadConfig()
	if err != nil {
		panic(err)
	}

	r := gin.Default()

	// 允许Web sdk跨域接入
	cs := cors.DefaultConfig()
	cs.AllowHeaders = []string{"Origin", "Content-Length", "Content-Type", "Authorization", "x-live-env"}
	cs.AllowOrigins = []string{"*"}
	r.Use(cors.New(cs))

	imService, err := im.NewLiveIMService(appConfig)

	var sapi storage.StorageAPI
	if appConfig.StorageConfig.Type == "none" {
		sapi = mock.NewMockDb(imService)
		log.Println("User liveIM as storage service...")
	} else {
		sapi, err = database.NewGormDb(appConfig.StorageConfig.Type, appConfig.StorageConfig.Url)
		if err != nil {
			panic(err)
		}
		log.Printf("User %s as storage service...", appConfig.StorageConfig.Type)
	}

	lm := _default.NewLiveRoomManager(sapi, imService, appConfig)
	h := handler.NewRoomHandler(lm)

	r.GET("/", func(c *gin.Context) {
		url := fmt.Sprintf("请在客户端配置访问访问地址：%s", c.Request.Host+c.Request.URL.Path)
		c.String(http.StatusOK, url)
	})

	authMiddleware, err := auth.GetGinJWTMiddleware()
	if err != nil {
		panic(err)
	}

	err = authMiddleware.MiddlewareInit()
	if err != nil {
		panic(err)
	}
	// just for test
	authMiddleware.Timeout = time.Hour * 24

	// 客户应用自身用户账号管理，以下为模拟，请修改为实际能力
	r.POST("/login", authMiddleware.LoginHandler)
	r.POST("/api/v1/live/login", authMiddleware.LoginHandler)
	r.POST("/api/v1/live/refresh_token", authMiddleware.RefreshHandler)

	auth := r.Group("/auth")
	auth.GET("/refresh_token", authMiddleware.RefreshHandler)

	// 对接互动直播AUI端上的Restful API
	v1 := r.Group("/api/v1")
	{
		// 演示开启token拦截，实际生产使用请保证开启
		v1.Use(authMiddleware.MiddlewareFunc())
		live := v1.Group("/live")

		// 如果是在FC环境，自动更新sts token
		live.Use(func() gin.HandlerFunc {
			return func(ctx *gin.Context) {
				header := ctx.Request.Header
				if header.Get(XHeaderAk) != "" {
					appConfig.OpenAPIConfig.RefreshToken(header.Get(XHeaderAk),
						header.Get(XHeaderSk),
						header.Get(XHeaderStsToken),
					)
				}
				ctx.Next()
			}
		}())
		{
			live.POST("/create", gin.WrapF(h.Create))
			live.POST("/list", gin.WrapF(h.List))
			live.POST("/get", gin.WrapF(h.Get))
			live.POST("/start", gin.WrapF(h.Start))
			live.POST("/pause", gin.WrapF(h.Pause))
			live.POST("/stop", gin.WrapF(h.Stop))
			live.POST("/delete", gin.WrapF(h.Delete))
			live.POST("/update", gin.WrapF(h.Update))
			live.POST("/token", gin.WrapF(h.GetToken))

			live.POST("/updateMeetingInfo", gin.WrapF(h.UpdateMeetingInfo))
			live.POST("/getMeetingInfo", gin.WrapF(h.GetMeetingInfo))
		}
	}

	// Swagger功能
	password := os.Getenv(EnvPasswordName)
	// 如果密码为空，则关闭swagger的功能
	if password != "" && password != "null" {
		sw := r.Group("/swagger")
		sw.Use(func() gin.HandlerFunc {
			return func(c *gin.Context) {
				docs.SwaggerInfo.Host = c.Request.Host
				c.Next()
			}
		}())
		sw.Use(gin.BasicAuth(gin.Accounts{SwaggerUserName: password}))
		sw.GET("/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
	}

	err = r.Run(":7001")
	if err != nil {
		log.Panicln(err)
	}
}
