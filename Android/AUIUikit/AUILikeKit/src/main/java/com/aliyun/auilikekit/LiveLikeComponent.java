package com.aliyun.auilikekit;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.alivc.auicommon.common.base.log.Logger;
import com.alivc.auicommon.common.base.util.Utils;
import com.aliyun.aliinteraction.roompaas.message.helper.LikeHelper;
import com.aliyun.aliinteraction.uikit.core.BaseComponent;
import com.aliyun.aliinteraction.uikit.core.ComponentHolder;
import com.aliyun.aliinteraction.uikit.core.IComponent;
import com.aliyun.aliinteraction.uikit.uibase.util.AppUtil;
import com.aliyun.aliinteraction.uikit.uibase.util.ViewUtil;
import com.aliyun.auipusher.LiveContext;
import com.alivc.auimessage.listener.InteractionCallback;
import com.alivc.auimessage.model.base.InteractionError;

import java.lang.ref.WeakReference;

/**
 * 点赞视图
 *
 * @author puke
 * @version 2021/7/29
 */
public class LiveLikeComponent extends FrameLayout implements ComponentHolder, Handler.Callback {
    public static final String TAG = "LiveLikeView";
    private static final int MSG_LIKE = 0;
    private static int screenWidth;
    private static int screenHeight;
    private final Component component = new Component();
    private final LikeHelper likeHelper;
    private final Context context;
    private final int[] LIKE_RES_ID_ARRAY = {
            R.drawable.ilr_icon_like_clicked_0,
            R.drawable.ilr_icon_like_clicked_1,
            R.drawable.ilr_icon_like_clicked_2,
            R.drawable.ilr_icon_like_clicked_3,
            R.drawable.ilr_icon_like_clicked_4,
            R.drawable.ilr_icon_like_clicked_5,
    };
    private final Handler handler;
    private Drawable[] likeDrawables;
    private boolean longPressBegin;
    private boolean longPressLikeSent;

    public LiveLikeComponent(@NonNull Context context) {
        this(context, null, 0);
    }

    public LiveLikeComponent(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public LiveLikeComponent(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        this.context = context;
        setClipChildren(false);
        View.inflate(context, R.layout.ilr_view_live_like, this);
        View likeIcon = findViewById(R.id.likeIcon);

        handler = new Handler(Looper.getMainLooper(), this);
        likeHelper = new LikeHelper(new LikeHelper.Callback() {
            @Override
            public void onRequest(int likeCount) {
                component.doSendLike(likeCount);
            }
        });

        likeIcon.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                LiveLikeComponent.this.onLike();
            }
        });

        likeIcon.setOnLongClickListener(new OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                longPressBegin = true;
                handler.sendEmptyMessageDelayed(MSG_LIKE, 50);
                return true;
            }
        });

        likeIcon.setOnTouchListener(new OnTouchListener() {
            @SuppressLint("ClickableViewAccessibility")
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if (event.getAction() == MotionEvent.ACTION_UP || event.getAction() == MotionEvent.ACTION_CANCEL) {
                    longPressBegin = false;
                    longPressLikeSent = false;
                }
                return false;
            }
        });
    }

    private void onLike() {
        animView();
        if (longPressBegin) {
            if (longPressLikeSent) {
                return;
            }
            longPressLikeSent = true;
        }
        likeHelper.doLike();
    }

    public void animView() {
        ImageView iv = new ImageView(context);
        iv.setImageDrawable(randomLikeDrawable());
        addView(iv);

        int sw = ofScreenWidth();
        int sh = ofScreenHeight();

        float ratioX = Utils.random(5, 0) / 10f;
        float ratioY = Utils.random(9, 3) / 10f;

        float positionXPoint = getX() / sw * 10;
        int score4LR = Utils.random(10, 1);
        int factorXLR = score4LR > positionXPoint ? 1 : -1;

        final WeakReference<ImageView> weakRefIV = new WeakReference<>(iv);
        iv.animate().scaleX(2f).scaleY(2f).translationX(factorXLR * ratioX * sw).translationY(-ratioY * sh).setDuration(1600).alpha(.5f)
                .withEndAction(new Runnable() {
                    @Override
                    public void run() {
                        ImageView v = Utils.getRef(weakRefIV);
                        if (v != null) {
                            ViewUtil.removeSelfSafely(v);
                            Utils.clear(v);
                            Logger.i(TAG, "resource cleared after anim");
                        }
                    }
                });
    }

    private int ofScreenWidth() {
        if (screenWidth == 0) {
            screenWidth = AppUtil.getScreenWidth();
        }
        return screenWidth;
    }

    private int ofScreenHeight() {
        if (screenHeight == 0) {
            screenHeight = AppUtil.getScreenHeight();
        }
        return screenHeight;
    }


    private Drawable randomLikeDrawable() {
        return ofLikeDrawable()[Utils.random(LIKE_RES_ID_ARRAY.length - 1, 0)];
    }

    private Drawable[] ofLikeDrawable() {
        if (likeDrawables == null) {
            likeDrawables = new Drawable[LIKE_RES_ID_ARRAY.length];
            for (int i = 0; i < LIKE_RES_ID_ARRAY.length; i++) {
                likeDrawables[i] = AppUtil.getDrawable(LIKE_RES_ID_ARRAY[i]);
            }
        }

        return likeDrawables;
    }

    @Override
    public boolean handleMessage(@NonNull Message msg) {
        switch (msg.what) {
            case MSG_LIKE:
                if (!longPressBegin) {
                    Utils.clear(handler);
                    break;
                }
                onLike();
                handler.sendEmptyMessageDelayed(MSG_LIKE, 50);
                break;
            default:
                break;
        }
        return false;
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        likeDrawables = null;
        likeHelper.release();
        Utils.clear(handler);
    }

    @Override
    public IComponent getComponent() {
        return component;
    }

    private class Component extends BaseComponent {

        @Override
        public void onInit(LiveContext liveContext) {
            super.onInit(liveContext);
            setVisibility(isOwner() ? GONE : VISIBLE);
        }

        private void doSendLike(int likeCount) {
            getMessageService().sendLike(likeCount, new InteractionCallback<String>() {
                @Override
                public void onSuccess(String data) {

                }

                @Override
                public void onError(InteractionError interactionError) {
                    showToast("点赞失败, " + interactionError);
                }
            });
        }
    }
}
