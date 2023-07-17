package handler

import (
	"net/http"
	"strings"

	"ApsaraLive/pkg/models"
	"github.com/gin-gonic/gin/binding"
	"github.com/go-chi/render"
)

type MeetingActionRequest struct {
	Id      string                 `json:"id" example:"直播Id"`
	Members []models.MeetingMember `json:"members"`
}

type GetMeetingInfoRequest struct {
	Id string `json:"id" example:"直播Id"`
}

// UpdateMeetingInfo
// @Summary 全量更新直播连麦人员信息
// @Description 全量更新直播连麦人员信息
// @ID UpdateMeetingInfo
// @Accept  json
// @Produce  json
// @Security ApiKeyAuth
// @param   Authorization header string true "Bearer your-token"
// @Param   request      body handler.MeetingActionRequest true "请求参数"
// @Success 200 {object} models.MeetingInfo	"ok"
// @Failure 400 {object} models.Status	"4xx, 客户端错误"
// @Failure 500 {object} models.Status	"5xx, 请求失败"
// @Router /updateMeetingInfo [post]
func (h *RoomHandler) UpdateMeetingInfo(w http.ResponseWriter, r *http.Request) {
	var in MeetingActionRequest
	b := binding.Default(r.Method, strings.Split(r.Header.Get("Content-Type"), ";")[0])
	err := b.Bind(r, &in)
	var rst interface{}
	if err != nil {
		render.Status(r, http.StatusBadRequest)
		rst = &models.Status{Code: http.StatusBadRequest, Message: err.Error()}
		render.DefaultResponder(w, r, rst)
		return
	}

	rst, err = h.lm.UpdateMeetingInfo(in.Id, in.Members)
	if err != nil {
		render.Status(r, http.StatusInternalServerError)
		rst = &models.Status{Code: http.StatusInternalServerError, Message: err.Error()}
	}
	render.DefaultResponder(w, r, rst)
}

// GetMeetingInfo
// @Summary 全量获取连麦信息
// @Description 全量获取连麦信息
// @ID GetMeetingInfo
// @Accept  json
// @Produce  json
// @Security ApiKeyAuth
// @param   Authorization header string true "Bearer your-token"
// @Param   request      body handler.GetMeetingInfoRequest true "请求参数"
// @Success 200 {object} models.MeetingInfo	"ok"
// @Failure 400 {object} models.Status	"4xx, 客户端错误"
// @Failure 500 {object} models.Status	"5xx, 请求失败"
// @Router /getMeetingInfo [post]
func (h *RoomHandler) GetMeetingInfo(w http.ResponseWriter, r *http.Request) {
	var in GetMeetingInfoRequest
	b := binding.Default(r.Method, strings.Split(r.Header.Get("Content-Type"), ";")[0])
	err := b.Bind(r, &in)
	var rst interface{}
	if err != nil {
		render.Status(r, http.StatusBadRequest)
		rst = &models.Status{Code: http.StatusBadRequest, Message: err.Error()}
		render.DefaultResponder(w, r, rst)
		return
	}

	rst, err = h.lm.GetMeetingInfo(in.Id)
	if err != nil {
		render.Status(r, http.StatusInternalServerError)
		rst = &models.Status{Code: http.StatusInternalServerError, Message: err.Error()}
	}
	render.DefaultResponder(w, r, rst)
}
