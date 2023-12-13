package com.aliyun.auiappserver.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * @author puke
 * @version 2022/9/2
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class GetLiveRequest implements Serializable {

    // 直播间Id
    @JsonProperty("id")
    public String id;

    // UserId
    @JsonProperty("user_id")
    public String userId;

    // 配置使用哪些im服务。可多选
    // aliyun_old / aliyun_new
    @JsonProperty("im_server")
    public List<String> imServer = new ArrayList<>(4);

}
