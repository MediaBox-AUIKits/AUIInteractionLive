package com.aliyuncs.aui.dto.req;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import javax.validation.constraints.NotBlank;
import java.util.List;

/**
 * 获取房间信息
 * @author chunlei.zcl
 */
@Data
@ApiModel(value = "获取房间信息")
public class RoomGetRequestDto {
    @ApiModelProperty(value = "直播间Id")
    @NotBlank(message="直播间Id不能为空")
    private String id;

    @ApiModelProperty(value = "UserId")
    @NotBlank(message="UserId不能为空")
    @JsonProperty("user_id")
    private String userId;

    @ApiModelProperty(value = "im群列表")
    @JsonProperty("im_server")
    private List<String> imServer;
}
