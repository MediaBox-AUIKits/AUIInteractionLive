package com.aliyun.auiappserver.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.HashMap;

/**
 * @author puke
 * @version 2021/12/14
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class LiveRoomModel {

    public String title;
    public String notice;
    public String coverUrl;
    public HashMap<String, String> extension;
}
