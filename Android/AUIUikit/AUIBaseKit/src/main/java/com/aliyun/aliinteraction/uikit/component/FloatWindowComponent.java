package com.aliyun.aliinteraction.uikit.component;

import android.content.Context;
import android.graphics.PixelFormat;
import android.os.Build;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.WindowManager;
import android.widget.LinearLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.aliyun.aliinteraction.uikit.core.BaseComponent;
import com.aliyun.aliinteraction.uikit.core.ComponentHolder;
import com.aliyun.aliinteraction.uikit.core.IComponent;
import com.aliyun.auipusher.LiveContext;
import com.aliyun.player.AliPlayer;
import com.aliyun.player.AliPlayerFactory;
import com.aliyun.player.source.UrlSource;

/**
 * 小窗播放
 */
public class FloatWindowComponent extends LinearLayout implements ComponentHolder {

    private static AliPlayer mAliPlayer;
    private final Component component = new Component();
    private WindowManager mWindowManager;
    private DisplayMetrics mDisplayMetrics;
    private WindowManager.LayoutParams mLayoutParams;
    private Context mContext;
    private SurfaceView mSurfaceView;

    public FloatWindowComponent(Context context) {
        this(context, null, 0);
    }

    public FloatWindowComponent(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public FloatWindowComponent(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initView();
    }

    public static void init(Context context) {
        mAliPlayer = AliPlayerFactory.createAliPlayer(context);
    }

    public static void prepareAndStart(String url) {
        UrlSource urlSource = new UrlSource();
        urlSource.setUri(url);
        mAliPlayer.setDataSource(urlSource);
        mAliPlayer.setAutoPlay(true);
        mAliPlayer.prepare();
    }

    public static void setSurface(SurfaceHolder surfaceHolder) {
        mAliPlayer.setDisplay(null);
        mAliPlayer.setDisplay(surfaceHolder);
    }

    @Override
    public IComponent getComponent() {
        return component;
    }

    private void initView() {
        this.mContext = getContext();
        mAliPlayer = AliPlayerFactory.createAliPlayer(mContext);
        mWindowManager = (WindowManager) mContext.getSystemService(Context.WINDOW_SERVICE);
        mDisplayMetrics = mContext.getResources().getDisplayMetrics();
        mLayoutParams = new WindowManager.LayoutParams(350, 450, 0, 0, PixelFormat.TRANSPARENT);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            mLayoutParams.type = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY;
        } else {
            mLayoutParams.type = WindowManager.LayoutParams.TYPE_SYSTEM_ALERT;
        }
        mLayoutParams.format = PixelFormat.RGBA_8888; //窗口透明
        mLayoutParams.flags = WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL | WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE;
        mLayoutParams.x = mDisplayMetrics.widthPixels - 100;
        mLayoutParams.y = mDisplayMetrics.heightPixels - 100;
        initSurfaceView();
    }

    private void initSurfaceView() {
        mSurfaceView = new SurfaceView(mContext);
        mSurfaceView.getHolder().addCallback(new SurfaceHolder.Callback() {
            @Override
            public void surfaceCreated(@NonNull SurfaceHolder surfaceHolder) {
                setSurface(surfaceHolder);
            }

            @Override
            public void surfaceChanged(@NonNull SurfaceHolder surfaceHolder, int i, int i1, int i2) {

            }

            @Override
            public void surfaceDestroyed(@NonNull SurfaceHolder surfaceHolder) {

            }
        });
    }

    public void showFloatWindow() {
        mWindowManager.addView(mSurfaceView, mLayoutParams);
    }

    public void hideFloatWindow() {
        mWindowManager.removeView(mSurfaceView);
    }

    private class Component extends BaseComponent {
        @Override
        public void onInit(LiveContext liveContext) {
            super.onInit(liveContext);

        }
    }

}
