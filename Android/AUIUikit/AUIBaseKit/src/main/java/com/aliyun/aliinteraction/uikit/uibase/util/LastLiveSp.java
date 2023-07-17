package com.aliyun.aliinteraction.uikit.uibase.util;

import com.aliyun.aliinteraction.uikit.uibase.helper.SpHelper;

import java.io.Serializable;

/**
 * @author puke
 * @version 2021/5/24
 */
@SpHelper.Sp
public interface LastLiveSp extends Serializable {

    LastLiveSp INSTANCE = SpHelper.getInstance(LastLiveSp.class);

    @SpHelper.Getter()
    String getLastLiveId();

    @SpHelper.Setter
    void setLastLiveId(String lastLiveId);

    @SpHelper.Getter()
    String getLastLiveAnchorId();

    @SpHelper.Setter
    void setLastLiveAnchorId(String lastLiveAnchorId);
}
