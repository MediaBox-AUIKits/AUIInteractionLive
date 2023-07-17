package models

// https://help.aliyun.com/document_detail/71397.html

// PlayInfo https://help.aliyun.com/document_detail/436555.html
type PlayInfo struct {
	// 颜色位深。取值为整数。
	BitDepth int32 `json:"bit_depth,omitempty"`
	// 媒体流码率。单位：Kbps。
	Bitrate string `json:"bit_rate,omitempty"`
	// 创建时间 音/视频创建时间。格式为：yyyy-MM-ddTHH:mm:ssZ（UTC时间）。
	CreationTime string `json:"creation_time,omitempty"`
	// 视频流清晰度定义。取值： FD：流畅。 LD：标清。 SD：高清。 HD：超清 OD：原画。 2K：2K。 4K：4K。 SQ：普通音质。 HQ：高音质。 AUTO：自适应码率。
	Definition string `json:"definition,omitempty"`
	// 媒体流长度。单位：秒。
	Duration string `json:"duration,omitempty"`
	// 媒体流是否加密流，取值：0：否。1 是。
	Encrypt int64 `json:"encrypt,omitempty"`
	// 媒体流加密类型。取值: AliyunVoDEncryption：阿里云视频加密。AliyunVoDEncryption：阿里云视频加密。
	EncryptType string `json:"encrypt_type,omitempty"`
	// 媒体流格式。 若媒体文件为视频则取值： mp4、 m3u8。
	Format string `json:"format,omitempty"`
	// 媒体流帧率。单位：帧/每秒。
	Fps string `json:"fps,omitempty"`
	// 媒体流HDR类型。取值: HDR,HDR10,HLG,DolbyVision,HDRVivid,HDRVivid
	HDRType string `json:"hdr_type,omitempty"`
	// 媒体流高度。单位：px。
	Height int64 `json:"height,omitempty"`
	// 媒体流宽度。单位：px。
	Width int64 `json:"width,omitempty"`
	// 媒体流宽度。单位：px。
	PlayURL string `json:"play_url,omitempty"`
	// 媒体流宽度。单位：px。
	Size int64 `json:"size,omitempty"`
	// 媒体流状态，Normal：正常状态，标记的是每种清晰度和格式的一路最新转码完成的流的状态。Invisible：不可见状态，当每种清晰度和格式有多路重复的转码流时，除了最新的一路流会被标记为正常状态，其他流会被标记为不可见状态。
	Status string `json:"status,omitempty"`
	// 媒体流类型。 若媒体流为视频则取值：video，若是纯音频则取值：audio。
	StreamType string `json:"stream_type,omitempty" `
	// 当前媒体流关联的水印ID。
	WatermarkId string `json:"watermark_id,omitempty"`
}

type VodInfo struct {
	// 状态  0 准备中，1 成功，2 失败
	Status   int        `json:"status"`
	PlayList []PlayInfo `json:"playlist,omitempty"`
}

const (
	// VodStatusPrepare 0 准备中
	VodStatusPrepare = iota
	// VodStatusOK 1 成功
	VodStatusOK
	// VodStatusFailed 2 失败
	VodStatusFailed
)
