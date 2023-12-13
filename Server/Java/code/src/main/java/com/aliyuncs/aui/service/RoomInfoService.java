package com.aliyuncs.aui.service;

import com.aliyuncs.aui.common.utils.PageUtils;
import com.aliyuncs.aui.dto.MeetingMemberInfo;
import com.aliyuncs.aui.dto.req.*;
import com.aliyuncs.aui.dto.res.*;
import com.aliyuncs.aui.entity.RoomInfoEntity;
import com.baomidou.mybatisplus.extension.service.IService;

/**
 *  房间服务
 *  @author chunlei.zcl
 */
public interface RoomInfoService extends IService<RoomInfoEntity> {

    /**
    * 获取IM的token
    * @author chunlei.zcl
    */
    ImTokenResponseDto getImToken(ImTokenRequestDto imTokenRequestDto);

    /**
     * 获取新IM的token
     * @author chunlei.zcl
     */
    NewImTokenResponseDto getNewImToken(ImTokenRequestDto imTokenRequestDto);


    /**
     * 创建房间
     * @author chunlei.zcl
     */
    RoomInfoDto createRoomInfo(RoomCreateRequestDto roomCreateRequestDto);

    /**
     * 获取房间详情
     * @author chunlei.zcl
     */
    RoomInfoDto get(RoomGetRequestDto roomGetRequestDto);

    /**
     * 批量获取房间详情
     * @author chunlei.zcl
     */
    PageUtils list(RoomListRequestDto roomListRequestDto);

    /**
     * 关闭房间（直播间）
     * @author chunlei.zcl
     */
    RoomInfoDto stop(RoomUpdateStatusRequestDto roomUpdateStatusRequestDto);

    /**
     * 暂停房间（直播间）
     * @author chunlei.zcl
     */
    RoomInfoDto pause(RoomUpdateStatusRequestDto roomUpdateStatusRequestDto);

    /**
     * 开始房间（直播间）
     * @author chunlei.zcl
     */
    RoomInfoDto start(RoomUpdateStatusRequestDto roomUpdateStatusRequestDto);

    /**
     * 删除房间（直播间）
     * @author chunlei.zcl
     */
    RoomInfoDto delete(RoomDeleteRequestDto roomDeleteRequestDto);

    /**
     * 修改房间（直播间）
     * @author chunlei.zcl
     */
    RoomInfoDto update(RoomUpdateRequestDto roomUpdateRequestDto);

    /**
     * 修改连麦信息
     * @author chunlei.zcl
     */
    MeetingMemberInfo.Members updateMeetingInfo(MeetingActionRequestDto meetingActionRequestDto);

    /**
     * 获取连麦信息
     * @author chunlei.zcl
     */
    MeetingMemberInfo.Members getMeetingInfo(MeetingGetRequestDto meetingGetRequestDto);

    /**
     * 检验直播推流状态回调的签名。见文档：https://help.aliyun.com/document_detail/199365.html?spm=5176.13499635.help.dexternal.35d92699jvVrc7#section-mxt-vfh-b6s
     * @author chunlei.zcl
     */
    boolean handlePushStreamEventCallback(LivePushStreamEventRequestDto livePushStreamEventRequestDto);

    /**
     * 获取PC小助手的跳转链接
     * @author chunlei.zcl
     */
    JumpUrlResponse getLiveJumpUrl(JumpUrlRequestDto jumpUrlRequestDto, String serverHost);

    /**
     * 验证跳转链接
     * @author chunlei.zcl
     */
    AuthTokenResponse verifyAuthToken(AuthTokenRequestDto authTokenRequestDto);

    RtcAuthTokenResponse getRtcAuthToken(RtcAuthTokenRequestDto rtcAuthTokenRequestDto);
}

