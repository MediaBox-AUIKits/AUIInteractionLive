package com.aliyun.auiappserver.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.io.Serializable;

/**
 * @author puke
 * @version 2022/8/25
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class LoginRequest implements Serializable {

    public String username;

    public String password;
}
