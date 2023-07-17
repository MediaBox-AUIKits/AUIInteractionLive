package com.aliyun.aliinteraction.uikit.uibase.helper;

import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.alivc.auimessage.MessageService;
import com.alivc.auimessage.MessageServiceFactory;
import com.alivc.auimessage.listener.InteractionCallback;
import com.alivc.auimessage.model.base.AUIMessageUserInfo;
import com.alivc.auimessage.model.base.InteractionError;

/**
 * IM登录辅助类
 *
 * @author puke
 * @version 2023/1/11
 */
public class IMLoginHelper {

    private static boolean isLoginPending;

    public static void login(@NonNull final AUIMessageUserInfo userInfo, final InteractionCallback<Void> callback) {
        String userId = userInfo.userId;
        if (TextUtils.isEmpty(userId)) {
            if (callback != null) {
                callback.onError(new InteractionError("用户Id不能为空"));
            }
            return;
        }

        if (isLoginPending) {
            if (callback != null) {
                callback.onError(new InteractionError("正在进行登录操作, 请稍等"));
            }
            return;
        }

        isLoginPending = true;
        MessageService messageService = MessageServiceFactory.getMessageService();
        AUIMessageUserInfo currentUserInfo = messageService.getCurrentUserInfo();
        if (messageService.isLogin() && currentUserInfo != null) {
            // 1. 已登录, 检查是不是同一个userId
            if (TextUtils.equals(userId, currentUserInfo.userId)) {
                // 1.1 是同一个, 直接回调成功
                isLoginPending = false;
                if (callback != null) {
                    callback.onSuccess(null);
                }
            } else {
                // 1.2 不是同一个, 先登出旧的
                messageService.logout(new InteractionCallback<Void>() {
                    @Override
                    public void onSuccess(Void unused) {
                        // 1.2.1 再登入新的
                        performLogin(userInfo, callback);
                    }

                    @Override
                    public void onError(InteractionError error) {
                        // 1.2.2 登出失败, 回调失败信息出去
                        isLoginPending = false;
                        if (callback != null) {
                            callback.onError(error);
                        }
                    }
                });
            }
        } else {
            // 2. 未登录, 直接登录
            performLogin(userInfo, callback);
        }
    }

    private static void performLogin(final AUIMessageUserInfo userInfo, final InteractionCallback<Void> callback) {
        MessageService messageService = MessageServiceFactory.getMessageService();
        messageService.login(userInfo, new InteractionCallback<Void>() {
            @Override
            public void onSuccess(Void data) {
                isLoginPending = false;
                if (callback != null) {
                    callback.onSuccess(null);
                }
            }

            @Override
            public void onError(InteractionError error) {
                isLoginPending = false;
                if (callback != null) {
                    callback.onError(error);
                }
            }
        });
    }
}
