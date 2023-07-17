package com.alivc.auimessage;

import android.text.TextUtils;

import com.alivc.auicommon.common.base.log.Logger;

/**
 * {@link MessageService}工厂类
 *
 * @author puke
 * @version 2022/8/31
 */
public class MessageServiceFactory {

    private static final String TAG = "MessageServiceFactory";
    private static MessageService messageService;

    public static MessageService getMessageService() {
        if (messageService != null) {
            return messageService;
        }

        // 注: 为方便AUI中快速切换消息引擎和避免代码改动, 此处使用反射方式来进行实例化
        // 若业务上层确定消息引擎后, 可以直接改为手动new对象的方式, 如下
        // return messageService = new MessageServiceImpl();
        for (ServiceImpl impl : ServiceImpl.values()) {
            String implClassName = impl.className;
            try {
                Class<?> implType = Class.forName(implClassName);
                messageService = (MessageService) implType.newInstance();
                Logger.i(TAG, "The message service's implementation is " + implClassName);
                return messageService;
            } catch (IllegalAccessException | InstantiationException e) {
                throw new RuntimeException(String.format("Instance %s failure", implClassName), e);
            } catch (ClassNotFoundException ignored) {
            }
        }
        throw new RuntimeException("No message service's implementation found in dependencies.");
    }

    public static boolean useInternal() {
        String messageServiceClassName = getMessageService().getClass().getName();
        return TextUtils.equals(messageServiceClassName, ServiceImpl.INTERNAL.className);
    }

    public static boolean useRongCloud() {
        String messageServiceClassName = getMessageService().getClass().getName();
        return TextUtils.equals(messageServiceClassName, ServiceImpl.RONG_CLOUD.className);
    }

    private enum ServiceImpl {
        // 内部SDK
        INTERNAL("com.alivc.auimessage.internal.MessageServiceImpl"),

        // 融云SDK
        RONG_CLOUD("com.alivc.auimessage.rongcloud.MessageServiceImpl"),
        ;

        final String className;

        ServiceImpl(String className) {
            this.className = className;
        }
    }
}
