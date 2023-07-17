package com.aliyun.aliinteraction.player;

import com.aliyun.player.bean.ErrorInfo;

/**
 * @author puke
 * @version 2022/9/21
 */
public interface LivePlayerEventHandler {

    /**
     * 渲染开始
     */
    void onRenderStart();

    /**
     * load开始
     */
    void onLoadingBegin();

    /**
     * load进度，0~100
     */
    void onLoadingProgress(int progress);

    /**
     * load结束
     */
    void onLoadingEnd();

    /**
     * 播放器出错
     *
     * @param errorInfo 原始错误信息
     */
    void onPlayerError(ErrorInfo errorInfo);

    /**
     * 播放器出错
     */
    void onPlayerError();

    /**
     * 播放器准备完毕
     */
    void onPrepared();

    /**
     * 播放结束
     */
    void onPlayerEnd();

    /**
     * 播放器当前进度
     */
    void onPlayerCurrentPosition(long position);

    /**
     * 播放器缓冲进度
     */
    void onPlayerBufferedPosition(long position);

    /**
     * 播放器生命周期
     *
     * @param status
     */
    void onPlayerStatusChange(int status);

    /**
     * 播放器画面尺寸变化回调
     *
     * @param width  画面宽度
     * @param height 画面高度
     */
    void onPlayerVideoSizeChanged(int width, int height);

    /**
     * 下载速度变化回调
     *
     * @param kb 下载速度, 单位 kb
     */
    void onPlayerDownloadSpeedChanged(long kb);
}
