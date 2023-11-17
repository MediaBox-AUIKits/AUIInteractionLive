package com.aliyun.auiappserver.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * @author puke
 * @version 2022/8/30
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class ListLiveRequest implements Serializable {

    // 用户UserId
    @JsonProperty("user_id")
    public String userId;

    // 页码，默认值：1
    @JsonProperty("page_num")
    public int pageNum;

    // 单页显示数量，默认值：10。
    @JsonProperty("page_size")
    public int pageSize;

    // 配置使用哪些im服务。可多选。不传默认为aliyun_old
    // aliyun_old / aliyun_new
    @JsonProperty("im_server")
    public List<String> imServer = new ArrayList<>(4);

}
