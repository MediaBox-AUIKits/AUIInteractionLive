package com.aliyun.aliinteraction.uikit.core;


import android.Manifest;

import com.alivc.auicommon.common.roombase.Const;

/**
 * @author puke
 * @version 2021/5/13
 */
public class LiveConst extends Const implements LivePermissionConst {

    public static final String SYSTEM_NOTICE_NICKNAME = "";
    public static final String SYSTEM_NOTICE_ALERT = "欢迎大家来到直播间！直播间内严禁出现违法违规、低俗色情、吸烟酗酒等内容，若有违规行为请及时举报。";

    public static final String PARAM_KEY_LIVE_PARAM = getSdkKey("live_param");

    // 主播权限
    public static final String[] PERMISSIONS_4_ANCHOR = PERMISSIONS_4_LINKER;

    // 普通直播的观众权限
    public static final String[] PERMISSIONS_4_AUDIENCE = {
    };

    // 连麦直播的观众权限
    public static final String[] PERMISSIONS_4_AUDIENCE_OF_LINK_MIC = {
            Manifest.permission.CAMERA,
            Manifest.permission.RECORD_AUDIO,
    };
}
