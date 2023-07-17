package com.alivc.auimessage.model.lwp;

import java.io.Serializable;

/**
 * @author puke
 * @version 2023/4/23
 */
public class SendMessageToGroupRequest implements Serializable {

    /**
     * 群组
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
     * 是否跳过消息审核
     */
    public boolean skipAudit;
}
