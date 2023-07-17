package live

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"time"
)

type LiveMic struct {
	AppId  string
	AppKey string
}

// RTCAuth https://help.aliyun.com/document_detail/450516.html
func (l *LiveMic) RTCAuth(appId, appKey, channelId, userId string, timestamp int64) string {
	val := fmt.Sprintf("%s%s%s%s%d", appId, appKey, channelId, userId, timestamp)
	sum := sha256.Sum256([]byte(val))
	return hex.EncodeToString(sum[:])
}

// RTCLinkPushUrl https://help.aliyun.com/document_detail/450515.html
// 前缀字段（artc://）+固定字段（live.aliyun.com）+推流标识位（push）+roomid（房间ID）+SdkIAppID（连麦应用ID）+UserID（主播ID）+timestamp（有效时长时间戳）+token
func (l *LiveMic) RTCLinkPushUrl(channelId, userId string, expirationSeconds int64) string {
	const domain = "live.aliyun.com"
	timestamp := time.Now().Unix() + expirationSeconds
	appId := l.AppId
	token := l.RTCAuth(appId, l.AppKey, channelId, userId, timestamp)
	return fmt.Sprintf("artc://%s/push/%s?sdkAppId=%s&userId=%s&timestamp=%d&token=%s", domain, channelId, appId, userId, timestamp, token)
}

// RTCLinkPullUrl https://help.aliyun.com/document_detail/450515.html
func (l *LiveMic) RTCLinkPullUrl(channelId, userId string, expirationSeconds int64) string {
	const domain = "live.aliyun.com"
	timestamp := time.Now().Unix() + expirationSeconds
	appId := l.AppId
	token := l.RTCAuth(appId, l.AppKey, channelId, userId, timestamp)
	return fmt.Sprintf("artc://%s/play/%s?sdkAppId=%s&userId=%s&timestamp=%d&token=%s", domain, channelId, appId, userId, timestamp, token)
}

// RTCLinkCDNUrl https://help.aliyun.com/document_detail/450515.html
func (l *LiveMic) RTCLinkCDNUrl(channelId, userId string, schema, domain string, pullAuthKey string, expirationSeconds int64) *PullLiveInfo {
	appId := l.AppId
	streamName := GetStreamName(appId, channelId, userId)

	return AuthUrl(schema, domain, "live", streamName, pullAuthKey, expirationSeconds)
}

func GetStreamName(appId, channelId, userId string) string {
	return fmt.Sprintf("%s_%s_%s_camera", appId, channelId, userId)
}
