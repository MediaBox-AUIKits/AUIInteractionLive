package com.aliyun.auiappserver.model;

import androidx.annotation.Nullable;

import com.alivc.auicommon.common.base.util.CollectionUtil;
import com.alivc.auicommon.common.base.util.Utils;
import com.alivc.auicommon.common.biz.exposable.enums.LiveStatus;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.io.Serializable;
import java.util.List;

/**
 * @author puke
 * @version 2022/8/25
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class LiveModel implements Serializable {

    public String id;

    public int status;

    public int pv;

    public String notice;

    @JsonProperty("anchor_id")
    public String anchorId;

    @JsonProperty("anchor_nick")
    public String anchorNick;


    @JsonProperty("vod_info")
    public VodInfo vodInfo;

    @JsonProperty("vod_id")
    public String vodId;

    public String title;

    @JsonProperty("created_at")
    public String createdAt;

    @JsonProperty("chat_id")
    public String chatId;

    @JsonProperty("pull_url_info")
    public LivePullUrlInfo pullUrlInfo;

    @JsonProperty("push_url_info")
    public LivePushUrlInfo pushUrlInfo;

    @JsonProperty("link_info")
    public LiveLinkInfo linkInfo;

    @JsonProperty("mode")
    public int mode;

    @JsonProperty("extends")
    public String extend;

    public Metrics metrics;

    @Nullable
    public String getPlaybackUrl() {
        if (vodInfo != null && vodInfo.isPlaybackReady()) {
            List<Playlist> playlist = vodInfo.playlist;
            Playlist first = CollectionUtil.getFirst(playlist);
            if (first != null) {
                return first.play_url;
            }
        }
        return null;
    }

    @JsonIgnore
    public String getPullUrl() {
        String pullUrl = null;
        if (linkInfo == null) {
            if (pullUrlInfo != null) {
                pullUrl = Utils.firstNotEmpty(
                        pullUrlInfo.rtsUrl,
                        pullUrlInfo.flvOriaacUrl,
                        pullUrlInfo.flvUrl
                );
            }
        } else {
            pullUrl = linkInfo.rtcPullUrl;
        }
        return pullUrl;
    }

    @JsonIgnore
    public String getPushUrl() {
        String pushUrl = null;
        if (linkInfo == null) {
            if (pushUrlInfo != null) {
                pushUrl = pushUrlInfo.rtmpUrl;
            }
        } else {
            pushUrl = linkInfo.rtcPushUrl;
        }
        return pushUrl;
    }

    @JsonIgnore
    public LiveStatus getLiveStatus() {
        return LiveStatus.of(status);
    }

    @JsonIgnore
    public String getCdnPullUrl() {
        String cdnPullUrl = null;
        if (linkInfo != null) {
            LiveCdnPullInfo cdnPullInfo = linkInfo.liveCdnPullInfo;
            if (cdnPullInfo != null) {
                cdnPullUrl = Utils.firstNotEmpty(
                        cdnPullInfo.rtsUrl,
                        cdnPullInfo.flvOriaacUrl,
                        cdnPullInfo.flvUrl
                );
            }
        }
        return cdnPullUrl;
    }

    @Override
    public String toString() {
        return "LiveModel{" +
                "id='" + id + '\'' +
                ", status=" + status +
                ", pv=" + pv +
                ", notice='" + notice + '\'' +
                ", anchorId='" + anchorId + '\'' +
                ", anchorNick='" + anchorNick + '\'' +
                ", vodInfo=" + vodInfo +
                ", vodId='" + vodId + '\'' +
                ", title='" + title + '\'' +
                ", createdAt='" + createdAt + '\'' +
                ", chatId='" + chatId + '\'' +
                ", pullUrlInfo=" + pullUrlInfo +
                ", pushUrlInfo=" + pushUrlInfo +
                ", linkInfo=" + linkInfo +
                ", mode=" + mode +
                ", extend='" + extend + '\'' +
                '}';
    }
}
