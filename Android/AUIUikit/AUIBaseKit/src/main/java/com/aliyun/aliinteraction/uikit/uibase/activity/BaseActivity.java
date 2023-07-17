package com.aliyun.aliinteraction.uikit.uibase.activity;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;
import androidx.appcompat.app.AppCompatActivity;

import com.alivc.auicommon.common.base.util.CommonUtil;
import com.alivc.auicommon.common.base.util.PermissionStrategy;
import com.alivc.auicommon.common.base.util.ThreadUtil;
import com.alivc.auicommon.common.base.util.Utils;
import com.aliyun.aliinteraction.uikit.uibase.util.immersionbar.ImmersionBar;
import com.aliyun.aliinteraction.uikit.uibase.view.IImmersiveSupport;

public abstract class BaseActivity extends AppCompatActivity implements IImmersiveSupport {

    protected Context context;
    private PermissionStrategy permissionStrategy;

    @Override
    protected void attachBaseContext(Context newBase) {
        super.attachBaseContext(newBase);
        context = this;
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (!shouldDisableImmersive()) {
            statusBarProcess(this);
        } else {
            Utils.run(actionWhenDisableImmersive());
        }

        permissionStrategy = new PermissionStrategy(this, parsePermissionArray(), permissionIgnoreStrictCheck()
                , asPermissionGrantedAction(), asPermissionRejectedAction(), asPermissionGuidanceAction());
    }

    @Override
    protected void onResume() {
        super.onResume();
        permissionStrategy.onResume(this);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Utils.destroy(permissionStrategy);
    }

    protected boolean permissionIgnoreStrictCheck() {
        return true;
    }

    protected String[] parsePermissionArray() {
        return new String[0];
    }

    protected Runnable asPermissionGrantedAction() {
        return null;
    }

    protected Runnable asPermissionRejectedAction() {
        return null;
    }

    protected Runnable asPermissionGuidanceAction() {
        return null;
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        permissionStrategy.handleRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    public boolean shouldDisableImmersive() {
        return false;
    }

    protected Runnable actionWhenDisableImmersive() {
        return null;
    }

    private void statusBarProcess(Activity activity) {
        ImmersionBar.with(activity)
                .transparentBar()
                .init();
    }

    protected void showToast(@StringRes int id) {
        CommonUtil.showToast(this, id);
    }

    protected void showToast(String toast) {
        CommonUtil.showToast(this, toast);
    }

    protected void postToMain(@Nullable Runnable task) {
        ThreadUtil.runOnUiThread(task);
    }

    protected void postDelay(@Nullable Runnable task, long delayMillis) {
        ThreadUtil.postDelay(delayMillis, task);
    }

    protected boolean isActivityValid() {
        return !isFinishing() && !isDestroyed();
    }
}
