export const RoomModeMap = {
  normal: 0, // 普通直播
  rtc: 1, // 连麦直播
  pkId: 2, // PK直播
}

export const RoomStatusMap = {
  Preparing: 0, // 准备中
  Streaming: 1, // 已开始
  Stopped: 2, // 已结束
};

// 上一场直播id储存在 localstorage 中的 key
export const LatestLiveidStorageKey = 'aliyun_interaction_latest_liveid';

export const CustomMessageTypes = {
  Comment: 10001, // 评论
  LiveStart: 10003, // 开始直播
  LiveStop: 10004, // 结束直播
  LiveInfo: 10005, // 直播间信息
  NoticeUpdate: 10006, // 公告更新
  ApplyRTC: 20001, // 申请连麦（观众发送、主播接收）
  RespondRTC: 20002, // 同意/拒绝 连麦申请（主播发送，观众接收）
  RTCStart: 20003, // 上麦通知
  RTCStop: 20004, // 下麦通知
  RTCKick: 20005, // 踢下麦（主播发送，观众接收）
};

export const MaxMessageCount = 100;

export const RoomStatus = {
  no_data: -1, // 非服务端状态，意思为还未取到数据
  not_start: 0, // 未开播
  started: 1, // 已开始
  ended: 2, // 已结束
}
