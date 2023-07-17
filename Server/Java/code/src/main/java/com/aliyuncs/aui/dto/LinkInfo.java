package com.aliyuncs.aui.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * RTC 推拉流地址
 *
 * @author chunlei.zcl
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LinkInfo {

    // 推流地址
    @JsonProperty("rtc_push_url")
    private String rtcPushUrl;

    // 拉流地址
    @JsonProperty("rtc_pull_url")
    private String rtcPullUrl;

    // 普通观众CDN拉流地址
    @JsonProperty("cdn_pull_info")
    private PullLiveInfo cdnPullInfo;
}