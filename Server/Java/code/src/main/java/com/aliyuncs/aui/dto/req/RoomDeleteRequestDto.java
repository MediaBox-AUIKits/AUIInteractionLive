package com.aliyuncs.aui.dto.req;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * 删除房间信息
 * @author chunlei.zcl
 */
@Data
public class RoomDeleteRequestDto {
    @NotBlank(message="直播间Id不能为空")
    private String id;

    @NotBlank(message="UserId不能为空")
    @JsonProperty("user_id")
    private String userId;

}
