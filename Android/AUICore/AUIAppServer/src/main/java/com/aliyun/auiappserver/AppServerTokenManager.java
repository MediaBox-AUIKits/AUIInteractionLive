package com.aliyun.auiappserver;

import android.text.TextUtils;

import com.alivc.auicommon.common.base.util.CommonUtil;
import com.aliyun.auiappserver.model.AppServerToken;
import com.aliyun.auiappserver.model.LoginRequest;
import com.aliyun.auiappserver.model.Token;
import com.aliyun.auiappserver.model.TokenRequest;
import com.alivc.auimessage.MessageServiceFactory;
import com.alivc.auimessage.listener.InteractionCallback;
import com.alivc.auimessage.model.base.InteractionError;

public class AppServerTokenManager {

    private static String username;
    private static String password;
    private static String appServerToken;

    public static String getAppServerToken() {
        return appServerToken;
    }

    public static void login(final String username, final String password, final InteractionCallback<Void> callback) {
        LoginRequest request = new LoginRequest();
        request.username = username;
        request.password = password;
        AppServerApi.instance().login(request).invoke(new InteractionCallback<AppServerToken>() {
            @Override
            public void onSuccess(AppServerToken data) {
                appServerToken = data.token;
                AppServerTokenManager.username = username;
                AppServerTokenManager.password = password;
                if (callback != null) {
                    callback.onSuccess(null);
                }
            }

            @Override
            public void onError(InteractionError error) {
                if (callback != null) {
                    callback.onError(error);
                }
            }
        });
    }

    public static void refreshToken(final InteractionCallback<Void> callback) {
        if (TextUtils.isEmpty(username) || TextUtils.isEmpty(password)) {
            if (callback != null) {
                callback.onError(new InteractionError("Auth message is empty"));
            }
        } else {
            login(username, password, callback);
        }
    }

    public static void fetchToken(String userId, final InteractionCallback<String> interactionCallback) {
        if (!MessageServiceFactory.useInternal() && !MessageServiceFactory.useRongCloud()) {
            throw new RuntimeException("Not support");
        }
        TokenRequest request = new TokenRequest();
        request.userId = userId;
        request.deviceId = CommonUtil.getDeviceId();
        request.deviceType = "android";
        ApiService apiService = AppServerApi.instance();
        apiService.fetchToken(request).invoke(new InteractionCallback<Token>() {
            @Override
            public void onSuccess(Token token) {
                if (interactionCallback != null) {
                    if (MessageServiceFactory.useInternal()) {
                        interactionCallback.onSuccess(String.format("%s_%s", token.accessToken, token.refreshToken));
                    } else if (MessageServiceFactory.useRongCloud()) {
                        // 注意：消息组件的live/token接口，融云方案的app server和内部方案的app server地址不一样，后面需要统一掉.
                        interactionCallback.onSuccess(token.accessToken);
                    } else {
                        interactionCallback.onError(new InteractionError("fetch token failed with error type."));
                    }
                }
            }

            @Override
            public void onError(InteractionError error) {
                if (interactionCallback != null) {
                    interactionCallback.onError(error);
                }
            }
        });
    }
}
