package com.aliyuncs.aui.dto.req;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * 删除房间信息
 * @author chunlei.zcl
 */
@Data
@ApiModel(value = "删除房间信息")
public class RoomDeleteRequestDto {
    @ApiModelProperty(value = "直播间Id")
    @NotBlank(message="直播间Id不能为空")
    private String id;

    @ApiModelProperty(value = "UserId")
    @NotBlank(message="UserId不能为空")
    @JsonProperty("user_id")
    private String userId;

}
