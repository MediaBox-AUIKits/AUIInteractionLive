package config

// StorageConfig 内部存储配置
type StorageConfig struct {
	Type string `json:"type" mapstructure:"type"`
	Url  string `json:"url" mapstructure:"url"`
}
