package com.aliyun.auiappserver.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * @author baorunchen
 * @date 2023/7/5
 * @brief
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class FetchStatisticsResponse {

    @JsonProperty("pv")
    public long pv;

    @JsonProperty("uv")
    public int uv;

    @JsonProperty("like_count")
    public int likeCount;

    @JsonProperty("online_count")
    public int onlineCount;
}