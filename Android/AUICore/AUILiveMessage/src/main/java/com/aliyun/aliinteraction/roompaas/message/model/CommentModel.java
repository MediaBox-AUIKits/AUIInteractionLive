package com.aliyun.aliinteraction.roompaas.message.model;

import com.aliyun.aliinteraction.roompaas.message.annotation.MessageType;

import java.io.Serializable;

/**
 * 弹幕消息体
 *
 * @author puke
 * @version 2022/8/31
 */
@MessageType(10001)
public class CommentModel implements Serializable {

    /**
     * 弹幕内容
     */
    public String content;
}
