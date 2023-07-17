package com.aliyun.aliinteraction.roompaas.message.model;

import com.aliyun.aliinteraction.roompaas.message.annotation.MessageType;

import java.io.Serializable;

/**
 * 上麦消息
 *
 * @author puke
 * @version 2022/8/31
 */
@MessageType(20003)
public class JoinLinkMicModel implements Serializable {

    /**
     * 上麦观众的rtc拉流地址
     */
    public String rtcPullUrl;
}
