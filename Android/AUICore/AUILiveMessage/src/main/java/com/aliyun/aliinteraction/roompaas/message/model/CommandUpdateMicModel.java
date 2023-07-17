package com.aliyun.aliinteraction.roompaas.message.model;

import com.aliyun.aliinteraction.roompaas.message.annotation.MessageType;

import java.io.Serializable;

/**
 * 命令更改麦克风状态消息
 *
 * @author puke
 * @version 2022/8/31
 */
@MessageType(20009)
public class CommandUpdateMicModel implements Serializable {

    public boolean needOpenMic; // true:打开; false:关闭;
}
