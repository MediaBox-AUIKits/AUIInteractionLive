package com.alivc.auimessage.model.lwp;

import java.io.Serializable;

/**
 * @author puke
 * @version 2023/4/23
 */
public class GetGroupInfoResponse implements Serializable {

    /**
     * 群组id
     */
    public String groupId;

    /**
     * 在线人数
     */
    public int onlineCount;
}
