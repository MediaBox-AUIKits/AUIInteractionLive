package com.aliyun.aliinteraction.roompaas.message.model;

import com.aliyun.aliinteraction.roompaas.message.annotation.MessageType;

import java.io.Serializable;

/**
 * 麦克风状态变化
 *
 * @author puke
 * @version 2022/8/31
 */
@MessageType(20007)
public class MicStatusUpdateModel implements Serializable {

    /**
     * true:打开; false:关闭;
     */
    public boolean micOpened;
}
