package live

type PullLiveInfo struct {
	RtmpUrl string `json:"rtmp_url"`
	RtsUrl  string `json:"rts_url"`
	FlvUrl  string `json:"flv_url"`
	HlsUrl  string `json:"hls_url"`
}
