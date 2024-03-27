/** 
 * 该组件为移动端互动直播间，播放器为竖屏模式，适用于娱乐类型的直播场景
*/
import { useEffect, useContext, useMemo, useState, useRef } from 'react';
import { RoomContext } from '../../RoomContext';
import { RoomStatusEnum } from '../../types';
import Player from "../Player";
import Banner from "./Banner";
import ChatBox from "./ChatBox";
import styles from "./index.less";
import { RoomModeEnum } from "@/types/room";
import GridView from "./GridView";
import services from '@/services';
import livePush from '../../utils/LivePush';
import { Toast } from 'antd-mobile';

enum ViewerModeEnum {
  normal = 'normal',
  grid = 'grid',
}

function MobileRoom() {
  const { roomState, dispatch } = useContext(RoomContext);
  const { id, status, isPlayback, mode, connectedSpectators } = roomState;
  const [controlHidden, setControlHidden] = useState(false);
  const [playerReady, setPlayerReady] = useState(false);
  const hiddenTimer = useRef<number|undefined>();

  const userInfo = useMemo(() => services.getUserInfo(), []);

  const isInited = useMemo(() => {
    return status !== RoomStatusEnum.no_data && status !== RoomStatusEnum.ended;
  }, [status]);

  const wrapClass = useMemo(() => {
    let str = styles['room-wrap'];
    if (controlHidden) {
      str += ` ${styles['control-hidden']}`;
    }
    return str;
  }, [controlHidden]);

  const livePusher = useMemo(() => {
    return livePush.getInstance('alivc')!;
  }, []);

  const initMobileRoom = async () => {
    // 初始化可直接进入连麦状态
    await services
      .getMeetingInfo(id)
      .then(async (res) => {
        if (res.members.map((item: any) => item.userId).includes(userInfo.userId)) {
          const self = res.members.find((item: any) => item.userId === userInfo.userId);
          dispatch({
            type: 'update',
            payload: {
              connectedSpectators: res.members,
              cameraOpened: self?.cameraOpened ?? true,
              micOpened: self?.micOpened ?? true,
            },
          });

          // 申请连麦先检查是否有麦克风、摄像头的权限
          const permissionResult = await livePusher.checkMediaDevicePermission({
            audio: true,
            video: true,
          });
          if (!permissionResult.video && !permissionResult.audio) {
            Toast.show({ content: '麦克风和摄像头设备异常，请尝试打开设备权限后刷新重试' });
            return;
          } else if (!permissionResult.video) {
            Toast.show({ content: '摄像头设备异常，请尝试打开设备权限后刷新重试' });
            return;
          } else if (!permissionResult.audio) {
            Toast.show({ content: '麦克风设备异常，请尝试打开设备权限后刷新重试' });
            return;
          }
        }
      });
  };

  useEffect(() => {
    if (!isInited) {
      return;
    }
    try {
      initMobileRoom();
    } catch (error) {
      console.error('initMobileRoom error :', error);
    }

    return () => {
      livePush.destroyInstance('alivc');
    }
  }, [isInited]);

  const playerView = useMemo(() => {
    if (
      mode === RoomModeEnum.rtc &&
      connectedSpectators.length > 1 &&
      connectedSpectators.map(item => item.userId).includes(userInfo.userId)
    ) {
      return ViewerModeEnum.grid;
    }
    return ViewerModeEnum.normal;
  }, [mode, connectedSpectators, userInfo]);

  const setHiddenTimer = () => {
    if (hiddenTimer.current) {
      clearTimeout(hiddenTimer.current);
    }
    // 5 秒后隐藏控件，进入沉浸式观看
    hiddenTimer.current = window.setTimeout(() => {
      setControlHidden(true);
    }, 5000);
  };

  // 只有回看才会触发
  const showControls = () => {
    if (playerReady && isPlayback) {
      setControlHidden(false);
      setHiddenTimer();
    }
  };

  const handleReady = () => {
    setPlayerReady(true);
    setHiddenTimer();
  };

  return (
    <div
      className={wrapClass}
      onClick={showControls}
    >
      {
        (playerView === ViewerModeEnum.normal || status === RoomStatusEnum.ended) ? (
          <Player
            wrapClassName={styles['player-container']}
            device="mobile"
            onReady={isPlayback ? handleReady : undefined}
          />
        ) : null
      }
      {
        playerView === ViewerModeEnum.grid && status !== RoomStatusEnum.ended ? (
          <GridView />
        ) : null
      }
      <Banner />
      {
        isInited && (<ChatBox hidden={controlHidden} />)
      }
    </div>
  );
}

export default MobileRoom;
