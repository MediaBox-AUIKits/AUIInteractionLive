export enum InteractionV2EventNames {
  RecvC2cMessage = 'recvc2cmessage',
  RecvGroupMessage = 'recvgroupmessage',
  MuteChange = 'mutechange',
  Memberchange = 'memberchange',
}

export interface ImGroupInfo {
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

export interface ImGroupStatistics {
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

export interface ImGroupMuteStatus {
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

export interface ImMessage {
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

export enum ImLogLevel {
  NONE = 0,
  DBUG = 1,
  INFO = 2,
  WARN = 3,
  ERROR = 4
}

type Optional<T, K extends keyof T> = Pick<Partial<T>, K> & Omit<T, K>;
