package com.aliyun.auiappserver.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.io.Serializable;

/**
 * @author puke
 * @version 2022/8/25
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class TokenRequest implements Serializable {

    @JsonProperty("user_id")
    public String userId;

    @JsonProperty("device_id")
    public String deviceId;

    @JsonProperty("device_type")
    public String deviceType;
}
