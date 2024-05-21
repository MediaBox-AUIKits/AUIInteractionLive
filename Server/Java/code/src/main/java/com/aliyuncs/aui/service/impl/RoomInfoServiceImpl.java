package com.aliyuncs.aui.service.impl;

import com.alibaba.fastjson.JSONObject;
import com.aliyuncs.aui.common.utils.JwtUtils;
import com.aliyuncs.aui.common.utils.PageUtils;
import com.aliyuncs.aui.dao.RoomInfoDao;
import com.aliyuncs.aui.dto.LinkInfo;
import com.aliyuncs.aui.dto.MeetingMemberInfo;
import com.aliyuncs.aui.dto.PullLiveInfo;
import com.aliyuncs.aui.dto.PushLiveInfo;
import com.aliyuncs.aui.dto.enums.LiveMode;
import com.aliyuncs.aui.dto.enums.LiveStatus;
import com.aliyuncs.aui.dto.enums.PushStreamStatus;
import com.aliyuncs.aui.dto.req.*;
import com.aliyuncs.aui.dto.res.*;
import com.aliyuncs.aui.entity.RoomInfoEntity;
import com.aliyuncs.aui.service.RoomInfoService;
import com.aliyuncs.aui.service.VideoCloudService;
import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.exceptions.JWTVerificationException;
import com.auth0.jwt.interfaces.Claim;
import com.auth0.jwt.interfaces.DecodedJWT;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.time.DateUtils;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.util.UriUtils;

import javax.annotation.Resource;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.concurrent.*;

import static com.aliyuncs.aui.common.Constants.IM_NEW;
import static com.aliyuncs.aui.common.Constants.IM_OLD;

/**
 * 房间服务实现类
 *
 * @author chunlei.zcl
 */
@Service("roomInfosService")
@Slf4j
public class RoomInfoServiceImpl extends ServiceImpl<RoomInfoDao, RoomInfoEntity> implements RoomInfoService {

    /**
     * token过期时间
     */
    private static final long EXPIRE_TIME = 3600;

    /**
     * token秘钥
     */
    private static final String TOKEN_SECRET = "323assa2323.dqe223b434";

    @Value("${biz.live_mic.app_id}")
    private String liveMicAppId;

    private static ThreadPoolExecutor THREAD_POOL = new ThreadPoolExecutor(0, Integer.MAX_VALUE,
            60L, TimeUnit.SECONDS,
            new SynchronousQueue<>());

    @Resource
    private VideoCloudService videoCloudService;

    @Override
    public ImTokenResponseDto getImToken(ImTokenRequestDto imTokenRequestDto) {

        return videoCloudService.getImToken(imTokenRequestDto);
    }

    @Override
    public NewImTokenResponseDto getNewImToken(ImTokenRequestDto imTokenRequestDto) {

        return videoCloudService.getNewImToken(imTokenRequestDto);
    }

    @Override
    public RoomInfoDto createRoomInfo(RoomCreateRequestDto roomCreateRequestDto) {

        long start = System.currentTimeMillis();

        String groupId = null;
        if (CollectionUtils.isNotEmpty(roomCreateRequestDto.getImServer())) {
            if (roomCreateRequestDto.getImServer().contains(IM_OLD)) {
                groupId = videoCloudService.createMessageGroup(roomCreateRequestDto.getAnchor());
            }

            if (roomCreateRequestDto.getImServer().contains(IM_NEW)) {
                if (StringUtils.isEmpty(groupId)) {
                    groupId = UUID.randomUUID().toString().replaceAll("-", "");
                }
                groupId = videoCloudService.createNewImMessageGroup(groupId, roomCreateRequestDto.getAnchor());
            }
        } else {
            // 兼容老的im逻辑
            groupId = videoCloudService.createMessageGroup(roomCreateRequestDto.getAnchor());
        }

        if (StringUtils.isEmpty(groupId)) {
            log.error("createMessageGroup error. author:{}", roomCreateRequestDto.getAnchor());
            return null;
        }

        Date now = new Date();
        RoomInfoEntity roomInfoEntity = RoomInfoEntity.builder()
                .id(groupId)
                .createdAt(now)
                .updatedAt(now)
                .title(roomCreateRequestDto.getTitle())
                .notice(roomCreateRequestDto.getNotice())
                .anchorId(roomCreateRequestDto.getAnchor())
                .extendsInfo(roomCreateRequestDto.getExtendsInfo())
                .chatId(groupId)
                .anchorNick(roomCreateRequestDto.getAnchorNick())
                .mode(roomCreateRequestDto.getMode())
                .status((long) LiveStatus.LiveStatusPrepare.getVal())
                .build();

        LiveMode liveMode = LiveMode.of(roomCreateRequestDto.getMode());

        if (liveMode == LiveMode.LiveModeLink) {
            roomInfoEntity.setMeetingId(UUID.randomUUID().toString().replaceAll("_", ""));
        }

        // insert db
        boolean saved = this.save(roomInfoEntity);
        if (!saved) {
            log.error("save db error. roomInfoEntity:{}", JSONObject.toJSONString(roomInfoEntity));
            return null;
        }

        RoomInfoDto roomInfoDto = new RoomInfoDto();
        BeanUtils.copyProperties(roomInfoEntity, roomInfoDto);

        PushLiveInfo pushLiveInfo = videoCloudService.getPushLiveInfo(groupId);
        PullLiveInfo pullLiveInfo = videoCloudService.getPullLiveInfo(groupId);
        roomInfoDto.setPushLiveInfo(pushLiveInfo);
        roomInfoDto.setPullLiveInfo(pullLiveInfo);
        if (liveMode == LiveMode.LiveModeLink) {
            LinkInfo rtcInfo = videoCloudService.getRtcInfo(roomInfoEntity.getMeetingId(), roomCreateRequestDto.getAnchor(), roomCreateRequestDto.getAnchor());
            roomInfoDto.setLinkInfo(rtcInfo);
        }

        log.info("createRoomInfo. roomCreateRequestDto:{}, roomInfoDto:{}, consume:{}", JSONObject.toJSONString(roomCreateRequestDto),
                JSONObject.toJSONString(roomInfoDto), (System.currentTimeMillis() - start));
        return roomInfoDto;
    }

    @Override
    public RoomInfoDto get(RoomGetRequestDto roomGetRequestDto) {

        RoomInfoEntity roomInfoEntity = this.getById(roomGetRequestDto.getId());
        if (roomInfoEntity == null) {
            log.warn("get roomInfoEntity is null. roomGetRequestDto:{}", JSONObject.toJSONString(roomGetRequestDto));
            return null;
        }

        RoomInfoDto roomInfoDto = new RoomInfoDto();
        BeanUtils.copyProperties(roomInfoEntity, roomInfoDto);

        roomInfoDto.setPullLiveInfo(videoCloudService.getPullLiveInfo(roomGetRequestDto.getId()));

        if (isOwner(roomInfoEntity.getAnchorId(), roomGetRequestDto.getUserId())) {
            roomInfoDto.setPushLiveInfo(videoCloudService.getPushLiveInfo(roomGetRequestDto.getId()));
        }

        if (roomInfoEntity.getMode() == LiveMode.LiveModeLink.getVal()) {
            LinkInfo rtcInfo = videoCloudService.getRtcInfo(roomInfoEntity.getMeetingId(), roomGetRequestDto.getUserId(), roomInfoEntity.getAnchorId());
            roomInfoDto.setLinkInfo(rtcInfo);
        }

        String mediaId = videoCloudService.searchMediaByTitle(getTitle(roomInfoEntity));
        if (StringUtils.isNotEmpty(mediaId)) {
            RoomInfoDto.VodInfo vodInfo = videoCloudService.getPlayInfo(mediaId);
            if (vodInfo != null) {
                roomInfoDto.setVodInfo(vodInfo);
            }
        }

        RoomInfoDto.Metrics metrics = null;
        RoomInfoDto.UserStatus userStatus = null;

        if (CollectionUtils.isNotEmpty(roomGetRequestDto.getImServer())) {
            if (roomGetRequestDto.getImServer().contains(IM_OLD)) {
                metrics = videoCloudService.getGroupDetails(roomInfoEntity.getId());
                userStatus = videoCloudService.getUserInfo(roomInfoEntity.getId(), roomInfoEntity.getAnchorId());
            } else if (roomGetRequestDto.getImServer().contains(IM_NEW)) {
                metrics = videoCloudService.getNewImGroupDetails(roomInfoEntity.getId());
            } else {
                metrics = videoCloudService.getGroupDetails(roomInfoEntity.getId());
                userStatus = videoCloudService.getUserInfo(roomInfoEntity.getId(), roomInfoEntity.getAnchorId());
            }
        } else {
            metrics = videoCloudService.getGroupDetails(roomInfoEntity.getId());
            userStatus = videoCloudService.getUserInfo(roomInfoEntity.getId(), roomInfoEntity.getAnchorId());
        }

        if (metrics == null) {
            metrics = RoomInfoDto.Metrics.builder().pv(0L).uv(0L).onlineCount(0L).build();
        }
        roomInfoDto.setMetrics(metrics);
        
        if (userStatus != null) {
            roomInfoDto.setUserStatus(userStatus);
        }
        return roomInfoDto;
    }


    @Override
    public PageUtils list(RoomListRequestDto roomListRequestDto) {

        Page<RoomInfoEntity> page = new Page<>(roomListRequestDto.getPageNum(), roomListRequestDto.getPageSize());
        QueryWrapper<RoomInfoEntity> queryWrapper = new QueryWrapper<>();
        queryWrapper.lambda().orderByDesc(RoomInfoEntity::getCreatedAt);

        Page<RoomInfoEntity> roomInfoEntityPage = this.page(page, queryWrapper);
        if (roomInfoEntityPage == null || CollectionUtils.isEmpty(roomInfoEntityPage.getRecords())) {
            log.warn("list. roomInfoEntityPage or roomInfoEntityPage.getRecords is empty");
            return null;
        }

        List<Future<RoomInfoDto>> futureList = new ArrayList<>(roomInfoEntityPage.getRecords().size());
        CountDownLatch countDownLatch = new CountDownLatch(roomInfoEntityPage.getRecords().size());

        for (RoomInfoEntity record : roomInfoEntityPage.getRecords()) {
            RoomGetRequestDto roomGetRequestDto = new RoomGetRequestDto();
            roomGetRequestDto.setId(record.getId());
            roomGetRequestDto.setUserId(record.getAnchorId());
            roomGetRequestDto.setImServer(roomListRequestDto.getImServer());
            Future<RoomInfoDto> future = THREAD_POOL.submit(() -> getRoomInfo(roomGetRequestDto, countDownLatch));
            futureList.add(future);
        }

        try {
            countDownLatch.await();
        } catch (InterruptedException e) {
            log.error(String.format("list InterruptedException. roomListRequestDto:{}", JSONObject.toJSONString(roomListRequestDto)), e);
            return null;
        }

        List<RoomInfoDto> roomInfoDtos = new ArrayList<>(futureList.size());
        for (Future<RoomInfoDto> roomInfoDtoFuture : futureList) {
            try {
                roomInfoDtos.add(roomInfoDtoFuture.get());
            } catch (Exception e) {
                log.error(String.format("roomInfoDtoFuture.get() Exception. roomListRequestDto:{}", JSONObject.toJSONString(roomListRequestDto)), e);
            }
        }

        return new PageUtils(roomInfoDtos, (int) roomInfoEntityPage.getTotal(), (int) roomInfoEntityPage.getSize(), (int) roomInfoEntityPage.getCurrent());
    }

    @Override
    public RoomInfoDto stop(RoomUpdateStatusRequestDto roomUpdateStatusRequestDto) {

        boolean valid = verifyPermission(roomUpdateStatusRequestDto.getId(), roomUpdateStatusRequestDto.getUserId());
        if (!valid) {
            return null;
        }

        boolean result = updateStatus(roomUpdateStatusRequestDto.getId(), LiveStatus.LiveStatusOff);
        if (result) {
            RoomGetRequestDto roomGetRequestDto = new RoomGetRequestDto();
            roomGetRequestDto.setId(roomUpdateStatusRequestDto.getId());
            roomGetRequestDto.setUserId(roomUpdateStatusRequestDto.getUserId());
            return get(roomGetRequestDto);
        }
        return null;
    }

    @Override
    public RoomInfoDto pause(RoomUpdateStatusRequestDto roomUpdateStatusRequestDto) {

        boolean valid = verifyPermission(roomUpdateStatusRequestDto.getId(), roomUpdateStatusRequestDto.getUserId());
        if (!valid) {
            return null;
        }

        boolean result = updateStatus(roomUpdateStatusRequestDto.getId(), LiveStatus.LiveStatusPrepare);
        if (result) {
            RoomGetRequestDto roomGetRequestDto = new RoomGetRequestDto();
            roomGetRequestDto.setId(roomUpdateStatusRequestDto.getId());
            roomGetRequestDto.setUserId(roomUpdateStatusRequestDto.getUserId());
            return get(roomGetRequestDto);
        }
        return null;
    }

    @Override
    public RoomInfoDto start(RoomUpdateStatusRequestDto roomUpdateStatusRequestDto) {

        boolean valid = verifyPermission(roomUpdateStatusRequestDto.getId(), roomUpdateStatusRequestDto.getUserId());
        if (!valid) {
            return null;
        }
        boolean result = updateStatus(roomUpdateStatusRequestDto.getId(), LiveStatus.LiveStatusOn);
        if (result) {
            RoomGetRequestDto roomGetRequestDto = new RoomGetRequestDto();
            roomGetRequestDto.setId(roomUpdateStatusRequestDto.getId());
            roomGetRequestDto.setUserId(roomUpdateStatusRequestDto.getUserId());
            return get(roomGetRequestDto);
        }
        return null;
    }

    @Override
    public RoomInfoDto delete(RoomDeleteRequestDto roomDeleteRequestDto) {

        boolean valid = verifyPermission(roomDeleteRequestDto.getId(), roomDeleteRequestDto.getUserId());
        if (!valid) {
            return null;
        }

        RoomGetRequestDto roomGetRequestDto = new RoomGetRequestDto();
        roomGetRequestDto.setId(roomDeleteRequestDto.getId());
        roomGetRequestDto.setUserId(roomDeleteRequestDto.getUserId());
        RoomInfoDto roomInfoDto = get(roomGetRequestDto);

        if (this.removeById(roomDeleteRequestDto.getId())) {
            return roomInfoDto;
        }

        return null;
    }

    @Override
    public RoomInfoDto update(RoomUpdateRequestDto roomUpdateRequestDto) {

        RoomInfoEntity roomInfoEntity = new RoomInfoEntity();
        roomInfoEntity.setId(roomUpdateRequestDto.getId());
        if (StringUtils.isNotEmpty(roomUpdateRequestDto.getTitle())) {
            roomInfoEntity.setTitle(roomUpdateRequestDto.getTitle());
        }
        if (StringUtils.isNotEmpty(roomUpdateRequestDto.getNotice())) {
            roomInfoEntity.setNotice(roomUpdateRequestDto.getNotice());
        }
        if (StringUtils.isNotEmpty(roomUpdateRequestDto.getExtendsInfo())) {
            roomInfoEntity.setExtendsInfo(roomUpdateRequestDto.getExtendsInfo());
        }
        roomInfoEntity.setUpdatedAt(new Date());
        if (this.updateById(roomInfoEntity)) {
            RoomInfoEntity re = this.getById(roomUpdateRequestDto.getId());
            if (re != null) {
                RoomGetRequestDto roomGetRequestDto = new RoomGetRequestDto();
                roomGetRequestDto.setId(re.getId());
                roomGetRequestDto.setUserId(re.getAnchorId());
                return get(roomGetRequestDto);
            }
        }
        return null;
    }

    @Override
    public MeetingMemberInfo.Members updateMeetingInfo(MeetingActionRequestDto meetingActionRequestDto) {

        RoomInfoEntity roomInfoEntity = this.getById(meetingActionRequestDto.getId());
        if (roomInfoEntity == null) {
            log.warn("RoomInfoEntity Not Found. roomId:{}", meetingActionRequestDto.getId());
            return null;
        }

        if (roomInfoEntity.getMode() != LiveMode.LiveModeLink.getVal()) {
            log.warn("unsupported live mode: {}", roomInfoEntity.getMode());
            return null;
        }

        RoomInfoEntity re = new RoomInfoEntity();
        re.setId(meetingActionRequestDto.getId());

        MeetingMemberInfo.Members members = new MeetingMemberInfo.Members();
        members.setMembers(meetingActionRequestDto.getMembers());

        re.setMeetingInfo(JSONObject.toJSONString(members));
        re.setUpdatedAt(new Date());

        if (this.updateById(re)) {
            return members;
        }
        return null;
    }

    @Override
    public MeetingMemberInfo.Members getMeetingInfo(MeetingGetRequestDto meetingGetRequestDto) {

        RoomInfoEntity roomInfoEntity = this.getById(meetingGetRequestDto.getId());
        if (roomInfoEntity == null) {
            log.warn("RoomInfoEntity Not Found. roomId:{}", meetingGetRequestDto.getId());
            return null;
        }
        if (roomInfoEntity.getMode() != LiveMode.LiveModeLink.getVal()) {
            log.warn("unsupported live mode: {}", roomInfoEntity.getMode());
            return null;
        }

        return JSONObject.parseObject(roomInfoEntity.getMeetingInfo(), MeetingMemberInfo.Members.class);
    }

    @Override
    public boolean handlePushStreamEventCallback(LivePushStreamEventRequestDto livePushStreamEventRequestDto) {

        boolean valid = videoCloudService.validLiveCallbackSign(livePushStreamEventRequestDto.getLiveSignature(), livePushStreamEventRequestDto.getLiveTimestamp());
        if (!valid) {
            log.warn("InvalidLiveCallbackSign");
            return false;
        }
        RoomInfoEntity roomInfoEntity = null;

        // StreamId是通过推流URL中的多个字段拼接生成，具体拼接规则为：
        // 如果是视频连麦，其StreamId为：${连麦应用ID}_${房间ID}_${主播ID}_camera。
        // 如果是纯语音连麦，其StreamId为：${连麦应用ID}_${房间ID}_${主播ID}_audio。
        // 见文档：https://help.aliyun.com/document_detail/450515.html
        if (livePushStreamEventRequestDto.getId().endsWith("_camera") || livePushStreamEventRequestDto.getId().endsWith("_audio")) {
            //表明是连麦id
            String[] s = livePushStreamEventRequestDto.getId().split("_");
            if (s.length >= 3) {
                String meetingId = s[1];
                roomInfoEntity = this.lambdaQuery().ge(RoomInfoEntity::getMeetingId, meetingId).one();
            }
        } else {
            roomInfoEntity = this.getById(livePushStreamEventRequestDto.getId());
        }

        if (roomInfoEntity == null) {
            log.warn("handlePushStreamEventCallback roomInfoEntity is null");
            return true;
        }

        if (PushStreamStatus.PUBLIC.getStatus().equals(livePushStreamEventRequestDto.getAction())) {
            if (roomInfoEntity.getStatus() == LiveStatus.LiveStatusOff.getVal() || roomInfoEntity.getStatus() == LiveStatus.LiveStatusPrepare.getVal()) {
                updateStatus(roomInfoEntity.getId(), LiveStatus.LiveStatusOn);
            }
        } else if (PushStreamStatus.PUBLIC_DONE.getStatus().equals(livePushStreamEventRequestDto.getAction())) {
            if (roomInfoEntity.getStatus() == LiveStatus.LiveStatusOn.getVal()) {
                updateStatus(roomInfoEntity.getId(), LiveStatus.LiveStatusPrepare);
            }
        }

        return true;
    }

    @Override
    public JumpUrlResponse getLiveJumpUrl(JumpUrlRequestDto jumpUrlRequestDto, String serverHost) {

        try {
            // 设置过期时间
            long exp = System.currentTimeMillis() / 1000L + EXPIRE_TIME;
            // 设置头部信息
            Map<String, Object> header = new HashMap<>(2);
            // 返回token字符串
            String token = JWT.create()
                    .withHeader(header)
                    .withClaim("user_id", jumpUrlRequestDto.getUserId())
                    .withClaim("live_id", jumpUrlRequestDto.getLiveId())
                    .withClaim("user_name", jumpUrlRequestDto.getUserName())
                    .withClaim("app_server", serverHost)
                    .withClaim("exp", exp)
                    .sign(Algorithm.HMAC256(TOKEN_SECRET));

            String liveJumpUrl;
            if (StringUtils.isNotEmpty(jumpUrlRequestDto.getVersion())) {
                liveJumpUrl = String.format("auipusher://page/live-room?app_server=%s&token=%s&user_id=%s&user_name=%s&live_id=%s&version=%s",
                        UriUtils.encodePath(serverHost, StandardCharsets.UTF_8),
                        token,
                        UriUtils.encodePath(jumpUrlRequestDto.getUserId(), StandardCharsets.UTF_8),
                        UriUtils.encodePath(jumpUrlRequestDto.getUserName(), StandardCharsets.UTF_8),
                        UriUtils.encodePath(jumpUrlRequestDto.getLiveId(), StandardCharsets.UTF_8),
                        UriUtils.encodePath(jumpUrlRequestDto.getVersion(), StandardCharsets.UTF_8)
                        );
            } else {
                liveJumpUrl = String.format("auipusher://page/live-room?app_server=%s&token=%s&user_id=%s&user_name=%s&live_id=%s",
                        UriUtils.encodePath(serverHost, StandardCharsets.UTF_8),
                        token,
                        UriUtils.encodePath(jumpUrlRequestDto.getUserId(), StandardCharsets.UTF_8),
                        UriUtils.encodePath(jumpUrlRequestDto.getUserName(), StandardCharsets.UTF_8),
                        UriUtils.encodePath(jumpUrlRequestDto.getLiveId(), StandardCharsets.UTF_8));
            }
            return JumpUrlResponse.builder().liveJumpUrl(liveJumpUrl).build();
        } catch (Exception e) {
            log.error("getLiveJumpUrl exception:{}", e);
        }
        return null;
    }

    @Override
    public AuthTokenResponse verifyAuthToken(AuthTokenRequestDto authTokenRequestDto) {

        try {
            Algorithm algorithm = Algorithm.HMAC256(TOKEN_SECRET);
            DecodedJWT decode = JWT.require(algorithm).build().verify(authTokenRequestDto.getToken());

            Map<String, Claim> claims = decode.getClaims();
            String userId = claims.get("user_id").asString();
            if (!authTokenRequestDto.getUserId().equals(userId)) {
                log.warn("verifyAuthToken. userId not matched");
                return null;
            }
            String liveId = claims.get("live_id").asString();
            if (!authTokenRequestDto.getLiveId().equals(liveId)) {
                log.warn("verifyAuthToken. liveId not matched");
                return null;
            }

            String userName = null;
            if (claims.containsKey("user_name")) {
                userName = claims.get("user_name").asString();
            }
            if (StringUtils.isNotEmpty(authTokenRequestDto.getUserName()) && !authTokenRequestDto.getUserName().equals(userName)) {
                log.warn("verifyAuthToken. userName not matched");
                return null;
            }

            String appServer = claims.get("app_server").asString();
            if (!authTokenRequestDto.getAppServer().equals(appServer)) {
                log.warn("verifyAuthToken. appServer not matched");
                return null;
            }

            // 生成登录token
            String token = JwtUtils.generateToken(userName);
            return AuthTokenResponse.builder().loginToken(token).build();
        } catch (JWTVerificationException e) {
            log.error("verifyAuthToken:{}", e.getMessage());
        }
        return null;
    }

    @Override
    public RtcAuthTokenResponse getRtcAuthToken(RtcAuthTokenRequestDto rtcAuthTokenRequestDto) {

        // 24小时有效
        long timestamp = DateUtils.addDays(new Date(), 1).getTime() / 1000;
        String token = videoCloudService.getSpecialRtcAuth(rtcAuthTokenRequestDto.getRoomId(), rtcAuthTokenRequestDto.getUserId(), timestamp);
        return RtcAuthTokenResponse.builder().authToken(token).timestamp(timestamp).build();
    }

    private boolean verifyPermission(String roomId, String reqUid) {

        RoomInfoEntity roomInfoEntity = this.getById(roomId);
        if (roomInfoEntity == null) {
            log.warn("RoomInfoEntity Not Found. roomId:{}", roomId);
            return true;
        }

        if (!roomInfoEntity.getAnchorId().equals(reqUid)) {
            log.warn("Insufficient permission. roomId:{}, anthor:{}, reqUid:{}", roomId,
                    roomInfoEntity.getAnchorId(), reqUid);
            return false;
        }
        return true;
    }

    private boolean updateStatus(String id, LiveStatus liveStatus) {

        RoomInfoEntity roomInfoEntity = new RoomInfoEntity();
        roomInfoEntity.setId(id);
        roomInfoEntity.setStatus((long) liveStatus.getVal());

        switch (liveStatus) {
            case LiveStatusPrepare:
                break;
            case LiveStatusOn:
                roomInfoEntity.setStartedAt(new Date());
                break;
            case LiveStatusOff:
                roomInfoEntity.setStoppedAt(new Date());
        }
        roomInfoEntity.setUpdatedAt(new Date());
        return this.updateById(roomInfoEntity);
    }

    private RoomInfoDto getRoomInfo(RoomGetRequestDto roomGetRequestDto, CountDownLatch countDownLatch) {

        try {
            return get(roomGetRequestDto);
        } catch (Exception e) {
            log.error(String.format("getRoomInfo. roomGetRequestDto:{}", JSONObject.toJSONString(roomGetRequestDto), e));
        } finally {
            countDownLatch.countDown();
        }
        return null;
    }

    private String getTitle(RoomInfoEntity roomInfoEntity) {

        String title = roomInfoEntity.getId();
        if (roomInfoEntity.getMode() == LiveMode.LiveModeLink.getVal()) {
            return String.format("%s_%s_%s_camera", liveMicAppId, roomInfoEntity.getMeetingId(), roomInfoEntity.getAnchorId());
        }
        return title;
    }

    private boolean isOwner(String anchor, String userId) {

        if (StringUtils.isNotEmpty(anchor) && anchor.equals(userId)) {
            return true;
        }
        return false;
    }
}