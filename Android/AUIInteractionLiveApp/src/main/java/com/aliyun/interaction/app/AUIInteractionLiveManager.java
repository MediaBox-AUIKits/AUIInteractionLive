package com.aliyun.interaction.app;

import com.aliyun.aliinteraction.app.BuildConfig;
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

    private static final String BUILD_IM_TYPE_RONGCLOUD = "rongcloud";

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
        if (BUILD_IM_TYPE_RONGCLOUD.equals(BuildConfig.BUILD_IM_TYPE)) {
            RetrofitManager.setAppServerUrl(RetrofitManager.Const.APP_SERVER_URL_RONG_CLOUD);
        } else {
            RetrofitManager.setAppServerUrl(RetrofitManager.Const.APP_SERVER_URL_ALIVC);
        }
    }
}
