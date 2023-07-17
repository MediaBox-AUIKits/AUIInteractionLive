package com.aliyuncs.aui.dto.req;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * 获取IM服务Token的请求参数
 * @author chunlei.zcl
 */
@Data
@ApiModel(value = "获取IM服务Token的请求参数")
public class ImTokenRequestDto {
    @ApiModelProperty(value = "用户Id")
    @NotBlank(message="userId不能为空")
    @JsonProperty("user_id")
    private String userId;

    @ApiModelProperty(value = "设备Id")
    @NotBlank(message="deviceId不能为空")
    @JsonProperty("device_id")
    private String deviceId;
    @ApiModelProperty(value = "设备类型")
    @NotBlank(message="deviceType不能为空")
    @JsonProperty("device_type")
    private String deviceType;

}
