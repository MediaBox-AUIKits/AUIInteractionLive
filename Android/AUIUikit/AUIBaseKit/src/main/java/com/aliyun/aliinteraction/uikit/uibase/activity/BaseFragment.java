package com.aliyun.aliinteraction.uikit.uibase.activity;


import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.alivc.auicommon.common.base.util.CommonUtil;

/**
 * Created by KyleCe on 2021/7/9
 */
public abstract class BaseFragment extends Fragment {

    @Nullable
    protected Context context;
    protected View inflatedView;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        context = getContext();
        super.onCreate(savedInstanceState);
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        int layoutId = getLayoutId();
        if (layoutId > 0) {
            inflatedView = inflater.inflate(layoutId, container, true);
        }
        onCreateViewProcess(inflatedView);
        return super.onCreateView(inflater, container, savedInstanceState);
    }

    protected abstract int getLayoutId();

    protected abstract void onCreateViewProcess(@Nullable View inflatedView);

    protected void showToast(String toast) {
        CommonUtil.showToast(context, toast);
    }
}
