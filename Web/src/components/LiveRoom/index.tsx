/**
 * 该文件为直播间入口，统一处理数据、事件等，本地无 UI 相关
 */
import React, {
  useEffect,
  useReducer,
  useRef,
  useCallback,
  useMemo,
  useContext
} from 'react';
import { useTranslation, I18nextProvider } from 'react-i18next';
import { throttle } from 'throttle-debounce';
import { Toast } from 'antd-mobile';
import { toast } from 'react-toastify';
import { useMemoizedFn } from 'ahooks';
import MobileRoom from './components/MobileRoom';
import PCRoom from './components/PCRoom';
import {
  ILiveRoomProps,
  IRoomState,
  IRoomInfo,
  InteractionMessage,
  RoomStatusEnum,
  CustomMessageTypes,
  LiveRoomTypeEnum,
  GroupIdObject,
} from './types';
import { RoomContext, defaultRoomState, roomReducer } from './RoomContext';
import { createDom, UA, assignObjectByParams } from './utils/common';
import LikeProcessor from './utils/LikeProcessor';
import { usePrevious } from './utils/hooks';
import { AUIMessageEvents, AUIMessageTypes, AUIMessageInsType } from '@/BaseKits/AUIMessage/types';
import i18n from './locales';
import './styles/anime.less';
import './styles/mobileBullet.less';

const MaxMessageCount = 100;

const LiveRoom: React.FC<ILiveRoomProps> = (props: ILiveRoomProps) => {
  const { roomType, userInfo, getRoomInfo, getToken, onExit } = props;
  const { t: tr } = useTranslation();
  const [roomState, dispatch] = useReducer<(state: IRoomState, action: any) => IRoomState>(roomReducer, defaultRoomState);
  const previousRoomState = usePrevious(roomState);
  const groupIdRef = useRef<string>(''); // 解决评 groupId 闭包问题
  const commentListCache = useRef<InteractionMessage[]>([]); // 解决评论列表闭包问题
  const animeContainerEl = useRef<HTMLDivElement>(null); // 用于点赞动画
  const bulletContainerEl = useRef<HTMLDivElement>(null); // 用于会消失的消息
  // 创建点赞处理实例
  const likeProcessor = useMemo(() => (new LikeProcessor()), []);

  const { auiMessage } = useContext(RoomContext);

  useEffect(() => {
    if (animeContainerEl.current) {
      likeProcessor.setAnimeContainerEl(animeContainerEl.current);
    }

    fetchRoomDetail();

    return () => {
      if (groupIdRef.current) {
        auiMessage
          .leaveGroup()
          .finally(() => {
            destroyAuiMessage();
          });
      } else {
        destroyAuiMessage();
      }
    };
  }, []);

  const destroyAuiMessage = () => {
    auiMessage.logout();
    auiMessage.removeAllListeners();
    auiMessage.unInit();
  }

  const fetchRoomDetail = () => {
    getRoomInfo()
      .then((res: IRoomInfo) => {
        dispatch({
          type: 'updateRoomDetail',
          payload: res,
        });
      });
  };

  useEffect(() => {
    // 通过 chatId 从无变有来触发初始化互动消息 SDK
    // 当前默认只使用新版IM，如果需要多通道则需加上对应通道的IM群组id的条件
    if (previousRoomState && !previousRoomState.chatId && roomState.chatId) {
      // group id存在，就初始化对应的IM实例
      initAUIMessage({
        aliyunV2GroupId: roomState.chatId,
      });
    }
  }, [previousRoomState, roomState]);

  const initAUIMessage = useMemoizedFn(
    async (groupIdObject: GroupIdObject) => {
      // 支持多通道的AUIMessage，如果没有获取某个通道的群组id，就会销毁该通道的IM实例
      const { aliyunV2GroupId, rongIMId } = groupIdObject;

      try {
        if (!rongIMId && !aliyunV2GroupId) {
          throw { code: -1, message: 'IM group id is empty' };
        }

        if (!rongIMId || !aliyunV2GroupId) {
          const destroyInstances = [];
          if (!rongIMId) {
            destroyInstances.push(AUIMessageInsType.RongIM);
          }
          if (!aliyunV2GroupId) {
            destroyInstances.push(AUIMessageInsType.AliyunIMV2);
          }
          auiMessage.destroyInstance(destroyInstances);
        }

        // 用户为主播时，才有阿里云新版IM admin管理员权限
        const role = roomState.anchorId === userInfo.userId ? 'admin' : undefined;
        const tokenConfig = await getToken(role);
        if (aliyunV2GroupId && tokenConfig.aliyunIMV2) {
          tokenConfig.aliyunIMV2.extra = {
            scene: 'AUIInteractionLive',
            platform: 'web',
          };
        }
        auiMessage.setConfig(tokenConfig);
        await auiMessage.init();
        await auiMessage.login(userInfo);
        await auiMessage.joinGroup(groupIdObject);
        groupIdRef.current = aliyunV2GroupId || rongIMId as string;

        // 初始化禁言状态
        auiMessage
          .queryMuteStatus()
          .then(res => {
            if (res.groupMuted) {
              updateRoomState({ groupMuted: true, commentInput: '' });
              showInfoMessage(tr('chat_all_banned_start'));
            }
          })
          .catch(() => {});

        // 更新 likeProcessor
        likeProcessor.setGroupId(groupIdRef.current);
        likeProcessor.setAuiMessage(auiMessage);
  
        // 监听 AUIMesssage 消息
        listenAUIMesssageEvents();

        // 更新直播统计数据
        updateGroupStatistics();
      } catch (error) {
        console.log('initAUIMessage err', error);
      }
    }
  );
  
  const updateGroupStatistics = () => {
    auiMessage.getGroupStatistics(groupIdRef.current)
      .then((res: any) => {
        const payload = assignObjectByParams(res, ['onlineCount', 'pv']);
        if (payload) {
          dispatch({ type: 'updateMetrics', payload });
        }
      })
      .catch(() => {});
  };

  // 监听 AUIMesssage 消息
  const listenAUIMesssageEvents = useCallback(() => {
    [
      AUIMessageEvents.onLikeInfo,
      AUIMessageEvents.onJoinGroup,
      AUIMessageEvents.onLeaveGroup,
      AUIMessageEvents.onMuteGroup,
      AUIMessageEvents.onUnmuteGroup,
      AUIMessageEvents.onMuteUser,
      AUIMessageEvents.onUnmuteUser,
      AUIMessageEvents.onMessageReceived,
    ].map((eventName) => {
      auiMessage.addListener(eventName, (eventData: any) => {
        console.log('收到信息啦', eventName, eventData);
        handleReceivedMessage(eventData || {});
      });
    })
  }, [roomState]);

  const handleReceivedMessage = useCallback((eventData: any) => {
    const { type, data, messageId, senderId, senderInfo = {} } = eventData || {};
    const nickName = senderInfo.userNick || senderId;

    switch (type) {
      case CustomMessageTypes.Comment:
        // 接收到评论消息
        if (data && data.content) {
          addMessageItem({
            content: data.content,
            nickName,
            messageId,
            isSelf: senderId === userInfo.userId,
            isAnchor: senderId === roomState.anchorId,
          });
        }
        break;
      case AUIMessageTypes.PaaSLikeInfo:
        // 接收到点赞消息逻辑，业务根据 发送点赞 约定的消息体类型自行实现
        break;
      case AUIMessageTypes.PaaSUserJoin:
        // 用户加入聊天组，更新直播间统计数据
        handleUserJoined(nickName, data);
        break;
      case AUIMessageTypes.PaaSUserLeave:
        // 用户离开聊天组，不需要展示
        break;
      case AUIMessageTypes.PaaSMuteGroup:
        // 互动消息组被禁言
        updateRoomState({ groupMuted: true, commentInput: '' });
        showInfoMessage(tr('chat_all_banned_start'));
        break;
      case AUIMessageTypes.PaaSCancelMuteGroup:
        // 互动消息组取消禁言
        updateRoomState({ groupMuted: false });
        showInfoMessage(tr('chat_all_banned_stop'));
        break;
      case AUIMessageTypes.PaaSMuteUser:
        // 个人被禁言
        break;
      case AUIMessageTypes.PaaSCancelMuteUser:
        // 个人被取消禁言
        break;
      case CustomMessageTypes.LiveStart:
        // 开始直播
        updateRoomState({ status: RoomStatusEnum.started });
        break;
      case CustomMessageTypes.LiveStop:
        // 结束直播
        updateRoomState({ status: RoomStatusEnum.ended });
        break;
      case CustomMessageTypes.LiveInfo:
        // 直播间信息更新
        break;
      case CustomMessageTypes.NoticeUpdate:
        // 公告更新
        if (typeof data.notice === 'string') {
          updateRoomState({ notice: data.notice });
          showInfoMessage(tr('notice_updated'));
        }
        break;
      default:
        break;
    }
  }, [roomState]);

  // 节流展示进入房间的消息
  const handleUserJoined = useCallback(throttle(1500, (nickName: string, data: any) => {
    updateGroupStatistics();
    addBulletItem(`${nickName} ${tr('liveroom_enter')}`);
  }), [])

  const showInfoMessage = (text: string) => {
    if (UA.isPC) {
      toast.info(text);
    } else {
      Toast.show(text);
    }
  }

  const addMessageItem = (messageItem: InteractionMessage) => {
    let list: InteractionMessage[] = [];
    // 只有是移动端互动直播间时才是添加到数组前面
    const isTail = UA.isPC || roomType === LiveRoomTypeEnum.Enterprise;
    if (isTail) {
      list = [...commentListCache.current, messageItem];
    } else {
      list = [messageItem, ...commentListCache.current];
    }
    // 别超过最大消息个数
    if (list.length > MaxMessageCount) {
      if (isTail) {
        list = list.slice(MaxMessageCount / 2, -1);
      } else {
        list = list.slice(0, MaxMessageCount / 2);
      }
    }
    commentListCache.current = list;
    throttleUpdateMessageList(list);
  };

  const throttleUpdateMessageList = throttle(500, (list: InteractionMessage[]) => {
    // 节流，防止瞬时大量数据
    updateRoomState({ messageList: list });
  });

  const updateRoomState = (payload: any) => {
    dispatch({ type: 'update', payload });
  };

  const sendComment = (content: string) => {
    if (roomState.groupMuted || roomState.selfMuted) {
      return Promise.reject(new Error('isMuted'));
    }
    const options = {
      groupId: groupIdRef.current,
      type: CustomMessageTypes.Comment,
      data: { content },
    }
    return auiMessage.sendMessageToGroup(options);
  };

  const sendLike = () => {
    if (!likeProcessor.animeContainerEl && animeContainerEl.current) {
      likeProcessor.setAnimeContainerEl(animeContainerEl.current);
    }
    likeProcessor.send();
  };

  // 用于显示会消失的的气泡消息，如 入会、禁言 相关
  const addBulletItem = (content: string) => {
    if (!content || !bulletContainerEl.current) {
      return;
    }
    const item = createDom('div', { class: 'aui-bullet-item' });
    item.textContent = content;
    bulletContainerEl.current.append(item);

    setTimeout(() => {
      if (bulletContainerEl.current) {
        bulletContainerEl.current.removeChild(item);
      }
    }, 1500);
  };

  const applyCall = () => {
    const options = {
      groupId: groupIdRef.current,
      type: CustomMessageTypes.ApplyRTC,
      receiverId: roomState.anchorId,
      skipAudit: true,
      noStorage: true,
    };
    return auiMessage.sendMessageToGroupUser(options);
  };

  const cancelApplyCall = () => {
    const options = {
      groupId: groupIdRef.current,
      type: CustomMessageTypes.CancelApplyRTC,
      receiverId: roomState.anchorId,
      skipAudit: true,
      noStorage: true,
    };
    return auiMessage.sendMessageToGroupUser(options);
  };

  const sendRTCStop = async (reason?: string) => {
    const options = {
      groupId: groupIdRef.current,
      type: CustomMessageTypes.RTCStop,
      skipMuteCheck: true,
      skipAudit: true,
      noStorage: true,
      data: { 
        reason,
      },
    };
    return auiMessage.sendMessageToGroup(options);
  };

  return (
    <RoomContext.Provider
      value={{
        auiMessage,
        roomState,
        roomType,
        animeContainerEl,
        bulletContainerEl,
        dispatch,
        sendComment,
        sendLike,
        exit: onExit,
        applyCall,
        cancelApplyCall,
        sendRTCStop,
      }}
    >
      {UA.isPC ? <PCRoom /> : <MobileRoom />}
    </RoomContext.Provider>
  )
}

const LiveRoomWrap: React.FC<ILiveRoomProps> = (props: ILiveRoomProps) => {
  return (
    <I18nextProvider i18n={i18n}>
      <LiveRoom {...props} />
    </I18nextProvider>
  )
};

export default LiveRoomWrap;
