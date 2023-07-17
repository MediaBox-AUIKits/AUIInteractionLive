package com.aliyun.auipusher;

import android.app.Activity;

import com.alivc.auicommon.common.biz.exposable.enums.LiveStatus;
import com.alivc.auicommon.core.event.EventManager;
import com.aliyun.aliinteraction.player.LivePlayerService;
import com.aliyun.aliinteraction.roompaas.message.AUIMessageService;
import com.aliyun.auiappserver.model.LiveModel;
import com.aliyun.auipusher.manager.LiveLinkMicPushManager;

public interface LiveContext {

    Activity getActivity();

    LiveRole getRole();

    String getNick();

    String getTips();

    LiveStatus getLiveStatus();

    EventManager getEventManager();

    boolean isPushing();

    void setPushing(boolean isPushing);

    /**
     * @return 判断当前是否是横屏
     */
    boolean isLandscape();

    /**
     * 设置是否横屏
     *
     * @param landscape true:横屏; false:竖屏;
     */
    void setLandscape(boolean landscape);

    String getLiveId();

    String getGroupId();

    String getUserId();

    LiveService getLiveService();

    LivePlayerService getLivePlayerService();

    AUIMessageService getMessageService();

    LiveLinkMicPushManager getLiveLinkMicPushManager();

    LiveModel getLiveModel();

    AnchorPreviewHolder getAnchorPreviewHolder();

    boolean isOwner(String userId);
}
