package com.aliyun.auiappserver.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.io.Serializable;
import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public class VodInfo implements Serializable {

    private static final int STATUS_PLAYBACK_READY = 1;

    public int status;

    public List<Playlist> playlist;

    @JsonIgnore
    public boolean isPlaybackReady() {
        return status == STATUS_PLAYBACK_READY;
    }
}
