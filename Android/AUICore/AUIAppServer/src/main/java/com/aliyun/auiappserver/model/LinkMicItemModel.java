package com.aliyun.auiappserver.model;

import android.text.TextUtils;

import com.alivc.auicommon.common.base.base.Function;
import com.alivc.auicommon.common.base.util.CollectionUtil;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.List;

/**
 * @author puke
 * @version 2022/11/19
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class LinkMicItemModel {

    @JsonProperty("camera_opened")
    public boolean cameraOpened;

    @JsonProperty("mic_opened")
    public boolean micOpened;

    @JsonProperty("user_id")
    public String userId;

    @JsonProperty("user_nick")
    public String userNick;

    @JsonProperty("user_avatar")
    public String userAvatar;

    @JsonProperty("rtc_pull_url")
    public String rtcPullUrl;

    public static int findIndexByUserId(List<LinkMicItemModel> dataList, final String userId) {
        return CollectionUtil.findIndex(dataList, new Function<LinkMicItemModel, Boolean>() {
            @Override
            public Boolean apply(LinkMicItemModel model) {
                return TextUtils.equals(model.userId, userId);
            }
        });
    }
}
