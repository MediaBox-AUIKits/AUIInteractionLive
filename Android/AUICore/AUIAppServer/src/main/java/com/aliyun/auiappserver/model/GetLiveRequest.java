package com.aliyun.auiappserver.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.io.Serializable;

/**
 * @author puke
 * @version 2022/9/2
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class GetLiveRequest implements Serializable {

    @JsonProperty("id")
    public String id;

    @JsonProperty("user_id")
    public String userId;
}
