package com.aliyuncs.aui.filter;


import com.aliyuncs.aui.common.utils.JwtUtils;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Arrays;

/**
* 用户请求授权过滤器
* @author chunlei.zcl
*/
@Component
@WebFilter
@Slf4j
public class TokenAuthenticationFilter extends OncePerRequestFilter {

    private static final String TOKEN_HEADER = "Authorization";

    private static final String TOKEN_PREFIX = "Bearer";
    @Override
    protected void doFilterInternal(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, FilterChain filterChain)
            throws ServletException, IOException {

        long start = System.currentTimeMillis();
        String authorization = httpServletRequest.getHeader(TOKEN_HEADER);
        if (StringUtils.isNotEmpty(authorization) && authorization.startsWith(TOKEN_PREFIX)) {
            String authToken = authorization.substring(TOKEN_PREFIX.length());
            if (StringUtils.isNotEmpty(authToken)) {
                log.info("checking authentication. username:{}, token:{}", TOKEN_PREFIX, authToken);
                if (JwtUtils.validateToken(authToken)) {
                    log.info("doFilterInternal. authentication ok. token:{}", authToken);
                    Authentication authentication = new UsernamePasswordAuthenticationToken(TOKEN_PREFIX, null, Arrays.asList(new SimpleGrantedAuthority(TOKEN_PREFIX)));
                    SecurityContextHolder.getContext().setAuthentication(authentication);
                } else {
                    log.warn("doFilterInternal. authentication failed. token:{}", authToken);
                }
            } else {
                log.warn("doFilterInternal. authentication failed. authToken is null");
            }
        } else {
            log.warn("doFilterInternal. authentication failed. not authToken");
        }

        log.info("doFilterInternal, consume:{}", (System.currentTimeMillis() - start));

        start = System.currentTimeMillis();
        try {
            filterChain.doFilter(httpServletRequest, httpServletResponse);
        }finally {
            log.info("filterChain.doFilter, consume:{}", (System.currentTimeMillis() - start));
        }
    }
}