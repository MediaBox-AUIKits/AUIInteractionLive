package com.aliyuncs.aui.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
*  推流地址
* @author chunlei.zcl
*/
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PushLiveInfo {

    @JsonProperty("rtmp_url")
    private String rtmpUrl;
    @JsonProperty("rts_url")
    private String rtsUrl;
    @JsonProperty("srt_url")
    private String srtUrl;

}