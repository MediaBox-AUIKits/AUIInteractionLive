import React from 'react';
import {
  IRoomInfo,
  IRoomState,
  RoomStatusEnum,
  RoomModeEnum,
  BasicMap,
  LiveRoomType,
  LiveRoomTypeEnum,
} from './types';

export const defaultRoomState: IRoomState = {
  id: '',
  anchorId: '',
  chatId: '',
  createdAt: '',
  extends: '',
  mode: 0,
  pkId: '',
  status: RoomStatusEnum.no_data,
  title: '',
  updatedAt: '',
  notice: '',
  coverUrl: '',

  // 直播间观众数据
  likeCount: 0,
  onlineCount: 0,
  pv: 0,
  totalCount: 0,
  uv: 0,

  // 拉流地址
  flvUrl: '',
  hlsUrl: '',
  rtmpUrl: '',
  rtsUrl: '',

  // 回看相关
  isPlayback: false,

  // 互动消息 相关
  messageList: [],
  commentInput: '',
  groupMuted: false,
  selfMuted: false,

  // 样式相关
  pcTheme: 'light', // pc直播间主题
};

interface IRoomReducerAction {
  type: string;
  payload?: BasicMap<any>;
}

function flatRoomDetail(info: IRoomInfo) {
  const obj: BasicMap<any> = { ...info };
  delete obj.pullUrlInfo;
  delete obj.metrics;

  let groupMuted = false;
  let selfMuted = false;
  if (info.userStatus.mute && Array.isArray(info.userStatus.muteSource)) {
    groupMuted = info.userStatus.muteSource.includes('group');
    selfMuted = info.userStatus.muteSource.includes('user');
  }

  let pullUrlInfo = {};
  // 普通直播时使用 pullUrlInfo 中的播放地址
  if (info.mode === RoomModeEnum.normal) {
    pullUrlInfo = info.pullUrlInfo || {};
  } else if (info.linkInfo) {
    // 连麦直播时使用 linkInfo.cdnPullInfo 中的播放地址
    pullUrlInfo = info.linkInfo.cdnPullInfo || {};
  }

  return {
    ...obj,
    ...pullUrlInfo,
    ...(info.metrics || {}),
    groupMuted,
    selfMuted,
  };
}

export function roomReducer(state: IRoomState, action: IRoomReducerAction) {
  switch (action.type) {
    case 'update':
      if (!action.payload) {
        return state;
      }
      return { ...state, ...action.payload };
    case 'updateRoomDetail':
      const roomDetail = (action.payload || {}) as IRoomInfo;
      const data = flatRoomDetail(roomDetail);
      // console.log('updateRoomDetail', data);
      return { ...state, ...data };
    case 'updateMetrics':
      // 更新直播间统计数据，这部分需要跟当前值做比较，取最大值
      const metrics: any = (action.payload || {});
      const keys: string[] = Object.keys(metrics);
      const metricData: any = {};
      keys.forEach((key: string) => {
        if (typeof state[key] === 'number' && typeof metrics[key] === 'number') {
          metricData[key] = Math.max(state[key], metrics[key]);
        }
      });
      // console.log('updateMetrics', metricData);
      if (Object.keys(metricData).length === 0) {
        return state;
      }
      return { ...state, ...metricData };
    case 'reset':
      return { ...defaultRoomState };
    default:
      throw new Error();
  }
}

const { InteractionEngine } = window.AliyunInteraction;

type RoomContextType = {
  interaction?: InstanceType<typeof InteractionEngine>,
  roomState: IRoomState;
  roomType: LiveRoomType;
  animeContainerEl: React.RefObject<HTMLDivElement>,
  bulletContainerEl: React.RefObject<HTMLDivElement>,
  dispatch: React.Dispatch<IRoomReducerAction>;
  sendComment: (text: string) => Promise<any>;
  sendLike: () => void;
  exit: () => void;
}

export const RoomContext  = React.createContext<RoomContextType>({
  roomState: defaultRoomState,
  roomType: LiveRoomTypeEnum.Interaction,
  animeContainerEl: React.createRef(),
  bulletContainerEl: React.createRef(),
  dispatch: () => {},
  sendComment: () => Promise.resolve(),
  sendLike: () => {},
  exit: () => {},
});
