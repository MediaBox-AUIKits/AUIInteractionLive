import { IRoomInfo, LiveRoomType } from './room';

export interface IUserInfo {
  userId: string;
  userName: string;
  userAvatar?: string;
}

export interface ILiveRoomProps {
  roomType: LiveRoomType;
  userInfo: IUserInfo;
  onExit: () => void;
  getRoomInfo: () => Promise<IRoomInfo>;
  getToken: () => Promise<string>;
}
