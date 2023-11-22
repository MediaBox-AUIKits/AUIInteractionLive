package com.aliyuncs.aui.dto.req;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * RtcAuthTokenRequestDto
 *
 * @author chunlei.zcl
 */
@Data
public class RtcAuthTokenRequestDto {

    @ApiModelProperty(value = "房间Id")
    @NotBlank(message="roomId不能为空")
    @JsonProperty("room_id")
    private String roomId;

    @ApiModelProperty(value = "用户Id")
    @NotBlank(message="userId不能为空")
    @JsonProperty("user_id")
    private String userId;

}
