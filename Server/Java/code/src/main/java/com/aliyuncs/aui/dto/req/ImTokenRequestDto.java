package com.aliyuncs.aui.dto.req;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import javax.validation.constraints.NotBlank;
import java.util.List;

/**
 * 获取IM服务Token的请求参数
 * @author chunlei.zcl
 */
@Data
public class ImTokenRequestDto {
    @NotBlank(message="userId不能为空")
    @JsonProperty("user_id")
    private String userId;

    @NotBlank(message="deviceId不能为空")
    @JsonProperty("device_id")
    private String deviceId;

    @NotBlank(message="deviceType不能为空")
    @JsonProperty("device_type")
    private String deviceType;

    @JsonProperty("im_server")
    private List<String> imServer;

    @JsonProperty("role")
    private String role = "";

}
