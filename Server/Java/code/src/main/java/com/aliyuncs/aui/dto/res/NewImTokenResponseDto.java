package com.aliyuncs.aui.dto.res;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * NewImTokenResponseDto
 *
 * @author chunlei.zcl
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NewImTokenResponseDto {

    @JsonProperty("app_id")
    private String appId;

    @JsonProperty("app_sign")
    private String appSign;

    @JsonProperty("app_token")
    private String appToken;

    private Auth auth;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Auth {

        @JsonProperty("user_id")
        private String userId;

        private String nonce;

        private long timestamp;

        private String role;
    }
}
