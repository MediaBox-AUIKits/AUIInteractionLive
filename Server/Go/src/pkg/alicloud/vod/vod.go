package vod

import (
	"fmt"
	"log"

	"ApsaraLive/pkg/config"
	"ApsaraLive/pkg/models"
	openapi "github.com/alibabacloud-go/darabonba-openapi/v2/client"
	util "github.com/alibabacloud-go/tea-utils/v2/service"
	"github.com/alibabacloud-go/tea/tea"
	vod20170321 "github.com/alibabacloud-go/vod-20170321/v3/client"
)

type VodService struct {
	openAPIConfig *config.OpenAPIConfig
}

func NewVodService(config *config.OpenAPIConfig) *VodService {
	return &VodService{openAPIConfig: config}
}

func (v *VodService) CreateClient() (_result *vod20170321.Client, _err error) {
	config := &openapi.Config{
		AccessKeyId:     &v.openAPIConfig.AccessKeyId,
		AccessKeySecret: &v.openAPIConfig.AccessKeySecret,
		SecurityToken:   &v.openAPIConfig.StsToken,
	}
	config.Endpoint = tea.String(fmt.Sprintf("vod.%s.aliyuncs.com", v.openAPIConfig.Region))
	_result = &vod20170321.Client{}
	_result, _err = vod20170321.NewClient(config)
	return _result, _err
}

func (v *VodService) GetVodIdByTitle(title string) (string, error) {
	client, err := v.CreateClient()
	if err != nil {
		return "", err
	}

	searchMediaRequest := &vod20170321.SearchMediaRequest{
		Match: tea.String(fmt.Sprintf("Title='%s'", title)),
	}
	rst, err := client.SearchMediaWithOptions(searchMediaRequest, &util.RuntimeOptions{})
	if err != nil {
		return "", err
	}

	log.Printf("GetVodIdByTitle title:%s, rst:%v", title, rst)

	if rst.Body == nil || rst.Body.MediaList == nil {
		return "", fmt.Errorf("get vodId failed. rst:%v", rst)
	}

	// 直播转点播还未完成
	if len(rst.Body.MediaList) == 0 {
		return "", nil
	}

	return tea.StringValue(rst.Body.MediaList[0].MediaId), nil
}

func (v *VodService) GetVodPlayInfo(id string) (*models.VodInfo, error) {
	client, err := v.CreateClient()
	if err != nil {
		return nil, err
	}

	getPlayInfoRequest := &vod20170321.GetPlayInfoRequest{
		VideoId: tea.String(id),
	}

	rst, err := client.GetPlayInfoWithOptions(getPlayInfoRequest, &util.RuntimeOptions{})
	if err != nil {
		return nil, err
	}

	log.Printf("GetVodPlayInfo id:%s, rst:%v", id, rst)
	
	if rst.Body == nil || rst.Body.PlayInfoList == nil || len(rst.Body.PlayInfoList.PlayInfo) == 0 {
		return nil, fmt.Errorf("get playinfo failed. rst:%v", rst)
	}
	vodInfo := &models.VodInfo{}
	vodInfo.Status = models.VodStatusOK
	for _, item := range rst.Body.PlayInfoList.PlayInfo {
		palyInfo := models.PlayInfo{
			BitDepth:     tea.Int32Value(item.BitDepth),
			Bitrate:      tea.StringValue(item.Bitrate),
			CreationTime: tea.StringValue(item.CreationTime),
			Definition:   tea.StringValue(item.Definition),
			Duration:     tea.StringValue(item.Duration),
			Encrypt:      tea.Int64Value(item.Encrypt),
			EncryptType:  tea.StringValue(item.EncryptType),
			Format:       tea.StringValue(item.Format),
			Fps:          tea.StringValue(item.Fps),
			HDRType:      tea.StringValue(item.HDRType),
			Height:       tea.Int64Value(item.Height),
			Width:        tea.Int64Value(item.Width),
			PlayURL:      tea.StringValue(item.PlayURL),
			Size:         tea.Int64Value(item.Size),
			Status:       tea.StringValue(item.Status),
			StreamType:   tea.StringValue(item.StreamType),
			WatermarkId:  tea.StringValue(item.WatermarkId),
		}
		vodInfo.PlayList = append(vodInfo.PlayList, palyInfo)
	}

	return vodInfo, nil
}
