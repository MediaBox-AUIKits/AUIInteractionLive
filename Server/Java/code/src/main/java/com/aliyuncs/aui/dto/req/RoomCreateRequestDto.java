package com.aliyuncs.aui.dto.req;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.util.List;

/**
 * 创建直播间请求参数
 * @author chunlei.zcl
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@ApiModel(value = "创建直播间请求参数")
public class RoomCreateRequestDto {
    @ApiModelProperty(value = "直播标题")
    @NotBlank(message="title不能为空")
    private String title;

    @ApiModelProperty(value = "直播公告")
    private String notice;

    @ApiModelProperty(value = "主播userId")
    @NotBlank(message="anchor不能为空")
    private String anchor;

    @ApiModelProperty(value = "主播nick")
    @JsonProperty("anchor_nick")
    private String anchorNick;

    @ApiModelProperty(value = "模式，默认0 普通直播，1 连麦直播")
    @NotNull(message="mode不能为空")
    @Builder.Default
    private Long mode = 0L;

    @ApiModelProperty(value = "扩展字段, json格式")
    @JsonProperty("extends")
    private String extendsInfo;

    @ApiModelProperty(value = "im群列表")
    @JsonProperty("im_server")
    private List<String> imServer;

}
