package com.aliyun.auiappserver;


public abstract class AppServerApi implements ApiService {

    public static ApiService instance() {
        return RetrofitManager.getService(ApiService.class);
    }
}
