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
public class LiveSendLikeRequest implements Serializable {
    @JsonProperty("chatroom_id")
    public String chatroom_id;

    @JsonProperty("user_id")
    public String user_id;

    @JsonProperty("like_count")
    public int like_count;
}
