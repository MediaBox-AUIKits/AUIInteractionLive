package com.aliyun.auipusher;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Process;
import android.text.TextUtils;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.alivc.auicommon.common.base.EventHandlerManager;
import com.alivc.auicommon.common.base.callback.UICallback;
import com.alivc.auicommon.common.base.error.Errors;
import com.alivc.auicommon.common.base.exposable.Callback;
import com.alivc.auicommon.common.base.log.Logger;
import com.alivc.auicommon.common.base.util.CommonUtil;
import com.aliyun.auiappserver.model.LiveModel;
import com.aliyun.auipusher.config.AliLivePusherOptions;
import com.aliyun.auipusher.config.CanvasScale;
import com.aliyun.auipusher.config.LiveEvent;
import com.aliyun.auipusher.manager.LiveLinkMicPushManager;
import com.aliyun.auipusher.manager.LivePushManager;

import java.util.Map;

class LivePusherServiceImpl implements LivePusherService {

    private static final String TAG = LivePusherServiceImpl.class.getSimpleName();

    private final LiveServiceImpl.LiveServiceContext serviceContext;
    private final Context context;
    private final AliLivePusherOptions aliLivePusherOptions;

    private LivePushManager livePushManager;
    private LiveLinkMicPushManager liveLinkMicPushManager;
    private FrameLayout renderView;
    private boolean isCanLinkMic = false;

    public LivePusherServiceImpl(LiveServiceImpl.LiveServiceContext serviceContext, AliLivePusherOptions aliLivePusherOptions) {
        this.serviceContext = serviceContext;
        this.context = serviceContext.getContext();
        this.aliLivePusherOptions = aliLivePusherOptions;
        if (serviceContext.getLiveModel().mode == 1) {
            isCanLinkMic = true;
        }
    }

    @Override
    public void startPreview(Callback<View> callback) {

        if (noPermission(Manifest.permission.CAMERA)
                || noPermission(Manifest.permission.RECORD_AUDIO)) {
            CommonUtil.showToast(context, "请在手机设置中开启摄像头权限");
            return;
        }

        // 主播
        View previewLive = previewLive();
        if (callback != null) {
            callback.onSuccess(previewLive);
        }
    }

    private boolean noPermission(String permission) {
        int checkResult = context.checkPermission(
                permission, Process.myPid(), Process.myUid());
        return checkResult != PackageManager.PERMISSION_GRANTED;
    }

    private View previewLive() {
        if (isCanLinkMic) {
            return getLinkMicPushManager().startPreview(renderView);
        } else {
            return getPushManager().startPreview();
        }

    }

    @Override
    public void startLive(Callback<View> callback) {
        startLive(null, callback);
    }

    @Override
    public void setRenderView(FrameLayout renderView, boolean isAnchor) {
        this.renderView = renderView;
    }

    @Override
    public void startLive(String pushUrl, Callback<View> callback) {
        if (noPermission(Manifest.permission.CAMERA)
                || noPermission(Manifest.permission.RECORD_AUDIO)) {
            CommonUtil.showToast(context, "请在手机设置中开启摄像头权限");
            return;
        }
        final UICallback<View> uiCallback = new UICallback<>(callback);
        if (!serviceContext.isOwner()) {
            // 观众不允许调用开播
            Logger.e(TAG, "audience hasn't permission");
            uiCallback.onError(Errors.BIZ_PERMISSION_DENIED.getMessage());
            return;
        }

        LiveModel liveModel = serviceContext.getLiveModel();
        String pushStreamUrl = liveModel == null ? null : liveModel.getPushUrl();
        String finalPushUrl = TextUtils.isEmpty(pushUrl) ? pushStreamUrl : pushUrl;

        final View renderView;
        try {
            if (isCanLinkMic) {
                renderView = getLinkMicPushManager().startPublish(finalPushUrl);
            } else {
                renderView = getPushManager().startPublish(finalPushUrl);
            }

        } catch (Exception e) {
            e.printStackTrace();
            Logger.e(TAG, "start publish error", e);
            callback.onError(e.getMessage());
            return;
        }
        callback.onSuccess(renderView);
    }

    @Override
    public void setPreviewMode(@CanvasScale.Mode int mode) {
        if (isCanLinkMic) {
            getLinkMicPushManager().setViewContentMode(mode);
        } else {
            getPushManager().setViewContentMode(mode);
        }
    }

    @Override
    public void switchCamera() {
        if (isCanLinkMic) {
            getLinkMicPushManager().switchCamera();
        } else {
            getPushManager().switchCamera();
        }
    }

    @Override
    public void closeCamera() {
        if (isCanLinkMic) {
            getLinkMicPushManager().pause();
        } else {
            getPushManager().pauseLive();
        }
    }

    @Override
    public void openCamera() {
        if (isCanLinkMic) {
            getLinkMicPushManager().resume();
        } else {
            getPushManager().resumeLive();
        }
    }

    @Override
    public void setPreviewMirror(boolean mirror) {
        if (isCanLinkMic) {
            getLinkMicPushManager().setPreviewMirror(mirror);
        } else {
            getPushManager().setPreviewMirror(mirror);
        }
    }

    @Override
    public void setPushMirror(boolean mirror) {
        if (isCanLinkMic) {
            getLinkMicPushManager().setPushMirror(mirror);
        } else {
            getPushManager().setPushMirror(mirror);
        }
    }


    @Override
    public void setMutePush(boolean mute) {
        if (isCanLinkMic) {
            getLinkMicPushManager().setMute(mute);
        } else {
            getPushManager().setMute(mute);
        }
    }

    @Override
    public void stopLive(Callback<Void> callback) {
        stopLive(true, callback);
    }

    @Override
    public void stopLive(boolean destroyLive, Callback<Void> callback) {
        final UICallback<Void> uiCallback = new UICallback<>(callback);
        if (!serviceContext.isOwner()) {
            // 观众不允许调用停播
            Logger.e(TAG, "audience hasn't permission");
            uiCallback.onError(Errors.BIZ_PERMISSION_DENIED.getMessage());
            return;
        }

        final String liveId = serviceContext.getLiveId();
        if (liveId == null) {
            // 取不到liveId时仍认为调用成功, 不做额外处理
            Logger.w(TAG, "stopLive: the liveId is null");
            stopPublishIfNeed();
            uiCallback.onSuccess(null);
            return;
        }

        if (!destroyLive) {
            stopPublishIfNeed();
            uiCallback.onSuccess(null);
            return;
        }

        stopPublishIfNeed();
        uiCallback.onSuccess(null);
    }

    private void stopPublishIfNeed() {
        if (livePushManager != null) {
            livePushManager.stopPublish();
        }
        if (liveLinkMicPushManager != null) {
            liveLinkMicPushManager.stopPublish();
        }
    }

    @Override
    public void restartLive() {
        if (!serviceContext.isOwner()) {
            // 观众不允许调用开播
            Logger.e(TAG, "audience hasn't permission");
            return;
        }

        long startTime = System.currentTimeMillis();
        getLinkMicPushManager().reconnectPushAsync();
        long duration = System.currentTimeMillis() - startTime;
        Logger.i(TAG, String.format("restartLive take %sms", duration));
    }

    @Override
    public void setFlash(boolean open) {
        if (livePushManager != null) {
            livePushManager.setFlash(open);
        }
        if (liveLinkMicPushManager != null) {
            liveLinkMicPushManager.setFlash(open);
        }
    }

    @Override
    public boolean isCameraSupportFlash() {
        if (isCanLinkMic) {
            return liveLinkMicPushManager != null && liveLinkMicPushManager.isCameraSupportFlash();
        } else {
            return livePushManager != null && livePushManager.isCameraSupportFlash();
        }
    }

    @Override
    public void setZoom(int zoom) {
        if (livePushManager != null) {
            livePushManager.setZoom(zoom);
        }
        if (liveLinkMicPushManager != null) {
            liveLinkMicPushManager.setZoom(zoom);
        }
    }

    @Override
    public int getCurrentZoom() {
        if (livePushManager != null) {
            return livePushManager.getCurrentZoom();
        }
        if (liveLinkMicPushManager != null) {
            return liveLinkMicPushManager.getCurrentZoom();
        }
        return 0;
    }

    @Override
    public int getMaxZoom() {
        if (livePushManager != null) {
            return livePushManager.getMaxZoom();
        }
        if (liveLinkMicPushManager != null) {
            return liveLinkMicPushManager.getMaxZoom();
        }
        return 0;
    }

    @Override
    public void focusCameraAtAdjustedPoint(float x, float y, boolean autoFocus) {
        if (livePushManager != null) {
            livePushManager.focusCameraAtAdjustedPoint(x, y, autoFocus);
        }
        if (liveLinkMicPushManager != null) {
            liveLinkMicPushManager.focusCameraAtAdjustedPoint(x, y, autoFocus);
        }
    }

    @Override
    public void destroy() {
        if (isCanLinkMic) {
            if (liveLinkMicPushManager != null) {
                liveLinkMicPushManager.destroy();
            }
        } else {
            if (livePushManager != null) {
                livePushManager.destroy();
            }
        }
    }

    // 懒加载处理, 使用时再获取
    @NonNull
    private LivePushManager getPushManager() {
        if (livePushManager == null) {
            livePushManager = createLivePushManager();
        }
        return livePushManager;
    }

    // 懒加载处理, 使用时再获取
    @NonNull
    private LiveLinkMicPushManager getLinkMicPushManager() {
        if (liveLinkMicPushManager == null) {
            liveLinkMicPushManager = createLiveLinkMicPushManager();
        }
        return liveLinkMicPushManager;
    }

    @NonNull
    private LivePushManager createLivePushManager() {
        LivePushManager pushManager = new LivePushManager(context, aliLivePusherOptions);
        pushManager.setCallback(new LiveSdkEventListener());
        return pushManager;
    }

    @NonNull
    private LiveLinkMicPushManager createLiveLinkMicPushManager() {
        LiveLinkMicPushManager pushManager = new LiveLinkMicPushManager(context, aliLivePusherOptions);
        pushManager.setCallback(new LiveLinkSdkEventListener());
        return pushManager;
    }

    private class LiveSdkEventListener implements LivePushManager.Callback {

        @Override
        public void onEvent(final LiveEvent event, @Nullable final Map<String, Object> extras) {
            serviceContext.dispatch(new EventHandlerManager.Consumer<LiveEventHandler>() {
                @Override
                public void consume(LiveEventHandler eventHandler) {
                    // 透出到外部
                    eventHandler.onPusherEvent(event, extras);
                }
            });
        }
    }

    private class LiveLinkSdkEventListener implements LiveLinkMicPushManager.Callback {

        @Override
        public void onEvent(final LiveEvent event, @Nullable final Map<String, Object> extras) {
            serviceContext.dispatch(new EventHandlerManager.Consumer<LiveEventHandler>() {
                @Override
                public void consume(LiveEventHandler eventHandler) {
                    // 透出到外部
                    eventHandler.onPusherEvent(event, extras);
                }
            });
        }
    }
}
