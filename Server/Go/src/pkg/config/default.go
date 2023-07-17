package config

import (
	"log"
	"os"
	"strings"

	"github.com/asim/go-micro/plugins/config/source/nacos/v4"
	"github.com/nacos-group/nacos-sdk-go/v2/common/constant"
	"github.com/spf13/viper"
	microconfig "go-micro.dev/v4/config"
)

const (
	NacosGroup       = "DEFAULT_GROUP"
	NacosDataId      = "config.json"
	NacosAddrEnvName = "NACOS_ADDR"
)

var appConfig AppConfig

type AppConfig struct {
	LiveStreamConfig LiveStreamConfig `json:"live_stream" mapstructure:"live_stream"`
	LiveMicConfig    LiveMicConfig    `json:"live_mic" mapstructure:"live_mic"`
	LiveIMConfig     LiveIMConfig     `json:"live_im" mapstructure:"live_im"`
	OpenAPIConfig    OpenAPIConfig    `json:"openapi" mapstructure:"openapi"`
	StorageConfig    StorageConfig    `json:"storage" mapstructure:"storage"`
	GatewayConfig    GatewayConfig    `json:"gateway" mapstructure:"gateway"`
}

type GatewayConfig struct {
	Enable  bool   `json:"enable" mapstructure:"enable"`
	WsAddr  string `json:"ws_addr" mapstructure:"ws_addr"`
	LwpAddr string `json:"lwp_addr" mapstructure:"lwp_addr"`
}

func LoadNacosConfig(address string) (*AppConfig, error) {
	clientConfig := *constant.NewClientConfig(
		constant.WithLogDir("/tmp/"),
		constant.WithCacheDir("/tmp/"),
	)

	if err := microconfig.Load(nacos.NewSource(
		nacos.WithAddress([]string{address}),
		nacos.WithGroup(NacosGroup),
		nacos.WithDataId(NacosDataId),
		nacos.WithClientConfig(clientConfig),
	)); err != nil {
		return nil, err
	}
	if err := microconfig.Scan(&appConfig); err != nil {
		return nil, err
	}

	return &appConfig, nil
}

func LoadConfig() (*AppConfig, error) {
	viper.SetConfigName("config") // name of config file (without extension)
	viper.AddConfigPath("./conf") // path to look for the config file in
	viper.AddConfigPath(".")      // optionally look for config in the working directory

	address := os.Getenv(NacosAddrEnvName)
	if address != "" {
		log.Printf("load config from nacos. addr: %s", address)
		return LoadNacosConfig(address)
	}

	viper.SetEnvPrefix("SPF")
	viper.AutomaticEnv()
	replacer := strings.NewReplacer(".", "_")
	viper.SetEnvKeyReplacer(replacer)

	err := viper.ReadInConfig()
	if err != nil {
		return nil, err
	}

	err = viper.Unmarshal(&appConfig)
	if err != nil {
		return nil, err
	}

	return &appConfig, nil
}
