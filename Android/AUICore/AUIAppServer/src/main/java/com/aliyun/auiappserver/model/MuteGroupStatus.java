package com.aliyun.auiappserver.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.io.Serializable;

/**
 * @author baorunchen
 * @date 2023/7/4
 * @brief
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class MuteGroupStatus implements Serializable {

    @JsonProperty("code")
    public int code;

    @JsonProperty("mute")
    public boolean mute;

}
