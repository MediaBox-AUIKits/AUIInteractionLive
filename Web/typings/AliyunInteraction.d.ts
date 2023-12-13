interface BasicMap< U > {
  [index: string]: U
}

export interface IMCreateGroupRspModel {
  groupId?: string; // 消息组id
}

export interface IMCreateGroupReqModel {
  extension?: BasicMap<string>; // 业务扩展字段
}

export interface IMGetGroupRspModel {
  groupId?: string; // 话题id, 聊天插件实例id
  extension?: BasicMap<string>; // 业务扩展字段
  createTime?: number; // 创建时间
  status?: number; // 群组状态
  creatorId?: string; // 创建者id
  isMuteAll?: boolean; // 是否被全体禁言
}

export interface IMGetGroupReqModel {
  groupId?: string; // 话题id, 聊天插件实例id
}

export interface IMCloseGroupRspModel {
}

export interface IMCloseGroupReqModel {
  groupId?: string; // 话题id, 聊天插件实例id
}

export interface IMJoinGroupRspModel {
}

export interface IMJoinGroupReqModel {
  groupId?: string; // 话题id, 聊天插件实例id
  userNick?: string; // 用户昵称
  userAvatar?: string; // 用户头像
  userExtension?: string; // 用户扩展信息
  broadCastType?: number; // 系统消息扩散类型，0： 不扩散；1：扩散到指定人; 2:扩散到群组
  broadCastStatistics?: boolean; // 是否扩散统计类消息， 默认为0，false； 取值 0：不扩散统计信息;1:扩散统计信息；统计信息包含PV、UV、onlineCount
}

export interface IMLeaveGroupRspModel {
}

export interface IMLeaveGroupReqModel {
  groupId?: string; // 话题id, 聊天插件实例id
  broadCastType?: number; // 系统消息扩散类型，0： 不扩散；1：扩散到指定人; 2:扩散到群组
}

export interface IMListGroupUserRspModel {
  total?: number; // 总数
  userList?: Array<IMGroupUserModel>; // 返回的消息组的在线成员列表
  hasMore?: boolean; // 是否还剩数据
}

export interface IMGroupUserModel {
  userId?: string; // 用户的id
  joinTime?: number; // 加入时间
}

export interface IMListGroupUserReqModel {
  groupId?: string; // 话题id, 聊天插件实例id
  sortType?: number; // 排序方式,0-时间递增顺序，1-时间递减顺序
  pageNum?: number; // 分页拉取的索引下标,第一次调用传1，后续调用+1
  pageSize?: number; // 分页拉取的大小,默认50条，最大200条
}

export interface IMGetGroupStatisticsRspModel {
  groupId?: string; // 话题id, 聊天插件实例id
  createTime?: number; // 创建时间
  status?: number; // 群组状态
  likeCount?: number; // 点赞数
  pv?: number; // PV
  uv?: number; // UV
  onlineCount?: number; // 在线人数
  isMuteAll?: boolean; // 是否全局被禁言
}

export interface IMGetGroupStatisticsReqModel {
  groupId?: string; // 消息组id
}

export interface IMGetGroupUserByIdListRspModel {
  userList?: Array<IMGroupUserDetailModel>; // 消息组id
}

export interface IMGroupUserDetailModel {
  userId?: string; // 用户id
  userNick?: string; // 用户昵称
  userAvatar?: string; // 用户头像
  userExtension?: string; // 用户扩展信息
  isMute?: boolean; // 用户的加入时间
  muteBy?: Array<string>; // 被禁言的原因["group","user"]
}

export interface IMGetGroupUserByIdListReqModel {
  groupId?: string; // 消息组id
  userIdList?: Array<string>; // 用户昵称
}

export interface IMSendMessageToGroupRspModel {
  messageId?: string; // 消息唯一ID标识
}

export interface IMSendMessageToGroupReqModel {
  groupId?: string; // 话题id,聊天插件实例id
  type?: number; // 消息类型，小于等于10000位系统消息，大于10000位自定义消息
  data?: string; // 消息体
  skipMuteCheck?: boolean; // 跳过禁言检测，true: 忽略被禁言用户，还可发消息；false： 当被禁言时，消息无法发送，默认为false，即为不跳过禁言检测。
  skipAudit?: boolean; // 跳过安全审核，true: 发送的消息不经过阿里云安全审核服务审核；false：发送的消息经过阿里云安全审核服务审核，审核失败则不发送；
  level?: number; // 消息分级：0-普通；1-低优先级； 2-高优先级
}

export interface IMSendMessageToGroupUsersRspModel {
  messageId?: string; // 消息唯一ID标识
}

export interface IMSendMessageToGroupUsersReqModel {
  groupId?: string; // 话题id,聊天插件实例id
  type?: number; // 话题id,聊天插件实例id
  data?: string; // 消息体
  receiverIdList?: Array<string>; // 接收者用户ID列表,最大100人
  skipMuteCheck?: boolean; // 跳过禁言检测，true: 忽略被禁言用户，还可发消息；false： 当被禁言时，消息无法发送，默认为false，即为不跳过禁言检测。
  skipAudit?: boolean; // 跳过安全审核，true: 发送的消息不经过阿里云安全审核服务审核；false：发送的消息经过阿里云安全审核服务审核，审核失败则不发送；
  level?: number; // 消息分级：0-普通；1-低优先级； 2-高优先级
  messageId?: string; // 消息Id， 用于重传消息时指定
}

export interface IMListMessageRspModel {
  messageList?: Array<IMMessageModel>; // 返回的消息组的在线成员列表
  hasMore?: boolean; // 是否还剩数据
}
export interface IMMessageModel {
  groupId?: string; // 话题id,聊天插件实例id
  messageId?: string; // 消息id
  type?: number; // 消息类型。系统消息小于10000
  senderId?: string; // 发送者id
  data?: string; // 消息内容，为xxDataModel转为字符串而来
  senderInfo?: string; // 发送者信息 (弃用, 必须为空)
  level?: number; // 消息分级：0-普通；1-低优先级； 2-高优先级
  userInfo?: IMUserModel; // 发送者信息
}

export interface IMUserModel {
  userId?: string; // 用户id
  userNick?: string; // 用户昵称
  userAvatar?: string; // 用户头像
  userExtension?: string; // 用户扩展信息
}

export interface IMListMessageReqModel {
  groupId?: string; // 话题id, 聊天插件实例id
  sortType?: number; // 排序方式,0-时间递增顺序，1-时间递减顺序
  type?: number; // 消息类型
  pageNum?: number; // 分页拉取的索引下标,第一次调用传1，后续调用+1
  pageSize?: number; // 分页拉取的大小，默认50条，最大200条
}

export interface IMSendLikeRspModel {
  intervalSecond?: number; // 服务端限流发送弹幕间隔，单位为秒
  likeCount?: number; // 点赞总数
}

export interface IMSendLikeReqModel {
  groupId?: string; // 话题id, 聊天插件实例id
  count?: number; // 点赞数
  broadCastType?: number; // 系统消息扩散类型，0： 不扩散；1：扩散到指定人; 2:扩散到群组
}

export interface IMMuteAllRspModel {
}

export interface IMMuteAllReqModel {
  groupId?: string; // 话题id,聊天插件实例id
  broadCastType?: number; // 系统消息扩散类型，0： 不扩散；1：扩散到指定人; 2:扩散到群组
}

export interface IMCancelMuteAllRspModel {
}

export interface IMCancelMuteAllReqModel {
  groupId?: string; // 话题id,聊天插件实例id
  broadCastType?: number; // 系统消息扩散类型，0： 不扩散；1：扩散到指定人; 2:扩散到群组
}

export interface IMMuteUserRspModel {
}

export interface IMMuteUserReqModel {
  groupId?: string; // 话题id, 聊天插件实例id
  muteUserList?: Array<string>; // 需要禁言的用户列表，最大200个
  muteTime?: number; // 禁言的时间，单位为s，如果不传或者传0则采用默认禁言时间
  broadCastType?: number; // 系统消息扩散类型，0： 不扩散；1：扩散到指定人; 2:扩散到群组
}

export interface IMCancelMuteUserRspModel {
}

export interface IMCancelMuteUserReqModel {
  groupId?: string; // 话题id, 聊天插件实例id
  cancelMuteUserList?: Array<string>; // 被取消禁言的用户列表，最大200个
  broadCastType?: number; // 系统消息扩散类型，0： 不扩散；1：扩散到指定人; 2:扩散到群组
}

export interface IMListMuteUsersRspModel {
  muteUserModelList?: Array<IMMuteUserModel>; // 禁言用户列表
}

export interface IMMuteUserModel {
  userId?: string; // 禁言的用户id
}

export interface IMListMuteUsersReqModel {
  groupId?: string; // 话题id, 聊天插件实例id
}

declare class Emitter {
  /**
   * 事件监听
   * @param {string} eventName
   * @param {*} eventHandler
   */
  on(eventName: string, eventHandler: Function): void;
  /**
   * 取消事件监听
   * @param {string} eventName
   * @param {*} [eventHandler]
   */
  remove(eventName: string, eventHandler?: Function): void;
  /**
   * 移除所有事件监听
   */
  removeAllEvents(): void;
}

export declare class InteractionEngine extends Emitter {
  /**
   * 创建实例
   * @return {InteractionEngine}
   */
  static create(): InteractionEngine;

  /**
   * 获取deviceId
   * @return {string} deviceId
   */
  static getDeviceId(): string;

  /**
   * 对外登录认证接口
   *
   * @param {string} base64token
   * @return {Promise}
   */
  auth(base64token: string): Promise<void>;

  /**
   * 退出登录
   */
  logout(): Promise<void>;

  /**
   * 创建聊天组
   * @param {IMCreateGroupReqModel} [options]
   * @return {Promise}
   */
  createGroup(options?: IMCreateGroupReqModel): Promise<IMCreateGroupRspModel>;

  /**
   * 获取聊天组
   * @param {IMGetGroupReqModel} options
   * @return {Promise}
   */
  getGroup(options: IMGetGroupReqModel): Promise<IMGetGroupRspModel>;

  /**
   * 关闭聊天组
   * @param {IMCloseGroupReqModel} options
   * @return {Promise}
   */
  closeGroup(options: IMCloseGroupReqModel): Promise<IMCloseGroupRspModel>;

  /**
   * 加入聊天组
   * @param {IMJoinGroupReqModel} options
   * @return {Promise}
   */
  joinGroup(options: IMJoinGroupReqModel): Promise<IMJoinGroupRspModel>;

  /**
   * 离开聊天组方法
   *
   * @param {IMLeaveGroupReqModel} options
   * @return {Promise}
   */
  leaveGroup(options: IMLeaveGroupReqModel): Promise<IMLeaveGroupRspModel>;

  /**
   * 加入聊天组
   * @param {IMListGroupUserReqModel} options
   * @return {Promise}
   */
  listGroupUser(options: IMListGroupUserReqModel): Promise<IMListGroupUserRspModel>;

  /**
   * 广播群组消息
   * @param {IMSendMessageToGroupReqModel} options
   * @return {Promise}
   */
  sendMessageToGroup(options: IMSendMessageToGroupReqModel): Promise<IMSendMessageToGroupRspModel>;

  /**
   * 发送点对点消息
   * @param {IMSendMessageToGroupUsersReqModel} options
   * @return {Promise}
   */
  sendMessageToGroupUsers(options: IMSendMessageToGroupUsersReqModel): Promise<IMSendMessageToGroupUsersRspModel>;

  /**
   * 点赞方法
   * @param {IMSendLikeReqModel} options
   * @return {Promise}
   */
  sendLike(options: IMSendLikeReqModel): Promise<IMSendLikeRspModel>;

  /**
   * 获取消息列表接口
   * @param {IMListMessageReqModel} options
   * @return {Promise}
   */
  listMessage(options: IMListMessageReqModel): Promise<IMListMessageRspModel>;

  /**
   * 获取IM组统计数据
   * @param {IMGetGroupStatisticsReqModel} options
   * @return {Promise}
   */
  getGroupStatistics(options: IMGetGroupStatisticsReqModel): Promise<IMGetGroupStatisticsRspModel>;

  /**
   * 取组成员信息,包含是否被禁言
   * @param {IMGetGroupUserByIdListReqModel} options
   * @return {Promise}
   */
  getGroupUserByIdList(options: IMGetGroupUserByIdListReqModel): Promise<IMGetGroupUserByIdListRspModel>;

  /**
   * 全体禁言
   * @param {IMMuteAllReqModel} options
   * @return {Promise}
   */
  muteAll(options: IMMuteAllReqModel): Promise<IMMuteAllRspModel>;

  /**
   * 取消全体禁言
   * @param {IMCancelMuteAllReqModel} options
   * @return {Promise}
   */
  cancelMuteAll(options: IMCancelMuteAllReqModel): Promise<IMCancelMuteAllRspModel>;

  /**
   * 禁言某些用户
   * @param {IMMuteUserReqModel} options
   * @return {Promise}
   */
  muteUser(options: IMMuteUserReqModel): Promise<IMMuteUserRspModel>;

  /**
   * 取消禁言某些用户
   * @param {IMCancelMuteUserReqModel} options
   * @return {Promise}
   */
  cancelMuteUser(options: IMCancelMuteUserReqModel): Promise<IMCancelMuteUserRspModel>;

  /**
   * 获取禁言的用户列表
   * @param {IMListMuteUsersReqModel} options
   * @return {Promise}
   */
  listMuteUsers(options: IMListMuteUsersReqModel): Promise<IMListMuteUsersRspModel>;
}

export enum InteractionEventNames {
  Message = 'message',
}

export declare type AliyunInteraction = {
  InteractionEngine: typeof InteractionEngine,
  InteractionEventNames: typeof InteractionEventNames,
};
