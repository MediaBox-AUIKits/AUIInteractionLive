import {
  useState,
  useEffect,
  useCallback,
  useMemo,
  useContext,
} from 'react';
import Icon from '@ant-design/icons';
import { Dialog, Toast } from 'antd-mobile';
import {
  ApplyCallSvg,
  ManagerMicOnSvg,
  ManagerMicOffSvg,
  ManagerVideoOnSvg,
  ManagerVideoOffSvg,
  ManagerCameraSvg,
} from '../CustomIcon';
import { RoomContext } from '../../RoomContext';
import { AUIMessageEvents } from '@/BaseKits/AUIMessage/types';
import { CustomMessageTypes } from '../../types/interaction';
import { ISenderInfo, ISpectatorInfo } from '@/types/interaction';
import { checkMediaDevicePermission } from '../../utils/common';
import services from '@/services';
import livePush from '../../utils/LivePush';
import styles from './ConnectingManager.less';
import classNames from 'classnames';

interface ConnectingManagerProps {
  className?: string;
}

enum ManagerTextStatusEnum {
  StartApply = 'StartApply',
  CancelApply = 'CancelApply',
  HangUp = 'HangUp',
}

// 5s不操作自动收起管理模块
let wrapManagerTimer: NodeJS.Timeout;
// 主播30s未同意连麦申请计时器
let answerApplyCallTimer: NodeJS.Timeout;

const ConnectingManager: React.FC<ConnectingManagerProps> = (props) => {
  const { className } = props;
  const {
    roomState, 
    auiMessage, 
    dispatch, 
    applyCall, 
    cancelApplyCall,
    sendRTCStop,
  } = useContext(RoomContext);
  const {
    id, 
    chatId, 
    connectedSpectators, 
    rtcPullUrl,
    micOpened, 
    cameraOpened,
    facingMode,
    selfPushReady,
  } = roomState;

  const ManagerText = {
    [ManagerTextStatusEnum.StartApply]: '申请连麦',
    [ManagerTextStatusEnum.CancelApply]: '取消连麦',
    [ManagerTextStatusEnum.HangUp]: '挂断',
  };

  const [connecting, setConnecting] = useState<boolean>(false);
  const [showText, setShowText] = useState<boolean>(false);
  const [
    ManagerTextStatus, 
    setManagerTextStatus
  ] = useState<ManagerTextStatusEnum>(
    ManagerTextStatusEnum.StartApply
  );

  const userInfo = useMemo(() => services.getUserInfo(), []);

  const livePusher = useMemo(() => {
    return livePush.getInstance('alivc')!;
  }, []);

  useEffect(() => {
    if (connectedSpectators.length > 1) {
      setConnecting(true);
      setManagerTextStatus(ManagerTextStatusEnum.HangUp);
    }
  }, [connectedSpectators]);

  // 连麦状态展开管理模块，点击其他模块外区域触发收起
  useEffect(() => {
    let connectManager = document.getElementById('connect-manager');
    const handleClick = (event: any) => {
      if (
        connecting && 
        showText && 
        !connectManager?.contains(event.target as Node)
      ) {
        setShowText(false);
        clearTimeout(wrapManagerTimer);
      }
    };
    document.addEventListener('click', handleClick);

    return () => {
      document.removeEventListener('click', handleClick);
    }
  }, [connecting, showText]);

  const handleRTCStop = useCallback(
    async (reason: string) => {
      await sendRTCStop(reason);

      dispatch({
        type: 'update',
        payload: { 
          connectedSpectators: [],
          selfPushReady: false,
        },
      });

      setConnecting(false);
      setShowText(false);
      setManagerTextStatus(ManagerTextStatusEnum.StartApply);
    },
    [sendRTCStop, dispatch]
  );

  const handleRTCStart = useCallback(
    async () => {
      await services
        .getMeetingInfo(id)
        .then((res) => {
          const list = [
            ...res.members,
            {
              ...userInfo,
              micOpened: true,
              cameraOpened: true,
              rtcPullUrl,
            }
          ];
          dispatch({
            type: 'update',
            payload: { connectedSpectators: list },
          });
        });

      setShowText(false);
      setConnecting(true);
      setManagerTextStatus(ManagerTextStatusEnum.HangUp);
    },
    [id, chatId, userInfo, rtcPullUrl, auiMessage, dispatch]
  );

  useEffect(() => {
    if (selfPushReady) {
      const options = {
        groupId: chatId,
        type: CustomMessageTypes.RTCStart,
        skipMuteCheck: true,
        skipAudit: true,
        noStorage: true,
        data: { rtcPullUrl },
      };
      auiMessage.sendMessageToGroup(options);
    }
  }, [selfPushReady]);

  const handleRespondRTC = useCallback(
    async (agree: boolean) => {
      clearTimeout(answerApplyCallTimer);

      if (agree) {
        const result = await Dialog.confirm({
          content: '连麦申请通过，是否开始连麦？',
        });
        if (result) {
          handleRTCStart();
        } else {
          setShowText(false);
          setManagerTextStatus(ManagerTextStatusEnum.StartApply);
        }
      } else {
        Toast.show({ content: '主播拒绝了您的连麦申请' });
        setShowText(false);
        setManagerTextStatus(ManagerTextStatusEnum.StartApply);
      }
    }, 
    [handleRTCStart]
  );

  const handleMicChanged = useCallback(
    async (needOpenMic?: boolean) => {
      dispatch({
        type: 'update',
        payload: {
          micOpened: needOpenMic ?? !micOpened,
        },
      });

      const micOptions = {
        groupId: chatId,
        type: CustomMessageTypes.MicChanged,
        skipMuteCheck: true,
        skipAudit: true,
        noStorage: true,
        data: { 
          micOpened: needOpenMic ?? !micOpened,
        },
      };
      await auiMessage.sendMessageToGroup(micOptions);
    }, 
    [micOpened, chatId, auiMessage, dispatch]
  );

  const handleCameraChanged = useCallback(
    async (needOpenCamera?: boolean) => {
      dispatch({
        type: 'update',
        payload: {
          cameraOpened: needOpenCamera ?? !cameraOpened,
        },
      });
  
      const cameraOptions = {
        groupId: chatId,
        type: CustomMessageTypes.CameraChanged,
        skipMuteCheck: true,
        skipAudit: true,
        noStorage: true,
        data: { 
          cameraOpened: needOpenCamera ?? !cameraOpened,
        },
      };
      auiMessage.sendMessageToGroup(cameraOptions);
    },
    [cameraOpened, chatId, auiMessage, dispatch]
  );
  
  const updateConnectedSpectators = useCallback(
    async (
      senderInfo: ISenderInfo,
      type: number,
      data: any
    ) => {
      const list = connectedSpectators.slice();
      const index = list.findIndex((item) => item.userId === senderInfo.userId);

      switch (type) {
        case CustomMessageTypes.RTCStart:
          // 上麦通知
          if (index !== -1 || userInfo.userId === senderInfo.userId) {
            return;
          }
          const newItem: ISpectatorInfo = {
            ...senderInfo,
            micOpened: data.micOpened ?? true,
            cameraOpened: data.cameraOpened ?? true,
            rtcPullUrl: data.rtcPullUrl,
          };
          list.push(newItem);
          break;
        case CustomMessageTypes.RTCStop:
          // 下麦通知
          if (index === -1) {
            return;
          }
          list.splice(index, 1);
          break;
        case CustomMessageTypes.RTCKick:
          // 踢下麦（主播发送，观众接收）
          if (index === -1) {
            return;
          }
          handleRTCStop('byKickout');
          return;
        case CustomMessageTypes.MicChanged:
          // 麦克风状态变化
          if (index === -1) {
            return;
          }
          const micItem = {
            ...list[index],
            micOpened: data.micOpened,
          };
          list.splice(index, 1, micItem);
          break;
        case CustomMessageTypes.CameraChanged:
          // 摄像头状态变化
          if (index === -1) {
            return;
          }
          const cameraItem = {
            ...list[index],
            cameraOpened: data.cameraOpened,
          };
          list.splice(index, 1, cameraItem);
          break;
        case CustomMessageTypes.ToggleSpectatorMic:
          // 打开/关闭观众麦克风
          handleMicChanged(data.needOpenMic);
          break;
        case CustomMessageTypes.ToggleSpectatorCamera:
          // 打开/关闭观众摄像头
          handleCameraChanged(data.needOpenCamera);
          break;
        default:
          break;
      };

      if (list.length > 1) {
        dispatch({
          type: 'update',
          payload: { connectedSpectators: list },
        });
      }
    },
    [
      connectedSpectators,
      handleRTCStop, 
      handleMicChanged,
      handleCameraChanged,
      dispatch
    ]
  );

  useEffect(() => {
    const handleReceivedMessage = (eventData: any) => {
      console.log('收到信息啦', eventData);
      const { type, senderInfo, data } = eventData || {};
  
      switch (type) {
        case CustomMessageTypes.RespondRTC:
          // 主播同意/拒绝 连麦申请
          handleRespondRTC(data.agree);
          break;
        case CustomMessageTypes.RTCStart:
          // 上麦通知
          updateConnectedSpectators(senderInfo, type, data);
          break;
        case CustomMessageTypes.RTCStop:
          // 下麦通知
          updateConnectedSpectators(senderInfo, type, data);
          break;
        case CustomMessageTypes.RTCKick:
          // 踢下麦（主播发送，观众接收）
          updateConnectedSpectators(senderInfo, type, data);
          break;
        case CustomMessageTypes.MicChanged:
          // 麦克风状态变化
          updateConnectedSpectators(senderInfo, type, data);
          break;
        case CustomMessageTypes.CameraChanged:
          // 摄像头状态变化
          updateConnectedSpectators(senderInfo, type, data);
          break;
        case CustomMessageTypes.ToggleSpectatorMic:
          // 打开/关闭观众麦克风
          updateConnectedSpectators(senderInfo, type, data);
          break;
        case CustomMessageTypes.ToggleSpectatorCamera:
          // 打开/关闭观众摄像头
          updateConnectedSpectators(senderInfo, type, data);
          break;
        default:
          break;
      }
    };
    auiMessage.addListener(AUIMessageEvents.onMessageReceived, handleReceivedMessage);

    return () => {
      auiMessage.removeListener(AUIMessageEvents.onMessageReceived, handleReceivedMessage);
    };
  }, [auiMessage, handleRespondRTC, updateConnectedSpectators]);

  const handleApplyCallIconClick = useCallback(
    (event: any) => {
      event.stopPropagation();
      // 取消连麦时，点连麦图标不能收起
      if (ManagerTextStatus === ManagerTextStatusEnum.CancelApply) {
        return;
      }
      if (connecting) {
        setManagerTextStatus(ManagerTextStatusEnum.HangUp);
      }

      if (showText && !connecting) {
        setShowText(false);
        clearTimeout(wrapManagerTimer);
      } else {
        setShowText(true);
        wrapManagerTimer = setTimeout(() => {
          setShowText(false);
        }, 5000);
      }
    },
    [ManagerTextStatus, connecting, showText]
  );

  const handleManagerTextClick = async () => {
    if (ManagerTextStatus === ManagerTextStatusEnum.StartApply) {
      clearTimeout(wrapManagerTimer);
      const result = await Dialog.confirm({
        content: '您确定要向主播申请连麦吗？',
      });

      if (result) {
        // 申请连麦先检查是否有麦克风、摄像头的权限
        const permissionResult = await checkMediaDevicePermission({
          audio: true,
          video: true,
        });
        if (!permissionResult.video || !permissionResult.audio) {
          Toast.show({ content: '麦克风/摄像头设备异常' });
          return;
        }

        await applyCall();
        Toast.show({ 
          content: '已发送连麦申请，等待主播操作',
        });
        setManagerTextStatus(ManagerTextStatusEnum.CancelApply);

        // 30s后主播未同意连麦申请，提示主播未响应
        answerApplyCallTimer = setTimeout(() => {
          Toast.show({ content: '主播未响应' });
        }, 30000);
      } else {
        wrapManagerTimer = setTimeout(() => {
          setShowText(false);
        }, 5000);
      }
    } else if (ManagerTextStatus === ManagerTextStatusEnum.CancelApply) {
      const result = await Dialog.confirm({
        content: '是否取消连麦？',
      });
      if (result) {
        await cancelApplyCall();
        Toast.show({ content: '连麦申请取消成功' });
        setShowText(false);
        setManagerTextStatus(ManagerTextStatusEnum.StartApply);
      }
    } else if (ManagerTextStatus === ManagerTextStatusEnum.HangUp) {
      // 挂断连麦
      handleRTCStop('bySelf');
    }
  };

  const restartWrapManagerTimer = () => {
    clearTimeout(wrapManagerTimer);
    wrapManagerTimer = setTimeout(() => {
      setShowText(false);
    }, 5000);
  };

  const handleSwitchCamera = async (event: any) => {
    event.stopPropagation();
    restartWrapManagerTimer();

    if (!cameraOpened) {
      Toast.show({ content: '请先打开摄像头' });
      return;
    }

    const mode = facingMode === 'user' ? 'environment' : 'user';
    dispatch({
      type: 'update',
      payload: {
        facingMode: mode,
      },
    });
    await livePusher.startCamera({facingMode: mode});
  };

  const managerMicIconClick = (event: any) => {
    event.stopPropagation();
    restartWrapManagerTimer();
    handleMicChanged();
  };

  const managerCameraIconClick = (event: any) => {
    event.stopPropagation();
    restartWrapManagerTimer();
    handleCameraChanged();
  };

  return (
    <div
      id='connect-manager'
      className={classNames(
        className, 
        styles['connect-manager-wrap'], 
        {[styles['connecting']]: connecting && !showText},
      )}
    >
      <div className={styles['icon-sec']}>
        {
          connecting && showText ? (
            <div
              className={styles['device-manage']}
            >
              <Icon
                component={micOpened ? ManagerMicOnSvg : ManagerMicOffSvg}
                className={styles['device-manage-icon']}
                onClick={managerMicIconClick}/>
              <Icon
                component={cameraOpened ? ManagerVideoOnSvg : ManagerVideoOffSvg}
                className={styles['device-manage-icon']}
                onClick={managerCameraIconClick}/>
              <Icon
                component={ManagerCameraSvg}
                className={styles['device-manage-icon']}
                onClick={handleSwitchCamera}/>
            </div>
          ) : (
            <div
              className={styles['apply-manage']}
              onClick={handleApplyCallIconClick}
            >
              <Icon component={ApplyCallSvg} />
            </div>
          )
        }
      </div>

      {
        showText ? (
          <div className={styles['text-sec']} onClick={handleManagerTextClick}>
            { ManagerText[ManagerTextStatus] }
          </div>
        ) : null
      }
    </div>
  )
};

export default ConnectingManager;
