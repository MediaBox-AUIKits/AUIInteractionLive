package com.aliyuncs.aui.dto.req;

import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * 获取连麦信息
 * @author chunlei.zcl
 */
@Data
public class MeetingGetRequestDto {
    @NotBlank(message="直播间Id不能为空")
    private String id;

}
