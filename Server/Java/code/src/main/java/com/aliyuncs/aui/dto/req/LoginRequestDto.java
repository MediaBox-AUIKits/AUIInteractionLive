package com.aliyuncs.aui.dto.req;

import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * 登录表单
 * @author chunlei.zcl
 */
@Data
public class LoginRequestDto {
    @NotBlank(message="用户名不能为空")
    private String username;

    @NotBlank(message="密码不能为空")
    private String password;

}
