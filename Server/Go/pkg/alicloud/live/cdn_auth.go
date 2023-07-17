package live

import (
	"crypto/md5"
	"encoding/hex"
	"fmt"
	"time"
)

func md5sum(src string) string {
	h := md5.New()
	h.Write([]byte(src))
	return hex.EncodeToString(h.Sum(nil))
}

// AAuth 获取鉴权 https://help.aliyun.com/document_detail/199349.html
func AAuth(path, key string, expirationSeconds int64) string {
	rand := "0" // "0" by default, other value is ok
	uid := "0"  // "0" by default, other value is ok
	exp := time.Now().Unix() + expirationSeconds
	hashValue := md5sum(fmt.Sprintf("%s-%d-%s-%s-%s", path, exp, rand, uid, key))
	authKey := fmt.Sprintf("%d-%s-%s-%s", exp, rand, uid, hashValue)
	return authKey
}

func AuthUrl(schema, domain, appName, streamName, key string, expirationSeconds int64) *PullLiveInfo {
	path := fmt.Sprintf("/%s/%s", appName, streamName)
	pathWithLld := fmt.Sprintf("/%s/%s_lld", appName, streamName)
	pathWithLsd := fmt.Sprintf("/%s/%s_lsd", appName, streamName)
	pathWithLhd := fmt.Sprintf("/%s/%s_lhd", appName, streamName)
	pathWithLud := fmt.Sprintf("/%s/%s_lud", appName, streamName)
	pathWithOriaac := fmt.Sprintf("/%s/%s_oriaac", appName, streamName)
	streamUrl := fmt.Sprintf("%s/%s/%s", domain, appName, streamName)
	streamLldUrl := fmt.Sprintf("%s/%s/%s_lld", domain, appName, streamName)
	streamLsdUrl := fmt.Sprintf("%s/%s/%s_lsd", domain, appName, streamName)
	streamLhdUrl := fmt.Sprintf("%s/%s/%s_lhd", domain, appName, streamName)
	streamLudUrl := fmt.Sprintf("%s/%s/%s_lud", domain, appName, streamName)
	streamOriaacUrl := fmt.Sprintf("%s/%s/%s_oriaac", domain, appName, streamName)
	return &PullLiveInfo{
		RtmpUrl:       fmt.Sprintf("%s://%s?auth_key=%s", "rtmp", streamUrl, AAuth(path, key, expirationSeconds)),
		RtmpLldUrl:    fmt.Sprintf("%s://%s?auth_key=%s", "rtmp", streamLldUrl, AAuth(pathWithLld, key, expirationSeconds)),
		RtmpLsdUrl:    fmt.Sprintf("%s://%s?auth_key=%s", "rtmp", streamLsdUrl, AAuth(pathWithLsd, key, expirationSeconds)),
		RtmpLhdUrl:    fmt.Sprintf("%s://%s?auth_key=%s", "rtmp", streamLhdUrl, AAuth(pathWithLhd, key, expirationSeconds)),
		RtmpLudUrl:    fmt.Sprintf("%s://%s?auth_key=%s", "rtmp", streamLudUrl, AAuth(pathWithLud, key, expirationSeconds)),
		RtmpOriaacUrl: fmt.Sprintf("%s://%s?auth_key=%s", "rtmp", streamOriaacUrl, AAuth(pathWithOriaac, key, expirationSeconds)),

		RtsUrl:       fmt.Sprintf("%s://%s?auth_key=%s", "artc", streamUrl, AAuth(path, key, expirationSeconds)),
		RtsLldUrl:    fmt.Sprintf("%s://%s?auth_key=%s", "artc", streamLldUrl, AAuth(pathWithLld, key, expirationSeconds)),
		RtsLsdUrl:    fmt.Sprintf("%s://%s?auth_key=%s", "artc", streamLsdUrl, AAuth(pathWithLsd, key, expirationSeconds)),
		RtsLhdUrl:    fmt.Sprintf("%s://%s?auth_key=%s", "artc", streamLhdUrl, AAuth(pathWithLhd, key, expirationSeconds)),
		RtsLudUrl:    fmt.Sprintf("%s://%s?auth_key=%s", "artc", streamLudUrl, AAuth(pathWithLud, key, expirationSeconds)),
		RtsOriaacUrl: fmt.Sprintf("%s://%s?auth_key=%s", "artc", streamOriaacUrl, AAuth(pathWithOriaac, key, expirationSeconds)),

		FlvUrl:       fmt.Sprintf("%s://%s.flv?auth_key=%s", schema, streamUrl, AAuth(fmt.Sprintf("%s%s", path, ".flv"), key, expirationSeconds)),
		FlvLldUrl:    fmt.Sprintf("%s://%s.flv?auth_key=%s", schema, streamLldUrl, AAuth(fmt.Sprintf("%s%s", pathWithLld, ".flv"), key, expirationSeconds)),
		FlvLsdUrl:    fmt.Sprintf("%s://%s.flv?auth_key=%s", schema, streamLsdUrl, AAuth(fmt.Sprintf("%s%s", pathWithLsd, ".flv"), key, expirationSeconds)),
		FlvLhdUrl:    fmt.Sprintf("%s://%s.flv?auth_key=%s", schema, streamLhdUrl, AAuth(fmt.Sprintf("%s%s", pathWithLhd, ".flv"), key, expirationSeconds)),
		FlvLudUrl:    fmt.Sprintf("%s://%s.flv?auth_key=%s", schema, streamLudUrl, AAuth(fmt.Sprintf("%s%s", pathWithLud, ".flv"), key, expirationSeconds)),
		FlvOriaacUrl: fmt.Sprintf("%s://%s.flv?auth_key=%s", schema, streamOriaacUrl, AAuth(fmt.Sprintf("%s%s", pathWithOriaac, ".flv"), key, expirationSeconds)),

		HlsUrl:       fmt.Sprintf("%s://%s.m3u8?auth_key=%s", schema, streamUrl, AAuth(fmt.Sprintf("%s%s", path, ".m3u8"), key, expirationSeconds)),
		HlsLldUrl:    fmt.Sprintf("%s://%s.m3u8?auth_key=%s", schema, streamLldUrl, AAuth(fmt.Sprintf("%s%s", pathWithLld, ".m3u8"), key, expirationSeconds)),
		HlsLsdUrl:    fmt.Sprintf("%s://%s.m3u8?auth_key=%s", schema, streamLsdUrl, AAuth(fmt.Sprintf("%s%s", pathWithLsd, ".m3u8"), key, expirationSeconds)),
		HlsLhdUrl:    fmt.Sprintf("%s://%s.m3u8?auth_key=%s", schema, streamLhdUrl, AAuth(fmt.Sprintf("%s%s", pathWithLhd, ".m3u8"), key, expirationSeconds)),
		HlsLudUrl:    fmt.Sprintf("%s://%s.m3u8?auth_key=%s", schema, streamLudUrl, AAuth(fmt.Sprintf("%s%s", pathWithLud, ".m3u8"), key, expirationSeconds)),
		HlsOriaacUrl: fmt.Sprintf("%s://%s.m3u8?auth_key=%s", schema, streamOriaacUrl, AAuth(fmt.Sprintf("%s%s", pathWithOriaac, ".m3u8"), key, expirationSeconds)),
	}
}
