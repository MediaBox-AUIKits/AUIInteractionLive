package com.aliyuncs.aui.controller;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.aliyuncs.aui.common.utils.Result;
import com.aliyuncs.aui.common.utils.ValidatorUtils;
import com.aliyuncs.aui.dto.req.ImTokenRequestDto;
import com.aliyuncs.aui.dto.req.RoomCreateRequestDto;
import com.aliyuncs.aui.dto.res.ImTokenResponseDto;
import com.aliyuncs.aui.dto.res.NewImTokenResponseDto;
import com.aliyuncs.aui.dto.res.RoomInfoDto;
import com.aliyuncs.aui.service.RoomInfoService;
import com.google.common.collect.ImmutableMap;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.collections.CollectionUtils;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.Map;

import static com.aliyuncs.aui.common.Constants.IM_NEW;
import static com.aliyuncs.aui.common.Constants.IM_OLD;

/**
 * 直播间管理的Controller V2版本
 * 主要是接入新的IM, 并兼容老的IM
 *
 * @author chunlei.zcl
 */
@RestController
@RequestMapping("/api/v2/live")
@Slf4j
public class RoomInfoControllerV2 {

    @Resource
    private RoomInfoService roomInfoService;

    /**
     * 获取Im的token
     */
    @RequestMapping("/token")
    public Result getImToken(@RequestBody ImTokenRequestDto imTokenRequestDto) {

        ValidatorUtils.validateEntity(imTokenRequestDto);

        if (CollectionUtils.isEmpty(imTokenRequestDto.getImServer())) {
            return Result.invalidParam();
        }

        for (String s : imTokenRequestDto.getImServer()) {
            if (!IM_OLD.equals(s) && !IM_NEW.equals(s) ) {
                return Result.invalidParam();
            }
        }

        NewImTokenResponseDto newImTokenResponseDto = null;
        Map<String, Object> result = new HashMap<>();
        if (imTokenRequestDto.getImServer().contains(IM_OLD)) {
            ImTokenResponseDto imTokenResDto = roomInfoService.getImToken(imTokenRequestDto);
            if (imTokenResDto != null) {
                result.put("aliyun_old_im", ImmutableMap.<String, String>builder().put("access_token", imTokenResDto.getAccessToken())
                        .put("refresh_token", imTokenResDto.getAccessToken()).build());
            }
        }

        if (imTokenRequestDto.getImServer().contains(IM_NEW)) {
            newImTokenResponseDto = roomInfoService.getNewImToken(imTokenRequestDto);
            if (newImTokenResponseDto != null) {
                result.put("aliyun_new_im", newImTokenResponseDto);
            }
        }

        return Result.ok(result);
    }

    @RequestMapping("/create")
    public Result createRoomInfo(@RequestBody RoomCreateRequestDto roomCreateRequestDto) {

        ValidatorUtils.validateEntity(roomCreateRequestDto);

        if (CollectionUtils.isEmpty(roomCreateRequestDto.getImServer())) {
            return Result.invalidParam();
        }
        for (String s : roomCreateRequestDto.getImServer()) {
            if (!IM_OLD.equals(s) && !IM_NEW.equals(s) ) {
                return Result.invalidParam();
            }
        }

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
}
