package com.aliyuncs.aui.service;

import com.aliyuncs.aui.dto.LinkInfo;
import com.aliyuncs.aui.dto.PullLiveInfo;
import com.aliyuncs.aui.dto.PushLiveInfo;
import com.aliyuncs.aui.dto.req.ImTokenRequestDto;
import com.aliyuncs.aui.dto.res.ImTokenResponseDto;
import com.aliyuncs.aui.dto.res.RoomInfoDto;

/**
 * 视频云服务
 *
 * @author chunlei.zcl
 */
public interface VideoCloudService {

    /**
    * 获取Im的Token。见文档：https://help.aliyun.com/document_detail/465127.html
    * @author chunlei.zcl
    */
    ImTokenResponseDto getImToken(ImTokenRequestDto imTokenRequestDto);

    /**
    * 创建消息组。见文档：https://help.aliyun.com/document_detail/465128.html
    * @author chunlei.zcl
    */
    String createMessageGroup(String anchor);


    /**
    * 获取推流地址。见文档：https://help.aliyun.com/document_detail/199339.html
    * @author chunlei.zcl
    */
    PushLiveInfo getPushLiveInfo(String streamName);


    /**
     * 获取拉流地址。见文档：https://help.aliyun.com/document_detail/199339.html
     * @author chunlei.zcl
     */
    PullLiveInfo getPullLiveInfo(String streamName);


    /**
     * 获取RTC地址。见文档：https://help.aliyun.com/document_detail/450515.html
     * @author chunlei.zcl
     */
    LinkInfo getRtcInfo(String channelId, String userId, String anchorId);

    /**
     * 从点播搜索录制的视频Id。见文档：https://help.aliyun.com/document_detail/436559.htm
     * @author chunlei.zcl
     */
    String searchMediaByTitle(String title);


    /**
     * 通过音视频ID直接获取视频的播放地址。见文档：https://help.aliyun.com/document_detail/436555.html
     * @author chunlei.zcl
     */
    RoomInfoDto.VodInfo getPlayInfo(String mediaId);

    /**
    *
    * @author chunlei.zcl
    */
    RoomInfoDto.Metrics getGroupDetails(String groupId);

    /**
     * 用ListMessageGroupUserById通过用户ID列表查询用户信息。见文档；https://help.aliyun.com/document_detail/465143.html
     * @author chunlei.zcl
     */
    RoomInfoDto.UserStatus getUserInfo(String groupId, String anchor) ;

    /**
     * 校验直播推流状态回调事件签名。见文档；https://help.aliyun.com/document_detail/199365.html?spm=5176.13499635.help.dexternal.35d92699jvVrc7#section-mxt-vfh-b6s
     * @author chunlei.zcl
     */
    boolean validLiveCallbackSign(String liveSignature, String liveTimestamp);
}
