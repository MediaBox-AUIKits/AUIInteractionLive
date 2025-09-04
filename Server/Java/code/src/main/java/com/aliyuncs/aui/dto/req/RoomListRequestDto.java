package com.aliyuncs.aui.dto.req;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.util.List;

/**
 * 批量获取房间信息
 * @author chunlei.zcl
 */
@Data
public class RoomListRequestDto {

    @NotBlank(message="UserId不能为空")
    @JsonProperty("user_id")
    private String userId;

    @NotNull(message="page_num不能为空")
    @JsonProperty("page_num")
    private Integer pageNum;

    @NotNull(message="page_size不能为空")
    @JsonProperty("page_size")
    private Integer pageSize;

    @JsonProperty("im_server")
    private List<String> imServer;

}
