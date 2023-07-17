package com.aliyun.auiappserver.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.List;

/**
 * @author puke
 * @version 2022/11/21
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class UpdateMeetingInfoRequest {

    public String id;

    public List<LinkMicItemModel> members;
}
