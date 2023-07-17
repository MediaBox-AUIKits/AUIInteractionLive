/**
 * 该文件为直播间入口，统一处理数据、事件等，本地无 UI 相关
 */
import React, { useEffect, useReducer, useRef, useCallback, useMemo } from 'react';
import { useTranslation, I18nextProvider } from 'react-i18next';
import { throttle } from 'throttle-debounce';
import { Toast } from 'antd-mobile';
import { toast } from 'react-toastify';
import MobileRoom from './components/MobileRoom';
import PCRoom from './components/PCRoom';
import {
  ILiveRoomProps,
  IRoomState,
  IRoomInfo,
  InteractionMessage,
  RoomStatusEnum,
  CustomMessageTypes,
  BroadcastTypeEnum,
} from './types';
import { RoomContext, defaultRoomState, roomReducer } from './RoomContext';
import { createDom, UA, assignObjectByParams } from './utils/common';
import LikeProcessor from './utils/LikeProcessor';
import { usePrevious } from './utils/hooks';
import i18n from './locales';
import './styles/anime.less';
import './styles/mobileBullet.less';

const MaxMessageCount = 100;

const LiveRoom: React.FC<ILiveRoomProps> = (props: ILiveRoomProps) => {
  const { roomType, userInfo, getRoomInfo, getToken, onExit } = props;
  const { t: tr } = useTranslation();
  const [roomState, dispatch] = useReducer<(state: IRoomState, action: any) => IRoomState>(roomReducer, defaultRoomState);
  const previousRoomState = usePrevious(roomState);
  const InteractionRef = useRef<any>(); // 互动 sdk 实例
  const groupIdRef = useRef<string>(''); // 解决评 groupId 闭包问题
  const commentListCache = useRef<InteractionMessage[]>([]); // 解决评论列表闭包问题
  const animeContainerEl = useRef<HTMLDivElement>(null); // 用于点赞动画
  const bulletContainerEl = useRef<HTMLDivElement>(null); // 用于会消失的消息
  // 创建点赞处理实例
  const likeProcessor = useMemo(() => (new LikeProcessor()), []);

  useEffect(() => {
    const { InteractionEngine } = window.AliyunInteraction;
    InteractionRef.current = InteractionEngine.create();

    if (animeContainerEl.current) {
      likeProcessor.setAnimeContainerEl(animeContainerEl.current);
    }

    fetchRoomDetail();

    return () => {
      if (groupIdRef.current) {
        InteractionRef.current
          .leaveGroup({
            groupId: groupIdRef.current,
            broadCastType: BroadcastTypeEnum.nobody, // 离开不广播
          })
          .finally(() => {
            InteractionRef.current.logout();
            InteractionRef.current.removeAllEvents();
          });
      } else {
        InteractionRef.current.logout();
        InteractionRef.current.removeAllEvents();
      }
    };
  }, []);

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
    if (previousRoomState && !previousRoomState.chatId && roomState.chatId) {
      initInteraction(roomState.chatId);
    }
  }, [previousRoomState, roomState]);

  const initInteraction = async (groupId: string) => {
    try {
      // 获取token
      const token = await getToken();
      // im 服务认证
      await InteractionRef.current.auth(token);
      // 加入房间
      await InteractionRef.current.joinGroup({
        groupId,
        userNick: userInfo.userName,
        userAvatar: userInfo.userAvatar, // 随机取头像
        broadCastType: BroadcastTypeEnum.all, // 广播所有人
        broadCastStatistics: true,
      });
      groupIdRef.current = groupId;
      // 更新 likeProcessor
      likeProcessor.setGroupId(groupId);
      likeProcessor.setInteractionInstance(InteractionRef.current);

      listenInteractionMessage();
      // 检查更新自己信息
      updateSelfInfo();
      // 更新直播统计数据
      updateGroupStatistics();
    } catch (error) {
      console.log('initInteraction err', error);
    }
  };

  const updateSelfInfo = () => {
    InteractionRef.current.getGroupUserByIdList({
      groupId: groupIdRef.current,
      userIdList: [userInfo.userId],
    }).then((res: any) => {
      const info = ((res || {}).userList || [])[0];
      if (info) {
        const muteBy: string[] = info.muteBy || [];
        updateRoomState({
          selfMuted: muteBy.includes('user'),
          groupMuted: muteBy.includes('group'),
        });
      }
    });
  };

  const updateGroupStatistics = () => {
    InteractionRef.current
      .getGroupStatistics({ groupId: groupIdRef.current })
      .then((res: any) => {
        const payload = assignObjectByParams(res, ['likeCount', 'onlineCount', 'pv', 'uv']);
        if (payload) {
          dispatch({ type: 'updateMetrics', payload });
        }
      })
      .catch(() => {});
  };

  // 监听 Interaction SDK 消息
  const listenInteractionMessage = useCallback(() => {
    const { InteractionEventNames } = window.AliyunInteraction;
    InteractionRef.current.on(InteractionEventNames.Message, (eventData: any) => {
      console.log('收到信息啦', eventData);
      handleReceivedMessage(eventData || {});
    });
  }, [roomState]);

  const handleReceivedMessage = useCallback((eventData: any) => {
    const { InteractionMessageTypes } = window.AliyunInteraction;
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
      case InteractionMessageTypes.PaaSLikeInfo:
        // 用户点赞数据，更新对应数据，后续考虑做节流
        if (data && data.likeCount) {
          dispatch({
            type: 'updateMetrics',
            payload: {
              likeCount: data.likeCount,
            },
          });
        }
        break;
      case InteractionMessageTypes.PaaSUserJoin:
        // 用户加入聊天组，更新直播间统计数据
        handleUserJoined(nickName, data);
        break;
      case InteractionMessageTypes.PaaSUserLeave:
        // 用户离开聊天组，不需要展示
        break;
      case InteractionMessageTypes.PaaSMuteGroup:
        // 互动消息组被禁言
        updateRoomState({ groupMuted: true, commentInput: '' });
        showInfoMessage(tr('chat_all_banned_start'));
        break;
      case InteractionMessageTypes.PaaSCancelMuteGroup:
        // 互动消息组取消禁言
        updateRoomState({ groupMuted: false });
        showInfoMessage(tr('chat_all_banned_stop'));
        break;
      case InteractionMessageTypes.PaaSMuteUser:
        // 个人被禁言
        handleMuteUser(true, messageId, data);
        break;
      case InteractionMessageTypes.PaaSCancelMuteUser:
        // 个人被取消禁言
        handleMuteUser(false, messageId, data);
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
    if (data && data.statistics) {
      dispatch({
        type: 'updateMetrics',
        payload: data.statistics,
      });
    }
    addBulletItem(`${nickName} ${tr('liveroom_enter')}`);
  }), [])

  const handleMuteUser = (isMuted: boolean, messageId: string, userData: any = {}) => {
    // 只展示你个人的禁言消息
    if (userInfo.userId !== userData.userId) {
      return;
    }

    const data: any = { selfMuted: isMuted };
    if (isMuted) {
      data.commentInput = ''; // 若当前输入框有内容要清空
      showInfoMessage(`${userData.userNick || ''}${tr('chat_someone_banned_start')}`);
    } else {
      showInfoMessage(`${userData.userNick || ''}${tr('chat_someone_banned_stop')}`);
    }

    updateRoomState(data);
  };

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
    const isTail = UA.isPC;
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
      data: JSON.stringify({ content }),
    }
    return InteractionRef.current.sendMessageToGroup(options);
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

  return (
    <RoomContext.Provider
      value={{
        interaction: InteractionRef.current,
        roomState,
        roomType,
        animeContainerEl,
        bulletContainerEl,
        dispatch,
        sendComment,
        sendLike,
        exit: onExit,
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
