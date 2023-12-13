import { v4 as uuidv4 } from 'uuid';
import AliyunIMV1 from './AliyunIMV1';
import RongIM from './RongIM';
import AliyunIMV2 from './AliyunIMV2';
import {
  AUIMessageServerProps,
  AUIMessageGroupIdObject,
  AUIMessageConfig,
  AUIMessageUserInfo,
  AUIMessageTypes,
  AUIMessageEvents,
  AUIMessageInsType,
  IMessageOptions,
  IMSendLikeReqModel,
  IGetMuteInfoRspModel,
} from './types';
import EventBus from './utils/EventBus';

type IMType = AliyunIMV1 | RongIM | AliyunIMV2;

class AUIMessage extends EventBus {
  private aliyunIMV1?: AliyunIMV1;
  private rongIM?: RongIM;
  private aliyunIMV2?: AliyunIMV2;
  private primaryIns?: IMType;
  private instances: IMType[];
  private config?: AUIMessageConfig;
  private userInfo?: AUIMessageUserInfo;
  private sidSet = new Set<string>();
  private groupMuted = false;
  private _removeMessageType?: number;
  private removedMessageSidSet = new Set<string>();

  constructor(serverProps: AUIMessageServerProps) {
    super();

    const instances: IMType[] = [];
    if (serverProps.aliyunIMV1 && serverProps.aliyunIMV1.enable) {
      this.aliyunIMV1 = new AliyunIMV1();
      this.aliyunIMV1.addListener(
        'event',
        this.handleInteractionMessage.bind(this)
      );
      instances.push(this.aliyunIMV1);
      if (serverProps.aliyunIMV1.primary) {
        this.primaryIns = this.aliyunIMV1;
      }
    }

    if (
      serverProps.rongCloud &&
      serverProps.rongCloud.enable &&
      serverProps.rongCloud.appKey
    ) {
      this.rongIM = new RongIM(serverProps.rongCloud.appKey);
      this.rongIM.addListener(
        'event',
        this.handleInteractionMessage.bind(this)
      );
      if (serverProps.rongCloud.primary) {
        this.primaryIns = this.rongIM;
        instances.unshift(this.rongIM);
      } else {
        instances.push(this.rongIM);
      }
    }

    if (serverProps.aliyunIMV2 && serverProps.aliyunIMV2.enable) {
      this.aliyunIMV2 = new AliyunIMV2();
      this.aliyunIMV2.addListener(
        'event',
        this.handleInteractionMessage.bind(this)
      );
      if (serverProps.aliyunIMV2.primary) {
        this.primaryIns = this.aliyunIMV2;
        instances.unshift(this.aliyunIMV2);
      } else {
        instances.push(this.aliyunIMV2);
      }
    }
    this.instances = instances;

    if (!this.primaryIns) {
      this.primaryIns = this.aliyunIMV2 || this.aliyunIMV1 || this.rongIM;
    }
  }

  get rongCloundIM() {
    return this.rongIM;
  }

  get primaryInstance() {
    return this.primaryIns as IMType;
  }

  private handleInteractionMessage(eventData: any) {
    const { type, data, messageId } = eventData || {};
    const { sid } = data || {};
    if (sid) {
      if (this.sidSet.has(sid)) {
        return;
      }
      this.sidSet.add(sid);
    }

    switch (type) {
      case AUIMessageTypes.PaaSLikeInfo:
        this.emit(AUIMessageEvents.onLikeInfo, eventData);
        break;
      case AUIMessageTypes.PaaSUserJoin:
        this.emit(AUIMessageEvents.onJoinGroup, eventData);
        break;
      case AUIMessageTypes.PaaSUserLeave:
        this.emit(AUIMessageEvents.onLeaveGroup, eventData);
        break;
      case AUIMessageTypes.PaaSMuteGroup:
        if (this.groupMuted) {
          return;
        }
        this.groupMuted = true;
        this.emit(AUIMessageEvents.onMuteGroup, eventData);
        break;
      case AUIMessageTypes.PaaSCancelMuteGroup:
        if (!this.groupMuted) {
          return;
        }
        this.groupMuted = false;
        this.emit(AUIMessageEvents.onUnmuteGroup, eventData);
        break;
      case AUIMessageTypes.PaaSMuteUser:
        this.emit(AUIMessageEvents.onMuteUser, eventData);
        break;
      case AUIMessageTypes.PaaSCancelMuteUser:
        this.emit(AUIMessageEvents.onUnmuteUser, eventData);
        break;
      default:
        this.emit(AUIMessageEvents.onMessageReceived, eventData);
        break;
    }
  }

  setConfig(config: AUIMessageConfig) {
    this.config = config;
    this.instances.forEach(ins => ins.setConfig(config));
  }

  destroyInstance(insTypes: AUIMessageInsType[]) {
    const handleDestroyInstance = (ins?: IMType) => {
      if (!ins) {
        return;
      }
      const idx = this.instances.indexOf(ins);
      this.instances.splice(idx, 1);
      this.primaryIns = this.instances[0];
    };

    if (insTypes.includes(AUIMessageInsType.AliyunIMV1)) {
      handleDestroyInstance(this.aliyunIMV1);
    }
    if (insTypes.includes(AUIMessageInsType.RongIM)) {
      handleDestroyInstance(this.rongIM);
    }
    if (insTypes.includes(AUIMessageInsType.AliyunIMV2)) {
      handleDestroyInstance(this.aliyunIMV2);
    }
  }

  init() {
    return new Promise<void>((resolve, reject) => {
      const list = this.instances.map(ins => ins.init());
      Promise.all(list)
        .then(() => {
          resolve();
        })
        .catch(err => {
          reject(err);
        })
    })
  }

  unInit() {
    return new Promise<void>((resolve, reject) => {
      const list = this.instances.map(ins => ins.unInit());
      Promise.all(list)
        .then(() => {
          resolve();
        })
        .catch(err => {
          reject(err);
        })
    })
  }

  login(userInfo: AUIMessageUserInfo) {
    if (!this.config) {
      return Promise.reject({
        code: -1,
        message: 'please set config first',
      });
    }

    return new Promise<void>((resolve, reject) => {
      this.userInfo = userInfo;
      const list = this.instances.map(ins => ins.login(userInfo));
      Promise.all(list)
        .then(() => {
          resolve();
        })
        .catch(err => {
          reject(err);
        });
    });
  }

  logout() {
    return new Promise<void>((resolve, reject) => {
      const list = this.instances.map(ins => ins.logout());
      Promise.all(list)
        .then(() => {
          resolve();
        })
        .catch(err => {
          reject(err);
        });
    });
  }

  removeAllListeners() {
    return new Promise<void>((resolve, reject) => {
      const list = this.instances.map(ins => ins.removeAllListeners());
      Promise.all(list)
        .then(() => {
          resolve();
        })
        .catch(err => {
          reject(err);
        });
    });
  }

  joinGroup(groupIdObject: AUIMessageGroupIdObject) {
    const { aliyunV1GroupId, aliyunV2GroupId, rongIMId } = groupIdObject;
    return new Promise<void>((resolve, reject) => {
      const list = [];
      if (this.aliyunIMV1 && aliyunV1GroupId) {
        const p1 = this.aliyunIMV1.joinGroup(aliyunV1GroupId);
        list.push(p1);
      }
      if (this.rongIM && rongIMId) {
        const p2 = this.rongIM.joinGroup(rongIMId);
        list.push(p2);
      }
      if (this.aliyunIMV2 && aliyunV2GroupId) {
        const p3 = this.aliyunIMV2.joinGroup(aliyunV2GroupId);
        list.push(p3);
      }
      Promise.all(list)
        .then(() => {
          resolve();
        })
        .catch(err => {
          reject(err);
        });
    });
  }

  leaveGroup() {
    return new Promise<void>((resolve, reject) => {
      const list = this.instances.map(ins => ins.leaveGroup());
      Promise.all(list)
        .then(() => {
          resolve();
        })
        .catch(err => {
          reject(err);
        });
    });
  }

  muteGroup() {
    return new Promise<void>((resolve, reject) => {
      const list = this.instances.map(ins => ins.muteGroup());
      Promise.any(list)
        .then(() => {
          resolve();
        })
        .catch(err => {
          reject(err);
        });
    });
  }

  cancelMuteGroup() {
    return new Promise<void>((resolve, reject) => {
      const list = this.instances.map(ins => ins.cancelMuteGroup());
      Promise.any(list)
        .then(() => {
          resolve();
        })
        .catch(err => {
          reject(err);
        });
    });
  }

  muteUser(userId: string) {
    return new Promise<void>((resolve, reject) => {
      const list = this.instances.map(ins => ins.muteUser(userId));
      Promise.any(list)
        .then(() => {
          resolve();
        })
        .catch(err => {
          reject(err);
        });
    });
  }

  cancelMuteUser(userId: string) {
    return new Promise<void>((resolve, reject) => {
      const list = this.instances.map(ins => ins.cancelMuteUser(userId));
      Promise.any(list)
        .then(() => {
          resolve();
        })
        .catch(err => {
          reject(err);
        });
    });
  }

  sendMessageToGroup(options: IMessageOptions) {
    return new Promise<void>((resolve, reject) => {
      const sid = uuidv4();
      options.data = {
        ...(options.data || {}),
        sid,
      };
      const list = this.instances.map(ins => ins.sendMessageToGroup(options));
      Promise.any(list)
        .then(() => {
          resolve();
        })
        .catch(err => {
          reject(err);
        });
    });
  }

  sendMessageToGroupUser(options: IMessageOptions) {
    return new Promise<void>((resolve, reject) => {
      if (!options.receiverId) {
        reject({
          code: -1,
          message: 'need receiverId',
        });
        return;
      }
      const sid = uuidv4();
      options.data = {
        ...(options.data || {}),
        sid,
      };
      const list = this.instances.map(ins => ins.sendMessageToGroupUser(options));
      Promise.any(list)
        .then(() => {
          resolve();
        })
        .catch(err => {
          reject(err);
        });
    });
  }

  sendLike(data: IMSendLikeReqModel) {
    if (!this.primaryIns) {
      throw new Error('primary im server is empty');
    }
    return this.primaryIns.sendLike(data);
  }

  getGroupStatistics(groupId: string): Promise<any> {
    if (!this.primaryIns) {
      throw new Error('primary im server is empty');
    }
    return this.primaryIns.getGroupStatistics(groupId);
  }

  listMessage(type: number) {
    if (!this.primaryIns) {
      throw new Error('primary im server is empty');
    }
    return this.primaryIns.listMessage(type);
  }

  listRecentMessage(type: number) {
    if (!this.primaryIns) {
      throw new Error('primary im server is empty');
    }
    return this.primaryIns.listRecentMessage(type);
  }

  queryMuteStatus(): Promise<IGetMuteInfoRspModel> {
    if (!this.primaryIns) {
      throw new Error('primary im server is empty');
    }
    return this.primaryIns.queryMuteStatus();
  }

  // 删除群聊天消息，mvp 版本用特定 type 代表删除信令
  removeMessages(options: IMessageOptions) {
    return new Promise<void>((resolve, reject) => {
      const sid = uuidv4();
      options.data = {
        ...(options.data || {}),
        sid,
      };
      const list = this.instances.map(ins => ins.sendMessageToGroup(options));
      Promise.any(list)
        .then(() => {
          resolve();
        })
        .catch(err => {
          reject(err);
        });
    });
  }

  async updateRemovedMessageSidSet() {
    if (!this.primaryIns) {
      throw new Error('primary im server is empty');
    }

    if (this._removeMessageType === undefined) return;

    const removeMessagesRes = await this.primaryIns.listRecentMessage(
      this._removeMessageType
    );
    (removeMessagesRes?.messageList ?? []).forEach(({ data }) => {
      const { removeSids = '' } = data ? JSON.parse(data) : {};
      if (!removeSids) return;
      const removedMessageSids = removeSids
        .split(';')
        .map((sid: string) => sid.trim())
        .filter((sid: string) => !!sid);
      removedMessageSids.forEach((sid: string) =>
        this.removedMessageSidSet.add(sid)
      );
    });
  }

  async getChatRoomMessages(messageType: number) {
    if (!this.primaryIns) {
      throw new Error('primary im server is empty');
    }
    const chatRoomMessagesRes = await this.primaryIns.listRecentMessage(messageType);
    if (!chatRoomMessagesRes) throw new Error('return no listMessageRsp');

    const { messageList } = chatRoomMessagesRes;
    const parsedMessageList =
      messageList?.map(({ data, ...rest }) => {
        return {
          data: data ? JSON.parse(data) : {},
          ...rest,
        };
      }) ?? [];

    await this.updateRemovedMessageSidSet();

    if (!this.removedMessageSidSet.size) return parsedMessageList;

    return parsedMessageList?.filter(
      ({ data: { sid } }) => !this.removedMessageSidSet.has(sid)
    );
  }

  set removeMessageType(type: number) {
    this._removeMessageType = type;
  }
}

export default AUIMessage;
