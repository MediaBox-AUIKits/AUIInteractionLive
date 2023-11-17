package com.aliyun.auiappserver.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * @author puke
 * @version 2022/8/25
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class TokenRequest implements Serializable {

    // 用户UserId，用户自定义，在AppId下单独唯一
    @JsonProperty("user_id")
    public String userId;

    // 终端设备ID，唯一代表一个用户终端设备，用户自定义。
    // 特别说明:仅针对aliyun_old服务启作用
    @JsonProperty("device_id")
    public String deviceId;

    // 终端设备类型，取值：ios/android/web/pc
    // 特别说明:仅针对aliyun_old服务启作用
    @JsonProperty("device_type")
    public String deviceType = "android";

    // 配置使用哪些im服务。可多选
    // aliyun_old / aliyun_new
    @JsonProperty("im_server")
    public List<String> imServer = new ArrayList<>(4);

    // 角色，默认为空。为admin时，表示该用户可以调用管控接口。
    // 特别说明:仅针对aliyun_new服务启作用
    @JsonProperty("role")
    public String role;

}
