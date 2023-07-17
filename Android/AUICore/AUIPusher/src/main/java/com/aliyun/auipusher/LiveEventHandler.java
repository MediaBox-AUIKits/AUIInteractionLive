package com.aliyun.auipusher;

import androidx.annotation.Nullable;

import com.aliyun.auipusher.config.LiveEvent;

import java.util.Map;

public interface LiveEventHandler {

    /**
     * 推流事件回调
     *
     * @param event 事件
     */
    void onPusherEvent(LiveEvent event, @Nullable Map<String, Object> extras);
}
