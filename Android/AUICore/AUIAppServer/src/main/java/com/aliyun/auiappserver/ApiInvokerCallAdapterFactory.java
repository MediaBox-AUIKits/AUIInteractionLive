package com.aliyun.auiappserver;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.alivc.auicommon.common.base.AppContext;
import com.alivc.auicommon.common.base.log.Logger;
import com.alivc.auimessage.MessageServiceFactory;
import com.alivc.auimessage.listener.InteractionCallback;
import com.alivc.auimessage.listener.InteractionUICallback;
import com.alivc.auimessage.model.base.InteractionError;

import java.io.IOException;
import java.lang.annotation.Annotation;
import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;

import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.CallAdapter;
import retrofit2.Response;
import retrofit2.Retrofit;

class ApiInvokerCallAdapterFactory extends CallAdapter.Factory {

    public static boolean isNetworkInvalid(Context context) {
        return !isNetworkAvailable(context);
    }

    public static boolean isNetworkAvailable(Context context) {
        if (context == null) {
            return false;
        }
        ConnectivityManager connectivityManager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo activeNetworkInfo = connectivityManager.getActiveNetworkInfo();
        return activeNetworkInfo != null && activeNetworkInfo.isAvailable();
    }

    @Override
    public CallAdapter<?, ?> get(@NonNull Type returnType, @NonNull Annotation[] annotations,
                                 @NonNull Retrofit retrofit) {
        if (returnType instanceof ParameterizedType
                && ((ParameterizedType) returnType).getRawType() == ApiInvoker.class) {
            Type responseType = getParameterUpperBound(0, (ParameterizedType) returnType);
            return new CallAdapterForApiInvoker<>(responseType);
        }
        return null;
    }

    private static class CallAdapterForApiInvoker<R> implements CallAdapter<R, ApiInvoker<R>> {

        final Type responseType;

        CallAdapterForApiInvoker(Type responseType) {
            this.responseType = responseType;
        }

        @NonNull
        @Override
        public Type responseType() {
            return responseType;
        }

        @NonNull
        @Override
        public ApiInvoker<R> adapt(@NonNull final Call<R> call) {
            return new ApiInvoker<R>() {
                @Override
                public void invoke(final InteractionCallback<R> callback) {
                    InteractionUICallback<R> uiCallback = new InteractionUICallback<>(callback);
                    call.enqueue(new retrofit2.Callback<R>() {
                        @Override
                        public void onResponse(@NonNull Call<R> call, @NonNull Response<R> response) {
                            int httpCode = response.code();
                            Logger.w("ApiRequest", "[RESP] " + call.request().url() + " [" + httpCode + "][" + response.message() + "]");
                            switch (httpCode) {
                                case 200:
                                    R body = response.body();
                                    uiCallback.onSuccess(body);
                                    break;
                                case 401:
                                    if (MessageServiceFactory.getMessageService().isLogin()) {
                                        // AppServer的token过期
                                        AppServerTokenManager.refreshToken(new InteractionCallback<Void>() {
                                            @Override
                                            public void onSuccess(Void unused) {
                                                // 刷新token后再次请求
                                                invoke(uiCallback);
                                            }

                                            @Override
                                            public void onError(InteractionError error) {
                                                uiCallback.onError(error);
                                            }
                                        });
                                    } else {
                                        // 登录失败
                                        uiCallback.onError(new InteractionError("用户名或密码错误"));
                                    }
                                    break;
                                default:
                                    String msg = "http code is " + httpCode;
                                    ResponseBody responseBody = response.errorBody();
                                    if (responseBody != null) {
                                        try {
                                            String serverMsg = responseBody.string();
                                            if (!TextUtils.isEmpty(serverMsg)) {
                                                msg = serverMsg;
                                            }
                                        } catch (IOException ignored) {
                                        }
                                    }
                                    uiCallback.onError(new InteractionError(msg));
                                    break;
                            }
                        }

                        @Override
                        public void onFailure(@NonNull Call<R> call, @NonNull Throwable t) {
                            boolean networkInvalid = isNetworkInvalid(AppContext.getContext());
                            Logger.e("ApiRequest", "[RESP] " + call.request().url() + " [networkInvalid: " + networkInvalid + "][" + t.getMessage() + "]");
                            if (networkInvalid) {
                                uiCallback.onError(new InteractionError("当前网络不可用，请检查后再试"));
                            } else {
                                uiCallback.onError(new InteractionError(t.getMessage()));
                            }
                        }
                    });
                }
            };
        }
    }
}
