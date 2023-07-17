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
	streamUrl := fmt.Sprintf("%s/%s/%s", domain, appName, streamName)
	return &PullLiveInfo{
		RtmpUrl: fmt.Sprintf("%s://%s?auth_key=%s", "rtmp", streamUrl, AAuth(path, key, expirationSeconds)),
		RtsUrl:  fmt.Sprintf("%s://%s?auth_key=%s", "artc", streamUrl, AAuth(path, key, expirationSeconds)),
		FlvUrl:  fmt.Sprintf("%s://%s.flv?auth_key=%s", schema, streamUrl, AAuth(fmt.Sprintf("%s%s", path, ".flv"), key, expirationSeconds)),
		HlsUrl:  fmt.Sprintf("%s://%s.m3u8?auth_key=%s", schema, streamUrl, AAuth(fmt.Sprintf("%s%s", path, ".m3u8"), key, expirationSeconds)),
	}
}
