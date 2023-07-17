package com.aliyun.aliinteraction.uikit.adapter;

import androidx.annotation.DrawableRes;
import androidx.annotation.StringRes;

import com.alivc.auicommon.common.base.exposable.PosCallback;

/**
 * Created by KyleCe on 2021/12/29
 */
public class SceneChooserBean {
    @DrawableRes
    public int iconId;
    @StringRes
    public int nameId;

    public PosCallback<Integer> clickResponseAction;

    public SceneChooserBean(int iconId, int nameId, PosCallback<Integer> clickResponseAction) {
        this.iconId = iconId;
        this.nameId = nameId;
        this.clickResponseAction = clickResponseAction;
    }
}
