package com.aliyuncs.aui.dto.req;

import lombok.Data;

/**
 * 推流事件
 *
 * @author chunlei.zcl
 */
@Data
public class LivePushStreamEventRequestDto {

    private String action;
    private String app;
    private String ip;
    private String id;
    private String appname;
    private Integer time;
    private String height;
    private String width;
    private String liveSignature;
    private String liveTimestamp;
}
