package com.aliyun.aliinteraction.roompaas.message;

/**
 * {@link AUIMessageService}工厂类
 *
 * @author puke
 * @version 2022/8/31
 */
public class AUIMessageServiceFactory {

    public static AUIMessageService getMessageService(String groupId) {
        return new AUIMessageServiceImpl(groupId);
    }
}
