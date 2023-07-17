package live

type PullLiveInfo struct {
	RtmpUrl string `json:"rtmp_url"`
	// 流畅
	RtmpLldUrl string `json:"rtmp_lld_url"`
	// 标清
	RtmpLsdUrl string `json:"rtmp_lsd_url"`
	// 高清
	RtmpLhdUrl string `json:"rtmp_lhd_url"`
	// 超清
	RtmpLudUrl string `json:"rtmp_lud_url"`
	// 原画
	RtmpOriaacUrl string `json:"rtmp_oriaac_url"`

	RtsUrl string `json:"rts_url"`
	// 流畅
	RtsLldUrl string `json:"rts_lld_url"`
	// 标清
	RtsLsdUrl string `json:"rts_lsd_url"`
	// 高清
	RtsLhdUrl string `json:"rts_lhd_url"`
	// 超清
	RtsLudUrl string `json:"rts_lud_url"`
	// 原画
	RtsOriaacUrl string `json:"rts_oriaac_url"`

	FlvUrl string `json:"flv_url"`
	// 流畅
	FlvLldUrl string `json:"flv_lld_url"`
	// 标清
	FlvLsdUrl string `json:"flv_lsd_url"`
	// 高清
	FlvLhdUrl string `json:"flv_lhd_url"`
	// 超清
	FlvLudUrl string `json:"flv_lud_url"`
	// 原画
	FlvOriaacUrl string `json:"flv_oriaac_url"`

	HlsUrl string `json:"hls_url"`
	// 流畅
	HlsLldUrl string `json:"hls_lld_url"`
	// 标清
	HlsLsdUrl string `json:"hls_lsd_url"`
	// 高清
	HlsLhdUrl string `json:"hls_lhd_url"`
	// 超清
	HlsLudUrl string `json:"hls_lud_url"`
	// 原画
	HlsOriaacUrl string `json:"hls_oriaac_url"`
}
