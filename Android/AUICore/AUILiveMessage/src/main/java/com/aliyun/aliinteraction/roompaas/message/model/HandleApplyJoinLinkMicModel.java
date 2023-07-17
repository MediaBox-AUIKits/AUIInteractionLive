package com.aliyun.aliinteraction.roompaas.message.model;

import com.aliyun.aliinteraction.roompaas.message.annotation.MessageType;

import java.io.Serializable;

/**
 * 处理连麦申请消息
 *
 * @author puke
 * @version 2022/8/31
 */
@MessageType(20002)
public class HandleApplyJoinLinkMicModel implements Serializable {

    /**
     * true: 同意, false: 拒绝
     */
    public boolean agree;

    /**
     * 主播端的rtc拉流地址
     */
    public String rtcPullUrl;
}
