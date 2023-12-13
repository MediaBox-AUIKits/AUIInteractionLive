import { IAReceivedMessage, IConversationOption } from '@rongcloud/imlib-next';
import * as RongIMLib from '@rongcloud/imlib-next';
import {
  AUIMessageConfig,
  AUIMessageUserInfo,
  IMessageOptions,
  AUIMessageTypes,
  IGetMuteInfoRspModel,
} from './types';
import EventBus from './utils/EventBus';

const RCEvents = RongIMLib.Events;

interface RongServices {
  isMuteChatroom: (
    chatroomId: string,
    serverType: string
  ) => Promise<{ result: boolean }>;
  muteChatroom: (
    chatroomId: string,
    serverType: string
  ) => Promise<{ result: boolean }>;
  cancelMuteChatroom: (
    chatroomId: string,
    serverType: string
  ) => Promise<{ result: boolean }>;
  muteUser: (
    chatroomId: string,
    userId: string,
    minute: number,
    serverType: string
  ) => Promise<{ result: boolean }>;
  cancelMuteUser: (
    chatroomId: string,
    userId: string,
    serverType: string
  ) => Promise<{ result: boolean }>;
  [x: string]: any;
}

class RongIM extends EventBus {
  private config?: AUIMessageConfig;
  private userInfo?: AUIMessageUserInfo;
  private joinedGroupId?: string;
  private services: RongServices = {
    isMuteChatroom: () => Promise.resolve({ result: false }),
    muteChatroom: () => Promise.resolve({ result: false }),
    cancelMuteChatroom: () => Promise.resolve({ result: false }),
    muteUser: () => Promise.resolve({ result: false }),
    cancelMuteUser: () => Promise.resolve({ result: false }),
  };

  constructor(appkey: string) {
    super();

    // 应用初始化，请务必保证此过程只被执行一次
    RongIMLib.init({ appkey });
    this.listenRCEvents();
  }

  // 设置 http 接口服务
  setServices(services: RongServices) {
    if (services) {
      this.services = services;
    }
  }

  private listenRCEvents() {
    // 消息事件
    RongIMLib.addEventListener(RCEvents.MESSAGES, evt => {
      // console.log('融云消息', evt);
      const messages = evt.messages;
      messages.forEach(item => {
        this.handleMessage(item);
      });
    });
    RongIMLib.addEventListener(RCEvents.CHATROOM, event => {
      if (event.userChange) {
        // console.log('加入退出的用户通知:', event.userChange)
        const { chatroomId, users } = event.userChange;
        for (const key in users) {
          if (Object.prototype.hasOwnProperty.call(users, key)) {
            const value = users[key];
            let type = 0;
            if (value === 0) {
              type = AUIMessageTypes.PaaSUserLeave;
            } else if (value === 1) {
              type = AUIMessageTypes.PaaSUserJoin;
            }
            if (type) {
              this.emit('event', {
                type,
                data: {
                  time: Date.now(),
                },
                groupId: chatroomId,
                senderId: key,
                messageId: '',
                senderInfo: {
                  userId: key,
                  userNick: '',
                  userAvatar: '',
                },
              });
            }
          }
        }
      }
      if (event.chatroomNotifyBan) {
        // 暂时只处理群禁言
        console.log('聊天室用户禁言通知:', event.chatroomNotifyBan);
        const { banType, chatroomId, userIdList } = event.chatroomNotifyBan;
        const map: any = {
          // banType = 0：解除指定聊天室中用户禁言
          0: AUIMessageTypes.PaaSCancelMuteUser,
          // banType = 1：禁言指定聊天室中用户
          1: AUIMessageTypes.PaaSMuteUser,
          // banType = 2：解除聊天室全体禁言
          2: AUIMessageTypes.PaaSCancelMuteGroup,
          // banType = 3：聊天室全体禁言
          3: AUIMessageTypes.PaaSMuteGroup,
        };
        if (chatroomId !== this.joinedGroupId || !map[banType]) {
          return;
        }
        if (
          [0, 1].includes(banType) &&
          !userIdList.includes(this.userInfo?.userId || '')
        ) {
          return;
        }
        this.emit('event', {
          type: map[banType],
          groupId: chatroomId,
          senderId: 'rongcloud_system',
          messageId: '',
          senderInfo: {
            userId: 'rongcloud_system',
            userNick: '',
            userAvatar: '',
          },
        });
      }
    });
  }

  private handleMessage(message: IAReceivedMessage) {
    try {
      const contents = JSON.parse(message.content.content);
      const data = JSON.parse(contents.data);
      this.emit('event', {
        type: contents.type,
        data,
        groupId: this.joinedGroupId,
        senderId: message.senderUserId,
        messageId: message.messageId,
        senderInfo: {
          userId: message.senderUserId,
          userNick: contents.nick || '',
          userAvatar: contents.avatar || '',
        },
      });
    } catch (error) {
      //
    }
  }

  setConfig(config: AUIMessageConfig) {
    this.config = config;
  }

  init() { return Promise.resolve() }

  unInit() { return Promise.resolve() }

  login(userInfo: AUIMessageUserInfo) {
    return new Promise((resolve, reject) => {
      if (!this.config || !this.config.rongCloud?.accessToken) {
        reject('please set config first');
        return;
      }
      this.userInfo = userInfo;
      const { accessToken } = this.config.rongCloud;
      RongIMLib.connect(accessToken)
        .then(res => {
          if (res.code === RongIMLib.ErrorCode.SUCCESS) {
            resolve(true);
          } else {
            reject(res);
          }
        })
        .catch(err => {
          reject(err);
        });
    });
  }

  logout() {
    return RongIMLib.disconnect();
  }

  removeAllListeners() {
    RongIMLib.removeEventListeners(RCEvents.MESSAGES);
    RongIMLib.removeEventListeners(RCEvents.CHATROOM);
    super.removeAllEvent();
  }

  joinGroup(groupId: string) {
    return new Promise((resolve, reject) => {
      RongIMLib.joinChatRoom(groupId, {
        count: -1,
      })
        .then(res => {
          // 加入聊天室成功
          if (res.code === RongIMLib.ErrorCode.SUCCESS) {
            this.joinedGroupId = groupId;
            resolve(true);
          } else {
            reject(res);
          }
        })
        .catch(error => {
          reject(error);
        });
    });
  }

  leaveGroup() {
    if (!this.joinedGroupId) {
      return Promise.resolve(true);
    }
    const chatRoomId = this.joinedGroupId;
    return new Promise((resolve, reject) => {
      RongIMLib.quitChatRoom(chatRoomId)
        .then(res => {
          // 退出聊天室成功
          if (res.code === 0) {
            this.joinedGroupId = '';
            resolve(true);
          } else {
            reject(res);
          }
        })
        .catch(err => {
          reject(err);
        });
    });
  }

  // 业务自行通过appserver实现
  sendLike() { return Promise.resolve({}); }
  getGroupStatistics() { return Promise.resolve(); }

  // 目前融云未支持该功能，原因如下：
  // 1、未开通对应的服务
  // 2、不能通过 type 过滤
  listMessage(type: number) {
    return Promise.resolve({ hasMore: false, messageList: [] });
    // return new Promise((resolve, reject) => {
    //   if (!this.joinedGroupId) {
    //     return Promise.resolve([]);
    //   }
    //   resolve([]);
    //   RongIMLib.getChatroomHistoryMessages(this.joinedGroupId, {
    //     timestamp: 0,
    //     count: 20,
    //     order: 0
    //   }).then(res => {
    //     // 获取聊天室历史信息成功
    //     if (res.code === 0) {
    //       console.log(res.code, res.data)
    //       resolve([]);
    //     } else {
    //       console.log(res.code, res.msg)
    //       reject(res);
    //     }
    //   }).catch(error => {
    //     console.log(error)
    //     reject(error);
    //   })
    // });
  }

  listRecentMessage() {
    return Promise.resolve({ groupId: this.joinedGroupId, messageList: [] });
  }

  private doSendMessage(
    conversation: IConversationOption,
    options: IMessageOptions
  ) {
    const params = {
      ...options,
      groupId: this.joinedGroupId,
      nick: this.userInfo?.userNick,
      avatar: this.userInfo?.userAvatar,
      data: JSON.stringify(options.data || {}),
    };
    const message = new RongIMLib.TextMessage({
      content: JSON.stringify(params),
    });
    return RongIMLib.sendMessage(conversation, message);
  }

  sendMessageToGroup(options: IMessageOptions) {
    return new Promise((resolve, reject) => {
      if (!this.joinedGroupId) {
        reject({
          code: -1,
          message: 'not joined',
        });
        return;
      }

      const conversation = {
        conversationType: RongIMLib.ConversationType.CHATROOM,
        targetId: this.joinedGroupId!,
      };

      this.doSendMessage(conversation, options)
        .then(res => {
          if (res.code === RongIMLib.ErrorCode.SUCCESS) {
            resolve(res);
            if (res.data) {
              this.handleMessage(res.data);
            }
          } else {
            reject(res);
          }
        })
        .catch(err => {
          reject(err);
        });
    });
  }

  sendMessageToGroupUser(options: IMessageOptions) {
    return new Promise((resolve, reject) => {
      if (!options.receiverId) {
        reject({
          code: -1,
          message: 'need receiverId',
        });
        return;
      }

      const conversation = {
        conversationType: RongIMLib.ConversationType.PRIVATE,
        targetId: options.receiverId,
      };

      this.doSendMessage(conversation, options)
        .then(res => {
          if (res.code === RongIMLib.ErrorCode.SUCCESS) {
            resolve(res);
            if (res.data) {
              this.handleMessage(res.data);
            }
          } else {
            reject(res);
          }
        })
        .catch(err => {
          reject(err);
        });
    });
  }

  queryMuteStatus(): Promise<IGetMuteInfoRspModel> {
    return new Promise((resolve, reject) => {
      if (!this.joinedGroupId) {
        reject({
          code: -1,
          message: 'not joined',
        });
        return;
      }
      this.services
        .isMuteChatroom(this.joinedGroupId, 'rongCloud')
        .then(res => {
          resolve({
            groupMuted: res ? res.result || false : false,
          });
        })
        .catch(err => {
          reject(err);
        });
    });
  }

  muteGroup() {
    return new Promise((resolve, reject) => {
      if (!this.joinedGroupId) {
        reject({
          code: -1,
          message: 'not joined',
        });
        return;
      }
      this.services
        .muteChatroom(this.joinedGroupId, 'rongCloud')
        .then(res => {
          if (res.result) {
            resolve(res);
          } else {
            reject(res);
          }
        })
        .catch(err => {
          reject(err);
        });
    });
  }

  cancelMuteGroup() {
    return new Promise((resolve, reject) => {
      if (!this.joinedGroupId) {
        reject({
          code: -1,
          message: 'not joined',
        });
        return;
      }
      this.services
        .cancelMuteChatroom(this.joinedGroupId, 'rongCloud')
        .then(res => {
          if (res.result) {
            resolve(res);
          } else {
            reject(res);
          }
        })
        .catch(err => {
          reject(err);
        });
    });
  }

  muteUser(userId: string) {
    return new Promise((resolve, reject) => {
      if (!this.joinedGroupId) {
        reject({
          code: -1,
          message: 'not joined',
        });
        return;
      }
      // 融云单人禁言最多 43200 分钟
      this.services
        .muteUser(this.joinedGroupId, userId, 43200, 'rongCloud')
        .then(res => {
          if (res.result) {
            resolve(res);
          } else {
            reject(res);
          }
        })
        .catch(err => {
          reject(err);
        });
    });
  }

  cancelMuteUser(userId: string) {
    return new Promise((resolve, reject) => {
      if (!this.joinedGroupId) {
        reject({
          code: -1,
          message: 'not joined',
        });
        return;
      }
      this.services
        .cancelMuteUser(this.joinedGroupId, userId, 'rongCloud')
        .then(res => {
          if (res.result) {
            resolve(res);
          } else {
            reject(res);
          }
        })
        .catch(err => {
          reject(err);
        });
    });
  }
}

export default RongIM;
