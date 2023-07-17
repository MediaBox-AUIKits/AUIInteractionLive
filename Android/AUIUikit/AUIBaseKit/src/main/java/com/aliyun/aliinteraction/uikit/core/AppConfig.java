package com.aliyun.aliinteraction.uikit.core;

import com.alivc.auicommon.core.assist.Assist;
import com.alivc.auicommon.core.assist.Config;
import com.alivc.auicommon.core.assist.Property;

import java.io.Serializable;

/**
 * <b color="red">注: 该接口的所有配置均仅用于开发测试阶段, 实际接入时可忽略</b>
 *
 * @author puke
 * @version 2021/9/13
 */
@Config("应用配置")
public interface AppConfig extends Serializable {

    AppConfig INSTANCE = Assist.getConfig(AppConfig.class);

    @Property(tips = "接收全部消息", defaultValue = "false")
    boolean enableAllMessageReceived();

    @Property(tips = "自己发送的弹幕是否直接显示", defaultValue = "true", rebootIfChanged = false)
    boolean showSelfCommentFromLocal();

    @Property(tips = "服务器地址", defaultValue = "https://appserver.h5video.vip")
    String serverUrl();

    @Property(tips = "长连接地址")
    String longLinkUrl();
}
