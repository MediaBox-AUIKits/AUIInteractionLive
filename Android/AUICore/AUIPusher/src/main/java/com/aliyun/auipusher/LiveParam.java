package com.aliyun.auipusher;

import com.aliyun.auiappserver.model.LiveModel;

import java.io.Serializable;

/**
 * @author puke
 * @version 2021/12/15
 */
public class LiveParam implements Serializable {

    public String liveId;
    public LiveModel liveModel;
    public LiveRole role;
    public String userNick;
    public String userExtension;
    public String notice;
}
