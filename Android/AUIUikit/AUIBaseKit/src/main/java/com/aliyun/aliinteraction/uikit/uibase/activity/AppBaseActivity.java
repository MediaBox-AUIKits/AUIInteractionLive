package com.aliyun.aliinteraction.uikit.uibase.activity;

import android.content.Context;
import android.os.Bundle;
import android.view.KeyEvent;

import androidx.annotation.Nullable;

import com.alivc.auicommon.core.assist.Assist;

import java.util.concurrent.atomic.AtomicBoolean;

/**
 * 通用Activity, 封装最基础的复用逻辑
 *
 * @author puke
 * @version 2021/5/13
 */
public class AppBaseActivity extends BaseActivity {

    private static final AtomicBoolean isHaInitialized = new AtomicBoolean();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initMoTuAliHaIfNecessary(this);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        // 点击音量减按键, 进入配置页面
        if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
            Assist.openConfigPage(this);
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }


    public void initMoTuAliHaIfNecessary(Context context) {
        if (isHaInitialized.get() || context == null) {
            return;
        }
        isHaInitialized.set(true);
    }
}
