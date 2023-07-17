package com.aliyun.auiappserver;

import com.alivc.auimessage.listener.InteractionCallback;

public interface ApiInvoker<T> {

    void invoke(InteractionCallback<T> callback);
}
