package com.aliyuncs.aui.dto.req;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * RtcAuthTokenRequestDto
 *
 * @author chunlei.zcl
 */
@Data
public class RtcAuthTokenRequestDto {

    @NotBlank(message="roomId不能为空")
    @JsonProperty("room_id")
    private String roomId;

    @JsonProperty("user_id")
    private String userId;

}
