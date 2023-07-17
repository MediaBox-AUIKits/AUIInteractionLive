package config

type LiveStreamConfig struct {
	Scheme string `json:"scheme"`
	// 推流地址
	PushUrl string `json:"push_url" mapstructure:"push_url"`
	// 拉流地址
	PullUrl string `json:"pull_url" mapstructure:"pull_url"`
	// 推流地址authkey
	PushAuthKey string `json:"push_auth_key" mapstructure:"push_auth_key"`
	// 拉流地址authkey
	PullAuthKey string `json:"pull_auth_key" mapstructure:"pull_auth_key"`
	// 流对应的App名
	AppName string `json:"app_name" mapstructure:"app_name"`
	// Url鉴权过期秒数
	AuthExpires int64 `json:"auth_expires" mapstructure:"auth_expires"`
	// 转码模板Id
	TransId string `json:"trans_id" mapstructure:"trans_id"`
}

// LiveMicConfig 直播连麦配置
type LiveMicConfig struct {
	AppId  string `json:"app_id" mapstructure:"app_id"`
	AppKey string `json:"app_key" mapstructure:"app_key"`
}

// LiveIMConfig 直播IM配置
type LiveIMConfig struct {
	AppId string `json:"app_id" mapstructure:"app_id"`
}
