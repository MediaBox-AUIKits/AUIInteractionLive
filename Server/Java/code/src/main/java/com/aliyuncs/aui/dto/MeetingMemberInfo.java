package com.aliyuncs.aui.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.List;

/**
 * 连麦成员信息
 *
 * @author chunlei.zcl
 */
public class MeetingMemberInfo {

    /**
    * 用户Id
    * @author chunlei.zcl
    */
    @JsonProperty("user_id")
    private String userId;

    /**
     * 用户Nick
     * @author chunlei.zcl
     */
    @JsonProperty("user_nick")
    private String userNick;

    /**
     * 用户头像
     * @author chunlei.zcl
     */
    @JsonProperty("user_avatar")
    private String userAvatar;

    /**
     * 摄像头状态
     * @author chunlei.zcl
     */
    @JsonProperty("camera_opened")
    private Boolean cameraOpened;

    /**
     * 麦克风状态
     * @author chunlei.zcl
     */
    @JsonProperty("mic_opened")
    private Boolean micOpened;

    /**
     * 连麦拉流地址
     * @author chunlei.zcl
     */
    @JsonProperty("rtc_pull_url")
    private String rtcPullUrl;


    @Data
    public static class Members {
        private List<MeetingMemberInfo> members;
    }
}
