package im

import (
	"errors"
	"log"
	"net/http"

	"ApsaraLive/pkg/alicloud/openapi"
	"ApsaraLive/pkg/config"
	"github.com/mitchellh/mapstructure"
)

type LiveIMService struct {
	apiService    *openapi.LiveAPIService
	openAPIConfig *config.OpenAPIConfig
	appId         string
}

func NewLiveIMService(config *config.AppConfig) (*LiveIMService, error) {
	var err error
	this := &LiveIMService{}
	this.apiService, err = openapi.NewOpenAPIService()
	this.appId = config.LiveIMConfig.AppId
	this.openAPIConfig = &config.OpenAPIConfig
	return this, err
}

func (t *LiveIMService) CreateMessageGroup(userId string, extends map[string]string) (string, error) {
	in := map[string]interface{}{
		"AppId":     t.appId,
		"CreatorId": userId,
	}
	status, rst, err := t.apiService.DoRequest(t.openAPIConfig, false, "CreateMessageGroup", in)
	if err != nil {
		return "", err
	}
	if status != http.StatusOK {
		return "", errors.New("create message group failed")
	}
	type CreateMessageGroupResponse struct {
		RequestId string
		Result    struct {
			GroupId string
		}
	}
	var out CreateMessageGroupResponse
	err = mapstructure.Decode(rst, &out)
	if err != nil {

		return "", err
	}

	return out.Result.GroupId, nil
}

func (t *LiveIMService) GetToken(userId, deviceId, deviceType string) (string, error) {
	in := map[string]interface{}{
		"AppId":      t.appId,
		"DeviceId":   deviceId,
		"DeviceType": deviceType,
		"UserId":     userId,
	}
	status, rst, err := t.apiService.DoRequest(t.openAPIConfig, false, "GetMessageToken", in)
	if err != nil {
		return "", err
	}
	if status != http.StatusOK {
		return "", errors.New("create message group failed")
	}
	type Response struct {
		RequestId string
		Result    struct {
			RefreshToken string
			AccessToken  string
		}
	}
	var out Response
	err = mapstructure.Decode(rst, &out)
	if err != nil {

		return "", err
	}

	return out.Result.AccessToken, nil
}

type RoomUserDetails struct {
	LikeCount   int64
	OnlineCount int64
	PV          int64
	UV          int64
	IsMute      bool
	MuteBy      []string
}

func (t *LiveIMService) GetGroupDetails(groupId string, userId string) (*RoomUserDetails, error) {
	in := map[string]interface{}{
		"AppId":   t.appId,
		"GroupId": groupId,
	}

	details := &RoomUserDetails{}
	{
		status, rst, err := t.apiService.DoRequest(t.openAPIConfig, false, "GetGroupStatistics", in)
		if err != nil {
			return nil, err
		}
		if status != http.StatusOK {
			return nil, errors.New("unknown status")
		}
		type APIResponse struct {
			RequestId string
			Result    struct {
				LikeCount   int64
				OnlineCount int64
				PV          int64 `json:"PV"`
				UV          int64 `json:"UV"`
			}
		}

		var out APIResponse
		err = mapstructure.Decode(rst, &out)
		if err != nil {
			return nil, err
		}
		details.PV = out.Result.PV
		details.UV = out.Result.UV
		details.OnlineCount = out.Result.OnlineCount
		details.LikeCount = out.Result.LikeCount
	}

	in["UserIdList"] = userId
	{
		status, rst, err := t.apiService.DoRequest(t.openAPIConfig, false, "ListMessageGroupUserById", in)
		if err != nil {
			return nil, err
		}
		if status != http.StatusOK {
			return nil, errors.New("unknown status")
		}
		type APIResponse struct {
			RequestId string
			Result    struct {
				UserList []struct {
					IsMute bool
					MuteBy []string
				}
			}
		}
		var out APIResponse
		err = mapstructure.Decode(rst, &out)
		if err != nil {
			return nil, err
		}
		if len(out.Result.UserList) == 0 {
			// todo 校验为啥没有内容
			//return nil, errors.New("get user info failed" + string(sout))
			details.IsMute = false
		} else {
			details.IsMute = out.Result.UserList[0].IsMute
			details.MuteBy = out.Result.UserList[0].MuteBy
		}

	}

	return details, nil
}

func (t *LiveIMService) ListMessageGroup(pageSize int, pageNum int) ([]string, error) {
	in := map[string]interface{}{
		"AppId":    t.appId,
		"PageSize": pageSize,
		"PageNum":  pageNum,
	}
	status, rst, err := t.apiService.DoRequest(t.openAPIConfig, false, "ListMessageGroup", in)
	if err != nil {
		return nil, err
	}
	if status != http.StatusOK {
		return nil, errors.New("unknown status")
	}
	type Response struct {
		RequestId string
		Result    struct {
			HasMore   bool
			GroupList []struct {
				GroupId    string
				CreateTime int
			}
		}
	}

	var out Response
	err = mapstructure.Decode(rst, &out)
	if err != nil {
		return nil, err
	}
	var ids []string
	for _, item := range out.Result.GroupList {
		ids = append(ids, item.GroupId)
	}
	return ids, nil
}

func (t *LiveIMService) UpdateMessageGroup(groupId, extends string) error {
	in := map[string]interface{}{
		"AppId":     t.appId,
		"GroupId":   groupId,
		"Extension": map[string]interface{}{"x-key": extends},
	}
	status, rst, err := t.apiService.DoRequest(t.openAPIConfig, false, "UpdateMessageGroup", in)
	if err != nil {
		return err
	}

	log.Println("&&&", rst)
	if status != http.StatusOK {
		return errors.New("unknown status")
	}

	return nil
}

func (t *LiveIMService) GetMessageGroup(groupId string) (string, error) {
	in := map[string]interface{}{
		"AppId":   t.appId,
		"GroupId": groupId,
	}
	status, rst, err := t.apiService.DoRequest(t.openAPIConfig, false, "GetMessageGroup", in)
	if err != nil {
		return "", err
	}
	if status != http.StatusOK {
		return "", errors.New("unknown status")
	}
	type Response struct {
		RequestId string
		Result    struct {
			Extension map[string]string
		}
	}
	var out Response
	err = mapstructure.Decode(rst, &out)
	if err != nil {
		return "", err
	}
	return out.Result.Extension["x-key"], nil
}
