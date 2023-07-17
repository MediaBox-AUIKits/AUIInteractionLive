package com.aliyuncs.aui.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.Date;

/**
 * 直播间Entity
 * 
 * @author chunlei.zcl
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("room_infos")
public class RoomInfoEntity implements Serializable {
	private static final long serialVersionUID = 1L;

	@TableId(type = IdType.INPUT)
	private String id;
	/**
	 * 创建时间
	 */
	private Date createdAt;
	/**
	 * 修改时间
	 */
	private Date updatedAt;
	/**
	 * 直播间标题
	 */
	private String title;
	///**
	// * 直播间创建者
	// */
	//private String anchor;
	/**
	 * 扩展信息
	 */
	@TableField("extends")
	private String extendsInfo;
	/**
	 * 直播状态，0-准备中，1-已开始，2-已结束
	 */
	private Long status;
	/**
	 * 直播模式 0-普通直播, 1-连麦直播，2-PK直播
	 */
	private Long mode;
	/**
	 * 群组Id
	 */
	private String chatId;
	/**
	 * 
	 */
	private String pkId;
	/**
	 * 直播公告
	 */
	private String notice;
	/**
	 * 连麦Id
	 */
	private String meetingId;
	/**
	 * 直播封面
	 */
	private String coverUrl;
	/**
	 * 主播Id
	 */
	private String anchorId;
	/**
	 * 主播Nick
	 */
	private String anchorNick;
	/**
	 * 点播Id
	 */
	private String vodId;
	/**
	 * 连麦成员信息（json序列化）
	 */
	private String meetingInfo;
	/**
	 * 直播开始时间
	 */
	private Date startedAt;
	/**
	 * 直播结束时间
	 */
	private Date stoppedAt;

}
