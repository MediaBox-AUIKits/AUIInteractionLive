package com.aliyun.interaction.app;

public enum LiveMode {
    /**
     * 标准直播
     */
    Standard(0),
    /**
     * 连麦直播
     */
    Microphone(1),
    /**
     * 默认模式
     */
    Common(2);

    private int value;


    private LiveMode(int value) {
        this.value = value;
    }

    public int value(){
        return this.value;
    }
}
