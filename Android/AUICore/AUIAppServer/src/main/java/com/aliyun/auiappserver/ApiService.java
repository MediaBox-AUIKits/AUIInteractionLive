package com.aliyun.auiappserver;

import com.aliyun.auiappserver.model.AppServerToken;
import com.aliyun.auiappserver.model.CancelMuteAllRequest;
import com.aliyun.auiappserver.model.CreateLiveRequest;
import com.aliyun.auiappserver.model.FetchStatisticsRequest;
import com.aliyun.auiappserver.model.FetchStatisticsResponse;
import com.aliyun.auiappserver.model.GetLiveRequest;
import com.aliyun.auiappserver.model.GetMeetingInfoRequest;
import com.aliyun.auiappserver.model.ListLiveRequest;
import com.aliyun.auiappserver.model.LiveModel;
import com.aliyun.auiappserver.model.LiveSendLikeRequest;
import com.aliyun.auiappserver.model.LiveSendLikeResponse;
import com.aliyun.auiappserver.model.LoginRequest;
import com.aliyun.auiappserver.model.MeetingInfo;
import com.aliyun.auiappserver.model.MuteAllRequest;
import com.aliyun.auiappserver.model.MuteGroupStatus;
import com.aliyun.auiappserver.model.QueryMuteAllRequest;
import com.aliyun.auiappserver.model.StartLiveRequest;
import com.aliyun.auiappserver.model.StopLiveRequest;
import com.aliyun.auiappserver.model.Token;
import com.aliyun.auiappserver.model.TokenRequest;
import com.aliyun.auiappserver.model.UpdateLiveRequest;
import com.aliyun.auiappserver.model.UpdateMeetingInfoRequest;

import java.util.List;

import retrofit2.http.Body;
import retrofit2.http.POST;

public interface ApiService {

    //登录
    @POST("/api/v1/live/login")
    ApiInvoker<AppServerToken> login(@Body LoginRequest request);

    //获取token校验合法性
    @POST("/api/v2/live/token")
    ApiInvoker<Token> fetchToken(@Body TokenRequest request);

    //创建直播间
    @POST("/api/v2/live/create")
    ApiInvoker<LiveModel> createLive(@Body CreateLiveRequest request);

    //更新直播间信息，比如更新公告等
    @POST("/api/v1/live/update")
    ApiInvoker<LiveModel> updateLive(@Body UpdateLiveRequest request);

    //推流成功后, 调用此服务通知服务端更新状态（开播状态）
    @POST("/api/v1/live/start")
    ApiInvoker<Void> startLive(@Body StartLiveRequest request);

    //停止推流后, 调用此服务通知服务端更新状态（停播状态）
    @POST("/api/v1/live/stop")
    ApiInvoker<Void> stopLive(@Body StopLiveRequest request);

    //群统计：监听进出群事件，统计PV/UV/在线等数据；并新增API给端进行查询
    @POST("/api/v1/live/getStatistics")
    ApiInvoker<FetchStatisticsResponse> fetchStatistics(@Body FetchStatisticsRequest request);

    //向服务端请求全体禁言接口，目前APPServer仅支持融云聊天室
    @POST("/api/v1/live/muteChatroom")
    ApiInvoker<MuteGroupStatus> muteAll(@Body MuteAllRequest request);

    //向服务端请求取消全体禁言接口，目前APPServer仅支持融云聊天室
    @POST("/api/v1/live/cancelMuteChatroom")
    ApiInvoker<MuteGroupStatus> cancelMuteAll(@Body CancelMuteAllRequest request);

    //向服务端请求是否开启全体禁言接口，目前APPServer仅支持融云聊天室
    @POST("/api/v1/live/isMuteChatroom")
    ApiInvoker<MuteGroupStatus> queryMuteAll(@Body QueryMuteAllRequest request);

    //向服务端请求是否开启全体禁言接口，目前APPServer仅支持融云聊天室
    @POST("/api/v1/live/sendLikeMessage")
    ApiInvoker<LiveSendLikeResponse> sendLike(@Body LiveSendLikeRequest request);

    //获取直播间信息，方便进入直播间信息展示
    @POST("/api/v1/live/get")
    ApiInvoker<LiveModel> fetchLive(@Body GetLiveRequest request);

    //分页获取直播间列表
    @POST("/api/v1/live/list")
    ApiInvoker<List<LiveModel>> fetchLiveList(@Body ListLiveRequest request);

    //主播将最新的麦上成员列表更新到AppServer端，直播间连麦管理模块用
    @POST("/api/v1/live/updateMeetingInfo")
    ApiInvoker<MeetingInfo> updateMeetingInfo(@Body UpdateMeetingInfoRequest request);

    //获取连麦观众信息，直播间连麦管理模块用
    @POST("/api/v1/live/getMeetingInfo")
    ApiInvoker<MeetingInfo> getMeetingInfo(@Body GetMeetingInfoRequest request);
}
