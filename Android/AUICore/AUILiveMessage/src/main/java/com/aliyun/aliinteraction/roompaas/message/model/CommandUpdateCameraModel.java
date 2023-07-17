package com.aliyun.aliinteraction.roompaas.message.model;

import com.aliyun.aliinteraction.roompaas.message.annotation.MessageType;

import java.io.Serializable;

/**
 * 命令更改摄像头有状态消息
 *
 * @author puke
 * @version 2022/8/31
 */
@MessageType(20010)
public class CommandUpdateCameraModel implements Serializable {

    public boolean needOpenCamera; // true:打开; false:关闭;
}
