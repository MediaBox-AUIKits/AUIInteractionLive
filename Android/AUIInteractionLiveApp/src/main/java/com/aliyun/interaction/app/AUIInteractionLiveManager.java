package com.aliyun.interaction.app;

import com.aliyun.auiappserver.RetrofitManager;
import com.aliyun.common.AlivcBase;

/**
 * @author baorunchen
 * @date 2023/7/12
 * @brief 互动直播启动配置
 * @note 建议在application中进行初始化调用
 */
public class AUIInteractionLiveManager {

    private static final String TAG_PROJECT_INTERACTION_LIVE = "aui-live-interaction";

    private AUIInteractionLiveManager() {
    }

    /**
     * 启动配置
     */
    public static void setup() {
        AlivcBase.setIntegrationWay(TAG_PROJECT_INTERACTION_LIVE);
        setupAppServerUrl();
    }

    private static void setupAppServerUrl() {
        RetrofitManager.setAppServerUrl(RetrofitManager.Const.APP_SERVER_URL_DEFAULT);
    }
}
