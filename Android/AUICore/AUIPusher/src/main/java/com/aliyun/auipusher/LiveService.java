package com.aliyun.auipusher;

import com.alivc.auicommon.common.base.exposable.IEventHandlerManager;
import com.aliyun.auiappserver.model.LiveModel;

public interface LiveService extends IEventHandlerManager<LiveEventHandler> {

    /**
     * @return 查询直播详情 (同步方法, 仅限于内部请求过后才有值)
     */
    LiveModel getLiveModel();

    /**
     * @return 获取直播推流服务
     */
    LivePusherService getPusherService();
}
