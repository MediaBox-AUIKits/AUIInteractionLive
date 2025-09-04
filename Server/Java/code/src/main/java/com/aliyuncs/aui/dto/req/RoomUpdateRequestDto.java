package com.aliyuncs.aui.dto.req;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * 修改房间信息
 * @author chunlei.zcl
 */
@Data
public class RoomUpdateRequestDto {
    @NotBlank(message="直播间Id不能为空")
    private String id;

    @JsonProperty("title")
    private String title;

    @JsonProperty("notice")
    private String notice;

    @JsonProperty("extends")
    private String extendsInfo;

}
