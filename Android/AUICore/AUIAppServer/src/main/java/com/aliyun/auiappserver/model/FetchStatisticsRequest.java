package com.aliyun.auiappserver.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * @author baorunchen
 * @date 2023/7/5
 * @brief
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class FetchStatisticsRequest {

    @JsonProperty("chatroom_id")
    public String chatroom_id;
}