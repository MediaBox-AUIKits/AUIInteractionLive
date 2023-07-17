package com.aliyun.interaction.app;

import android.app.Application;

/**
 * @author baorunchen
 * @date 2023/7/7
 * @brief
 */
public class InteractionLiveApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();
        AUIInteractionLiveManager.setup();
    }
}
