// 阿里云新IM类型文件
export declare namespace AliVCInteraction {
	class AliVCIMGroupManager extends EventEmitter<ImGroupListener> {
	  private wasmIns;
	  private wasmGroupManager;
	  private groupListener;
	  constructor(wasmIns: any, wasmInterface: any);
	  addGroupListener(): void;
	  removeGroupListener(): void;
	  /**
	   * 创建群组，限管理员才能操作
	   * @param {ImCreateGroupReq} req
	   * @returns {Promise<ImCreateGroupRsp>}
	   */
	  createGroup(req: ImCreateGroupReq): Promise<ImCreateGroupRsp>;
	  /**
	   * 查询群组信息
	   * @param {string | ImQueryGroupReq} groupIdOrReq
	   * @returns {Promise<ImGroupInfo>}
	   */
	  queryGroup(groupIdOrReq: string | ImQueryGroupReq): Promise<ImGroupInfo>;
	  /**
	   * 关闭群组，限管理员才能操作
	   * @param {string | ImCloseGroupReq} groupIdOrReq
	   * @returns {Promise<void>}
	   */
	  closeGroup(groupIdOrReq: string | ImCloseGroupReq): Promise<void>;
	  /**
	   * 加入群组
	   * @param {string | ImJoinGroupReq} groupIdOrReq
	   * @returns {Promise<ImGroupInfo>}
	   */
	  joinGroup(groupIdOrReq: string | ImJoinGroupReq): Promise<ImGroupInfo>;
	  /**
	   * 离开群组
	   * @param {string | ImLeaveGroupReq} groupIdOrReq
	   * @returns {Promise<void>}
	   */
	  leaveGroup(groupIdOrReq: string | ImLeaveGroupReq): Promise<void>;
	  /**
	   * 修改群组信息
	   * @param {ImModifyGroupReq} req
	   * @returns {Promise<void>}
	   */
	  modifyGroup(req: ImModifyGroupReq): Promise<void>;
	  /**
	   * 查询最近组成员
	   * @param {string | ImListRecentGroupUserReq} groupIdOrReq
	   * @returns {Promise<ImListRecentGroupUserRsp>}
	   */
	  listRecentGroupUser(groupIdOrReq: string | ImListRecentGroupUserReq): Promise<ImListRecentGroupUserRsp>;
	  /**
	   * 查询群组成员，限管理员才能操作
	   * @param {string | ImListGroupUserReq} groupIdOrReq
	   * @returns {Promise<ImListGroupUserRsp>}
	   */
	  listGroupUser(groupIdOrReq: string | ImListGroupUserReq): Promise<ImListGroupUserRsp>;
	  /**
	   * 全体禁言，限管理员才能操作
	   * @param {string | ImMuteAllReq} groupIdOrReq
	   * @returns {Promise<void>}
	   */
	  muteAll(groupIdOrReq: string | ImMuteAllReq): Promise<void>;
	  /**
	   * 取消全体禁言，限管理员才能操作
	   * @param {string | ImCancelMuteAllReq} groupIdOrReq
	   * @returns {Promise<void>}
	   */
	  cancelMuteAll(groupIdOrReq: string | ImCancelMuteAllReq): Promise<void>;
	  /**
	   * 禁言指定用户，限管理员才能操作
	   * @param {ImMuteUserReq} req
	   * @returns {Promise<void>}
	   */
	  muteUser(req: ImMuteUserReq): Promise<void>;
	  /**
	   * 取消禁言指定用户，限管理员才能操作
	   * @param {ImCancelMuteUserReq} req
	   * @returns {Promise<void>}
	   */
	  cancelMuteUser(req: ImCancelMuteUserReq): Promise<void>;
	  /**
	   * 查询禁言用户列表，限管理员才能操作
	   * @param {string | ImListMuteUsersReq} groupIdOrReq
	   * @returns {Promise<ImListMuteUsersRsp>}
	   */
	  listMuteUsers(groupIdOrReq: string | ImListMuteUsersReq): Promise<ImListMuteUsersRsp>;
  }
  
  class AliVCIMMessageManager extends EventEmitter<ImMessageListener> {
	  private wasmIns;
	  private wasmMessageManager;
	  private messageListener;
	  constructor(wasmIns: any, wasmInterface: any);
	  addMessageListener(): void;
	  removeMessageListener(): void;
	  /**
	   * 发送单聊普通消息
	   * @param {ImSendMessageToUserReq} req
	   * @returns {string} messageId
	   */
	  sendC2cMessage(req: ImSendMessageToUserReq): Promise<string>;
	  /**
	   * 发送群聊普通消息
	   * @param {ImSendMessageToGroupReq} req
	   * @returns {string} messageId
	   */
	  sendGroupMessage(req: ImSendMessageToGroupReq): Promise<string>;
	  /**
	   * 查询消息列表
	   * @param {ImListMessageReq} req
	   * @returns {ImListMessageRsp}
	   */
	  listMessage(req: ImListMessageReq): Promise<ImListMessageRsp>;
	  /**
	   * 查询最近消息
	   * @param {string |ImListRecentMessageReq} groupIdOrReq
	   * @returns {ImListRecentMessageRsp}
	   */
	  listRecentMessage(groupIdOrReq: string | ImListRecentMessageReq): Promise<ImListRecentMessageRsp>;
	  /**
	   * 查询历史消息，该接口主要用户直播结束后的历史消息回放，用户无需进入群组可查询，比较耗时，在直播过程中不建议使用，另外该接口后续可能会收费。
	   * @param {ImListHistoryMessageReq} req
	   * @returns {ImListHistoryMessageRsp}
	   */
	  listHistoryMessage(req: ImListHistoryMessageReq): Promise<ImListHistoryMessageRsp>;
	  /**
	   * 删除/撤回群消息
	   */
	  deleteMessage(req: ImDeleteMessageReq): Promise<void>;
  }
  
  /**
   * Minimal `EventEmitter` interface that is molded against the Node.js
   * `EventEmitter` interface.
   */
  class EventEmitter<
  EventTypes extends EventEmitter.ValidEventTypes = string | symbol,
  Context extends any = any
  > {
	  static prefixed: string | boolean;
  
	  /**
	   * Return an array listing the events for which the emitter has registered
	   * listeners.
	   */
	  eventNames(): Array<EventEmitter.EventNames<EventTypes>>;
  
	  /**
	   * Return the listeners registered for a given event.
	   */
	  listeners<T extends EventEmitter.EventNames<EventTypes>>(
	  event: T
	  ): Array<EventEmitter.EventListener<EventTypes, T>>;
  
	  /**
	   * Return the number of listeners listening to a given event.
	   */
	  listenerCount(event: EventEmitter.EventNames<EventTypes>): number;
  
	  /**
	   * Calls each of the listeners registered for a given event.
	   */
	  emit<T extends EventEmitter.EventNames<EventTypes>>(
	  event: T,
	  ...args: EventEmitter.EventArgs<EventTypes, T>
	  ): boolean;
  
	  /**
	   * Add a listener for a given event.
	   */
	  on<T extends EventEmitter.EventNames<EventTypes>>(
	  event: T,
	  fn: EventEmitter.EventListener<EventTypes, T>,
	  context?: Context
	  ): this;
	  addListener<T extends EventEmitter.EventNames<EventTypes>>(
	  event: T,
	  fn: EventEmitter.EventListener<EventTypes, T>,
	  context?: Context
	  ): this;
  
	  /**
	   * Add a one-time listener for a given event.
	   */
	  once<T extends EventEmitter.EventNames<EventTypes>>(
	  event: T,
	  fn: EventEmitter.EventListener<EventTypes, T>,
	  context?: Context
	  ): this;
  
	  /**
	   * Remove the listeners of a given event.
	   */
	  removeListener<T extends EventEmitter.EventNames<EventTypes>>(
	  event: T,
	  fn?: EventEmitter.EventListener<EventTypes, T>,
	  context?: Context,
	  once?: boolean
	  ): this;
	  off<T extends EventEmitter.EventNames<EventTypes>>(
	  event: T,
	  fn?: EventEmitter.EventListener<EventTypes, T>,
	  context?: Context,
	  once?: boolean
	  ): this;
  
	  /**
	   * Remove all listeners, or those of the specified event.
	   */
	  removeAllListeners(event?: EventEmitter.EventNames<EventTypes>): this;
  }
  
  namespace EventEmitter {
	  interface ListenerFn<Args extends any[] = any[]> {
		  (...args: Args): void;
	  }
  
	  interface EventEmitterStatic {
		  new <
		  EventTypes extends ValidEventTypes = string | symbol,
		  Context = any
		  >(): EventEmitter<EventTypes, Context>;
	  }
  
	  /**
	   * `object` should be in either of the following forms:
	   * ```
	   * interface EventTypes {
	   *   'event-with-parameters': any[]
	   *   'event-with-example-handler': (...args: any[]) => void
	   * }
	   * ```
	   */
	  type ValidEventTypes = string | symbol | object;
  
	  type EventNames<T extends ValidEventTypes> = T extends string | symbol
	  ? T
	  : keyof T;
  
	  type ArgumentMap<T extends object> = {
		  [K in keyof T]: T[K] extends (...args: any[]) => void
		  ? Parameters<T[K]>
		  : T[K] extends any[]
		  ? T[K]
		  : any[];
	  };
  
	  type EventListener<
	  T extends ValidEventTypes,
	  K extends EventNames<T>
	  > = T extends string | symbol
	  ? (...args: any[]) => void
	  : (
	  ...args: ArgumentMap<Exclude<T, string | symbol>>[Extract<K, keyof T>]
	  ) => void;
  
	  type EventArgs<
	  T extends ValidEventTypes,
	  K extends EventNames<T>
	  > = Parameters<EventListener<T, K>>;
  
	  const EventEmitter: EventEmitterStatic;
  }
  
  interface ImAuth {
	  /**
	   * 随机数，格式："AK-随机串", 最长64字节, 仅限A-Z,a-z,0-9及"_"，可为空
	   */
	  nonce: string;
	  /**
	   * 过期时间:从1970到过期时间的秒数
	   */
	  timestamp: number;
	  /**
	   * 角色，为admin时，表示该用户可以调用管控接口,可为空,如果要给当前用户admin权限，应该传admin
	   */
	  role?: string;
	  /**
	   * token
	   */
	  token: string;
  }
  
  interface ImCancelMuteAllReq {
	  /**
	   * @param group_id 群组id
	   */
	  groupId: string;
  }
  
  interface ImCancelMuteUserReq {
	  /**
	   * @param group_id 群组id
	   */
	  groupId: string;
	  /**
	   * @param userList 被取消禁言的用户列表
	   */
	  userList: string[];
  }
  
  interface ImCloseGroupReq {
	  /**
	   * @param group_id 群组id
	   */
	  groupId: string;
  }
  
  interface ImCreateGroupReq {
	  /**
	   * @param group_id 群组id，【可选】id为空的话，会由sdk内部生成
	   */
	  groupId?: string;
	  /**
	   * @param groupName 群组名称
	   */
	  groupName: string;
	  /**
	   * @param extension 业务扩展字段
	   */
	  groupMeta?: string;
  }
  
  interface ImCreateGroupRsp {
	  /**
	   * @param group_id 群组id
	   */
	  groupId: string;
	  /**
	   * @param already_exists 是否已经创建过
	   */
	  alreadyExist: boolean;
  }
  
  interface ImDeleteMessageReq {
	  /**
	   * @param group_id 群组id
	   */
	  groupId: string;
	  /**
	   * @param msg_id 消息id
	   */
	  messageId: string;
  }
  
  class ImEngine extends EventEmitter<ImSdkListener> {
	  private wasmIns;
	  private wasmEngine;
	  private wasmInterface;
	  private transport?;
	  private appEventManager?;
	  private eventListener;
	  private messageManager?;
	  private groupManager?;
	  private supportsWebRtc;
	  private supportWASM;
	  constructor();
	  static engine: ImEngine;
	  /**
	   * @brief 获取 SDK 引擎实例（单例）
	   * @returns ImEngine
	   */
	  static createEngine(): ImEngine;
	  /**
	   * 当前 SDK 是否支持，支持 WASM 或者 ASM
	   * @returns
	   */
	  static isSupport(): boolean;
	  private initTransport;
	  private initAppEvent;
	  /**
	   * @brief 初始化
	   * @param config SDK配置信息
	   */
	  init(config: ImSdkConfig): Promise<void>;
	  /**
	   * 添加 Engine 事件监听
	   */
	  private addEventListener;
	  private removeEventListener;
	  private destroy;
	  /**
	   * @brief 销毁
	   */
	  unInit(): boolean;
	  /**
	   * @brief 登录
	   * @param req 登录请求数据
	   */
	  login(loginReq: ImLoginReq): Promise<void>;
	  /**
	   * @brief 登出
	   */
	  logout(): Promise<void>;
	  /**
	   * 强制重连
	   */
	  reconnect(): void;
	  /**
	   * @brief 获取当前登录用户 ID
	   */
	  getCurrentUserId(): string;
	  /**
	   * @brief 是否登录
	   */
	  isLogin(): boolean;
	  /**
	   * @brief 获取消息管理器 {AliVCIMMessageInterface}
	   * @return 返回消息管理器实例
	   */
	  getMessageManager(): AliVCIMMessageManager | undefined;
	  /**
	   * @brief 获取群组管理器 {AliVCIMGroupInterface}
	   * @return 返回群组管理器实例
	   */
	  getGroupManager(): AliVCIMGroupManager | undefined;
  }
  
  enum ImErrors {
	  /**
	   * 已经登录
	   */
	  ERROR_HAS_LOGIN = 304,
	  /**
	   * 参数错误；参数无法解析
	   */
	  ERROR_INVALID_PARAM = 400,
	  /**
	   * 错误码（subcode)	说明
	   * 403	操作无权限； 或登录时鉴权失败
	   */
	  ERROR_NO_PERMISSION = 403,
	  /**
	   * no session,可能因为客户网络变化等原因导致的连接变化，服务器在新连接上收到消息无法正常处理，需要reconnect 信令。
	   */
	  ERROR_NO_SESSION = 404,
	  /**
	   * 群组不存在
	   */
	  ERROR_GROUP_NOT_EXIST = 440,
	  /**
	   * 群组已删除
	   */
	  ERROR_GROUP_DELETED = 441,
	  /**
	   * 无法在该群组中发送消息，被禁言
	   */
	  ERROR_SEDN_GROUP_MSG_FAIL = 442,
	  /**
	   * 无法加入该群，被禁止加入（暂无需求未实现）预留
	   */
	  ERROR_JOIN_GROUP_FAIL = 450,
	  /**
	   * 未加入群组
	   */
	  ERROR_GROUP_NOT_JOINED = 425,
	  /**
	   * 繁忙，发送太快，稍候重试
	   */
	  ERROR_INTERNAL_BUSY = 412,
	  /**
	   * 系统临时错误，稍候重试
	   */
	  ERROR_INTERNALE_RROR = 500,
	  /**
	   * 进了太多的群组, 列表人数超大等
	   */
	  ERROR_REACH_MAX = 443,
	  /**
	   * 状态错误
	   */
	  ERROR_INVALID_STATE = 601,
	  /**
	   * 未登录
	   */
	  ERROR_NOT_LOGIN = 602,
	  /**
	   * 收到上次session的消息
	   */
	  ERROR_RECEIVE_LAST_SESSION = 603,
	  /**
	   * Parse Data Error
	   */
	  ERROR_PARSE_DATA_ERROR = 604
  }
  
  interface ImGroupInfo {
	  /**
	   * @param group_id 群组id
	   */
	  groupId: string;
	  /**
	   * @param group_name 群组名称
	   */
	  groupName: string;
	  /**
	   * @param group_name 群组透传信息
	   */
	  groupMeta: string;
	  /**
	   * @param createtime 创建时间
	   */
	  createTime: number;
	  /**
	   * @param createtime 创建者id
	   */
	  creator: string;
	  /**
	   * @param admins 管理员列表
	   */
	  admins: string[];
	  /**
	   * @param statistics 群组统计
	   */
	  statistics: ImGroupStatistics;
	  /**
	   * @param mute_status 群禁言信息
	   */
	  muteStatus: ImGroupMuteStatus;
  }
  
  interface ImGroupInfoStatus {
	  /**
	   * @param group_id 群组id
	   */
	  groupId: string;
	  /**
	   * @param group_meta 群组扩展信息
	   */
	  groupMeta: string;
	  /**
	   * @param admin_list 管理员列表
	   */
	  adminList: string[];
  }
  
  interface ImGroupListener {
	  /**
	   * 群组成员变化
	   * @param groupId  群组ID
	   * @param memberCount 当前群组人数
	   * @param joinUsers 加入的用户
	   * @param leaveUsers 离开的用户
	   */
	  memberchange: (groupId: string, memberCount: number, joinUsers: ImUser[], leaveUsers: ImUser[]) => void;
	  /**
	   * 退出群组
	   * @param groupId  群组ID
	   * @param reason 退出原因 1: 群被解散， 2：被踢出来了
	   */
	  exit: (groupId: string, reason: number) => void;
	  /**
	   * 群组静音状态变化
	   * @param groupId  群组ID
	   * @param status 静音状态
	   */
	  mutechange: (groupId: string, status: ImGroupMuteStatus) => void;
	  /**
	   * 群组信息变化
	   * @param groupId  群组ID
	   * @param info 群组信息
	   */
	  infochange: (groupId: string, info: ImGroupInfoStatus) => void;
  }
  
  interface ImGroupMuteStatus {
	  /**
	   * @param group_id 群组id
	   */
	  groupId: string;
	  /**
	   * @param mute_all 是否全员禁言
	   */
	  muteAll: boolean;
	  /**
	   * @param mute_user_list 禁言用户ID列表
	   */
	  muteUserList: string[];
	  /**
	   * @param white_user_list 白名单用户ID列表
	   */
	  whiteUserList: string[];
  }
  
  interface ImGroupStatistics {
	  /**
	   * @param pv PV
	   */
	  pv: number;
	  /**
	   * @param online_count 在线人数
	   */
	  onlineCount: number;
	  /**
	   * @param msg_amount 消息数量
	   */
	  msgAmount: {
		  [key: string]: number;
	  };
  }
  
  interface ImJoinGroupReq {
	  /**
	   * @param group_id 群组id
	   */
	  groupId: string;
  }
  
  interface ImLeaveGroupReq {
	  /**
	   * @param group_id 群组id
	   */
	  groupId: string;
  }
  
  interface ImListGroupUserReq {
	  /**
	   * @param group_id 群组id
	   */
	  groupId: string;
	  /**
	   * @param sortType 排序方式,ASC-先加入优先，DESC-后加入优先
	   */
	  sortType?: ImSortType;
	  /**
	   * @param nextpagetoken 默认表示第一页,遍历时服务端会返回，客户端获取下一页时，应带上
	   */
	  nextPageToken?: number;
	  /**
	   * @deprecated 请使用 nextPageToken
	   */
	  nextpagetoken?: number;
	  /**
	   * @param pageSize 最大不超过50
	   */
	  pageSize?: number;
  }
  
  interface ImListGroupUserRsp {
	  /**
	   * @param group_id 群组id
	   */
	  groupId: string;
	  /**
	   * @param nextpagetoken 下一页的token
	   */
	  nextPageToken: number;
	  /**
	   * @deprecated 请使用 nextpagetoken
	   */
	  nextpagetoken?: number;
	  /**
	   * @param hasMore 是否还有下一页
	   */
	  hasMore: boolean;
	  /**
	   * @param userList 返回的群组的在线成员列表
	   */
	  userList: ImUser[];
  }
  
  interface ImListHistoryMessageReq {
	  /**
	   * @param group_id 群组id
	   */
	  groupId: string;
	  /**
	   * @param type 消息类型
	   */
	  type: number;
	  /**
	   * @param nextpagetoken 不传时表示第一页,遍历时服务端会返回，客户端获取下一页时，应带上
	   */
	  nextPageToken?: number;
	  /**
	   * @param sorttype 排序类型，默认为时间递增
	   */
	  sortType?: ImSortType;
	  /**
	   * @param page_size 取值范围 10~30
	   */
	  pageSize?: number;
	  /**
	   * @param begintime 按时间范围遍历，开始时间，不传时表示最早时间,单位：秒
	   */
	  beginTime?: number;
	  /**
	   * @param endtime 按时间范围遍历，结束时间，不传时表示最晚时间,单位：秒
	   */
	  endTime?: number;
  }
  
  interface ImListHistoryMessageRsp {
	  /**
	   * @param group_id 群组id
	   */
	  groupId: string;
	  /**
	   * @param nextpagetoken 不传时表示第一页,遍历时服务端会返回，客户端获取下一页时，应带上
	   */
	  nextPageToken?: number;
	  /**
	   *@param hasmore 是否有更多数据
	   */
	  hasMore: boolean;
	  /**
	   *@param message_list 返回消息列表
	   **/
	  messageList: ImMessage[];
  }
  
  interface ImListMessageReq {
	  /**
	   * @param group_id 话题id，聊天插件实例id
	   */
	  groupId: string;
	  /**
	   * @param type 消息类型
	   */
	  type: number;
	  /**
	   * @param nextPageToken 不传时表示第一页，遍历时服务端会返回，客户端获取下一页时应带上
	   */
	  nextPageToken?: number;
	  /**
	   * @deprecated 请使用nextPageToken
	   */
	  nextpagetoken?: number;
	  /**
	   * @param sorttype 排序类型，默认为时间递增
	   */
	  sortType?: ImSortType;
	  /**
	   * @param pageSize 分页拉取的大小，默认10条，最大30条
	   */
	  pageSize?: number;
	  /**
	   * @param begintime 按时间范围遍历，开始时间，不传时表示最早时间,单位：秒
	   */
	  beginTime?: number;
	  /**
	   * @param endtime 按时间范围遍历，结束时间，不传时表示最晚时间,单位：秒
	   */
	  endTime?: number;
  }
  
  interface ImListMessageRsp {
	  /**
  
	   * @param group_id 群组id
	   */
	  groupId: string;
	  /**
	   *@param nextpagetoken 客户端获取下一页时，应带上
	   */
	  nextPageToken: number;
	  /**
	   * @deprecated 请使用 nextPageToken
	   */
	  nextpagetoken?: number;
	  /**
	   *@param hasmore 是否有更多数据
	   */
	  hasMore: boolean;
	  /**
	   *@param message_list 返回消息列表
	   **/
	  messageList: ImMessage[];
  }
  
  interface ImListMuteUsersReq {
	  /**
	   * @param group_id 群组id
	   */
	  groupId: string;
  }
  
  interface ImListMuteUsersRsp {
	  /**
	   * @param group_id 群组id
	   */
	  groupId: string;
	  /**
	   * @param mute_all 是否全员禁言
	   */
	  muteAll: boolean;
	  /**
	   * @param mute_user_list 禁言用户ID列表
	   */
	  muteUserList: string[];
	  /**
	   * @param white_user_list 白名单用户ID列表
	   */
	  whiteUserList: string[];
  }
  
  interface ImListRecentGroupUserReq {
	  /**
	   * @param group_id 群组id
	   */
	  groupId: string;
  }
  
  interface ImListRecentGroupUserRsp {
	  /**
	   * @param group_id 群组id
	   */
	  groupId: string;
	  /**
	   * @param total 群组成员总数
	   */
	  total: number;
	  /**
	   * @param userList 返回的群组的在线成员列表
	   */
	  userList: ImUser[];
  }
  
  interface ImListRecentMessageReq {
	  /**
	   * @param groupId 群组id
	   */
	  groupId: string;
	  /**
	   * @param seqnum 消息序列号
	   */
	  seqnum?: number;
	  /**
	   * @param pageSize 分页拉取的大小，默认50条
	   */
	  pageSize?: number;
  }
  
  interface ImListRecentMessageRsp {
	  /**
	   * @param group_id 群组id
	   */
	  groupId: string;
	  /**
	   * @param message_list 返回消息列表
	   */
	  messageList: ImMessage[];
  }
  
  interface ImLoginReq {
	  user: ImUser;
	  /**
	   * 用户鉴权信息
	   */
	  userAuth: ImAuth;
  }
  
  enum ImLogLevel {
	  NONE = 0,
	  DBUG = 1,
	  INFO = 2,
	  WARN = 3,
	  ERROR = 4
  }
  
  interface ImMessage {
	  /**
	   * @param group_id 话题id,聊天插件实例id
	   */
	  groupId?: string;
	  /**
	   * @param message_id 消息id
	   */
	  messageId: string;
	  /**
	   *@param type 消息类型。系统消息小于10000
	   */
	  type: number;
	  /**
	   *@param sender 发送者
	   */
	  sender?: ImUser;
	  /**
	   **@param data 消息内容
	   */
	  data: string;
	  /**
	   *@param seqnum 消息顺序号
	   */
	  seqnum: number;
	  /**
	   *@param timestamp 消息发送时间
	   */
	  timestamp: number;
	  /**
	   *@param level 消息分级
	   **/
	  level: ImMessageLevel;
	  /**
	   * @param repeat_count 消息统计数量增长值，默认1，主要用于聚合同类型消息。
	   */
	  repeatCount: number;
	  /**
	   * @param totalmsgs 同类型的消息数量
	   */
	  totalMsgs: number;
  }
  
  enum ImMessageLevel {
	  NORMAL = 0,
	  HIGH = 1
  }
  
  interface ImMessageListener {
	  /**
	   * 接收到c2c消息
	   * @param msg 消息
	   */
	  recvc2cmessage: (msg: ImMessage) => void;
	  /**
	   * 接收到群消息
	   * @param msg 消息
	   * @param groupId 群id
	   */
	  recvgroupmessage: (msg: ImMessage, groupId: string) => void;
	  /**
	   * 删除群消息
	   * @param msgId 消息id
	   * @param groupId 群id
	   */
	  deletegroupmessage: (msgId: string, groupId: string) => void;
  }
  
  interface ImModifyGroupReq {
	  /**
	   * @param group_id 群组id
	   */
	  groupId: string;
	  /**
	   * @param groupMeta 群信息扩展字段，不修改留空
	   */
	  groupMeta?: string;
	  /**
	   * @param admins 群管理员ID，不修改留空
	   */
	  admins?: string[];
  }
  
  interface ImMuteAllReq {
	  /**
	   * @param group_id 群组id
	   */
	  groupId: string;
  }
  
  interface ImMuteUserReq {
	  /**
	   * @param group_id 群组id
	   */
	  groupId: string;
	  /**
	   * @param userList 需要禁言的用户列表
	   */
	  userList: string[];
  }
  
  interface ImQueryGroupReq {
	  /**
	   * @param group_id 群组id
	   */
	  groupId: string;
  }
  
  interface ImSdkConfig {
	  /**
	   * 设备唯一标识
	   */
	  deviceId?: string;
	  /**
	   * 应用ID
	   */
	  appId: string;
	  /**
	   * 应用签名
	   */
	  appSign: string;
	  /**
	   * 日志级别
	   */
	  logLevel?: ImLogLevel;
	  /**
	   * 来源
	   */
	  source?: string;
	  /**
	   * 心跳超时时间，单位是秒，默认 99s，允许 [15-120]s
	   */
	  heartbeatTimeout?: number;
	  /**
	   * @param extra 用户自定义参数
	   */
	  extra?: {
		  [key: string]: string;
	  };
  }
  
  interface ImSdkListener {
	  /**
	   * 连接中
	   */
	  connecting: () => void;
	  /**
	   * 连接成功
	   */
	  connectsuccess: () => void;
	  /**
	   * 连接失败
	   */
	  connectfailed: (error: Error) => void;
	  /**
	   * 连接断开
	   * @param code 断开原因 1:主动退出， 2:被踢出 3：超时等其他原因 4:在其他端上登录
	   */
	  disconnect: (code: number) => void;
	  /**
	   * token过期
	   * @param callback 更新 Token 的回调
	   */
	  tokenexpired: (callback: TokenCallback) => void;
	  /**
	   * 重连成功
	   */
	  reconnectsuccess: (groupInfos: ImGroupInfo[]) => void;
  }
  
  interface ImSendMessageToGroupReq {
	  /**
	   * @param group_id 话题id,聊天插件实例id
	   */
	  groupId: string;
	  /**
	   * @param type 消息类型，小于等于10000位系统消息，大于10000位自定义消息
	   */
	  type: number;
	  /**
	   * @param data 消息体
	   */
	  data: string;
	  /**
	   * @param skip_mute_check 跳过禁言检测，true:忽略被禁言用户，还可发消息；false：当被禁言时，消息无法发送，默认为false，即为不跳过禁言检测。
	   */
	  skipMuteCheck?: boolean;
	  /**
	   * @param skip_audit 跳过安全审核，true:发送的消息不经过阿里云安全审核服务审核；false：发送的消息经过阿里云安全审核服务审核，审核失败则不发送；
	   */
	  skipAudit?: boolean;
	  /**
	   * @param level 消息分级
	   */
	  level?: ImMessageLevel;
	  /**
	   * @param no_storage 为true时，表示该消息不需要存储，也无法拉取查询
	   */
	  noStorage?: boolean;
	  /**
	   * @param repeat_count 消息统计数量增长值，默认1，主要用于聚合同类型消息，只发送一次请求，例如点赞场景
	   */
	  repeatCount?: number;
  }
  
  interface ImSendMessageToUserReq {
	  /**
	   * 消息类型。系统消息小于10000
	   */
	  type: number;
	  /**
	   * 消息体
	   */
	  data: string;
	  /**
	   * 接收者用户
	   */
	  receiverId: string;
	  /**
	   * 跳过安全审核，true:发送的消息不经过阿里云安全审核服务审核；false：发送的消息经过阿里云安全审核服务审核，审核失败则不发送；
	   */
	  skipAudit?: boolean;
	  /**
	   * 消息分级
	   */
	  level?: ImMessageLevel;
  }
  
  enum ImSortType {
	  ASC = 0,
	  DESC = 1
  }
  
  interface ImUser {
	  /**
	   * @param user_id 用户id
	   */
	  userId: string;
	  /**
	   * @param user_extension 用户扩展信息
	   */
	  userExtension?: string;
  }
  
  type TokenCallback = (error: {
	  code?: number;
	  msg: string;
  } | null, auth?: ImAuth) => void;
  }