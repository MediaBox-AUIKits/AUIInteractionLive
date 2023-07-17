package service

import (
	"ApsaraLive/pkg/models"
)

type LiveRoomManagerAPI interface {
	GetIMToken(env, userId, deviceId, deviceType string) (string, error)

	GetRoomList(pageSize int, pageNum int, role string) ([]*models.RoomInfo, error)

	CreateRoom(title, notice, Anchor string, extend string, mode int) (*models.RoomInfo, error)

	GetRoom(id, role string) (*models.RoomInfo, error)

	UpdateRoom(id string, title, notice string, extend string) (*models.RoomInfo, error)

	DeleteRoom(id string) (*models.RoomInfo, error)

	StartLive(id string, role string) (*models.RoomInfo, error)

	PauseLive(id string, role string) (*models.RoomInfo, error)

	StopLive(id string, role string) (*models.RoomInfo, error)

	UpdateMeetingInfo(id string, members []models.MeetingMember) (*models.MeetingInfo, error)

	GetMeetingInfo(id string) (*models.MeetingInfo, error)

	// HandleLivePushStreamCallbackEvent 处理直播回调事件
	HandleLivePushStreamCallbackEvent(liveRoomManagerEvent *models.LivePushStreamEvent) (bool, error)

	GetLiveJumpUrl(in *models.JumpUrlRequest, appServerHost string) (string, error)

	VerifyAuthToken(in *models.AuthTokenRequest, host string) error
}
