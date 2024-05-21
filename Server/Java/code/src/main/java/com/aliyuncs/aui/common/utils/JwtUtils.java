package com.aliyuncs.aui.common.utils;

import io.jsonwebtoken.*;
import lombok.experimental.UtilityClass;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang.StringUtils;

import java.util.Date;

/**
 * jwt工具类
 */
@Slf4j
@UtilityClass
public class JwtUtils {

    // 运行前先随机配置个jwt密钥
    private static final String SECRET = "";

    public static void check() {
        if (StringUtils.isEmpty(SECRET)) {
            throw new RuntimeException("Must config Jwt secret. please open class file: com.aliyuncs.aui.common.utils.JwtUtils, then config field SECRET");
        }
    }

    /**
     * 生成jwt token
     */
    public static String generateToken(String userId) {

        return Jwts.builder()
                .setHeaderParam("typ", "JWT")
                .setSubject(userId + "")
                .setIssuedAt(new Date())
                .setExpiration(expirationDate())
                .signWith(SignatureAlgorithm.HS256, SECRET)
                .compact();
    }

    /**
     * token是否过期
     */
    public static boolean validateToken(String token) {

        try {
            return !isTokenExpired(token);
        }catch (Exception e) {
            log.error("validateToken validateToken.token:{}, e:{}", token, e);
            return false;
        }
    }

    //从荷载中获取时间
    public static Date getExpiredDateFormToken(String token) {
        Claims claims = getClaimsFromToken(token);
        return claims.getExpiration();
    }

    private static boolean isTokenExpired(String token) {
        Date expiredDate = getExpiredDateFormToken(token);
        return expiredDate.before(new Date());
    }

    //从token中获取荷载
    private static Claims getClaimsFromToken(String token) {
        Claims claims = null;
        try {
            claims = Jwts.parser()
                    .setSigningKey(SECRET)
                    .parseClaimsJws(token)
                    .getBody();
        } catch (ExpiredJwtException e) {
            e.printStackTrace();
        } catch (UnsupportedJwtException e) {
            e.printStackTrace();
        } catch (MalformedJwtException e) {
            e.printStackTrace();
        } catch (SignatureException e) {
            e.printStackTrace();
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
        }
        return claims;
    }

    private static Date expirationDate() {
        //失效时间为：未来7天
        return new Date(System.currentTimeMillis() + 7 * 24 * 60 * 60 * 1000);
    }

}
