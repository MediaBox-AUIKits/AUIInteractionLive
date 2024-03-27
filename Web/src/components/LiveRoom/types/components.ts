import { IRoomInfo, LiveRoomType } from './room';

export interface IUserInfo {
  userId: string;
  userNick: string;
  userAvatar?: string;
}

export interface IInteracationTokenObject {
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
    extra?: {
      [key: string]: string;
    };
  },
}

export interface ILiveRoomProps {
  roomType: LiveRoomType;
  userInfo: IUserInfo;
  onExit: () => void;
  getRoomInfo: () => Promise<IRoomInfo>;
  getToken: (role?: string) => Promise<IInteracationTokenObject>;
}
