package com.aliyuncs.aui.dto.req;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import javax.validation.constraints.NotBlank;
import java.util.List;

/**
 * 获取房间信息
 * @author chunlei.zcl
 */
@Data
public class RoomGetRequestDto {
    @NotBlank(message="直播间Id不能为空")
    private String id;

    @NotBlank(message="UserId不能为空")
    @JsonProperty("user_id")
    private String userId;

    @JsonProperty("im_server")
    private List<String> imServer;
}
