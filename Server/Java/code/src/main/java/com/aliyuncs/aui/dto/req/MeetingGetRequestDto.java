package com.aliyuncs.aui.dto.req;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * 获取连麦信息
 * @author chunlei.zcl
 */
@Data
@ApiModel(value = "获取连麦信息")
public class MeetingGetRequestDto {
    @ApiModelProperty(value = "直播间Id")
    @NotBlank(message="直播间Id不能为空")
    private String id;

}
