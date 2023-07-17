package com.aliyun.aliinteraction.roompaas.message.model;

import static com.aliyun.aliinteraction.roompaas.message.model.CommentModel.MESSAGE_TYPE_COMMENT;

import com.aliyun.aliinteraction.roompaas.message.annotation.MessageType;

import java.io.Serializable;

/**
 * 弹幕消息体
 *
 * @author puke
 * @version 2022/8/31
 */
@MessageType(MESSAGE_TYPE_COMMENT)
public class CommentModel implements Serializable {

    public static final int MESSAGE_TYPE_COMMENT = 10001;

    /**
     * 弹幕内容
     */
    public String content;
}
