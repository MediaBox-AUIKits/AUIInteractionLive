package com.aliyun.auiappserver.model;

import com.alivc.auimessage.model.token.IMNewToken;
import com.alivc.auimessage.model.token.IMOldToken;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * @author puke
 * @version 2022/8/25
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class Token {

    @JsonProperty("code")
    public int code;

    // 仅针对aliyun_old服务启作用
    @JsonProperty("aliyun_old_im")
    public IMOldToken oldToken;

    // 仅针对aliyun_new服务启作用
    @JsonProperty("aliyun_new_im")
    public IMNewToken newToken;

}
