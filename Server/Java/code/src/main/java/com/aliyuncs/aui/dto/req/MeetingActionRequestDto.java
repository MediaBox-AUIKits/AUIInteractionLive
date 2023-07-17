package com.aliyuncs.aui.dto.req;

import com.aliyuncs.aui.dto.MeetingMemberInfo;
import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import javax.validation.constraints.NotBlank;
import java.util.List;

/**
 * 修改连麦信息
 * @author chunlei.zcl
 */
@Data
@ApiModel(value = "修改连麦信息")
public class MeetingActionRequestDto {
    @ApiModelProperty(value = "直播间Id")
    @NotBlank(message="直播间Id不能为空")
    private String id;

    @ApiModelProperty(value = "成员信息")
    @JsonProperty("members")
    private List<MeetingMemberInfo> members;

}
