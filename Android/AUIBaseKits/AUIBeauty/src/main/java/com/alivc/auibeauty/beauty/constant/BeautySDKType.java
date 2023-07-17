package com.alivc.auibeauty.beauty.constant;

/**
 * 美颜具体类型
 *
 * @note 由于beauty模块是插件化，因此beauty实例是通过反射进行实例化，请注意修改美颜具体实现（impl）类名，以免出现美颜初始化失败导致美颜失效的问题
 */
public enum BeautySDKType {
    // should be kept!
    QUEEN(BeautyConstant.BEAUTY_QUEEN_MANAGER_CLASS_NAME);

    private final String implClassName;

    BeautySDKType(String implClassName) {
        this.implClassName = implClassName;
    }

    public String getImplClassName() {
        return implClassName;
    }
}
