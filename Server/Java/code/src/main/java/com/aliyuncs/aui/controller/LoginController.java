package com.aliyuncs.aui.controller;

import com.aliyuncs.aui.common.utils.JwtUtils;
import com.aliyuncs.aui.common.utils.Result;
import com.aliyuncs.aui.common.utils.ValidatorUtils;
import com.aliyuncs.aui.dto.req.LoginRequestDto;
import com.aliyuncs.aui.service.LoginService;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.Map;

/**
 * 登录管理
 *
 * @author chunlei.zcl
 */
@RestController
public class LoginController {
    @Resource
    private LoginService loginService;

    @Resource
    private HttpServletRequest request;

    @RequestMapping("/")
    public Result index() {

        String scheme = request.getScheme();
        String serverName = request.getServerName();
        String serverHost = String.format("%s://%s", scheme, serverName);

        return Result.ok("部署成功，可正常访问地址 " + serverHost);
    }


    /**
     * 登录
     */
    @RequestMapping({"/login", "/api/v1/live/login"})
    public Result login(@RequestBody LoginRequestDto loginRequestDto) {

        //表单校验
        ValidatorUtils.validateEntity(loginRequestDto);

        //用户登录
        boolean result = loginService.login(loginRequestDto);
        if (result) {
            //生成token
            String token = JwtUtils.generateToken(loginRequestDto.getUsername());

            Map<String, Object> map = new HashMap<>();
            map.put("token", token);
            map.put("expire", JwtUtils.getExpiredDateFormToken(token));

            return Result.ok(map);
        }
        return Result.error(401, "incorrect Username or Password");
    }

}
