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
public class CreateLiveRequest implements Serializable {

    // 直播标题, 长度小于64
    @JsonProperty("title")
    public String title;

    // 直播公告
    // 特别说明:仅针对aliyun_old服务启作用
    @JsonProperty("notice")
    public String notice;

    // 主播userId
    @JsonProperty("anchor")
    public String anchor;

    // 主播昵称
    // 特别说明:仅针对aliyun_old服务启作用
    @JsonProperty("anchor_nick")
    public String anchor_nick;

    // 直播模式，默认为0
    // 0：普通直播，
    // 1：连麦直播
    @JsonProperty("mode")
    public int mode;

    // 扩展字段，SON格式字符串，长度小于512
    @JsonProperty("extends")
    public String extend;

    // 配置使用哪些im服务。可多选
    // aliyun_old / aliyun_new
    @JsonProperty("im_server")
    public List<String> imServer = new ArrayList<>(4);

}
