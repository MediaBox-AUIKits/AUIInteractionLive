package com.aliyuncs.aui.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 群统计数据
 *
 * @author chunlei.zcl
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GroupDetailInfo {

    private Long likeCount;

    private Long onlineCount;

    private Long pv;

    private Long uv;

    private Boolean isMute;
}
