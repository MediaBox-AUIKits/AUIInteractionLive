package com.aliyun.auiappserver.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.io.Serializable;

/**
 * @author puke
 * @version 2022/9/29
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class LinkMicInfoItem implements Serializable {

    public String userId;
    public String userNick;
    public String rtcPullUrl;
}
