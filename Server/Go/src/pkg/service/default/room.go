package _default

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"time"

	"golang.org/x/sync/errgroup"

	"ApsaraLive/pkg/alicloud/im"
	live2 "ApsaraLive/pkg/alicloud/live"
	"ApsaraLive/pkg/alicloud/vod"
	"ApsaraLive/pkg/config"
	"ApsaraLive/pkg/models"
	"ApsaraLive/pkg/storage"
	"github.com/google/uuid"
)

type LiveRoomManager struct {
	sa         storage.StorageAPI
	appConfig  *config.AppConfig
	imService  *im.LiveIMService
	vodService *vod.VodService
}

func NewLiveRoomManager(sa storage.StorageAPI, imSvr *im.LiveIMService, appConfig *config.AppConfig) *LiveRoomManager {
	l := &LiveRoomManager{sa: sa, appConfig: appConfig, imService: imSvr}
	l.vodService = vod.NewVodService(&appConfig.OpenAPIConfig)
	return l
}

func (l *LiveRoomManager) GetIMToken(env, userId, deviceId, deviceType string) (string, error) {
	token, err := l.imService.GetToken(userId, deviceId, deviceType)
	if err != nil {
		return "", err
	}

	if l.appConfig.GatewayConfig.Enable {
		return l.getStagingToken(deviceType, token)
	}
	return token, nil

}

func (l *LiveRoomManager) CreateRoom(title, notice, anchorId string, extends string, mode int) (*models.RoomInfo, error) {
	var chatId string
	var err error
	chatId, err = l.imService.CreateMessageGroup(anchorId, nil)
	if err != nil {
		return nil, err
	}
	// 在直播和群组一对一绑定模型里，可以复用chatId，否则不允许这么做
	liveId := chatId

	r := &models.RoomInfo{
		ID:        liveId,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
		Title:     title,
		Notice:    notice,
		AnchorId:  anchorId,
		Extends:   extends,
	}
	r.ChatId = chatId

	if mode > models.LiveModeNormal {
		r.MeetingId = uuid.NewString()
		r.Mode = mode
	}

	err = l.sa.CreateRoom(r)
	if err != nil {
		return nil, err
	}

	if r.Mode == models.LiveModeLink {
		r.LinkInfo, err = l.getRtcInfo(r.MeetingId, anchorId, anchorId, true, true)
		if err != nil {
			return nil, err
		}
	}

	// 保持普通推拉流信息存在
	{
		r.PushInfo, err = l.getPushLiveInfo(r)
		if err != nil {
			return nil, err
		}

		r.PullInfo, err = l.getPullLiveInfo(r)
		if err != nil {
			return nil, err
		}
	}

	return r, nil
}

func (l *LiveRoomManager) GetRoomList(pageSize int, pageNum int, role string) ([]*models.RoomInfo, error) {
	ids, err := l.sa.GetRoomList(pageSize, pageNum)
	if err != nil {
		return nil, err
	}

	roomList := make([]*models.RoomInfo, len(ids))
	var g errgroup.Group
	for idx, id := range ids {
		curIdx := idx
		curId := id
		g.Go(func() error {
			item, err := l.GetRoom(curId, role)
			if err != nil {
				return err
			}
			roomList[curIdx] = item
			return nil
		})
	}

	err = g.Wait()
	if err != nil {
		return nil, err
	}

	return roomList, nil
}

func (l *LiveRoomManager) UpdateRoom(id string, title, notice, extends string) (*models.RoomInfo, error) {
	record, err := l.sa.GetRoom(id)
	if err != nil {
		return nil, err
	}
	if "" != title {
		record.Title = title
	}
	if "" != notice {
		record.Notice = notice
	}
	if "" != extends {
		record.Extends = extends
	}
	record.UpdatedAt = time.Now()
	err = l.sa.UpdateRoom(id, record)
	if err != nil {
		return nil, err
	}
	return record, nil
}

func (l *LiveRoomManager) StartLive(id string, role string) (*models.RoomInfo, error) {
	record, err := l.sa.GetRoom(id)
	if err != nil {
		return nil, err
	}

	record.Status = models.LiveStatusOn
	record.StartedAt = time.Now()
	err = l.sa.UpdateRoom(id, record)
	if err != nil {
		return nil, err
	}

	return record, nil
}

func (l *LiveRoomManager) PauseLive(id string, role string) (*models.RoomInfo, error) {
	record, err := l.sa.GetRoom(id)
	if err != nil {
		return nil, err
	}
	record.Status = models.LiveStatusPrepare
	err = l.sa.UpdateRoom(id, record)
	if err != nil {
		return nil, err
	}

	return record, nil
}

func (l *LiveRoomManager) StopLive(id string, role string) (*models.RoomInfo, error) {
	record, err := l.sa.GetRoom(id)
	if err != nil {
		return nil, err
	}

	record.StoppedAt = time.Now()
	record.Status = models.LiveStatusOff
	err = l.sa.UpdateRoom(id, record)
	if err != nil {
		return nil, err
	}

	return record, nil
}

func (l *LiveRoomManager) DeleteRoom(id string) (*models.RoomInfo, error) {
	record, err := l.sa.GetRoom(id)
	if err != nil {
		return nil, err
	}

	err = l.sa.DeleteRoom(id)
	if err != nil {
		return nil, err
	}

	return record, nil
}

// GetRoom 获取直播详情
// 推流地址和播放地址 说明： https://help.aliyun.com/document_detail/199339.html
// 配置URL鉴权 说明：https://help.aliyun.com/document_detail/85018.html
func (l *LiveRoomManager) GetRoom(id string, userId string) (*models.RoomInfo, error) {
	r, err := l.sa.GetRoom(id)
	if err != nil {
		return nil, err
	}

	if r.ChatId == "" {
		r.ChatId = id
	}

	if r.Mode >= models.LiveModeLink {
		r.LinkInfo, err = l.getRtcInfo(r.MeetingId, userId, r.AnchorId, true, userId == r.AnchorId)
		if err != nil {
			return nil, err
		}
	}

	if r.AnchorId == userId || userId == "admin" {
		r.PushInfo, err = l.getPushLiveInfo(r)
		if err != nil {
			return nil, err
		}
	}

	r.PullInfo, err = l.getPullLiveInfo(r)
	if err != nil {
		return nil, err
	}

	r.VodInfo, err = l.getVodInfo(r)
	if err != nil {
		return nil, err
	}

	imService, err := im.NewLiveIMService(l.appConfig)
	if err != nil {
		return nil, err
	}

	details, err := imService.GetGroupDetails(r.ChatId, userId)
	if err != nil {
		return nil, err
	}

	r.Metrics = &models.Metrics{
		OnlineCount: uint64(details.OnlineCount),
		LikeCount:   uint64(details.LikeCount),
		Pv:          uint64(details.PV),
		Uv:          uint64(details.UV),
	}

	r.UserStatus = &models.UserStatus{
		Mute:       details.IsMute,
		MuteSource: details.MuteBy,
	}

	return r, nil
}

func (l *LiveRoomManager) getPushLiveInfo(r *models.RoomInfo) (*models.PushLiveInfo, error) {
	streamName := r.ID
	liveConfig := l.appConfig.LiveStreamConfig

	pushUrl := liveConfig.PushUrl
	pushAuthKey := live2.AAuth(fmt.Sprintf("/%s/%s", liveConfig.AppName, streamName), liveConfig.PushAuthKey, liveConfig.AuthExpires)

	url := fmt.Sprintf("%s/%s/%s?auth_key=%s", pushUrl, liveConfig.AppName, streamName, pushAuthKey)
	return &models.PushLiveInfo{
		RtmpUrl: fmt.Sprintf("%s://%s", "rtmp", url),
		RtsUrl:  fmt.Sprintf("%s://%s", "artc", url),
		SrtUrl:  fmt.Sprintf("%s://%s", "srt", url),
	}, nil
}

/*
RTMP 格式: rtmp://wgtest.pull.mcsun.cn/AppName/StreamName?auth_key={鉴权串}
FLV 格式: http://wgtest.pull.mcsun.cn/AppName/StreamName.flv?auth_key={鉴权串}
M3U8 格式: http://wgtest.pull.mcsun.cn/AppName/StreamName.m3u8?auth_key={鉴权串}
UDP 格式: artc://wgtest.pull.mcsun.cn/AppName/StreamName?auth_key={鉴权串}
*/
func (l *LiveRoomManager) getPullLiveInfo(r *models.RoomInfo) (*live2.PullLiveInfo, error) {
	streamName := r.ID
	liveConfig := l.appConfig.LiveStreamConfig

	return live2.AuthUrl(liveConfig.Scheme, liveConfig.PullUrl, liveConfig.AppName, streamName, liveConfig.PullAuthKey, liveConfig.AuthExpires), nil
}

// getRtcInfo https://help.aliyun.com/document_detail/450515.html
func (l *LiveRoomManager) getRtcInfo(meetingId, userId string, anchorId string, needLink bool, isAnchor bool) (*models.LinkInfo, error) {
	var err error
	//  artc: //live.aliyun.com）+推流标识位（push）+roomid（房间ID）+SdkIAppID（连麦应用ID）+UserID（主播ID）+timestamp（有效时长时间戳）+token
	t := &live2.LiveMic{
		AppId:  l.appConfig.LiveMicConfig.AppId,
		AppKey: l.appConfig.LiveMicConfig.AppKey,
	}
	schema := l.appConfig.LiveStreamConfig.Scheme
	domain := l.appConfig.LiveStreamConfig.PullUrl
	pullAuthKey := l.appConfig.LiveStreamConfig.PullAuthKey
	id := meetingId
	expirationSeconds := int64(time.Hour * 24 / time.Second)

	linkInfo := &models.LinkInfo{}

	if needLink || isAnchor {
		linkInfo.RtcPushUrl = t.RTCLinkPushUrl(id, userId, expirationSeconds)
		linkInfo.RtcPullUrl = t.RTCLinkPullUrl(id, userId, expirationSeconds)
	}

	linkInfo.CdnPullInfo = t.RTCLinkCDNUrl(id, anchorId, schema, domain, pullAuthKey, expirationSeconds)

	return linkInfo, err
}

func (l *LiveRoomManager) getVodInfo(r *models.RoomInfo) (*models.VodInfo, error) {
	if r.Status != models.LiveStatusOff {
		return nil, nil
	}
	var err error
	vodId := r.VodId
	if vodId == "" {
		liveId := r.ID
		userId := r.AnchorId
		appId := l.appConfig.LiveMicConfig.AppId
		title := liveId
		if r.Mode == models.LiveModeLink {
			title = live2.GetStreamName(appId, r.MeetingId, userId)
		}
		vodId, err = l.vodService.GetVodIdByTitle(title)
		if err != nil {
			return nil, err
		}
	}

	vodInfo := &models.VodInfo{}
	if vodId == "" {
		vodInfo.Status = models.VodStatusPrepare
		return vodInfo, nil
	}

	return l.vodService.GetVodPlayInfo(vodId)
}

func (l *LiveRoomManager) getStagingToken(deviceType, token string) (string, error) {
	type PackClaims struct {
		Endpoints []string `json:"endpoints"`
		Token     string   `json:"token"`
	}
	var packClaims PackClaims
	tokenBytes, err := base64.URLEncoding.DecodeString(token)
	if err != nil {
		return "", fmt.Errorf("base64 decode failed. %w", err)
	}
	err = json.Unmarshal(tokenBytes, &packClaims)
	if err != nil {
		return "", fmt.Errorf("json.Unmarshal failed. %w", err)
	}

	if deviceType == "web" {
		packClaims.Endpoints = []string{l.appConfig.GatewayConfig.WsAddr}
	} else {
		packClaims.Endpoints = []string{l.appConfig.GatewayConfig.LwpAddr}
	}
	tokenBytes, err = json.Marshal(packClaims)
	if err != nil {
		return "", fmt.Errorf("json.Marshal failed: %w", err)
	}

	return base64.URLEncoding.EncodeToString(tokenBytes), nil
}
