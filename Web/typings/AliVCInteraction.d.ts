// 阿里云新IM类型文件
export declare namespace AliVCInteraction {
	class AliVCIMGroupManager extends EventEmitter<ImGroupListener> {
		private wasmIns;
		private wasmGroupManager;
		private groupListener;
		constructor(wasmIns: any, wasmEngine: any);
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
		 * @param {string} groupId
		 * @returns {Promise<ImGroupInfo>}
		 */
		queryGroup(groupId: string): Promise<ImGroupInfo>;
		/**
		 * 关闭群组，限管理员才能操作
		 * @param {string} groupId
		 * @returns {Promise<void>}
		 */
		closeGroup(groupId: string): Promise<void>;
		/**
		 * 加入群组
		 * @param {string} groupId
		 * @returns {Promise<ImGroupInfo>}
		 */
		joinGroup(groupId: string): Promise<ImGroupInfo>;
		/**
		 * 离开群组
		 * @param {string} groupId
		 * @returns {Promise<void>}
		 */
		leaveGroup(groupId: string): Promise<void>;
		/**
		 * 修改群组信息
		 * @param {ImModifyGroupReq} req
		 * @returns {Promise<void>}
		 */
		modifyGroup(req: ImModifyGroupReq): Promise<void>;
		/**
		 * 查询最近组成员
		 * @param {string} groupId
		 * @returns {Promise<ImListRecentGroupUserRsp>}
		 */
		listRecentGroupUser(groupId: string): Promise<ImListRecentGroupUserRsp>;
		/**
		 * 查询群组成员，限管理员才能操作
		 * @param {ImListGroupUserReq} req
		 * @returns {Promise<ImListGroupUserRsp>}
		 */
		listGroupUser(req: ImListGroupUserReq): Promise<ImListGroupUserRsp>;
		/**
		 * 全体禁言，限管理员才能操作
		 * @param {string} groupId
		 * @returns {Promise<void>}
		 */
		muteAll(groupId: string): Promise<void>;
		/**
		 * 取消全体禁言，限管理员才能操作
		 * @param {string} groupId
		 * @returns {Promise<void>}
		 */
		cancelMuteAll(groupId: string): Promise<void>;
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
		 * @param {string} groupId
		 * @returns {Promise<ImListMuteUsersRsp>}
		 */
		listMuteUsers(groupId: string): Promise<ImListMuteUsersRsp>;
	}

	class AliVCIMMessageManager extends EventEmitter<ImMessageListener> {
		private wasmIns;
		private wasmMessageManager;
		private messageListener;
		constructor(wasmIns: any, wasmEngine: any);
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
		 * @param {ImListRecentMessageReq} req
		 * @returns {ImListRecentMessageRsp}
		 */
		listRecentMessage(req: ImListRecentMessageReq): Promise<ImListRecentMessageRsp>;
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

	type ImCreateGroupReq = Optional<_ImCreateGroupReq, 'groupId' | 'groupMeta'>;

	interface _ImCreateGroupReq {
		/**
		 * @param group_id 群组id，【可选】id为空的话，会由sdk内部生成
		 */
		groupId: string;
		/**
		 * @param groupName 群组名称
		 */
		groupName: string;
		/**
		 * @param extension 业务扩展字段
		 */
		groupMeta: string;
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

	class ImEngine extends EventEmitter<ImSdkListener> {
		private wasmIns;
		private logLevel?;
		private wasmEngine;
		private aliRts;
		private dataChannelMap;
		private tokenCallback;
		private eventListener;
		private messageManager?;
		private groupManager?;
		constructor();
		static engine: ImEngine;
		/**
		 * @brief 获取 SDK 引擎实例（单例）
		 * @returns ImEngine
		 */
		static createEngine(): ImEngine;
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
		private debug;
		/**
		 * @brief 更新 token
		 * @param token
		 */
		updateToken(token: string): void;
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
		join: (groupId: string, user: ImUser) => void;
		leave: (groupId: string, user: ImUser) => void;
		close: (groupId: string, reason: number) => void;
		mutechange: (groupId: string, status: ImGroupMuteStatus) => void;
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

	type ImListGroupUserReq = Optional<_ImListGroupUserReq, 'nextpagetoken' | 'pageSize' | 'sortType'>;

	interface _ImListGroupUserReq {
		/**
		 * @param group_id 群组id
		 */
		groupId: string;
		/**
		 * @param sortType 排序方式,ASC-先加入优先，DESC-后加入优先
		 */
		sortType: ImSortType;
		/**
		 * @param nextpagetoken 默认表示第一页,遍历时服务端会返回，客户端获取下一页时，应带上
		 */
		nextpagetoken: number;
		/**
		 * @param pageSize 最大不超过50
		 */
		pageSize: number;
	}

	interface ImListGroupUserRsp {
		/**
		 * @param group_id 群组id
		 */
		groupId: string;
		/**
		 * @param nextpagetoken 下一页的token
		 */
		nextpagetoken: number;
		/**
		 * @param hasMore 是否还有下一页
		 */
		hasMore: boolean;
		/**
		 * @param userList 返回的群组的在线成员列表
		 */
		userList: ImUser[];
	}

	type ImListMessageReq = Optional<_ImListMessageReq, 'nextpagetoken' | 'sortType' | 'pageSize'>;

	interface _ImListMessageReq {
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
		nextpagetoken: number;
		/**
		 * @param sorttype 排序类型，默认为时间递增
		 */
		sortType: ImSortType;
		/**
		 * @param pageSize 分页拉取的大小，默认10条，最大30条
		 */
		pageSize: number;
	}

	interface ImListMessageRsp {
		/**

		 * @param group_id 群组id
		 */
		groupId: string;
		/**
		 *@param nextpagetoken 客户端获取下一页时，应带上
		 */
		nextpagetoken: number;
		/**
		 *@param hasmore 是否有更多数据
		 */
		hasMore: boolean;
		/**
		 *@param message_list 返回消息列表
		 **/
		messageList: ImMessage[];
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

	type ImListRecentMessageReq = Optional<_ImListRecentMessageReq, 'pageSize' | 'seqnum'>;

	interface _ImListRecentMessageReq {
		/**
		 * @param groupId 群组id
		 */
		groupId: string;
		/**
		 * @param seqnum 消息序列号
		 */
		seqnum: number;
		/**
		 * @param pageSize 分页拉取的大小，默认50条
		 */
		pageSize: number;
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
	}

	enum ImMessageLevel {
		NORMAL = 0,
		HIGH = 1
	}

	interface ImMessageListener {
		recvc2cmessage: (msg: ImMessage) => void;
		recvgroupmessage: (msg: ImMessage, groupId: string) => void;
	}

	type ImModifyGroupReq = Optional<_ImModifyGroupReq, 'groupMeta' | 'admins'>;

	interface _ImModifyGroupReq {
		/**
		 * @param group_id 群组id
		 */
		groupId: string;
		/**
		 * @param groupMeta 群信息扩展字段，不修改留空
		 */
		groupMeta: string;
		/**
		 * @param admins 群管理员ID，不修改留空
		 */
		admins: string[];
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

	type ImSdkConfig = Optional<_ImSdkConfig, 'deviceId' | 'logLevel' | 'source'>;

	interface _ImSdkConfig {
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
		logLevel: ImLogLevel;
		/**
		 * 来源
		 */
		source: string;
	}

	interface ImSdkListener {
		connecting: () => void;
		connectsuccess: () => void;
		connectfailed: (error: Error) => void;
		disconnect: (code: number) => void;
		tokenexpired: (callback: TokenCallback) => void;
		reconnectsuccess: () => void;
	}

	type ImSendMessageToGroupReq = Optional<_ImSendMessageToGroupReq, 'skipMuteCheck' | 'skipAudit' | 'level'>;

	interface _ImSendMessageToGroupReq {
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
		skipMuteCheck: boolean;
		/**
		 * @param skip_audit 跳过安全审核，true:发送的消息不经过阿里云安全审核服务审核；false：发送的消息经过阿里云安全审核服务审核，审核失败则不发送；
		 */
		skipAudit: boolean;
		/**
		 * @param level 消息分级
		 */
		level: ImMessageLevel;
	}

	type ImSendMessageToUserReq = Optional<_ImSendMessageToUserReq, 'skipAudit' | 'level'>;

	interface _ImSendMessageToUserReq {
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
		skipAudit: boolean;
		/**
		 * 消息分级
		 */
		level: ImMessageLevel;
	}

	enum ImSortType {
		ASC = 0,
		DESC = 1
	}

	type ImUser = Optional<_ImUser, 'userNick' | 'userAvatar' | 'userExtension'>;

	interface _ImUser {
		/**
		 * @param user_id 用户id
		 */
		userId: string;
		/**
		 * @param user_nick 用户昵称
		 */
		userNick: string;
		/**
		 * @param user_avatar 用户头像地址
		 */
		userAvatar: string;
		/**
		 * @param user_extension 用户扩展信息
		 */
		userExtension: string;
	}

	type Optional<T, K extends keyof T> = Pick<Partial<T>, K> & Omit<T, K>;

	type TokenCallback = (error: {
		code?: number;
		msg: string;
	} | null, auth?: ImAuth) => void;
}
