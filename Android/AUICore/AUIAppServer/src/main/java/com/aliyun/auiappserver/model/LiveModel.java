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

    // 直播间Id
    @JsonProperty("id")
    public String id;

    // 创建时间
    @JsonProperty("created_at")
    public String createdAt;

    // 修改时间
    @JsonProperty("updated_at")
    public String updatedAt;

    // 直播标题
    @JsonProperty("title")
    public String title;

    // 直播公告
    @JsonProperty("notice")
    public String notice;

    // 封面图。预留字段
    @JsonProperty("cover_url")
    public String coverUrl;

    // 主播userId
    @JsonProperty("anchor_id")
    public String anchorId;

    // 主播昵称
    @JsonProperty("anchor_nick")
    public String anchorNick;

    // 扩展字段
    @JsonProperty("extends")
    public String extend;

    // 直播间状态：
    // 0：准备中；1：已开播；2：已停止
    @JsonProperty("status")
    public int status;

    // 直播模式
    // 0：普通直播；1：连麦直播
    @JsonProperty("mode")
    public int mode;


    // IM群Id
    @JsonProperty("chat_id")
    public String chatId;

    // 连麦Id
    @JsonProperty("meeting_id")
    public String meetingId;

    // Json字符串。连麦观众信息
    @JsonProperty("meeting_info")
    public String meetingInfo;


    // 推流地址集合
    @JsonProperty("push_url_info")
    public LivePushUrlInfo pushUrlInfo;

    // 拉流地址集合
    @JsonProperty("pull_url_info")
    public LivePullUrlInfo pullUrlInfo;

    // 连麦地址集合
    @JsonProperty("link_info")
    public LiveLinkInfo linkInfo;


    // 直播录制视频信息
    @JsonProperty("vod_info")
    public VodInfo vodInfo;

    @JsonProperty("vod_id")
    public String vodId;


    // 统计数据
    @JsonProperty("metrics")
    public Metrics metrics;

    public int pv;


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
                ", createdAt='" + createdAt + '\'' +
                ", updatedAt='" + updatedAt + '\'' +
                ", title='" + title + '\'' +
                ", notice='" + notice + '\'' +
                ", coverUrl='" + coverUrl + '\'' +
                ", anchorId='" + anchorId + '\'' +
                ", anchorNick='" + anchorNick + '\'' +
                ", extend='" + extend + '\'' +
                ", status=" + status +
                ", mode=" + mode +
                ", chatId='" + chatId + '\'' +
                ", meetingId='" + meetingId + '\'' +
                ", meetingInfo='" + meetingInfo + '\'' +
                ", pushUrlInfo=" + pushUrlInfo +
                ", pullUrlInfo=" + pullUrlInfo +
                ", linkInfo=" + linkInfo +
                ", pv=" + pv +
                ", vodInfo=" + vodInfo +
                ", vodId='" + vodId + '\'' +
                ", metrics=" + metrics +
                '}';
    }
}
