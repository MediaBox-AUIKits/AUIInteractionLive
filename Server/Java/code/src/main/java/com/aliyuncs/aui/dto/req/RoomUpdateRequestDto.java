package com.aliyuncs.aui.dto.req;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * 修改房间信息
 * @author chunlei.zcl
 */
@Data
@ApiModel(value = "修改房间信息")
public class RoomUpdateRequestDto {
    @ApiModelProperty(value = "直播间Id")
    @NotBlank(message="直播间Id不能为空")
    private String id;

    @ApiModelProperty(value = "Title")
    @JsonProperty("title")
    private String title;

    @ApiModelProperty(value = "Notice")
    @JsonProperty("notice")
    private String notice;

    @ApiModelProperty(value = "Extends")
    @JsonProperty("extends")
    private String extendsInfo;

}
