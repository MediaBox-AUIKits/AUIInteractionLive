export * from './aliyunIMV1';
export * from './aliyunIMV2';

export enum AUIMessageEvents {
  onLikeInfo = 'onLikeInfo',
  onJoinGroup = 'onJoinGroup',
  onLeaveGroup = 'onLeaveGroup',
  onMuteGroup = 'onMuteGroup',
  onUnmuteGroup = 'onUnmuteGroup',
  onMuteUser = 'onMuteUser',
  onUnmuteUser = 'onUnmuteUser',
  onMessageReceived = 'onMessageReceived',
}

export enum AUIMessageTypes {
  PaaSLikeInfo = 1001, // 点赞数据
  PaaSUserJoin = 1002, // 用户进入消息组
  PaaSUserLeave = 1003, // 用户离开消息组
  PaaSMuteGroup = 1004, // 禁言消息组
  PaaSCancelMuteGroup = 1005, // 取消禁言消息组
  PaaSMuteUser = 1006, // 禁言消息组某个用户
  PaaSCancelMuteUser = 1007, // 取消禁言消息组某个用户
}

export interface AUIMessageUserInfo {
  userId: string;
  userNick?: string;
  userAvatar?: string;
  userExtension?: string;
}

export interface AUIMessageConfig {
  aliyunIMV2?: {
    appId: string;
    appSign: string;
    appToken: string;
    auth: {
      nonce: string;
      role: string;
      timestamp: number;
      userId: string;
    };
  },
  aliyunIMV1?: {
    accessToken: string;
    refreshToken: string;
  },
  rongCloud?: {
    accessToken: string;
  },
}

export enum AUIMessageInsType {
  AliyunIMV1,
  RongIM,
  AliyunIMV2,
}

interface BasicMap<U> {
  [index: string]: U;
}

export interface IMessageOptions {
  groupId?: string;
  type: number;
  data?: BasicMap<any>;
  skipAudit?: boolean;
  skipMuteCheck?: boolean;
  receiverId?: string;
}

export interface AUIMessageServerProps {
  aliyunIMV1?: {
    enable: boolean; // 是否开启旧阿里云互动消息服务
    primary?: boolean; // 是否是主消息服务
  };
  rongCloud?: {
    enable: boolean; // 是否开启融云互动消息服务
    appKey: string; // 融云的AppKey，用于初始化
    primary?: boolean; // 是否是主消息服务
  };
  aliyunIMV2?: {
    enable: boolean; // 是否开启阿里云新IM
    primary?: boolean; // 是否是主消息服务
  };
}

export interface AUIMessageGroupIdObject {
  aliyunV2GroupId?: string,
  aliyunV1GroupId?: string,
  rongIMId?: string,
}

export interface IGetMuteInfoRspModel {
  selfMuted?: boolean;
  groupMuted: boolean;
}

export interface IDeleteMessagesData {
  notify?: boolean; // 是否在所有端通知有消息被删除
  removeSids: string; // 分号;分隔多个sid
  sid?: string;
}

export interface IDeleteMessagesOptions extends IMessageOptions {
  data: IDeleteMessagesData;
}
