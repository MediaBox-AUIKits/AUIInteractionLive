package openapi

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"ApsaraLive/pkg/config"
	"github.com/aliyun/alibaba-cloud-sdk-go/sdk"
	"github.com/aliyun/alibaba-cloud-sdk-go/sdk/auth/credentials"
	sdkerr "github.com/aliyun/alibaba-cloud-sdk-go/sdk/errors"
	"github.com/aliyun/alibaba-cloud-sdk-go/sdk/requests"
	"github.com/iancoleman/strcase"
	"github.com/mitchellh/mapstructure"
)

type LiveAPIService struct {
}

func NewOpenAPIService() (*LiveAPIService, error) {
	this := &LiveAPIService{}
	return this, nil
}

// DoRequest 发送请求
func (t *LiveAPIService) DoRequest(config *config.OpenAPIConfig, changeKeyStyle bool, name string, in map[string]interface{}) (int, map[string]interface{}, error) {
	impConfig := sdk.NewConfig()

	region := "cn-hangzhou"
	if region != "" {
		region = config.Region
	}

	var err error
	var client *sdk.Client

	ak, sk, stsToken := config.GetToken()
	if stsToken == "" {
		client, err = sdk.NewClientWithOptions(region, impConfig, &credentials.AccessKeyCredential{
			AccessKeyId: ak, AccessKeySecret: sk})
	} else {
		client, err = sdk.NewClientWithStsToken(region, ak, sk, stsToken)
	}

	if err != nil {
		return http.StatusInternalServerError, nil, err
	}

	request := requests.NewCommonRequest()
	request.Method = "POST"
	request.Scheme = "https" // https | http
	request.Domain = "live.aliyuncs.com"
	if config.Endpoint != "" {
		request.Domain = config.Endpoint
	}

	request.Version = "2016-11-01"
	if config.Version != "" {
		request.Version = config.Version
	}
	request.ApiName = name

	for k, v := range in {
		newKey := k
		if changeKeyStyle {
			newKey = strcase.ToCamel(k)
		}

		switch v.(type) {
		case string:
			request.QueryParams[newKey] = v.(string)
		case int:
			request.QueryParams[newKey] = fmt.Sprintf("%v", v)
		case bool:
			request.QueryParams[newKey] = fmt.Sprintf("%v", v)
		case float64:
			request.QueryParams[newKey] = fmt.Sprintf("%v", v)
		case map[string]interface{}:
			request.QueryParams[newKey], err = t.Encode(changeKeyStyle, v.(map[string]interface{}))
		default:
			var jsBytes []byte
			jsBytes, err = json.Marshal(v)
			request.QueryParams[newKey] = string(jsBytes)
		}
		if err != nil {
			return http.StatusInternalServerError, nil, err
		}
		// 某些值如果传空字符串，POP接口会报错
		if len(request.QueryParams[newKey]) == 0 {
			delete(request.QueryParams, newKey)
		}
	}

	var m map[string]interface{}
	defer func() {
		log.Printf("openapi name:%s request:%v, responses:%v", name, request.QueryParams, m)
	}()
	resp, err := client.ProcessCommonRequest(request)
	if err != nil {
		errRst := PopErrorResponse(err)
		m := &map[string]interface{}{}
		if errRst != nil {
			err := mapstructure.Decode(errRst, &m)
			if err != nil {
				return http.StatusInternalServerError, nil, fmt.Errorf("decode PopErrorResponse error: %v", err)
			}
		}
		return http.StatusInternalServerError, nil, fmt.Errorf("decode PopErrorResponse error: %v", err)
	}

	m, err = t.Decode(changeKeyStyle, resp.GetHttpContentString())
	if err != nil {
		return http.StatusInternalServerError, nil, fmt.Errorf("decode error: %v", err)
	}

	return resp.GetHttpStatus(), m, nil
}

func DeepCopy(value interface{}, changeKeyStyleFunc func(k string) string) interface{} {
	if valueMap, ok := value.(map[string]interface{}); ok {
		newMap := make(map[string]interface{})
		for k, v := range valueMap {
			newKey := changeKeyStyleFunc(k)
			newMap[newKey] = DeepCopy(v, changeKeyStyleFunc)
		}

		return newMap
	} else if valueSlice, ok := value.([]interface{}); ok {
		newSlice := make([]interface{}, len(valueSlice))
		for k, v := range valueSlice {
			newSlice[k] = DeepCopy(v, changeKeyStyleFunc)
		}

		return newSlice
	}

	return value
}

// Encode 将map转换为大坨峰Key风格json字符串
func (t *LiveAPIService) Encode(changeKeyStyle bool, data map[string]interface{}) (string, error) {
	rst, err := json.Marshal(DeepCopy(data, func(k string) string {
		if changeKeyStyle {
			return strcase.ToCamel(k)
		}
		return k
	}))
	if err != nil {
		return "", err
	}
	return string(rst), nil
}

// 	Decode 将json字符串转换为小驼峰风格Key的map
func (t *LiveAPIService) Decode(changeKeyStyle bool, data string) (map[string]interface{}, error) {
	var m map[string]interface{}
	err := json.Unmarshal([]byte(data), &m)
	if err != nil {
		return nil, err
	}

	out := DeepCopy(m, func(k string) string {
		if changeKeyStyle {
			return strcase.ToLowerCamel(k)
		}
		return k
	})
	return out.(map[string]interface{}), nil
}

func PopErrorResponse(err error) *ErrorResponse {
	if err == nil {
		return nil
	}
	if serr, ok := err.(*sdkerr.ServerError); ok {
		return &ErrorResponse{
			RespHeaders: serr.RespHeaders,
			HttpStatus:  serr.HttpStatus(),
			RequestId:   serr.RequestId(),
			HostId:      serr.HostId(),
			ErrorCode:   serr.ErrorCode(),
			Code:        serr.ErrorCode(),
			Recommend:   serr.Recommend(),
			Message:     serr.Message(),
			Comment:     serr.Comment(),
		}
	} else if serr, ok := err.(*sdkerr.ClientError); ok {
		return &ErrorResponse{
			RespHeaders: nil,
			HttpStatus:  serr.HttpStatus(),
			ErrorCode:   serr.ErrorCode(),
			Code:        serr.ErrorCode(),
			Message:     serr.Message(),
		}
	} else {
		return &ErrorResponse{
			RespHeaders: nil,
			HttpStatus:  http.StatusInternalServerError,
			ErrorCode:   "UnknownError",
			Code:        "UnknownError",
			Message:     err.Error(),
		}
	}
	return nil
}

type ErrorResponse struct {
	RespHeaders map[string][]string
	HttpStatus  int
	RequestId   string
	HostId      string
	ErrorCode   string
	Code        string
	Recommend   string
	Message     string
	Comment     string
}
