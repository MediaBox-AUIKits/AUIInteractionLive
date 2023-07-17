package config

import "sync"

var cLock sync.RWMutex

type OpenAPIConfig struct {
	// 视频直播OpenAPI接入点
	Endpoint string `json:"endpoint"`
	// 视频直播OpenAPI region
	Region string `json:"region"`
	// 视频直播OpenAPI 版本
	Version string `json:"version"`
	// 云帐号视频直播AK
	AccessKeyId string `json:"access_key_id" mapstructure:"access_key_id"`
	// 云帐号视频直播SK
	AccessKeySecret string `json:"access_key_secret" mapstructure:"access_key_secret"`
	// sts_token
	StsToken string `json:"sts_token" mapstructure:"sts_token"`
}

func (o *OpenAPIConfig) RefreshToken(accessKeyId, accessKeySecret, stsToken string) {
	cLock.Lock()
	defer cLock.Unlock()
	o.AccessKeyId = accessKeyId
	o.AccessKeySecret = accessKeySecret
	o.StsToken = stsToken
}

func (o *OpenAPIConfig) GetToken() (string, string, string) {
	cLock.RLock()
	defer cLock.RUnlock()
	return o.AccessKeyId, o.AccessKeySecret, o.StsToken
}
