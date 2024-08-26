package com.aliyun.auipusher.manager;

import static android.os.Environment.MEDIA_MOUNTED;
import static com.alivc.auicommon.common.base.util.CommonUtil.showToast;
import static com.alivc.live.pusher.AlivcLivePushCameraTypeEnum.CAMERA_TYPE_BACK;
import static com.alivc.live.pusher.AlivcLivePushCameraTypeEnum.CAMERA_TYPE_FRONT;

import android.content.Context;
import android.hardware.Camera;
import android.os.Environment;
import android.text.TextUtils;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.alibaba.fastjson.JSON;
import com.alivc.auibeauty.beauty.BeautyFactory;
import com.alivc.auibeauty.beauty.BeautyInterface;
import com.alivc.auibeauty.beauty.constant.BeautySDKType;
import com.alivc.auicommon.common.base.AppContext;
import com.alivc.auicommon.common.base.log.Logger;
import com.alivc.auicommon.common.base.util.CollectionUtil;
import com.alivc.auicommon.core.utils.AssetUtil;
import com.alivc.component.custom.AlivcLivePushCustomFilter;
import com.alivc.live.annotations.AlivcLiveMode;
import com.alivc.live.annotations.AlivcLiveNetworkQuality;
import com.alivc.live.player.AlivcLivePlayConfig;
import com.alivc.live.player.AlivcLivePlayer;
import com.alivc.live.player.annotations.AlivcLivePlayError;
import com.alivc.live.pusher.AlivcAudioAACProfileEnum;
import com.alivc.live.pusher.AlivcEncodeModeEnum;
import com.alivc.live.pusher.AlivcFpsEnum;
import com.alivc.live.pusher.AlivcLiveBase;
import com.alivc.live.pusher.AlivcLiveBaseListener;
import com.alivc.live.pusher.AlivcLiveMixStream;
import com.alivc.live.pusher.AlivcLivePushConfig;
import com.alivc.live.pusher.AlivcLivePushConstants;
import com.alivc.live.pusher.AlivcLivePushError;
import com.alivc.live.pusher.AlivcLivePushErrorListener;
import com.alivc.live.pusher.AlivcLivePushInfoListener;
import com.alivc.live.pusher.AlivcLivePushNetworkListener;
import com.alivc.live.pusher.AlivcLivePushStats;
import com.alivc.live.pusher.AlivcLivePushStatsInfo;
import com.alivc.live.pusher.AlivcLivePusher;
import com.alivc.live.pusher.AlivcLiveTranscodingConfig;
import com.alivc.live.pusher.AlivcPreviewDisplayMode;
import com.alivc.live.pusher.AlivcPreviewOrientationEnum;
import com.aliyun.auipusher.LivePushGlobalConfig;
import com.aliyun.auipusher.config.AliLivePusherOptions;
import com.aliyun.auipusher.config.CanvasScale;
import com.aliyun.auipusher.config.LiveEvent;
import com.aliyun.auipusher.config.MultiAlivcLivePlayer;
import com.aliyun.auipusher.listener.MultiInteractLivePushPullListener;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * 媒体推流服务
 */
public class LiveLinkMicPushManager {

    private static final String TAG = LiveLinkMicPushManager.class.getSimpleName();

    private final Context mContext;
    private final Map<String, MultiAlivcLivePlayer> mAlivcLivePlayerMap = new HashMap<>();

    AlivcLiveBaseListener liveBaseListener = new AlivcLiveBaseListener() {
        @Override
        public void onLicenceCheck(AlivcLivePushConstants.AlivcLiveLicenseCheckResultCode result, String reason) {
            if (result != AlivcLivePushConstants.AlivcLiveLicenseCheckResultCode.AlivcLiveLicenseCheckResultCodeSuccess) {
                showToast(mContext, "license error: " + result + ", " + reason);
            }
        }
    };

    AlivcLivePushErrorListener pushErrorListener = new AlivcLivePushErrorListener() {
        @Override
        public void onSystemError(AlivcLivePusher livePusher, AlivcLivePushError error) {
            if (error != null) {
                Logger.e(TAG, error.toString());
                reportPushLowPerformance(error);
            }
        }

        @Override
        public void onSDKError(AlivcLivePusher livePusher, AlivcLivePushError error) {
            if (error != null) {
                Logger.e(TAG, error.toString());
                reportPushLowPerformance(error);
            }
        }
    };

    private AlivcLivePusher mALivcLivePusher;
    private boolean isStartPush = false;
    private boolean isPause = false;
    // 当前直播推流地址
    private String mCurrentPublishUrl;
    private List<Callback> callbackList = new ArrayList<>();

    // region listener
    AlivcLivePushInfoListener pushInfoListener = new AlivcLivePushInfoListener() {
        @Override
        public void onPreviewStarted(AlivcLivePusher alivcLivePusher) {
            onEvent(LiveEvent.PREVIEW_STARTED);
        }

        @Override
        public void onPreviewStopped(AlivcLivePusher alivcLivePusher) {
            onEvent(LiveEvent.PREVIEW_STOPPED);
        }

        @Override
        public void onPushStarted(AlivcLivePusher alivcLivePusher) {
            onEvent(LiveEvent.PUSH_STARTED);
        }

        @Override
        public void onPushPaused(AlivcLivePusher alivcLivePusher) {
            onEvent(LiveEvent.PUSH_PAUSED);
        }

        @Override
        public void onFirstFramePushed(AlivcLivePusher alivcLivePusher) {
            onEvent(LiveEvent.FIRST_FRAME_PUSHED);
        }

        @Override
        public void onPushResumed(AlivcLivePusher alivcLivePusher) {
            onEvent(LiveEvent.PUSH_RESUMED);
        }

        @Override
        public void onPushStopped(AlivcLivePusher alivcLivePusher) {
            onEvent(LiveEvent.PUSH_STOPPED);
        }

        @Override
        public void onPushRestarted(AlivcLivePusher alivcLivePusher) {

        }

        @Override
        public void onFirstFramePreviewed(AlivcLivePusher alivcLivePusher) {
            onEvent(LiveEvent.FIRST_FRAME_PREVIEWED);
        }

        @Override
        public void onDropFrame(AlivcLivePusher alivcLivePusher, int i, int i1) {

        }

        @Override
        public void onAdjustBitrate(AlivcLivePusher alivcLivePusher, int i, int i1) {

        }

        @Override
        public void onAdjustFps(AlivcLivePusher alivcLivePusher, int curFps, int targetFps) {
        }

        @Override
        public void onPushStatistics(AlivcLivePusher alivcLivePusher, AlivcLivePushStatsInfo info) {
            Map<String, Object> extras = new HashMap<>();
            extras.put("v_bitrate", info.videoUploadBitrate);
            extras.put("a_bitrate", info.audioUploadBitrate);
            onEvent(LiveEvent.UPLOAD_BITRATE_UPDATED, extras);
        }
    };

    AlivcLivePushNetworkListener pushNetworkListener = new AlivcLivePushNetworkListener() {
        @Override
        public void onNetworkPoor(AlivcLivePusher pusher) {
            onEvent(LiveEvent.NETWORK_POOR);
        }

        @Override
        public void onNetworkRecovery(AlivcLivePusher pusher) {
            onEvent(LiveEvent.NETWORK_RECOVERY);
        }

        @Override
        public void onReconnectStart(AlivcLivePusher pusher) {
            onEvent(LiveEvent.RECONNECT_START);
        }

        @Override
        public void onReconnectFail(AlivcLivePusher pusher) {
            onEvent(LiveEvent.RECONNECT_FAIL);
        }

        @Override
        public void onReconnectSucceed(AlivcLivePusher pusher) {
            onEvent(LiveEvent.RECONNECT_SUCCESS);
        }

        @Override
        public void onSendDataTimeout(AlivcLivePusher pusher) {
        }

        @Override
        public void onConnectFail(AlivcLivePusher pusher) {
            onEvent(LiveEvent.CONNECTION_FAIL);
        }

        @Override
        public void onConnectionLost(AlivcLivePusher pusher) {
            //推流已断开
            onEvent(LiveEvent.CONNECTION_LOST);
        }

        @Override
        public String onPushURLAuthenticationOverdue(AlivcLivePusher pusher) {
            if (pusher != null) {
                return pusher.getPushUrl();
            }
            return null;
        }

        @Override
        public void onPushURLTokenWillExpire(AlivcLivePusher pusher) {

        }

        @Override
        public void onPushURLTokenExpired(AlivcLivePusher pusher) {

        }

        @Override
        public void onSendMessage(AlivcLivePusher pusher) {
        }

        @Override
        public void onPacketsLost(AlivcLivePusher pusher) {
        }

        @Override
        public void onNetworkQualityChanged(AlivcLiveNetworkQuality upQuality, AlivcLiveNetworkQuality downQuality) {

        }
    };

    private int mCameraId = Camera.CameraInfo.CAMERA_FACING_FRONT;
    private SurfaceHolder.Callback surfaceViewCallback;
    private FrameLayout renderView;
    private FrameLayout mAudienceFrameLayout;
    private AlivcLivePushConfig mAlivcLivePushConfig;
    private BeautyInterface mBeautyManager;
    private boolean isBeautyEnable = true;

    public LiveLinkMicPushManager(Context context, AliLivePusherOptions aliLivePusherOptions) {
        mContext = context;
        init();
//        initPlayer();
    }

    public static String getFilePath(Context context, String dir) {
        String logFilePath = "";
        //判断SD卡是否可用
        if (MEDIA_MOUNTED.equals(Environment.getExternalStorageState())) {
            logFilePath = context.getExternalFilesDir(dir).getAbsolutePath();
        } else {
            //没内存卡就存机身内存
            logFilePath = context.getFilesDir() + File.separator + dir;
        }
        File file = new File(logFilePath);
        if (!file.exists()) {//判断文件目录是否存在
            file.mkdirs();
        }

        //Set log folder path in 4.4.0+ version
        if (false) {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            String logFileName = "live_pusher_" + sdf.format(new Date()) + "_" + String.valueOf(System.currentTimeMillis()) + ".log";
            logFilePath += File.separator + logFileName;
        }

        Log.d(TAG, "log filePath====>" + logFilePath);
        return logFilePath;
    }

    public static AlivcPreviewDisplayMode convertToAlivcPreviewDisplayMode(@CanvasScale.Mode int mode) {
        switch (mode) {
            case CanvasScale.Mode.SCALE_FILL:
                return AlivcPreviewDisplayMode.ALIVC_LIVE_PUSHER_PREVIEW_SCALE_FILL;
            case CanvasScale.Mode.ASPECT_FIT:
                return AlivcPreviewDisplayMode.ALIVC_LIVE_PUSHER_PREVIEW_ASPECT_FIT;
            default:
            case CanvasScale.Mode.ASPECT_FILL:
                return AlivcPreviewDisplayMode.ALIVC_LIVE_PUSHER_PREVIEW_ASPECT_FILL;
        }
    }

    private void init() {
        if (mALivcLivePusher == null) {
            mALivcLivePusher = new AlivcLivePusher();
        }
        // 注册sdk
        AlivcLiveBase.setListener(liveBaseListener);
        AlivcLiveBase.registerSDK();

        // 初始化推流配置类
        mAlivcLivePushConfig = new AlivcLivePushConfig();
        mAlivcLivePushConfig.setLivePushMode(AlivcLiveMode.AlivcLiveInteractiveMode);
        // 设置H5兼容模式
        // 互动模式下，是否需要与Web 连麦互通，则必须使用H5兼容模式,否则，Web用户查看Native用户将是黑屏。
        mAlivcLivePushConfig.setH5CompatibleMode(true);
        mAlivcLivePushConfig.setExtraInfo(LivePushGlobalConfig.LIVE_PUSH_CONFIG_EXTRA_INFO);
        mAlivcLivePushConfig.setPreviewDisplayMode(AlivcPreviewDisplayMode.ALIVC_LIVE_PUSHER_PREVIEW_ASPECT_FILL);
        // 分辨率540P，最大支持720P
        mAlivcLivePushConfig.setResolution(LivePushGlobalConfig.CONFIG_RESOLUTION);
        // 建议用户使用20fps
        mAlivcLivePushConfig.setFps(AlivcFpsEnum.FPS_20);
        // 打开码率自适应，默认为true
        mAlivcLivePushConfig.setEnableBitrateControl(true);
        // 默认为竖屏，可设置home键向左或向右横屏
        mAlivcLivePushConfig.setPreviewOrientation(AlivcPreviewOrientationEnum.ORIENTATION_PORTRAIT);
        // 设置音频编码模式
        mAlivcLivePushConfig.setAudioProfile(AlivcAudioAACProfileEnum.AAC_LC);
        mAlivcLivePushConfig.setVideoEncodeMode(LivePushGlobalConfig.VIDEO_ENCODE_HARD ? AlivcEncodeModeEnum.Encode_MODE_HARD : AlivcEncodeModeEnum.Encode_MODE_SOFT);
        mAlivcLivePushConfig.setAudioEncodeMode(LivePushGlobalConfig.AUDIO_ENCODE_HARD ? AlivcEncodeModeEnum.Encode_MODE_HARD : AlivcEncodeModeEnum.Encode_MODE_SOFT);
        mAlivcLivePushConfig.setPausePushImage(getPushPauseImagePath());
        mALivcLivePusher = new AlivcLivePusher();
        mALivcLivePusher.init(mContext, mAlivcLivePushConfig);
        mALivcLivePusher.setLivePushInfoListener(pushInfoListener);
        mALivcLivePusher.setLivePushNetworkListener(pushNetworkListener);
        mALivcLivePusher.setLivePushErrorListener(pushErrorListener);

        mALivcLivePusher.setCustomFilter(new AlivcLivePushCustomFilter() {
            @Override
            public void customFilterCreate() {
                initBeautyManager();
            }

            @Override
            public int customFilterProcess(int inputTexture, int textureWidth, int textureHeight, long extra) {
                if (mBeautyManager == null) {
                    return inputTexture;
                }

                return mBeautyManager.onTextureInput(inputTexture, textureWidth, textureHeight);
            }

            @Override
            public void customFilterDestroy() {
                destroyBeautyManager();
                Log.d(TAG, "customFilterDestroy---> thread_id: " + Thread.currentThread().getId());
            }
        });

    }

    @NonNull
    private String getPushPauseImagePath() {
        // 此处文件名与 AUIInteractionLiveRoom/src/main/assets/background_push.png 对应
        String targetFileName = "background_push.png";
        File imageFile = new File(mContext.getFilesDir(), targetFileName);
        String imageFilePath = imageFile.getAbsolutePath();
        if (!imageFile.exists()) {
            AssetUtil.copyAssetFileToSdCard(mContext, targetFileName, imageFilePath);
        }
        return imageFilePath;
    }

    public void setCallback(Callback callback) {
        this.callbackList.add(callback);
    }

    public void removeCallback(Callback callback) {
        this.callbackList.remove(callback);
    }

    protected void onEvent(LiveEvent event) {
        onEvent(event, null);
    }

    protected void onEvent(LiveEvent event, Map<String, Object> extras) {
        if (callbackList != null && callbackList.size() > 0) {
            for (Callback callback : callbackList) {
                callback.onEvent(event, extras);
            }
        }
    }

    /**
     * 切换闪光灯
     *
     * @param open 是否开启
     */
    public void setFlash(boolean open) {
        if (mALivcLivePusher != null && isPreviewedOrPushed()) {
            mALivcLivePusher.setFlash(open);
        }
    }

    /**
     * @return 判断是否支持闪光灯
     */
    public boolean isCameraSupportFlash() {
        return mALivcLivePusher != null && mALivcLivePusher.isCameraSupportFlash();
    }

    /**
     * @param zoom
     */
    public void setZoom(int zoom) {
        if (mALivcLivePusher != null && isPreviewedOrPushed()) {
            mALivcLivePusher.setZoom(zoom);
        }
    }

    public int getCurrentZoom() {
        if (mALivcLivePusher != null && isPreviewedOrPushed()) {
            return mALivcLivePusher.getCurrentZoom();
        }
        return 0;
    }

    public int getMaxZoom() {
        if (mALivcLivePusher != null && isPreviewedOrPushed()) {
            return mALivcLivePusher.getMaxZoom();
        }
        return 0;
    }

    private boolean isPreviewedOrPushed() {
        AlivcLivePushStats pushStats = mALivcLivePusher.getCurrentStatus();
        return pushStats == AlivcLivePushStats.PREVIEWED || pushStats == AlivcLivePushStats.PUSHED;
    }

    private void resumePublish() {
        if (TextUtils.isEmpty(mCurrentPublishUrl)) {
            Logger.w(TAG, "resumePublish publishUrl is empty");
            return;
        }
        if (mALivcLivePusher == null) {
            Logger.w(TAG, "resumePublish mALivcLivePusher is null");
            return;
        }

        AlivcLivePushStats currentStatus = mALivcLivePusher.getCurrentStatus();
        if (currentStatus == AlivcLivePushStats.PUSHED) {
            Logger.w(TAG, "resumePublish currentStatus is already pushed");
            return;
        }

        // 未预览时, 先开启预览
        if (currentStatus != AlivcLivePushStats.PREVIEWED) {
            if (currentStatus == AlivcLivePushStats.INIT) {
                Logger.i(TAG, "resumePublish start preview");
                doStartPreviewByMediaSdk();
            } else {
                Logger.w(TAG, "resumePublish currentStatus is error");
                return;
            }
        }

        // 开始推流
        Logger.i(TAG, "resumePublish start publish");
        startPublish(mCurrentPublishUrl);
    }

    /**
     * 开启推流
     *
     * @param url
     * @return
     */
    public View startPublish(String url) {
        if (url == null || url.length() == 0) {
            Logger.e(TAG, "startPublish url must not null");
            return null;
        }
        if (isStartPush
                || (mALivcLivePusher.isPushing() && url.equals(mALivcLivePusher.getPushUrl()))) {
            Logger.i(TAG, "startPublish url is same");
            return renderView;
        }
        if (mALivcLivePusher.isPushing()) {
            mALivcLivePusher.stopPush();
        }
        mCurrentPublishUrl = url;
        mALivcLivePusher.startPushAsync(url);
        isStartPush = true;
        return renderView;
    }

    /**
     * 获取当前推流地址
     *
     * @return
     */
    public String getCurrentPublishUrl() {
        return mCurrentPublishUrl;
    }

    /**
     * 暂停
     */
    public void pause() {
        if (mALivcLivePusher != null) {
            try {
                mALivcLivePusher.pause();
            } catch (Exception e) {
                Logger.e(TAG, "pause error", e);
            }
            isStartPush = false;
        }
    }

    /**
     * 继续
     */
    public void resume() {
        if (mALivcLivePusher != null) {
            try {
                mALivcLivePusher.resume();
            } catch (Exception e) {
                Logger.e(TAG, "resume error", e);
            }
            isStartPush = true;
        }
    }

    /**
     * 结束推流
     */
    public void stopPublish() {
        if (mALivcLivePusher != null && mALivcLivePusher.isPushing()) {
            try {
                mALivcLivePusher.stopPush();
            } catch (Exception e) {
                Logger.e(TAG, "stopPublish error", e);
            }
            isStartPush = false;
//            mCurrentPublishUrl = null;
        }
        stopPreview();
    }

    private SurfaceView createSurfaceView() {
        final SurfaceView surfaceView = new SurfaceView(mContext);
        surfaceViewCallback = new SurfaceHolder.Callback() {

            private AlivcLivePushStats lastStatus;

            @Override
            public void surfaceCreated(SurfaceHolder surfaceHolder) {
                if (mALivcLivePusher == null) {
                    return;
                }

                AlivcLivePushStats currentStatus = mALivcLivePusher.getCurrentStatus();
                Logger.i(TAG, String.format("surfaceCreated, lastStatus is %s, currentStatus is %s",
                        lastStatus, currentStatus));

                if (isPause) {
                    // 暂停状态不继续预览和推流
                    Logger.i(TAG, "surfaceCreated, pusher is paused");
                    return;
                }
                doStartPreviewByMediaSdk();
            }

            @Override
            public void surfaceChanged(SurfaceHolder surfaceHolder, int i, int i1, int i2) {

            }

            @Override
            public void surfaceDestroyed(SurfaceHolder surfaceHolder) {
                lastStatus = mALivcLivePusher == null ? null : mALivcLivePusher.getCurrentStatus();
                Logger.i(TAG, String.format("surfaceDestroyed, lastStatus is %s", lastStatus));
            }
        };
        surfaceView.getHolder().addCallback(surfaceViewCallback);
        return surfaceView;
    }

    public void setPreviewMode(AlivcPreviewDisplayMode mode) {
        try {
            mALivcLivePusher.setPreviewMode(mode);
        } catch (IllegalStateException e) {
            e.printStackTrace();
        }
    }

    private void doStartPreviewByMediaSdk() {
        if (mALivcLivePusher != null) {
            try {
                mALivcLivePusher.startPreview(mContext, renderView, false);
            } catch (IllegalArgumentException | IllegalStateException e) {
                Logger.e(TAG, "surface create error", e);
            }
        }
    }

    public void setViewContentMode(@CanvasScale.Mode int mode) {
        if (mALivcLivePusher != null) {
            mALivcLivePusher.setPreviewMode(convertToAlivcPreviewDisplayMode(mode));
        }
    }

    /**
     * 开始预览
     */
    public View startPreview(FrameLayout renderView) {
        this.renderView = renderView;
        if (mALivcLivePusher == null) {
            init();
        }

        doStartPreviewByMediaSdk();

        return renderView;
    }

    private void stopPreview() {
        if (mALivcLivePusher != null) {
            try {
                mALivcLivePusher.stopPreview();
            } catch (Exception e) {
                Logger.e(TAG, "stopPreview error", e);
            }
        }
    }

    /**
     * 销毁直播服务
     */
    public void destroy() {
        stopPublish();
        if (callbackList != null && callbackList.size() > 0) {
            callbackList.clear();
        }
        if (mALivcLivePusher != null) {
            mALivcLivePusher.destroy();
            mALivcLivePusher = null;
        }
    }

    /**
     * 静音播放
     */
    public void setMute(boolean mute) {
        mALivcLivePusher.setMute(mute);
    }

    /**
     * 切换摄像头
     */
    public void switchCamera() {
        if (mCameraId == CAMERA_TYPE_FRONT.getCameraId()) {
            mCameraId = CAMERA_TYPE_BACK.getCameraId();
        } else {
            mCameraId = CAMERA_TYPE_FRONT.getCameraId();
        }
        mALivcLivePusher.switchCamera();
    }

    /**
     * 设置预览镜像
     *
     * @param mirror
     */
    public void setPreviewMirror(boolean mirror) {
        if (mALivcLivePusher == null) {
            return;
        }
        mALivcLivePusher.setPreviewMirror(mirror);
    }

    /**
     * 设置推流镜像
     *
     * @param mirror
     */
    public void setPushMirror(boolean mirror) {
        if (mALivcLivePusher == null) {
            return;
        }
        mALivcLivePusher.setPushMirror(mirror);
    }

    /**
     * 重新推流
     * 推流状态下或者接收到所有Error相关回调状态下可调用重新推流, 且Error状态下只可以调用此接口(或者reconnectPushAsync重连)或者调用destory销毁推流。
     */
    public void restartPush() {
        if (mALivcLivePusher == null) {
            return;
        }
        try {
            mALivcLivePusher.restartPush();
        } catch (IllegalArgumentException | IllegalStateException e) {
            Logger.e(TAG, "restartPush error", e);
        }
    }

    /**
     * 推流状态下或者接收到AlivcLivePusherNetworkDelegate相关的Error回调状态下可调用此接口,
     * 且Error状态下只可以调用此接口(或者restartPush重新推流)或者调用destory销毁推流。完成后推流重连，重新链接推流RTMP
     */
    public void reconnectPushAsync() {
        if (mALivcLivePusher == null) {
            return;
        }
        try {
            mALivcLivePusher.reconnectPushAsync(mCurrentPublishUrl);
        } catch (IllegalArgumentException | IllegalStateException e) {
            Logger.e(TAG, "restartPush error", e);
        }
    }

    private void reportPushLowPerformance(AlivcLivePushError error) {
        if (error.getCode() == AlivcLivePushError.ALIVC_PUSHER_ERROR_SDK_LIVE_PUSH_LOW_PERFORMANCE.getCode()) {
        }
    }

    public void focusCameraAtAdjustedPoint(float x, float y, boolean autoFocus) {
        if (mALivcLivePusher != null) {
            try {
                mALivcLivePusher.focusCameraAtAdjustedPoint(x, y, autoFocus);
            } catch (Exception e) {
                Logger.e(TAG, "focusCameraAtAdjustedPoint error", e);
            }
        }
    }

    // endregion listener

    public boolean isPushing() {
        return mALivcLivePusher.isPushing();
    }

    public void setPullView(String key, FrameLayout frameLayout, boolean isAnchor) {
        this.mAudienceFrameLayout = frameLayout;
        AlivcLivePlayConfig config = new AlivcLivePlayConfig();
        config.isFullScreen = isAnchor;
        AlivcLivePlayer alivcLivePlayer = mAlivcLivePlayerMap.get(key);
        if (alivcLivePlayer != null) {
            alivcLivePlayer.setupWithConfig(config);
            alivcLivePlayer.setPlayView(frameLayout);
            alivcLivePlayer.startPlay(key);
        }
    }

    public void stopPull() {
        for (Map.Entry<String, MultiAlivcLivePlayer> entry : mAlivcLivePlayerMap.entrySet()) {
            entry.getValue().stopPlay();
        }
        mAlivcLivePlayerMap.clear();
    }

    public void stopPull(String key) {
        AlivcLivePlayer alivcLivePlayer = mAlivcLivePlayerMap.get(key);
        if (alivcLivePlayer != null) {
            alivcLivePlayer.stopPlay();
        }
        mAlivcLivePlayerMap.remove(key);
    }

    public boolean isPulling(String key) {
        MultiAlivcLivePlayer multiAlivcLivePlayer = mAlivcLivePlayerMap.get(key);
        if (multiAlivcLivePlayer != null) {
            return multiAlivcLivePlayer.isPulling();
        }
        return false;
    }

    public void linkMic(FrameLayout frameLayout, String pullUrl) {
        frameLayout.setVisibility(View.VISIBLE);
        createAlivcLivePlayer(pullUrl);
        setPullView(pullUrl, frameLayout, false);
    }

    public void release() {
        try {
            stopPull();
            stopPublish();
            mALivcLivePusher.destroy();
            stopPull();

            for (AlivcLivePlayer alivcLivePlayer : mAlivcLivePlayerMap.values()) {
                alivcLivePlayer.destroy();
            }
            mAlivcLivePlayerMap.clear();
            clearLiveMixTranscodingConfig();
        } catch (IllegalStateException e) {
            e.printStackTrace();
        }
    }

    // ------------------ 单混切换 [start] ------------------

    // 该逻辑一般在主播侧发起操作，用于操作CDN拉流观众的旁路流的布局
    // 单流：旁路CDN流，仅一路主播流，铺满全屏，观众看到的画面就是主播的画面
    // 混流：主播侧，将当前的自己的窗口，和连麦观众、PK主播的窗口，按照指定的窗口布局规则，进行混流，观众看到的画面是混流布局后的画面
    // 对应接口：AlivcLivePusher#setLiveMixTranscodingConfig
    // 注意：
    // 1. 该接口需保证在主播回调 onFirstFramePushed 以后，即主播端已推流成功，再进行调用
    // 2. 开启自动旁路功能以后，会默认自动推一路主播的旁路流到CDN，用于普通观众的拉流；此功能可在控制台进行开关，默认打开
    // 3. 如果主播还在推流，但不再需要混流，请务必传入 null 进行取消；因为当发起混流后，云端混流模块就会开始工作，不及时取消混流可能会引起不必要的计费损失

    // 混流切单流
    public void clearLiveMixTranscodingConfig() {
        if (mALivcLivePusher != null) {
            mALivcLivePusher.setLiveMixTranscodingConfig(null);
        }
    }

    // 单流切混流
    public void updateMixItems(List<MixItem> mixItems) {
        if (mALivcLivePusher == null) {
            return;
        }

        // 如果当前混流列表为空，或者有且仅有一个推流用户，默认单流模式，不需要混流操作
        if (CollectionUtil.isEmpty(mixItems) || mixItems.size() == 1) {
            clearLiveMixTranscodingConfig();
            return;
        }

        ArrayList<AlivcLiveMixStream> mixStreams = new ArrayList<>();

        // 主播
        int canvasWidth = mAlivcLivePushConfig.getWidth();
        int canvasHeight = mAlivcLivePushConfig.getHeight();
        float canvasRatio = canvasWidth * 1f / canvasHeight;

        int screenWidth = AppContext.getContext().getResources().getDisplayMetrics().widthPixels;
        int screenHeight = AppContext.getContext().getResources().getDisplayMetrics().heightPixels;
        float screenRatio = screenWidth * 1f / screenHeight;

        boolean isHeightGrid = screenRatio < canvasRatio;

        Logger.i(TAG, String.format("canvas.size=(%s, %s)", canvasWidth, canvasHeight));
        Logger.i(TAG, String.format("canvasRatio=%s", canvasRatio));
        Logger.i(TAG, String.format("grid.size=(%s, %s)", screenWidth, screenHeight));
        Logger.i(TAG, String.format("screenRatio=%s", screenRatio));
        Logger.i(TAG, String.format("isHeightGrid=%s", isHeightGrid));

        for (int i = 0; i < mixItems.size(); i++) {
            MixItem mixItem = mixItems.get(i);
            int[] location = new int[2];
            View renderContainer = mixItem.renderContainer;
            if (renderContainer == null) {
                continue;
            }

            renderContainer.getLocationOnScreen(location);
            int xInGrid = location[0];
            int yInGrid = location[1];

            AlivcLiveMixStream mixStream = new AlivcLiveMixStream();
            mixStream.setUserId(mixItem.userId);

            float scaleRatio = isHeightGrid
                    ? (canvasHeight * 1f / screenHeight)
                    : (canvasWidth * 1f / screenWidth);

            int finalWidth = (int) (renderContainer.getWidth() * scaleRatio);
            int finalHeight = (int) (renderContainer.getHeight() * scaleRatio);

            int scaledScreenWidth = (int) (screenWidth * scaleRatio);
            int scaledScreenHeight = (int) (screenHeight * scaleRatio);
            mixStream.setX((int) (xInGrid * scaleRatio) + (canvasWidth - scaledScreenWidth) / 2);
            mixStream.setY((int) (yInGrid * scaleRatio) + (canvasHeight - scaledScreenHeight) / 2);
            mixStream.setWidth(finalWidth);
            mixStream.setHeight(finalHeight);

            mixStream.setZOrder(mixItem.isAnchor ? 1 : 2);
            mixStreams.add(mixStream);

            Logger.i(TAG, String.format(Locale.getDefault(),
                    "\t%02d: xInGrid=%s, yInGrid=%s", i, xInGrid, yInGrid));
            Logger.i(TAG, String.format(Locale.getDefault(),
                    "\t%02d: %s", i, JSON.toJSONString(mixStream)));
        }

        AlivcLiveTranscodingConfig mixInteractLiveTranscodingConfig = new AlivcLiveTranscodingConfig();
        mixInteractLiveTranscodingConfig.setMixStreams(mixStreams);
        mALivcLivePusher.setLiveMixTranscodingConfig(mixInteractLiveTranscodingConfig);
    }

    // ------------------ 单混切换 [end] ------------------

    /**
     * 创建 AlivcLivePlayer，用于多人连麦互动
     *
     * @param audiencePull 区分 AlivcLivePlayer 的 key
     */
    public boolean createAlivcLivePlayer(String audiencePull) {
        if (mAlivcLivePlayerMap.containsKey(audiencePull)) {
            return false;
        }
        final MultiAlivcLivePlayer alivcLivePlayer = new MultiAlivcLivePlayer(mContext, AlivcLiveMode.AlivcLiveInteractiveMode);
        alivcLivePlayer.setAudienceId(audiencePull);
        alivcLivePlayer.setMultiInteractPlayInfoListener(new MultiInteractLivePushPullListener() {
            @Override
            public void onPullSuccess(String audiencePull) {
            }

            @Override
            public void onPullError(String audiencePull, AlivcLivePlayError errorType, String errorMsg) {
                if (errorType == AlivcLivePlayError.AlivcLivePlayErrorStreamStopped) {
                    if (alivcLivePlayer != null) {
                        alivcLivePlayer.stopPlay();
                    }
                }
            }

            @Override
            public void onPullStop(String audiencePull) {
            }

            @Override
            public void onPushSuccess(String audiencePull) {
            }

            @Override
            public void onPushError(String audiencePull) {
            }
        });
        mAlivcLivePlayerMap.put(audiencePull, alivcLivePlayer);
        return true;
    }

    private void initBeautyManager() {
        if (mBeautyManager == null) {
            Log.d(TAG, "initBeautyManager start");
            // 从v6.2.0开始，基础模式下的美颜，和互动模式下的美颜，处理逻辑保持一致，即：QueenBeautyImpl；
            mBeautyManager = BeautyFactory.createBeauty(BeautySDKType.QUEEN, mContext);
            // initialize in texture thread.
            mBeautyManager.init();
            mBeautyManager.setBeautyEnable(isBeautyEnable);
            mBeautyManager.switchCameraId(mCameraId);
            Log.d(TAG, "initBeautyManager end");
        }
    }

    private void destroyBeautyManager() {
        if (mBeautyManager != null) {
            mBeautyManager.release();
            mBeautyManager = null;
        }
    }

    public interface Callback {

        void onEvent(LiveEvent event, @Nullable Map<String, Object> extras);
    }

    public static class MixItem {
        public String userId;
        public boolean isAnchor;
        public View renderContainer;
    }
}
