package com.aliyun.interaction.app;

import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.InputFilter;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.core.widget.ContentLoadingProgressBar;

import com.alivc.auicommon.common.roombase.Const;
import com.aliyun.aliinteraction.app.R;
import com.aliyun.aliinteraction.uikit.uibase.activity.BaseFragment;
import com.aliyun.aliinteraction.uikit.uibase.util.AppUtil;
import com.aliyun.aliinteraction.uikit.uibase.util.ExStatusBarUtils;
import com.aliyun.aliinteraction.uikit.uibase.util.UserHelper;
import com.aliyun.aliinteraction.uikit.uibase.util.ViewUtil;
import com.aliyun.auiappserver.AppServerTokenManager;
import com.alivc.auimessage.listener.InteractionCallback;
import com.alivc.auimessage.model.base.InteractionError;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by KyleCe on 2021/7/9
 */
public class LiveLoginFragment extends BaseFragment {
    public static final String TAG = "LiveLoginFragment";
    //限制只能输入中文，英文，数字
    InputFilter typeFilter = new InputFilter() {
        @Override
        public CharSequence filter(CharSequence source, int start, int end, Spanned dest, int dstart, int dend) {
            Pattern p = Pattern.compile("[0-9a-zA-Z|\u4e00-\u9fa5]+");
            Matcher m = p.matcher(source.toString());
            if (!m.matches()) return "";
            return null;
        }
    };
    private EditText userIdInput;
    private View loginButton;
    private ContentLoadingProgressBar loading;
    private TextView tips;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ExStatusBarUtils.setStatusBarColor(getActivity(), AppUtil.getColor(R.color.bus_login_status_bar_color));
    }

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_live_start;
    }

    @Override
    protected void onCreateViewProcess(@Nullable View view) {
        if (view == null) {
            return;
        }
        tips = view.findViewById(R.id.form_user_id_tips);
        userIdInput = view.findViewById(R.id.form_user_id);
        userIdInput.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (count == 0) {
                    loginButton.setBackgroundResource(R.drawable.ilr_bg_orange_button_radius_enable);
                    loginButton.setEnabled(false);
                    tips.setVisibility(View.GONE);
                } else {
                    tips.setVisibility(View.VISIBLE);
                    loginButton.setEnabled(true);
                    loginButton.setBackgroundResource(R.drawable.ilr_bg_orange_button_radius_selector);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });
        loginButton = view.findViewById(R.id.loginButton);
        loading = view.findViewById(R.id.loading);
        userIdInput.setFilters(new InputFilter[]{typeFilter});

        String currentUserId = Const.getUserId();
        String userId = TextUtils.isEmpty(currentUserId) ? UserHelper.parseUserId() : currentUserId;
        ViewUtil.applyText(userIdInput, userId);

        loginButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                loading.show();
                final String userId = userIdInput.getText().toString();
                AppServerTokenManager.login(userId, userId, new InteractionCallback<Void>() {
                    @Override
                    public void onSuccess(Void data) {
                        loading.hide();
                        Const.setUserId(userId);
                        Intent intent = new Intent(context, RoomListActivity.class);
                        if (context != null) {
                            context.startActivity(intent);
                        }
                        enableInput();
                    }

                    @Override
                    public void onError(InteractionError error) {
                        loading.hide();
                        showToast(error.msg);
                    }
                });
            }
        });

    }

    private void disableInput() {
        ViewUtil.disableView(userIdInput, loginButton);
    }

    private void enableInput() {
        ViewUtil.enableView(userIdInput, loginButton);
    }
}
