package com.aliyun.aliinteraction.roompaas.message.model;

import com.aliyun.aliinteraction.roompaas.message.annotation.MessageType;

import java.io.Serializable;

/**
 * @author puke
 * @version 2022/9/20
 */
@MessageType(10006)
public class UpdateNoticeModel implements Serializable {

    /**
     * 直播公告
     */
    public String notice;
}
