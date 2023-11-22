package com.aliyuncs.aui.controller;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.aliyuncs.aui.common.utils.PageUtils;
import com.aliyuncs.aui.common.utils.Result;
import com.aliyuncs.aui.common.utils.ValidatorUtils;
import com.aliyuncs.aui.dto.MeetingMemberInfo;
import com.aliyuncs.aui.dto.req.*;
import com.aliyuncs.aui.dto.res.*;
import com.aliyuncs.aui.service.RoomInfoService;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang.StringUtils;
import org.springframework.http.HttpHeaders;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * 直播间管理的Controller
 *
 * @author chunlei.zcl
 */
@RestController
@RequestMapping("/api/v1/live")
@Slf4j
public class RoomInfoController {

    @Resource
    private HttpServletRequest request;

    @Resource
    private RoomInfoService roomInfoService;

    /**
     * 获取Im的token
     */
    @RequestMapping("/token")
    public Result getImToken(@RequestBody ImTokenRequestDto imTokenRequestDto) {

        ValidatorUtils.validateEntity(imTokenRequestDto);

        ImTokenResponseDto imTokenResDto = roomInfoService.getImToken(imTokenRequestDto);
        if (imTokenResDto != null) {
            return Result.ok().put("access_token", imTokenResDto.getAccessToken())
                    .put("refresh_token", imTokenResDto.getAccessToken());
        }

        return Result.error();
    }

    @RequestMapping("/create")
    public Result createRoomInfo(@RequestBody RoomCreateRequestDto roomCreateRequestDto) {

        ValidatorUtils.validateEntity(roomCreateRequestDto);

        RoomInfoDto roomInfo = roomInfoService.createRoomInfo(roomCreateRequestDto);
        if (roomInfo != null) {
            String jsonStr = JSONObject.toJSONString(roomInfo);
            Map<String, Object> map = JSON.parseObject(jsonStr, Map.class);
            Result result = Result.ok();
            result.putAll(map);
            return result;
        }

        return Result.error();
    }

    /**
     * 信息
     */
    @RequestMapping("/get")
    public Result get(@RequestBody RoomGetRequestDto roomGetRequestDto) {

        ValidatorUtils.validateEntity(roomGetRequestDto);

        RoomInfoDto roomInfo = roomInfoService.get(roomGetRequestDto);
        if (roomInfo != null) {
            String jsonStr = JSONObject.toJSONString(roomInfo);
            Map<String, Object> map = JSON.parseObject(jsonStr, Map.class);
            Result result = Result.ok();
            result.putAll(map);
            return result;
        }
        return Result.notFound();
    }

    /**
     * 列表
     */
    @RequestMapping("/list")
    //  @RequiresPermissions("generator:roominfos:list")
    public List<?> list(@RequestBody RoomListRequestDto roomListRequestDto) {

        ValidatorUtils.validateEntity(roomListRequestDto);
        PageUtils page = roomInfoService.list(roomListRequestDto);
        if (page != null && CollectionUtils.isNotEmpty(page.getList())) {
            return page.getList();
        }
        return Collections.emptyList();
    }

    @RequestMapping("/start")
    public Result start(@RequestBody RoomUpdateStatusRequestDto roomUpdateStatusRequestDto) {

        ValidatorUtils.validateEntity(roomUpdateStatusRequestDto);
        RoomInfoDto roomInfo = roomInfoService.start(roomUpdateStatusRequestDto);
        if (roomInfo != null) {
            String jsonStr = JSONObject.toJSONString(roomInfo);
            Map<String, Object> map = JSON.parseObject(jsonStr, Map.class);
            Result result = Result.ok();
            result.putAll(map);
            return result;
        }
        return Result.error();
    }

    @RequestMapping("/stop")
    public Result stop(@RequestBody RoomUpdateStatusRequestDto roomUpdateStatusRequestDto) {

        ValidatorUtils.validateEntity(roomUpdateStatusRequestDto);
        RoomInfoDto roomInfo = roomInfoService.stop(roomUpdateStatusRequestDto);
        if (roomInfo != null) {
            String jsonStr = JSONObject.toJSONString(roomInfo);
            Map<String, Object> map = JSON.parseObject(jsonStr, Map.class);
            Result result = Result.ok();
            result.putAll(map);
            return result;
        }
        return Result.error();
    }

    @RequestMapping("/pause")
    public Result pause(@RequestBody RoomUpdateStatusRequestDto roomUpdateStatusRequestDto) {

        ValidatorUtils.validateEntity(roomUpdateStatusRequestDto);
        RoomInfoDto roomInfo = roomInfoService.pause(roomUpdateStatusRequestDto);
        if (roomInfo != null) {
            String jsonStr = JSONObject.toJSONString(roomInfo);
            Map<String, Object> map = JSON.parseObject(jsonStr, Map.class);
            Result result = Result.ok();
            result.putAll(map);
            return result;
        }
        return Result.error();
    }

    @RequestMapping("/delete")
    public Result delete(@RequestBody RoomDeleteRequestDto roomDeleteRequestDto) {

        ValidatorUtils.validateEntity(roomDeleteRequestDto);
        RoomInfoDto roomInfo = roomInfoService.delete(roomDeleteRequestDto);
        if (roomInfo != null) {
            String jsonStr = JSONObject.toJSONString(roomInfo);
            Map<String, Object> map = JSON.parseObject(jsonStr, Map.class);
            Result result = Result.ok();
            result.putAll(map);
            return result;
        }
        return Result.error();
    }

    @RequestMapping("/update")
    public Result update(@RequestBody RoomUpdateRequestDto roomUpdateRequestDto) {

        ValidatorUtils.validateEntity(roomUpdateRequestDto);
        RoomInfoDto roomInfo = roomInfoService.update(roomUpdateRequestDto);
        if (roomInfo != null) {
            String jsonStr = JSONObject.toJSONString(roomInfo);
            Map<String, Object> map = JSON.parseObject(jsonStr, Map.class);
            Result result = Result.ok();
            result.putAll(map);
            return result;
        }
        return Result.error();
    }

    @RequestMapping("/updateMeetingInfo")
    public MeetingMemberInfo.Members updateMeetingInfo(@RequestBody MeetingActionRequestDto meetingActionRequestDto) {


        ValidatorUtils.validateEntity(meetingActionRequestDto);
        return roomInfoService.updateMeetingInfo(meetingActionRequestDto);
    }

    @RequestMapping("/getMeetingInfo")
    public MeetingMemberInfo.Members getMeetingInfo(@RequestBody MeetingGetRequestDto meetingGetRequestDto, HttpServletResponse servletResponse) {

        ValidatorUtils.validateEntity(meetingGetRequestDto);
        MeetingMemberInfo.Members members =  roomInfoService.getMeetingInfo(meetingGetRequestDto);
        if (members != null) {
            return members;
        }
        MeetingMemberInfo.Members empty = new MeetingMemberInfo.Members();
        empty.setMembers(Collections.emptyList());
        return empty;
    }

    /**
     * 流状态实时信息回调，可以及时更新db中的直播（或房间）状态
     *
     * @author chunlei.zcl
     */
    @RequestMapping("/handlePushStreamEventCallback")
    public Result handlePushStreamEventCallback(LivePushStreamEventRequestDto livePushStreamEventRequestDto,
                                                @RequestHeader HttpHeaders headers) {

        ValidatorUtils.validateEntity(livePushStreamEventRequestDto);
        String liveSignature = headers.getFirst("ALI-LIVE-SIGNATURE");
        String liveTimestamp = headers.getFirst("ALI-LIVE-TIMESTAMP");

        if (StringUtils.isEmpty(liveSignature) || StringUtils.isEmpty(liveTimestamp)) {
            log.warn("liveSignature or liveTimestamp is null");
            return Result.invalidParam();
        }

        livePushStreamEventRequestDto.setLiveSignature(liveSignature);
        livePushStreamEventRequestDto.setLiveTimestamp(liveTimestamp);

        boolean result = roomInfoService.handlePushStreamEventCallback(livePushStreamEventRequestDto);
        return result ? Result.ok() : Result.error();
    }

    /**
     * 获取PC小助手跳转链接
     *
     * @author chunlei.zcl
     */
    @RequestMapping("/getLiveJumpUrl")
    public JumpUrlResponse getLiveJumpUrl(@RequestBody JumpUrlRequestDto jumpUrlRequestDto) {

        ValidatorUtils.validateEntity(jumpUrlRequestDto);

        String scheme = request.getScheme();
        String serverName = request.getServerName();
        Integer port = request.getServerPort();
        String serverHost = String.format("%s://%s:%s", scheme, serverName, port);

        return roomInfoService.getLiveJumpUrl(jumpUrlRequestDto, serverHost);
    }

    @RequestMapping("/verifyAuthToken")
    public AuthTokenResponse verifyAuthToken(@RequestBody AuthTokenRequestDto authTokenRequestDto) {

        ValidatorUtils.validateEntity(authTokenRequestDto);
        return roomInfoService.verifyAuthToken(authTokenRequestDto);
    }


    @RequestMapping("/getRtcAuthToken")
    public RtcAuthTokenResponse getRtcAuthToken(@RequestBody RtcAuthTokenRequestDto rtcAuthTokenRequestDto) {

        ValidatorUtils.validateEntity(rtcAuthTokenRequestDto);
        return roomInfoService.getRtcAuthToken(rtcAuthTokenRequestDto);
    }


}
