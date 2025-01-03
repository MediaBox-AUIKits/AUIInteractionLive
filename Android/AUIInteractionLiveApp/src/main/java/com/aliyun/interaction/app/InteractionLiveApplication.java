package com.aliyun.interaction.app;

import android.app.Application;

import com.alibaba.android.arouter.launcher.ARouter;

/**
 * @author baorunchen
 * @date 2023/7/7
 * @brief
 */
public class InteractionLiveApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();
        ARouter.init(this);
        AUIInteractionLiveManager.setup();
    }
}
