import {
  AUIMessageConfig,
  AUIMessageUserInfo,
  IMessageOptions,
  AUIMessageTypes,
  ImMessage,
  InteractionV2EventNames,
  ImGroupMuteStatus,
  ImLogLevel,
  ImGroupInfo,
  IGetMuteInfoRspModel,
} from './types';
import EventBus from './utils/EventBus';

const { ImEngine } = window.AliVCInteraction;

class AliyunIMV2 extends EventBus {
  engine: InstanceType<typeof ImEngine>;
  private config?: AUIMessageConfig;
  private userInfo?: AUIMessageUserInfo;
  private joinedGroupId: string = '';
  private muteAllStatus?: boolean;
  private muteUserStatus?: boolean;

  constructor() {
    super();
    this.engine = ImEngine.createEngine();
  }

  private listenV2IMEvents() {
    this.engine.getMessageManager()
      ?.on(InteractionV2EventNames.RecvC2cMessage, (eventData: ImMessage) => {
        this.emit('event', {
          ...eventData,
          data: JSON.parse(eventData.data),
          senderId: eventData.sender?.userId,
          senderInfo: eventData.sender,
        });
      });

    this.engine.getMessageManager()
      ?.on(InteractionV2EventNames.RecvGroupMessage, (eventData: ImMessage) => {
        this.emit('event', {
          ...eventData,
          data: JSON.parse(eventData.data),
          senderId: eventData.sender?.userId,
          senderInfo: eventData.sender,
        });
      });

    this.engine.getGroupManager()
      ?.on(InteractionV2EventNames.MuteChange, (groupId: string, status: ImGroupMuteStatus) => {
        let type;
        const newMuteUserStatus = status.muteUserList.includes(this.userInfo?.userId as string);
        if (status.muteAll !== this.muteAllStatus) {
          type = status.muteAll ? AUIMessageTypes.PaaSMuteGroup : AUIMessageTypes.PaaSCancelMuteGroup;
          this.muteAllStatus = status.muteAll;
          this.emit('event', {
            type,
            data: {
              status,
            },
            groupId,
            senderId: 'send from V2 IM sdk',
            messageId: '',
            senderInfo: {
              userId: 'send from V2 IM sdk',
              userNick: '',
              userAvatar: '',
            },
          });
        }
        if (newMuteUserStatus !== this.muteUserStatus) {
          type = newMuteUserStatus? AUIMessageTypes.PaaSMuteUser : AUIMessageTypes.PaaSCancelMuteUser;
          this.muteUserStatus = newMuteUserStatus;
          this.emit('event', {
            type,
            data: {
              status,
            },
            groupId,
            senderId: 'send from V2 IM sdk',
            messageId: '',
            senderInfo: {
              userId: 'send from V2 IM sdk',
              userNick: '',
              userAvatar: '',
            },
          });
        }
      });

    this.engine.getGroupManager()
      ?.on(InteractionV2EventNames.Join, (groupId: string, user: AUIMessageUserInfo) => {
        this.emit('event', {
          type: AUIMessageTypes.PaaSUserJoin,
          data: {
            user,
          },
          groupId,
          senderId: user.userId,
          messageId: '',
          senderInfo: user,
        });
      });

    this.engine.getGroupManager()
      ?.on(InteractionV2EventNames.Leave, (groupId: string, user: AUIMessageUserInfo) => {
        this.emit('event', {
          type: AUIMessageTypes.PaaSUserLeave,
          data: {
            user,
          },
          groupId,
          senderId: user.userId,
          messageId: '',
          senderInfo: user,
        });
      });
  }

  setConfig(config: AUIMessageConfig) {
    this.config = config;
  }

  init() {
    return new Promise((resolve, reject) => {
      this.engine.init({
        appId: this.config?.aliyunIMV2?.appId as string,
        appSign: this.config?.aliyunIMV2?.appSign as string,
        // logLevel: ImLogLevel.DBUG // 开启新版IM debug模式
      }).then(res => {
        // init后监听新IM事件
        this.listenV2IMEvents();
        resolve(res);
      }).catch(err => {
        reject(err);
      });
    });
  }

  unInit() {
    return new Promise<void>((resolve, reject) => {
      if (this.engine.unInit()) {
        resolve();
      } else {
        reject();
      }
    })
  }

  login(userInfo: AUIMessageUserInfo) {
    return new Promise((resolve, reject) => {
      this.userInfo = userInfo;
      this.engine.login({
        user: {
          userId: this.userInfo.userId,
        },
        userAuth: {
          nonce: this.config?.aliyunIMV2?.auth.nonce as string,
          timestamp: this.config?.aliyunIMV2?.auth.timestamp as number,
          role: this.config?.aliyunIMV2?.auth.role,
          token: this.config?.aliyunIMV2?.appToken as string,
        },
      }).then(res => {
        resolve(res);
      }).catch(err => {
        reject(err);
      });
    });
  }

  logout() {
    return this.engine.logout();
  }

  removeAllListeners() {
    this.engine.removeAllListeners();
    super.removeAllEvent();
  }

  joinGroup(groupId: string) {
    return new Promise((resolve, reject) => {
      this.engine.getGroupManager()
        ?.joinGroup(groupId)
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
    return new Promise((resolve, reject) => {
      this.engine.getGroupManager()
        ?.leaveGroup(this.joinedGroupId)
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
    return this.engine.getGroupManager()?.muteAll(this.joinedGroupId);
  }

  cancelMuteGroup() {
    return this.engine.getGroupManager()?.cancelMuteAll(this.joinedGroupId);
  }

  muteUser(userId: string) {
    const params = {
      groupId: this.joinedGroupId,
      userList: [userId],
    };
    return this.engine.getGroupManager()?.muteUser(params);
  }

  cancelMuteUser(userId: string) {
    const params = {
      groupId: this.joinedGroupId,
      userList: [userId],
    };
    return this.engine.getGroupManager()?.cancelMuteUser(params);
  }

  queryMuteStatus(): Promise<IGetMuteInfoRspModel> {
    return new Promise((resolve, reject) => {
      this.engine.getGroupManager()
        ?.queryGroup(this.joinedGroupId)
        .then((res: ImGroupInfo) => {
          resolve({
            selfMuted: res.muteStatus.muteUserList.includes(this.userInfo?.userId as string),
            groupMuted: res.muteStatus.muteAll,
          });
        })
        .catch(err => {
          reject(err);
        });
    });
  }

  // 业务自行实现sendLike逻辑
  sendLike() {
    console.log('AliyunIMV2 业务自行实现sendLike逻辑');
    return Promise.resolve();
  }

  getGroupStatistics(groupId: string) {
    return this.engine.getGroupManager()?.queryGroup(groupId)
      .then(res => res.statistics) as Promise<any>;
  }

  sendMessageToGroup(options: IMessageOptions) {
    const params = {
      ...options,
      groupId: options.groupId || this.joinedGroupId,
      data: JSON.stringify(options.data || {}),
    };
    return this.engine.getMessageManager()?.sendGroupMessage(params);
  }

  sendMessageToGroupUser(options: IMessageOptions) {
    const params = {
      ...options,
      receiverId: options.receiverId as string,
      data: JSON.stringify(options.data || {}),
    };
    return this.engine.getMessageManager()?.sendC2cMessage(params);
  }

  listMessage(type: number) {
    const params = {
      groupId: this.joinedGroupId,
      type,
      sortType: 0,
      nextpagetoken: 1,
      pageSize: 20,
    };
    return this.engine.getMessageManager()?.listMessage(params);
  }

  listRecentMessage(type: number) {
    return this.engine.getMessageManager()?.listRecentMessage({
      groupId: this.joinedGroupId,
    })
      .then(res => ({
        ...res,
        messageList: res?.messageList.filter((msg: ImMessage) => msg.type === type).map((_msg: ImMessage) => ({
          ..._msg,
          senderId: _msg.sender?.userId,
          senderInfo: _msg.sender,
        })).reverse().slice(0,20),
      }));
  }
}

export default AliyunIMV2;
