import {
  AUIMessageConfig,
  AUIMessageUserInfo,
  InteractionEventNames,
  IMessageOptions,
  IMuteGroupReqModel,
  IMMuteUserReqModel,
  IGetMuteInfoRspModel,
  IMSendLikeReqModel,
  BroadcastTypeEnum,
} from './types';
import EventBus from './utils/EventBus';

const { InteractionEngine } = window.AliyunInteraction;

class AliyunIMV1 extends EventBus {
  engine: InstanceType<typeof InteractionEngine>;
  private config?: AUIMessageConfig;
  private userInfo?: AUIMessageUserInfo;
  private joinedGroupId?: string;

  constructor() {
    super();

    this.engine = InteractionEngine.create();
    this.engine.on(InteractionEventNames.Message, (eventData: any) => {
      this.emit('event', eventData || {});
    });
  }

  setConfig(config: AUIMessageConfig) {
    this.config = config;
  }

  init() { return Promise.resolve() }

  unInit() { return Promise.resolve() }

  login(userInfo: AUIMessageUserInfo) {
    return new Promise((resolve, reject) => {
      if (!this.config || !this.config.aliyunIMV1?.accessToken) {
        reject('please set config first');
        return;
      }
      this.userInfo = userInfo;
      const { accessToken } = this.config.aliyunIMV1;
      this.engine
        .auth(accessToken)
        .then(res => {
          resolve(res);
        })
        .catch(err => {
          reject(err);
        });
    });
  }

  logout() {
    return this.engine.logout();
  }

  removeAllListeners() {
    this.engine.removeAllEvents();
    super.removeAllEvent();
  }

  joinGroup(groupId: string) {
    return new Promise((resolve, reject) => {
      this.engine
        .joinGroup({
          groupId,
          userNick: this.userInfo?.userNick,
          userAvatar: this.userInfo?.userAvatar,
          broadCastStatistics: true,
          broadCastType: BroadcastTypeEnum.all,
        })
        .then(res => {
          this.joinedGroupId = groupId;
          resolve(res);
        })
        .catch(err => {
          reject(err);
        });
    });
  }

  leaveGroup() {
    if (!this.joinedGroupId) {
      return Promise.resolve(true);
    }
    const groupId = this.joinedGroupId;
    return new Promise((resolve, reject) => {
      this.engine
        .leaveGroup({ groupId, broadCastType: BroadcastTypeEnum.all })
        .then(res => {
          this.joinedGroupId = '';
          resolve(res);
        })
        .catch(err => {
          reject(err);
        });
    });
  }

  muteGroup() {
    const params: IMuteGroupReqModel = {
      groupId: this.joinedGroupId,
      broadCastType: BroadcastTypeEnum.all,
    }
    return this.engine.muteAll(params);
  }

  cancelMuteGroup() {
    const params: IMuteGroupReqModel = {
      groupId: this.joinedGroupId,
      broadCastType: BroadcastTypeEnum.all,
    }
    return this.engine.cancelMuteAll(params);
  }

  muteUser(userId: string) {
    const params: IMMuteUserReqModel = {
      groupId: this.joinedGroupId,
      muteUserList: [userId],
      broadCastType: 1,
    };
    return this.engine.muteUser(params);
  }

  cancelMuteUser(userId: string) {
    const params = {
      groupId: this.joinedGroupId,
      cancelMuteUserList: [userId],
      broadCastType: 1,
    };
    return this.engine.cancelMuteUser(params);
  }

  queryMuteStatus(): Promise<IGetMuteInfoRspModel> {
    // 旧IM查询禁言状态的逻辑，互动直播不使用，代码暂时保留
    return new Promise((resolve, reject) => {
      this.engine
        .getGroupUserByIdList({
          groupId: this.joinedGroupId,
          userIdList: [this.userInfo?.userId || ''],
        })
        .then((res: any) => {
          const info = ((res || {}).userList || [])[0] || {};
          const muteBy: string[] = info.muteBy || [];
          resolve({
            selfMuted: muteBy.includes('user'),
            groupMuted: muteBy.includes('group'),
          });
        })
        .catch(err => {
          reject(err);
        });
    });
  }

  sendLike(data: IMSendLikeReqModel) {
    return this.engine.sendLike(data);
  }

  getGroupStatistics(groupId: string) {
    return this.engine.getGroupStatistics({ groupId });
  }

  sendMessageToGroup(options: IMessageOptions) {
    const params = {
      ...options,
      groupId: options.groupId || this.joinedGroupId,
      data: JSON.stringify(options.data),
    };
    return this.engine.sendMessageToGroup(params);
  }

  sendMessageToGroupUser(options: IMessageOptions) {
    const params = {
      ...options,
      groupId: this.joinedGroupId,
      receiverIdList: options.receiverId ? [options.receiverId] : undefined,
      data: JSON.stringify(options.data),
    };
    return this.engine.sendMessageToGroupUsers(params);
  }

  listMessage(type: number) {
    const params = {
      groupId: this.joinedGroupId,
      type,
      sortType: 0,
      pageNum: 1,
      pageSize: 20,
    };
    return this.engine.listMessage(params);
  }

  listRecentMessage(type: number) {
    const params = {
      groupId: this.joinedGroupId,
      type,
      sortType: 0,
      pageNum: 1,
      pageSize: 20,
    };
    return this.engine.listMessage(params);
  }
}

export default AliyunIMV1;
