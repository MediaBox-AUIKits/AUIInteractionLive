package handler

import (
	"net/http"
	"strings"

	"ApsaraLive/pkg/models"
	"ApsaraLive/pkg/service"
	"github.com/gin-gonic/gin/binding"
	"github.com/go-chi/render"
)

type RoomHandler struct {
	lm service.LiveRoomManagerAPI
}

func NewRoomHandler(lm service.LiveRoomManagerAPI) *RoomHandler {
	return &RoomHandler{lm: lm}
}

type CreateRequest struct {
	// 直播标题
	Title string `json:"title" binding:"required" example:"直播标题"`
	// 直播公告
	Notice string `json:"notice" example:"直播公告"`
	// 主播id
	Anchor string `json:"anchor" binding:"required" example:"主播userId"`
	// 主播Nick
	AnchorNick string `json:"anchor_nick" example:"主播nick"`
	// 模式，默认0 普通直播，1 连麦直播
	Mode int `json:"mode" default:"0" example:"0"`
	// 扩展字段，通常是JSON格式字符串
	Extends string `json:"extends" example:"扩展字段，通常是JSON格式字符串"`
}

// Create
// @Summary 创建直播房间
// @Description 创建直播房间
// @ID create
// @Accept  json
// @Produce  json
// @Security ApiKeyAuth
// @param   Authorization header string true "Bearer your-token"
// @Param   request      body handler.CreateRequest true "请求参数"
// @Success 200 {object} models.RoomInfo	"ok"
// @Failure 400 {object} models.Status	"4xx, 客户端错误"
// @Failure 500 {object} models.Status	"5xx, 请求失败"
// @Router /create [post]
func (h *RoomHandler) Create(w http.ResponseWriter, r *http.Request) {
	var in CreateRequest
	b := binding.Default(r.Method, strings.Split(r.Header.Get("Content-Type"), ";")[0])
	err := b.Bind(r, &in)
	var rst interface{}
	if err != nil {
		render.Status(r, http.StatusBadRequest)
		rst = &models.Status{Code: http.StatusBadRequest, Message: err.Error()}
		render.DefaultResponder(w, r, rst)
		return
	}
	rst, err = h.lm.CreateRoom(in.Title, in.Notice, in.Anchor, in.Extends, in.Mode)
	if err != nil {
		render.Status(r, http.StatusInternalServerError)
		rst = &models.Status{Code: http.StatusInternalServerError, Message: err.Error()}
	}
	render.DefaultResponder(w, r, rst)
}

type ListRequest struct {
	PageSize int    `json:"page_size" binding:"required" example:"10"`
	PageNum  int    `json:"page_num"  binding:"required" example:"1"`
	UserId   string `json:"user_id" binding:"required"`
}

// List
// @Summary 获取直播房间列表
// @Description 获取直播房间列表
// @ID list
// @Accept  json
// @Produce  json
// @Security ApiKeyAuth
// @param   Authorization header string true "Bearer your-token"
// @Param   request      body handler.ListRequest true "请求参数"
// @Success 200 {object} []models.RoomInfo	"ok"
// @Failure 400 {object} models.Status	"4xx, 客户端错误"
// @Failure 500 {object} models.Status	"5xx, 请求失败"
// @Router /list [post]
func (h *RoomHandler) List(w http.ResponseWriter, r *http.Request) {
	var in ListRequest
	b := binding.Default(r.Method, strings.Split(r.Header.Get("Content-Type"), ";")[0])
	err := b.Bind(r, &in)
	var rst interface{}
	if err != nil {
		render.Status(r, http.StatusBadRequest)
		rst = &models.Status{Code: http.StatusBadRequest, Message: err.Error()}
		render.DefaultResponder(w, r, rst)
		return
	}

	rst, err = h.lm.GetRoomList(in.PageSize, in.PageNum, in.UserId)
	if err != nil {
		render.Status(r, http.StatusInternalServerError)
		rst = &models.Status{Code: http.StatusInternalServerError, Message: err.Error()}
	}
	render.DefaultResponder(w, r, rst)
}

type GetRequest struct {
	Id     string `json:"id" binding:"required" example:"uuid，直播房间id"`
	UserId string `json:"user_id" binding:"required" example:"当前用户id"`
}

// Get
// @Summary 获取直播房间详情
// @Description 获取直播房间详情
// @ID get
// @Accept  json
// @Produce  json
// @Security ApiKeyAuth
// @param   Authorization header string true "Bearer your-token"
// @Param   request      body handler.GetRequest true "请求参数"
// @Success 200 {object} models.RoomInfo	"ok"
// @Failure 400 {object} models.Status	"4xx, 客户端错误"
// @Failure 500 {object} models.Status	"5xx, 请求失败"
// @Router /get [post]
func (h *RoomHandler) Get(w http.ResponseWriter, r *http.Request) {
	var in GetRequest
	b := binding.Default(r.Method, strings.Split(r.Header.Get("Content-Type"), ";")[0])
	err := b.Bind(r, &in)
	var rst interface{}
	if err != nil {
		render.Status(r, http.StatusBadRequest)
		rst = &models.Status{Code: http.StatusBadRequest, Message: err.Error()}
		render.DefaultResponder(w, r, rst)
		return
	}

	rst, err = h.lm.GetRoom(in.Id, in.UserId)
	if err != nil {
		render.Status(r, http.StatusInternalServerError)
		rst = &models.Status{Code: http.StatusInternalServerError, Message: err.Error()}
	}

	render.DefaultResponder(w, r, rst)
}

type UpdateRequest struct {
	Id string `json:"id" example:"直播Id"`
	// 直播标题
	Title string `json:"title" example:"直播标题"`
	// 直播公告
	Notice string `json:"notice" example:"直播公告"`
	// 扩展字段，通常是JSON格式字符串
	Extends string `json:"extends" example:"扩展字段，通常是JSON格式字符串"`
}

// Update
// @Summary 更新房间详情
// @Description 更新房间详情
// @ID update
// @Accept  json
// @Produce  json
// @Security ApiKeyAuth
// @param   Authorization header string true "Bearer your-token"
// @Param   request      body handler.UpdateRequest true "请求参数"
// @Success 200 {object} models.RoomInfo	"ok"
// @Failure 400 {object} models.Status	"4xx, 客户端错误"
// @Failure 500 {object} models.Status	"5xx, 请求失败"
// @Router /update [post]
func (h *RoomHandler) Update(w http.ResponseWriter, r *http.Request) {
	var in UpdateRequest
	b := binding.Default(r.Method, strings.Split(r.Header.Get("Content-Type"), ";")[0])
	err := b.Bind(r, &in)
	var rst interface{}
	if err != nil {
		render.Status(r, http.StatusBadRequest)
		rst = &models.Status{Code: http.StatusBadRequest, Message: err.Error()}
		render.DefaultResponder(w, r, rst)
		return
	}
	rst, err = h.lm.UpdateRoom(in.Id, in.Title, in.Notice, in.Extends)
	if err != nil {
		render.Status(r, http.StatusInternalServerError)
		rst = &models.Status{Code: http.StatusInternalServerError, Message: err.Error()}
	}
	render.DefaultResponder(w, r, rst)
}

type LiveStatusRequest struct {
	Id     string `json:"id" binding:"required" example:"uuid，直播房间id"`
	UserId string `json:"user_id" binding:"required" example:"当前用户id"`
}

// Start
// @Summary 开始直播
// @Description 开始直播
// @ID start
// @Accept  json
// @Produce  json
// @Security ApiKeyAuth
// @param   Authorization header string true "Bearer your-token"
// @Param   request      body handler.LiveStatusRequest true "请求参数"
// @Success 200 {object} models.RoomInfo	"ok"
// @Failure 400 {object} models.Status	"4xx, 客户端错误"
// @Failure 500 {object} models.Status	"5xx, 请求失败"
// @Router /start [post]
func (h *RoomHandler) Start(w http.ResponseWriter, r *http.Request) {
	var in DeleteRequest
	b := binding.Default(r.Method, strings.Split(r.Header.Get("Content-Type"), ";")[0])
	err := b.Bind(r, &in)
	var rst interface{}
	if err != nil {
		render.Status(r, http.StatusBadRequest)
		rst = &models.Status{Code: http.StatusBadRequest, Message: err.Error()}
		render.DefaultResponder(w, r, rst)
		return
	}

	rst, err = h.lm.StartLive(in.Id, in.UserId)
	if err != nil {
		render.Status(r, http.StatusInternalServerError)
		rst = &models.Status{Code: http.StatusInternalServerError, Message: err.Error()}
	}
	render.DefaultResponder(w, r, rst)
}

// Pause
// @Summary 暂停直播
// @Description 暂停直播
// @ID pause
// @Accept  json
// @Produce  json
// @Security ApiKeyAuth
// @param   Authorization header string true "Bearer your-token"
// @Param   request      body handler.LiveStatusRequest true "请求参数"
// @Success 200 {object} models.RoomInfo	"ok"
// @Failure 400 {object} models.Status	"4xx, 客户端错误"
// @Failure 500 {object} models.Status	"5xx, 请求失败"
// @Router /pause [post]
func (h *RoomHandler) Pause(w http.ResponseWriter, r *http.Request) {
	var in DeleteRequest
	b := binding.Default(r.Method, r.Header.Get("Content-Type"))
	err := b.Bind(r, &in)
	var rst interface{}
	if err != nil {
		render.Status(r, http.StatusBadRequest)
		rst = &models.Status{Code: http.StatusBadRequest, Message: err.Error()}
		render.DefaultResponder(w, r, rst)
		return
	}

	rst, err = h.lm.PauseLive(in.Id, in.UserId)
	if err != nil {
		render.Status(r, http.StatusInternalServerError)
		rst = &models.Status{Code: http.StatusInternalServerError, Message: err.Error()}
	}
	render.DefaultResponder(w, r, rst)
}

// Stop
// @Summary 停止直播
// @Description 停止直播
// @ID stop
// @Accept  json
// @Produce  json
// @Security ApiKeyAuth
// @param   Authorization header string true "Bearer your-token"
// @Param   request      body handler.LiveStatusRequest true "请求参数"
// @Success 200 {object} models.RoomInfo	"ok"
// @Failure 400 {object} models.Status	"4xx, 客户端错误"
// @Failure 500 {object} models.Status	"5xx, 请求失败"
// @Router /stop [post]
func (h *RoomHandler) Stop(w http.ResponseWriter, r *http.Request) {
	var in DeleteRequest
	b := binding.Default(r.Method, strings.Split(r.Header.Get("Content-Type"), ";")[0])
	err := b.Bind(r, &in)
	var rst interface{}
	if err != nil {
		render.Status(r, http.StatusBadRequest)
		rst = &models.Status{Code: http.StatusBadRequest, Message: err.Error()}
		render.DefaultResponder(w, r, rst)
		return
	}

	rst, err = h.lm.StopLive(in.Id, in.UserId)
	if err != nil {
		render.Status(r, http.StatusInternalServerError)
		rst = &models.Status{Code: http.StatusInternalServerError, Message: err.Error()}
	}
	render.DefaultResponder(w, r, rst)
}

type DeleteRequest struct {
	Id     string `json:"id" binding:"required" example:"uuid，直播房间id"`
	UserId string `json:"user_id" binding:"required" example:"当前用户id"`
}

// Delete
// @Summary 删除房间
// @Description 删除房间
// @ID delete
// @Accept  json
// @Produce  json
// @Security ApiKeyAuth
// @param   Authorization header string true "Bearer your-token"
// @Param   request      body handler.DeleteRequest true "请求参数"
// @Success 200 {object} models.RoomInfo	"ok"
// @Failure 400 {object} models.Status	"4xx, 客户端错误"
// @Failure 500 {object} models.Status	"5xx, 请求失败"
// @Router /delete [post]
func (h *RoomHandler) Delete(w http.ResponseWriter, r *http.Request) {
	var in DeleteRequest
	b := binding.Default(r.Method, strings.Split(r.Header.Get("Content-Type"), ";")[0])
	err := b.Bind(r, &in)
	var rst interface{}
	if err != nil {
		render.Status(r, http.StatusBadRequest)
		rst = &models.Status{Code: http.StatusBadRequest, Message: err.Error()}
		render.DefaultResponder(w, r, rst)
		return
	}

	rst, err = h.lm.DeleteRoom(in.Id)
	if err != nil {
		render.Status(r, http.StatusInternalServerError)
		rst = &models.Status{Code: http.StatusInternalServerError, Message: err.Error()}
	}
	render.DefaultResponder(w, r, rst)
}

type TokenRequest struct {
	UserId     string `json:"user_id" binding:"required" example:"用户id:foo"`
	DeviceId   string `json:"device_id" binding:"required" example:"设备id：DEVICE-ID"`
	DeviceType string `json:"device_type" binding:"required" example:"设备类型：android/ios/web/win/mac"`
}

type TokenResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
}

// GetToken
// @Summary 获取TOKEN
// @Description 获取token
// @ID token
// @Accept  json
// @Produce  json
// @Security ApiKeyAuth
// @param   Authorization header string true "Bearer your-token"
// @Param   request      body handler.TokenRequest true  "请求参数"
// @Success 200 {object} handler.TokenResponse	"ok"
// @Failure 400 {object} models.Status	"4xx, 客户端错误"
// @Failure 500 {object} models.Status	"5xx, 请求失败"
// @Router /token [post]
func (h *RoomHandler) GetToken(w http.ResponseWriter, r *http.Request) {
	env := r.Header.Get("x-live-env")
	var in TokenRequest
	b := binding.Default(r.Method, strings.Split(r.Header.Get("Content-Type"), ";")[0])
	err := b.Bind(r, &in)
	var rst interface{}
	if err != nil {
		render.Status(r, http.StatusBadRequest)
		rst = &models.Status{Code: http.StatusBadRequest, Message: err.Error()}
		render.DefaultResponder(w, r, rst)
		return
	}

	var tokenResp TokenResponse
	tokenResp.AccessToken, err = h.lm.GetIMToken(env, in.UserId, in.DeviceId, in.DeviceType)
	tokenResp.RefreshToken = tokenResp.AccessToken
	rst = tokenResp
	if err != nil {
		render.Status(r, http.StatusInternalServerError)
		rst = &models.Status{Code: http.StatusInternalServerError, Message: err.Error()}
	}

	render.DefaultResponder(w, r, rst)
}
