package com.aliyun.auipusher.manager;

import static android.os.Environment.MEDIA_MOUNTED;
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

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.alivc.auicommon.common.base.log.Logger;
import com.alivc.auicommon.core.utils.AssetUtil;
import com.alivc.component.custom.AlivcLivePushCustomFilter;
import com.alivc.live.annotations.AlivcLivePushKickedOutType;
import com.alivc.live.pusher.AlivcEncodeModeEnum;
import com.alivc.live.pusher.AlivcLiveBase;
import com.alivc.live.pusher.AlivcLiveBaseListener;
import com.alivc.live.pusher.AlivcLivePushConfig;
import com.alivc.live.pusher.AlivcLivePushConstants;
import com.alivc.live.pusher.AlivcLivePushError;
import com.alivc.live.pusher.AlivcLivePushErrorListener;
import com.alivc.live.pusher.AlivcLivePushInfoListener;
import com.alivc.live.pusher.AlivcLivePushLogLevel;
import com.alivc.live.pusher.AlivcLivePushNetworkListener;
import com.alivc.live.pusher.AlivcLivePushStats;
import com.alivc.live.pusher.AlivcLivePushStatsInfo;
import com.alivc.live.pusher.AlivcLivePusher;
import com.alivc.live.pusher.AlivcPreviewDisplayMode;
import com.alivc.live.pusher.AlivcQualityModeEnum;
import com.alivc.auibeauty.beauty.BeautyFactory;
import com.alivc.auibeauty.beauty.BeautyInterface;
import com.alivc.auibeauty.beauty.constant.BeautySDKType;
import com.aliyun.auipusher.LivePushGlobalConfig;
import com.aliyun.auipusher.config.AliLiveMediaStreamOptions;
import com.aliyun.auipusher.config.AliLivePusherOptions;
import com.aliyun.auipusher.config.CanvasScale;
import com.aliyun.auipusher.config.LiveEvent;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * 媒体推流服务
 */
public class LivePushManager implements AlivcLiveBaseListener {

    private static final String TAG = LivePushManager.class.getSimpleName();
    private final Context mContext;
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
    private AliLivePusherOptions mAliLivePusherOptions;
    private SurfaceView mSurfaceView;
    private boolean isStartPush = false;
    private boolean isPause = false;
    // 当前直播推流地址
    private String mCurrentPublishUrl;
    private Callback callback;
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
            // onEvent(LiveEvent.PUSH_STOPPED);
        }

        @Override
        public void onFirstFramePreviewed(AlivcLivePusher alivcLivePusher) {
            onEvent(LiveEvent.FIRST_FRAME_PREVIEWED);
        }

//        @Override
//        public void onFirstFramePushed(AlivcLivePusher alivcLivePusher) {
//            onEvent(LiveEvent.FIRST_FRAME_PUSHED);
//        }

        @Override
        public void onDropFrame(AlivcLivePusher alivcLivePusher, int i, int i1) {

        }

        @Override
        public void onAdjustBitrate(AlivcLivePusher alivcLivePusher, int curBr, int targetBr) {

        }

        @Override
        public void onAdjustFps(AlivcLivePusher alivcLivePusher, int curFps, int targetFps) {
        }

        @Override
        public void onPushStatistics(AlivcLivePusher alivcLivePusher, AlivcLivePushStatsInfo info) {
            Map<String, Object> extras = new HashMap<>();
            extras.put("v_bitrate", info.getVideoUploadBitrate());
            extras.put("a_bitrate", info.getAudioUploadBitrate());
            onEvent(LiveEvent.UPLOAD_BITRATE_UPDATED, extras);
        }

        @Override
        public void onSetLiveMixTranscodingConfig(AlivcLivePusher alivcLivePusher, boolean b, String s) {

        }

        @Override
        public void onKickedOutByServer(AlivcLivePusher pusher, AlivcLivePushKickedOutType kickedOutType) {

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
    };
    private int mCameraId = Camera.CameraInfo.CAMERA_FACING_FRONT;
    private SurfaceHolder.Callback surfaceViewCallback;
    private AlivcLivePushConfig alivcLivePushConfig;
    private BeautyInterface mBeautyManager;
    private boolean isBeautyEnable = true;

    public LivePushManager(Context context, AliLivePusherOptions aliLivePusherOptions) {
        mContext = context;
        mAliLivePusherOptions = aliLivePusherOptions;
        init();
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

        if (mAliLivePusherOptions == null) {
            alivcLivePushConfig = new AlivcLivePushConfig();
            alivcLivePushConfig.setPreviewDisplayMode(AlivcPreviewDisplayMode.ALIVC_LIVE_PUSHER_PREVIEW_ASPECT_FILL);
        } else {
            alivcLivePushConfig = convertAlivcLivePushConfig(mAliLivePusherOptions);
        }
        alivcLivePushConfig.setExtraInfo(LivePushGlobalConfig.LIVE_PUSH_CONFIG_EXTRA_INFO);

        alivcLivePushConfig.setPausePushImage(getPushPauseImagePath());

        // 日志配置
        AlivcLiveBase.setLogLevel(AlivcLivePushLogLevel.AlivcLivePushLogLevelError);
        AlivcLiveBase.setConsoleEnabled(true);
        String logPath = getFilePath(mContext, "log_path");
        // full log file limited was kLogMaxFileSizeInKB * 5 (parts)
        int maxPartFileSizeInKB = 100 * 1024 * 1024; //100G
        AlivcLiveBase.setLogDirPath(logPath, maxPartFileSizeInKB);

        // 注册sdk
        AlivcLiveBase.setListener(this);
        AlivcLiveBase.registerSDK();

        mALivcLivePusher.init(mContext, alivcLivePushConfig);
        mALivcLivePusher.setLivePushInfoListener(pushInfoListener);
        mALivcLivePusher.setLivePushNetworkListener(pushNetworkListener);
        mALivcLivePusher.setLivePushErrorListener(pushErrorListener);
        // mALivcLivePusher.setCustomFilter();
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
        this.callback = callback;
    }

    protected void onEvent(LiveEvent event) {
        onEvent(event, null);
    }

    protected void onEvent(LiveEvent event, Map<String, Object> extras) {
        if (callback != null) {
            callback.onEvent(event, extras);
        }
    }

    //转换为媒体层AlivcLivePushConfig参数
    private AlivcLivePushConfig convertAlivcLivePushConfig(AliLivePusherOptions options) {
        AlivcLivePushConfig alivcLivePushConfig = new AlivcLivePushConfig();

        AliLiveMediaStreamOptions mediaStreamOptions = options.mediaStreamOptions;
        if (mediaStreamOptions != null) {
            alivcLivePushConfig.setQualityMode(AlivcQualityModeEnum.QM_CUSTOM);
            alivcLivePushConfig.setEnableBitrateControl(true);
            alivcLivePushConfig.setVideoOnly(mediaStreamOptions.isVideoOnly);
            alivcLivePushConfig.setAudioOnly(mediaStreamOptions.isAudioOnly);
            alivcLivePushConfig.setTargetVideoBitrate(mediaStreamOptions.videoBitrate);
            alivcLivePushConfig.setFps(mediaStreamOptions.fps);
            alivcLivePushConfig.setResolution(mediaStreamOptions.getResolution());
            alivcLivePushConfig.setCameraType(mediaStreamOptions.getCameraType());
            alivcLivePushConfig.setVideoEncodeMode(mediaStreamOptions.getEncodeMode());
            alivcLivePushConfig.setVideoEncodeGop(mediaStreamOptions.getEncodeGop());
            alivcLivePushConfig.setPreviewOrientation(mediaStreamOptions.getPreviewOrientation());
            alivcLivePushConfig.setPreviewDisplayMode(mediaStreamOptions.getPreviewDisplayMode());
            switch (mediaStreamOptions.getCameraType()) {
                case CAMERA_TYPE_BACK:
                    mCameraId = CAMERA_TYPE_BACK.getCameraId();
                    break;
                case CAMERA_TYPE_FRONT:
                    mCameraId = CAMERA_TYPE_FRONT.getCameraId();
                    break;
            }
        }
        alivcLivePushConfig.setAudioEncodeMode(AlivcEncodeModeEnum.Encode_MODE_HARD);
        alivcLivePushConfig.setVideoEncodeMode(AlivcEncodeModeEnum.Encode_MODE_HARD);

        return alivcLivePushConfig;
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

        if (mSurfaceView == null) {
            Logger.w(TAG, "resumePublish mSurfaceView is null");
            return;
        }

        // 未预览时, 先开启预览
        if (currentStatus != AlivcLivePushStats.PREVIEWED) {
            if (currentStatus == AlivcLivePushStats.INIT) {
                Logger.i(TAG, "resumePublish start preview");
                doStartPreviewByMediaSdk(mSurfaceView);
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
    public SurfaceView startPublish(String url) {
        if (url == null || url.length() == 0) {
            Logger.e(TAG, "startPublish url must not null");
            return null;
        }
        if (isStartPush
                || (mALivcLivePusher.isPushing() && url.equals(mALivcLivePusher.getPushUrl()))) {
            Logger.i(TAG, "startPublish url is same");
            return mSurfaceView;
        }
        if (mALivcLivePusher.isPushing()) {
            mALivcLivePusher.stopPush();
        }
        mCurrentPublishUrl = url;
        mALivcLivePusher.startPush(url);
        isStartPush = true;
        return mSurfaceView;
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
     * 结束推流
     */
    public void stopPublish() {
        stopPublish(true);
    }

    /**
     * 结束推流
     */
    private void stopPublish(boolean reportEvent) {
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

                if (currentStatus != AlivcLivePushStats.PREVIEWED) {
                    doStartPreviewByMediaSdk(surfaceView);
                }

                resumeLive();
            }

            @Override
            public void surfaceChanged(SurfaceHolder surfaceHolder, int i, int i1, int i2) {

            }

            @Override
            public void surfaceDestroyed(SurfaceHolder surfaceHolder) {
                lastStatus = mALivcLivePusher == null ? null : mALivcLivePusher.getCurrentStatus();
                Logger.i(TAG, String.format("surfaceDestroyed, lastStatus is %s", lastStatus));
                pauseLive(false);
            }
        };
        surfaceView.getHolder().addCallback(surfaceViewCallback);
        return surfaceView;
    }

    private void doStartPreviewByMediaSdk(SurfaceView surfaceView) {
        if (mALivcLivePusher != null) {
            try {
                mALivcLivePusher.startPreview(surfaceView);
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
    public View startPreview() {
        if (mALivcLivePusher == null) {
            init();
        }

        if (mSurfaceView == null) {
            mSurfaceView = createSurfaceView();
        } else {
            doStartPreviewByMediaSdk(mSurfaceView);
        }

        return mSurfaceView;
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
     * 获取预览View
     *
     * @return
     */
    public SurfaceView getAliLiveRenderView() {
        return mSurfaceView;
    }

    /**
     * 销毁直播服务
     */
    public void destroy() {
        stopPublish();

        if (mALivcLivePusher != null) {
            try {
                mALivcLivePusher.destroy();
            } catch (Throwable e) {
                Logger.e(TAG, "destroy error", e);
            }
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
     * 暂停推流
     */
    public void pauseLive() {
        pauseLive(true);
    }

    /**
     * 暂停推流
     */
    private void pauseLive(boolean setPauseState) {
        if (mALivcLivePusher == null) {
            return;
        }

        AlivcLivePushStats pushStats = mALivcLivePusher.getCurrentStatus();
        if (pushStats != AlivcLivePushStats.PUSHED &&
                pushStats != AlivcLivePushStats.PAUSED &&
                pushStats != AlivcLivePushStats.PREVIEWED) {
            return;
        }
        try {
            mALivcLivePusher.pause();
            if (setPauseState) {
                isPause = true;
            }
        } catch (Throwable e) {
            Logger.e(TAG, "pauseLive: error:", e);
        }
    }

    /**
     * 恢复推流
     */
    public void resumeLive() {
        if (mALivcLivePusher == null) {
            return;
        }

        AlivcLivePushStats pushStats = mALivcLivePusher.getCurrentStatus();
        if (pushStats != AlivcLivePushStats.PAUSED &&
                pushStats != AlivcLivePushStats.ERROR) {
            return;
        }
        try {
            mALivcLivePusher.resume();
            isPause = false;
        } catch (Throwable e) {
            Logger.e(TAG, "resumeLive: error", e);
        }
    }

    private void resumeScreenCapture() {
        try {
            mALivcLivePusher.resumeScreenCapture();
        } catch (Throwable e) {
            Logger.e(TAG, "resumeScreenCapture: error:", e);
        }
    }

    private void pauseScreenCapture() {
        try {
            mALivcLivePusher.pauseScreenCapture();
        } catch (Throwable e) {
            Logger.e(TAG, "pauseScreenCapture: error:", e);
        }
    }

    /**
     * 切换摄像头
     */
    public void switchCamera() {
        if (mALivcLivePusher == null || isPushDisable()) {
            return;
        }
        if (mCameraId == CAMERA_TYPE_FRONT.getCameraId()) {
            mCameraId = CAMERA_TYPE_BACK.getCameraId();
        } else {
            mCameraId = CAMERA_TYPE_FRONT.getCameraId();
        }

        mALivcLivePusher.switchCamera();

        if (mBeautyManager != null) {
            mBeautyManager.switchCameraId(mCameraId);
        }
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
        if (isPushDisable()) {
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
        if (isPushDisable()) {
            return;
        }
        mALivcLivePusher.setPushMirror(mirror);
    }

    private boolean isPushDisable() {
        AlivcLivePushStats pushStats = mALivcLivePusher.getCurrentStatus();
        return pushStats != AlivcLivePushStats.PREVIEWED && pushStats != AlivcLivePushStats.PUSHED;
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

    @Override
    public void onLicenceCheck(AlivcLivePushConstants.AlivcLiveLicenseCheckResultCode alivcLiveLicenseCheckResultCode, String s) {

    }
    // endregion listener

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

}
