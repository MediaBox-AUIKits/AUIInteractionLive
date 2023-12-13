package com.aliyun.auiappserver;

import android.text.TextUtils;

import com.alivc.auicommon.common.base.util.CommonUtil;
import com.alivc.auimessage.MessageServiceFactory;
import com.alivc.auimessage.listener.InteractionCallback;
import com.alivc.auimessage.model.base.InteractionError;
import com.aliyun.auiappserver.model.AppServerToken;
import com.aliyun.auiappserver.model.LoginRequest;
import com.aliyun.auiappserver.model.Token;
import com.aliyun.auiappserver.model.TokenRequest;

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

    public static void fetchToken(String userId, final InteractionCallback<Token> interactionCallback) {
        if (!MessageServiceFactory.isMessageServiceValid()) {
            throw new RuntimeException("Not support");
        }

        TokenRequest request = new TokenRequest();
        request.userId = userId;
        request.deviceId = CommonUtil.getDeviceId();
        request.imServer.add("aliyun_new");
        ApiService apiService = AppServerApi.instance();
        apiService.fetchToken(request).invoke(new InteractionCallback<Token>() {
            @Override
            public void onSuccess(Token token) {
                if (interactionCallback == null) {
                    return;
                }
                if (token == null) {
                    interactionCallback.onError(new InteractionError("fetch token failed with null data."));
                    return;
                }
                interactionCallback.onSuccess(token);
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
