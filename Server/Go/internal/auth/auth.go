package auth

import (
	"time"

	jwt "github.com/appleboy/gin-jwt/v2"
	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

var identityKey = "id"
var jwtKey = "example-c895beb520125bba#$&"

// User demo
type User struct {
	UserId string
	Nick   string
}

type login struct {
	Username string `form:"username" json:"username" binding:"required"`
	Password string `form:"password" json:"password" binding:"required"`
}

type authResponse struct {
	Expire string `json:"expire""` //nolint:govet
	Token  string `json:"token"`
}

// Login
// @Summary App用户登陆
// @Description App用户登陆
// @ID login
// @Accept  json
// @Produce  json
// @Param   request      body auth.login true "请求参数"
// @Success 200 {object} auth.authResponse	"ok"
// @Failure 400 {object} models.Status	"4xx, 客户端错误"
// @Failure 500 {object} models.Status	"5xx, 请求失败"
// @Router /login [post]
func Login(c *gin.Context) (interface{}, error) {
	var loginVals login
	if err := c.ShouldBind(&loginVals); err != nil {
		return "", jwt.ErrMissingLoginValues
	}
	userID := loginVals.Username
	password := loginVals.Password

	// 演示，实际存储的密码非明文, 用户名即密码
	hash, _ := bcrypt.GenerateFromPassword([]byte(userID), bcrypt.DefaultCost)

	err := bcrypt.CompareHashAndPassword(hash, []byte(password))

	if userID != "" && err == nil {
		return &User{
			UserId: userID,
			Nick:   userID,
		}, nil
	}

	return nil, jwt.ErrFailedAuthentication
}

func GetGinJWTMiddleware() (*jwt.GinJWTMiddleware, error) {
	// the jwt middleware
	authMiddleware, err := jwt.New(&jwt.GinJWTMiddleware{
		Realm:       "zone",
		Key:         []byte(jwtKey),
		Timeout:     24 * time.Hour,
		MaxRefresh:  24 * time.Hour,
		IdentityKey: identityKey,
		PayloadFunc: func(data interface{}) jwt.MapClaims {
			if v, ok := data.(*User); ok {
				return jwt.MapClaims{
					identityKey: v.UserId,
				}
			}
			return jwt.MapClaims{}
		},
		IdentityHandler: func(c *gin.Context) interface{} {
			claims := jwt.ExtractClaims(c)
			return &User{
				UserId: claims[identityKey].(string),
			}
		},
		Authenticator: Login,

		Authorizator: func(data interface{}, c *gin.Context) bool {
			if v, ok := data.(*User); ok && v.UserId != "" {
				return true
			}

			return false
		},
		Unauthorized: func(c *gin.Context, code int, message string) {
			c.JSON(code, gin.H{
				"code":    code,
				"message": message,
			})
		},
		// TokenLookup is a string in the form of "<source>:<name>" that is used
		// to extract token from the request.
		// Optional. Default value "header:Authorization".
		// Possible values:
		// - "header:<name>"
		// - "query:<name>"
		// - "cookie:<name>"
		// - "param:<name>"
		TokenLookup: "header: Authorization, query: token, cookie: jwt",
		// TokenLookup: "query:token",
		// TokenLookup: "cookie:token",

		// TokenHeadName is a string in the header. Default value is "Bearer"
		TokenHeadName: "Bearer",

		// TimeFunc provides the current time. You can override it to use another time value. This is useful for testing or if your server uses a different time zone than your tokens.
		TimeFunc: time.Now,
	})

	return authMiddleware, err
}
