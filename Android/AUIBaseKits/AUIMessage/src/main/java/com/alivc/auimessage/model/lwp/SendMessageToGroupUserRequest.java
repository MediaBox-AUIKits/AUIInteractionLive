package com.alivc.auimessage.model.lwp;

import java.io.Serializable;

/**
 * @author puke
 * @version 2023/4/23
 */
public class SendMessageToGroupUserRequest implements Serializable {

    /**
     * 群组id
     */
    public String groupId;

    /**
     * 消息类型
     */
    public int type;

    /**
     * 消息体内容
     */
    public String data;

    /**
     * 接收用户ID
     */
    public String receiverId;

    /**
     * 是否跳过审核
     */
    public boolean skipAudit;
}
