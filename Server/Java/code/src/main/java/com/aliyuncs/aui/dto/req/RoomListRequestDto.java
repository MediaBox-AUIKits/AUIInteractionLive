package com.aliyuncs.aui.dto.req;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.util.List;

/**
 * 批量获取房间信息
 * @author chunlei.zcl
 */
@Data
@ApiModel(value = "批量获取房间信息")
public class RoomListRequestDto {

    @ApiModelProperty(value = "UserId")
    @NotBlank(message="UserId不能为空")
    @JsonProperty("user_id")
    private String userId;

    @NotNull(message="page_num不能为空")
    @JsonProperty("page_num")
    private Integer pageNum;

    @NotNull(message="page_size不能为空")
    @JsonProperty("page_size")
    private Integer pageSize;

    @ApiModelProperty(value = "im群列表")
    @JsonProperty("im_server")
    private List<String> imServer;

}
