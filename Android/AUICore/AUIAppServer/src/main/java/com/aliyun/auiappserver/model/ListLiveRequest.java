package com.aliyun.auiappserver.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.io.Serializable;

/**
 * @author puke
 * @version 2022/8/30
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class ListLiveRequest implements Serializable {

    @JsonProperty("user_id")
    public String userId;

    @JsonProperty("page_num")
    public int pageNum;

    @JsonProperty("page_size")
    public int pageSize;
}
