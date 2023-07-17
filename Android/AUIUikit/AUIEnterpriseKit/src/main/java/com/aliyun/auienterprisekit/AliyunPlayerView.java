package com.aliyun.auienterprisekit;

import android.app.Activity;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.util.AttributeSet;
import android.util.Log;
import android.view.SurfaceView;
import android.view.ViewGroup;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.aliyun.aliinteraction.uikit.uibase.util.ScreenUtils;
import com.cicada.player.utils.Logger;

public class AliyunPlayerView extends RelativeLayout {

    private static final String TAG = AliyunPlayerView.class.getSimpleName();

    private SurfaceView mSurfaceView;

    /**
     * 是否锁定全屏
     */
    private boolean mIsFullScreenLocked = false;

    /**
     * 当前屏幕模式
     */
    private AliyunScreenMode mCurrentScreenMode = AliyunScreenMode.Small;

    /**
     * 锁定竖屏
     */
    private LockPortraitListener mLockPortraitListener = null;


    public AliyunPlayerView(@NonNull Context context) {
        super(context);
    }

    public AliyunPlayerView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public AliyunPlayerView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, null, defStyleAttr);
    }

    public void createRenderView(SurfaceView surfaceView) {
        mSurfaceView = surfaceView;
        addView(mSurfaceView);
    }

    /**
     * 改变屏幕模式：小屏或者全屏。
     *
     * @param targetMode
     */
    public void changeScreenMode(AliyunScreenMode targetMode, boolean isReverse) {
        Log.d(TAG, "mIsFullScreenLocked = " + mIsFullScreenLocked + " ， targetMode = " + targetMode);
        AliyunScreenMode finalScreenMode = targetMode;

        if (mIsFullScreenLocked) {
            finalScreenMode = AliyunScreenMode.Full;
        }

        //这里可能会对模式做一些修改
        if (targetMode != mCurrentScreenMode) {
            mCurrentScreenMode = finalScreenMode;
        }
        Context context = getContext();
        if (context instanceof Activity) {
            if (finalScreenMode == AliyunScreenMode.Full) {
                if (getLockPortraitMode() == null) {
                    if (isReverse) {
                        ((Activity) context).setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE);
                    } else {
                        ((Activity) context).setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
                    }
                } else {
                    //如果是固定全屏，那么直接设置view的布局，宽高
                    ViewGroup.LayoutParams aliVcVideoViewLayoutParams = getLayoutParams();
                    aliVcVideoViewLayoutParams.height = ViewGroup.LayoutParams.MATCH_PARENT;
                    aliVcVideoViewLayoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT;
                    Logger.i(TAG, "aliVcVideoViewLayoutParams = " + aliVcVideoViewLayoutParams.height + " ， aliVcVideoViewLayoutParams = " + aliVcVideoViewLayoutParams.width);

                }

            } else if (finalScreenMode == AliyunScreenMode.Small) {

                if (getLockPortraitMode() == null) {
                    //不是固定竖屏播放。
                    ((Activity) context).setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
                } else {
                    //如果是固定全屏，那么直接设置view的布局，宽高
                    ViewGroup.LayoutParams aliVcVideoViewLayoutParams = getLayoutParams();
                    aliVcVideoViewLayoutParams.height = (int) (ScreenUtils.getWidth(context) * 9.0f / 16);
                    aliVcVideoViewLayoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT;
                    Logger.i(TAG, "aliVcVideoViewLayoutParams = " + aliVcVideoViewLayoutParams.height + " ， aliVcVideoViewLayoutParams = " + aliVcVideoViewLayoutParams.width);
                }
            }
        }
    }

    /**
     * 锁定竖屏
     *
     * @return 竖屏监听器
     */
    public LockPortraitListener getLockPortraitMode() {
        return mLockPortraitListener;
    }

    public void changeScreenMode() {
        AliyunScreenMode targetMode;
        if (mCurrentScreenMode == AliyunScreenMode.Small) {
            targetMode = AliyunScreenMode.Full;
        } else {
            targetMode = AliyunScreenMode.Small;
        }
        changeScreenMode(targetMode, false);
    }


    /**
     * UI 全屏和小屏模式
     */
    public enum AliyunScreenMode {
        /**
         * 小屏模式
         */
        Small,
        /**
         * 全屏模式
         */
        Full
    }


    public interface LockPortraitListener {
        public static final int FIX_MODE_SMALL = 1;
        public static final int FIX_MODE_FULL = 2;

        void onLockScreenMode(int screenMode);
    }
}
