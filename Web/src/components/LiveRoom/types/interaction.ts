// 此处是自定义的 Interaction 消息类型，约定 type > 10000，你可以根据你业务需要进行修改
export enum CustomMessageTypes {
  Comment = 10001, // 评论
  LiveStart = 10003, // 开始直播
  LiveStop = 10004, // 结束直播
  LiveInfo = 10005, // 直播间信息
  NoticeUpdate = 10006, // 公告更新
  ApplyRTC = 20001, // 申请连麦（观众发送、主播接收）
  RespondRTC = 20002, // 同意/拒绝 连麦申请（主播发送，观众接收）
  RTCStart = 20003, // 上麦通知
  RTCStop = 20004, // 下麦通知
  RTCKick = 20005, // 踢下麦（主播发送，观众接收）
  CancelApplyRTC = 20006, // 取消申请连麦（仅观众）
  MicChanged = 20007, // 麦克风状态变化
  CameraChanged = 20008, // 摄像头状态变化
  ToggleSpectatorMic = 20009, // 打开/关闭观众麦克风（仅主播）
  ToggleSpectatorCamera = 20010, // 打开/关闭观众摄像头（仅主播）
  ShoppingProduct = 30011,  // 电商卡片消息
}

// 扩散类型
export enum BroadcastTypeEnum {
  nobody = 0, // 不扩散
  somebody = 1, // 扩散到指定人
  all = 2, // 扩散到群组
}
