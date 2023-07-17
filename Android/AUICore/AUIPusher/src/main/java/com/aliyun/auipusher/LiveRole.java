package com.aliyun.auipusher;

/**
 * 角色
 */
public enum LiveRole {
    /**
     * 主播
     */
    ANCHOR("anchor"),
    /**
     * 观众
     */
    AUDIENCE("audience"),
    ;

    public final String value;

    LiveRole(String value) {
        this.value = value;
    }

    public static LiveRole ofValue(String value) {
        return ANCHOR.value.equals(value) ? ANCHOR : AUDIENCE;
    }
}