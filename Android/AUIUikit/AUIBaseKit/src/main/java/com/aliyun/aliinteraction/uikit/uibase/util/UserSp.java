package com.aliyun.aliinteraction.uikit.uibase.util;

import com.aliyun.aliinteraction.uikit.uibase.helper.SpHelper;

import java.io.Serializable;

/**
 * @author puke
 * @version 2021/5/24
 */
@SpHelper.Sp
public interface UserSp extends Serializable {

    @SpHelper.Getter
    String getUserId();

    @SpHelper.Setter
    void setUserId(String userId);

    @SpHelper.Getter
    String getNick();

    @SpHelper.Setter
    void setNick(String nick);
}
