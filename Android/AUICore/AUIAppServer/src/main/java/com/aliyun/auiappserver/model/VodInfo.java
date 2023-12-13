package com.aliyun.auiappserver.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.io.Serializable;
import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public class VodInfo implements Serializable {

    private static final int STATUS_PLAYBACK_READY = 1;

    // 录制视频的状态
    // 0：准备中；1：成功；2：失败
    public int status;

    // 录制的视频信息
    public List<Playlist> playlist;

    @JsonIgnore
    public boolean isPlaybackReady() {
        return status == STATUS_PLAYBACK_READY;
    }
}
