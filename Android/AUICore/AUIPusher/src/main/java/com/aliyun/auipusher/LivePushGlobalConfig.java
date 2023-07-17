package com.aliyun.auipusher;

import com.alivc.live.pusher.AlivcResolutionEnum;

public class LivePushGlobalConfig {

    public static final String LIVE_PUSH_CONFIG_EXTRA_INFO = "aui";
    /**
     * 多人互动模式
     */
    public static boolean IS_MULTI_INTERACT = false;
    /**
     * 分辨率
     */
    public static AlivcResolutionEnum CONFIG_RESOLUTION = AlivcResolutionEnum.RESOLUTION_720P;
    /**
     * 音视频编码
     */
    public static boolean VIDEO_ENCODE_HARD = true;
    public static boolean AUDIO_ENCODE_HARD = true;
}
