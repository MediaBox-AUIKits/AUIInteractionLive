package com.aliyun.auiappserver.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.io.Serializable;
import java.util.Date;

/**
 * @author puke
 * @version 2022/10/28
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class AppServerToken implements Serializable {

    public int code;

    public Date expire;

    public String token;
}
