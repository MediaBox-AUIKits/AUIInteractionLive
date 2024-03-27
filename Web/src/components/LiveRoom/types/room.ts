import { ISpectatorInfo } from '@/types/interaction';

export interface IMetricsInfo {
  likeCount: number; // 点赞数
  onlineCount: number; // 当前在线数
  pv: number;
  totalCount: number;
  uv: number;
}

export interface IPullUrlInfo {
  flvUrl: string;
  hlsUrl: string;
  rtmpUrl: string;
  rtsUrl: string;
}

export interface ILinkUrlInfo {
  rtcPullUrl: string;
  rtcPushUrl: string;
  cdnPullInfo: IPullUrlInfo;
}

export interface IUserStatus {
  mute: boolean, // 是否禁言
  muteSource: string[] | null; // 禁言原因
}

export enum RoomStatusEnum {
  no_data = -1, // 非服务端状态，意思为还未取到数据
  not_start = 0, // 未开播
  started = 1, // 已开始
  ended = 2, // 已结束
}

export enum VODStatusEnum {
  preparing = 0, // 准备中
  success = 1, // 成功
  fail = 2, // 失败
}

export interface IPlaylistItem {
  bitRate: string;
  creationTime: string;
  definition: string; // 清晰度标识
  format: string; // 文件格式
  duration: string; // 数字字符串
  fps: string; // 数字字符串
  width: number;
  height: number;
  playUrl: string;
  size: number;
  streamType: string; // 流类型，video | audio
}

export interface IVODInfo {
  status: VODStatusEnum,
  playlist: IPlaylistItem[],
}

export interface IRoomInfo {
  id: string; // 直播间 id
  anchorId: string; // 创建者id
  chatId: string; // im 聊天组 id
  createdAt: string; // 创建时间
  extends: string; // 额外配置 jsonstring
  coverUrl: string; // 封面图片
  notice: string; // 公告
  metrics: IMetricsInfo; // 直播间观众数据
  mode: number; // 直播模式 0-普通直播, 1-连麦直播, 2-PK直播
  pkId: string; // 未知
  pullUrlInfo: IPullUrlInfo; // 拉流地址对象
  status: RoomStatusEnum; // 状态
  title: string; // 直播间标题
  updatedAt: string; // 更新时间
  userStatus: IUserStatus;
  // 连麦有的字段
  linkInfo?: ILinkUrlInfo;
  meetingInfo?: string;
  // vod 回看数据
  vodInfo?: IVODInfo;
}

export enum RoomModeEnum {
  normal = 0, // 普通直播
  rtc = 1, // 连麦直播
  pkId = 2, // PK直播
}

export interface InteractionMessage {
  messageId?: string;
  nickName?: string;
  content: string;
  isSelf?: boolean; // 是否是自己发的
  isAnchor?: boolean; // 是否是主播发的
}

// room context 打平对象，方便更新、使用
export interface IRoomState {
  id: string; // 直播间 id
  anchorId: string; // 创建者id
  chatId: string; // im 聊天组 id
  createdAt: string; // 创建时间
  extends: string; // 额外配置 jsonstring
  mode: number; // 直播模式，0-普通直播, 1-连麦直播，2-PK直播
  pkId: string; // 未知
  status: RoomStatusEnum;
  title: string; // 直播间标题
  updatedAt: string; // 更新时间
  notice: string; // 公告
  coverUrl: string; // 封面图片

  // 直播间观众数据
  likeCount: number; // 点赞数
  onlineCount: number; // 当前在线数
  pv: number;
  totalCount: number;
  uv: number;

  // 拉流地址
  flvUrl: string;
  hlsUrl: string;
  rtmpUrl: string;
  rtsUrl: string;

  // vod 回看数据
  vodInfo?: IVODInfo;
  isPlayback: boolean;

  // 互动消息 相关
  messageList: InteractionMessage[];
  commentInput: string; // 输入框内容
  groupMuted: boolean, // 互动消息 组是否被禁言
  selfMuted: boolean, // 个人是否被禁言

  pcTheme: 'light' | 'dark',

  // 连麦
  connectedSpectators: ISpectatorInfo[];
  rtcPushUrl: string,
  rtcPullUrl: string,
  cameraOpened: boolean,
  micOpened: boolean,
  selfPushReady: boolean,
  facingMode: 'user'|'environment'

  [x: string]: any,
}

export enum LiveRoomTypeEnum {
  Enterprise = 'enterprise', // enterprise 企业直播
  Interaction = 'interaction', // interaction 互动直播
}

export type LiveRoomType = `${LiveRoomTypeEnum}`;

export interface GroupIdObject {
  aliyunV2GroupId?: string,
  rongIMId?: string,
}
