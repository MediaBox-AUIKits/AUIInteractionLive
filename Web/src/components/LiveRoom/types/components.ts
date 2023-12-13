import { IRoomInfo, LiveRoomType } from './room';

export interface IUserInfo {
  userId: string;
  userName: string;
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
  },
  aliyunIMV1?: {
    accessToken: string;
    refreshToken: string;
  },
}

export interface ILiveRoomProps {
  roomType: LiveRoomType;
  userInfo: IUserInfo;
  onExit: () => void;
  getRoomInfo: () => Promise<IRoomInfo>;
  getToken: (role?: string) => Promise<IInteracationTokenObject>;
}
