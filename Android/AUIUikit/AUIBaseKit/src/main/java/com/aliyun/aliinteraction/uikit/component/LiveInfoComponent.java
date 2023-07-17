package com.aliyun.aliinteraction.uikit.component;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.aliyun.aliinteraction.uikit.R;
import com.aliyun.aliinteraction.uikit.core.BaseComponent;
import com.aliyun.aliinteraction.uikit.core.ComponentHolder;
import com.aliyun.aliinteraction.uikit.core.IComponent;
import com.aliyun.aliinteraction.uikit.uibase.util.AppUtil;
import com.aliyun.auiappserver.model.LiveModel;
import com.aliyun.auipusher.LiveContext;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * 直播信息视图, 包含主播头像、直播标题、观看人数和点赞数信息
 *
 * @author puke
 * @version 2021/6/30
 */
public class LiveInfoComponent extends RelativeLayout implements ComponentHolder {

    private final Component component = new Component();
    private final TextView title;
    private final TextView anchorNick;
    private final TextView forceView;
    private final ImageView avatarImage;

    public LiveInfoComponent(@NonNull final Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        setMinimumHeight(AppUtil.dp(42));
        setBackgroundResource(R.drawable.ilr_bg_anchor_profile);
        inflate(context, R.layout.ilr_view_live_info, this);
        title = findViewById(R.id.view_title);
        anchorNick = findViewById(R.id.view_anchor);
        forceView = findViewById(R.id.force_view);
        avatarImage = findViewById(R.id.avatar_image);
        forceView.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                if (!"取消".equals(forceView.getText().toString())) {
                    forceView.setText("取消");
                    forceView.setBackgroundResource(R.drawable.ilr_bg_pink_button_radius);
                } else {
                    forceView.setText("+关注");
                    forceView.setBackgroundResource(R.drawable.ilr_bg_orange_button_radius_selector);
                }
            }
        });
    }

    /**
     * 设置标题
     *
     * @param text 标题信息
     */
    public void setTitle(String text) {
        this.title.setText(text);
    }

    public void setAnchorNick(String name) {
        anchorNick.setText(name);
    }

    /**
     * 设置头像
     *
     * @param AvatarUrl
     */
    public void setAvatarImage(String AvatarUrl) {
        switch (AvatarUrl) {
            case "https://img.alicdn.com/imgextra/i1/O1CN01chynzk1uKkiHiQIvE_!!6000000006019-2-tps-80-80.png":
                avatarImage.setBackgroundResource(R.drawable.avatar_1);
                break;
            case "https://img.alicdn.com/imgextra/i4/O1CN01kpUDlF1sEgEJMKHH8_!!6000000005735-2-tps-80-80.png":
                avatarImage.setBackgroundResource(R.drawable.avatar_2);
                break;
            case "https://img.alicdn.com/imgextra/i4/O1CN01ES6H0u21ObLta9mAF_!!6000000006975-2-tps-80-80.png":
                avatarImage.setBackgroundResource(R.drawable.avatar_3);
                break;
            case "https://img.alicdn.com/imgextra/i1/O1CN01KWVPkd1Q9omnAnzAL_!!6000000001934-2-tps-80-80.png":
                avatarImage.setBackgroundResource(R.drawable.avatar_4);
                break;
            case "https://img.alicdn.com/imgextra/i1/O1CN01P6zzLk1muv3zymjjD_!!6000000005015-2-tps-80-80.png":
                avatarImage.setBackgroundResource(R.drawable.avatar_5);
                break;
            case "https://img.alicdn.com/imgextra/i2/O1CN01ZDasLb1Ca0ogtITHO_!!6000000000096-2-tps-80-80.png":
                avatarImage.setBackgroundResource(R.drawable.avatar_6);
                break;
            default:
                avatarImage.setBackgroundResource(R.drawable.avatar_1);
        }
    }

    @Override
    public IComponent getComponent() {
        return component;
    }

    private class Component extends BaseComponent {

        @Override
        public void onInit(LiveContext liveContext) {
            super.onInit(liveContext);
        }

        @Override
        public void onEnterRoomSuccess(LiveModel liveModel) {
            // 进入房间后, 填充房间基本信息
            setTitle(liveModel.title);
            setAnchorNick(liveModel.anchorId);
            if (isOwner()) {
                forceView.setVisibility(View.GONE);
            }
            try {
                JSONObject jsonObject = new JSONObject(liveModel.extend);
                setAvatarImage(jsonObject.optString("userAvatar"));
            } catch (JSONException e) {
                e.printStackTrace();
            }

        }

        @Override
        public void onEvent(String action, Object... args) {

        }
    }
}
