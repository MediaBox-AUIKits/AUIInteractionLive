package com.aliyun.auiappserver;

import android.text.TextUtils;

import com.alivc.auicommon.common.base.log.Logger;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

import okhttp3.Interceptor;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import retrofit2.Retrofit;
import retrofit2.converter.jackson.JacksonConverterFactory;

@SuppressWarnings({"FieldMayBeFinal"})
public class RetrofitManager {
    private static Retrofit sRetrofit;
    private static String sAPPServerUrl;
    private static String sEnv = "production";

    static <T> T getService(Class<T> serviceType) {
        return getRetrofit().create(serviceType);
    }

    /**
     * 外部设置app server地址
     *
     * @param serverUrl app server地址
     */
    public static void setAppServerUrl(String serverUrl) {
        sAPPServerUrl = serverUrl;
    }

    private static Retrofit getRetrofit() {
        if (sRetrofit == null) {
            sRetrofit = new Retrofit.Builder()
                    .baseUrl(sAPPServerUrl)
                    .addConverterFactory(JacksonConverterFactory.create())
                    .addCallAdapterFactory(new ApiInvokerCallAdapterFactory())
                    .client(new OkHttpClient.Builder()
                            .connectTimeout(5, TimeUnit.SECONDS)
                            .readTimeout(10, TimeUnit.SECONDS)
                            .addInterceptor(new Interceptor() {
                                @Override
                                public Response intercept(Chain chain) throws IOException {
                                    Request oldRequest = chain.request();
                                    MediaType contentType = MediaType.get("application/json");
                                    Request.Builder headerBuilder = oldRequest.newBuilder()
                                            .post(new ContentTypeOverridingRequestBody(oldRequest.body(), contentType))
                                            .header("x-live-env", sEnv);
                                    String appServerToken = AppServerTokenManager.getAppServerToken();
                                    if (!TextUtils.isEmpty(appServerToken)) {
                                        headerBuilder.addHeader("Authorization", "Bearer " + appServerToken);
                                    }
                                    Request request = headerBuilder.build();
                                    Logger.i("ApiRequest", "[REQ] " + request.url() + " [" + sEnv + "]");
                                    return chain.proceed(request);
                                }
                            })
                            .build()
                    )
                    .build();
        }
        return sRetrofit;
    }

    /**
     * TODO: 请在此处填写您已搭建好的APP Server地址
     */
    public static class Const {
        /**
         * The default URL for the APP Server.
         * This URL is used for both Interactive Live and Enterprise Live services.
         * <p>
         * Note: Ensure this URL is updated according to the server configuration you deploy.
         */
        public static final String APP_SERVER_URL_DEFAULT = "";
    }
}
