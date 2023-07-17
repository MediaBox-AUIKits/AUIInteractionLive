package com.aliyun.auiappserver.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.io.Serializable;

/**
 * @author puke
 * @version 2022/8/30
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class CreateLiveRequest implements Serializable {

    // public String id;
    public String anchor;
    public String title;
    public String notice;
    public String anchor_nick;

    @JsonProperty("extends")
    public String extend;
    public int mode;
}
