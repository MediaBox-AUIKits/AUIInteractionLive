package com.aliyun.auiappserver.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.io.Serializable;

/**
 * @author puke
 * @version 2022/9/2
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class LivePushUrlInfo implements Serializable {

    @JsonProperty("rtmp_url")
    public String rtmpUrl;
}
