package com.aliyun.auiappserver.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.io.Serializable;

@JsonIgnoreProperties(ignoreUnknown = true)
public class LiveLinkInfo implements Serializable {

    @JsonProperty("rtc_pull_url")
    public String rtcPullUrl;

    @JsonProperty("rtc_push_url")
    public String rtcPushUrl;

    @JsonProperty("cdn_pull_info")
    public LiveCdnPullInfo liveCdnPullInfo;

}
