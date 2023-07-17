package com.aliyun.aliinteraction.roompaas.message.model;

import com.aliyun.aliinteraction.roompaas.message.annotation.MessageType;

import java.io.Serializable;

/**
 * 下麦消息
 *
 * @author puke
 * @version 2022/8/31
 */
@MessageType(20004)
public class LeaveLinkMicModel implements Serializable {

    public static final String REASON_BY_SELF = "bySelf";
    public static final String REASON_BY_KICK = "byKick";

    public String reason;
}
