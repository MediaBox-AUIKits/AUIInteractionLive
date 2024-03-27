import React, { 
  useEffect, 
  useMemo, 
  useRef, 
  useContext, 
} from 'react';
import {
  GridMicOnSvg,
  GridMicOffSvg,
} from '../CustomIcon';
import Icon from '@ant-design/icons';
import styles from './CardPlayer.less';
import livePush from '../../utils/LivePush';
import { RoomContext } from '../../RoomContext';
import services from '@/services';
import { ISpectatorInfo } from '@/types/interaction';
import classNames from 'classnames';

interface ICardPlayerProps {
  className: string;
  info: ISpectatorInfo;
  size: {
    width: string;
    height: string;
  };
}

let startPlayRetryCount = 0;

const CardPlayer: React.FC<ICardPlayerProps> = (props) => {
  const {
    className,
    info,
    size,
  } = props;
  const { roomState, dispatch } = useContext(RoomContext);
  const {
    anchorId,
    rtcPushUrl,
    cameraOpened,
    micOpened,
    selfPushReady,
    facingMode,
  } = roomState;

  const videoRef = useRef<HTMLVideoElement>(null);

  const userInfo = useMemo(() => services.getUserInfo(), []);

  const livePusher = useMemo(() => {
    return livePush.getInstance('alivc')!;
  }, []);

  const player = useMemo(() => {
    return livePush.createPlayerInstance();
  }, []);

  const isSelf = useMemo(() => (
    userInfo.userId === info.userId
  ), [userInfo, info]);

  const isAnchor = useMemo(() => (
    anchorId === info.userId
  ), [userInfo, info]);

  useEffect(() => {
    if (!videoRef.current) return;

    if (isSelf) {
      handleSelfPush();
    }

    return () => {
      if (isSelf) {
        livePush.destroyInstance('alivc');
      }
    };
  }, [isSelf]);

  useEffect(() => {
    if (!videoRef.current) return;

    if (!isSelf && selfPushReady) {
      startPlay();
    }
  }, [isSelf, selfPushReady]);

  useEffect(() => {
    if (isSelf && selfPushReady) {
      try {
        const cameraOpenedChange = async () => {
          if (cameraOpened) {
            await livePusher.startCamera({facingMode});
          } else {
            await livePusher.stopCamera();
          }
        };
        cameraOpenedChange();
      } catch (err) {
        console.log(err);
      }
    }
  }, [cameraOpened]);

  useEffect(() => {
    if (isSelf && selfPushReady) {
      try {
        const micOpenedChange = async () => {
          if (micOpened) {
            await livePusher.startMicrophone();
          } else {
            await livePusher.stopMicrophone();
          }
        };
        micOpenedChange();
      } catch (err) {
        console.log(err);
      }
    }
  }, [micOpened]);

  const handleSelfPush = async() => {
    try {
      await livePusher.init({
        video: info.cameraOpened,
        audio: info.micOpened,
      });
      await livePusher.startPreview(videoRef.current);
      await livePusher.startPush(rtcPushUrl);
      dispatch({
        type: 'update',
        payload: {
          selfPushReady: true,
        },
      });
    } catch (err) {
      // 推流失败，恢复拉流观看模式
      dispatch({
        type: 'update',
        payload: {
          connectedSpectators: [],
        },
      });
      console.log('handleSelfPush error ->',err);
    }
  };

  const startPlay = async() => {
    if (info.rtcPullUrl && videoRef.current) {
      try {
        await player.startPlay(info.rtcPullUrl, videoRef.current);
      } catch (err) {
        console.log(err);
        if (startPlayRetryCount < 5) {
          setTimeout(() => {
            startPlayRetryCount++;
            console.log('用户' + info.userId + '   Play fail, 已尝试重连次数：', startPlayRetryCount)
            startPlay();
          }, 1000);
        }
      }
    }
  };

  return (
    <div
      className={className}
      style={size || undefined}
    >
      <video
        autoPlay
        ref={videoRef}
        className={styles['card-player-container']}
      />

      <div className={classNames(styles['card-player-bottom'])}>
        {isAnchor ? (
          <span className={classNames(styles['card-player-info'], styles['anchor'])}>
            <span className={styles['card-player-info-name']}>主播</span>
          </span>
        ) : null}
        <span className={styles['card-player-info']}>
          {info.micOpened ?
            <Icon component={GridMicOnSvg} /> : <Icon component={GridMicOffSvg} />
          }
          <span className={styles['card-player-info-name']}>
            {info.userId === userInfo.userId ? '我' : info.userNick}
          </span>
        </span>
      </div>
    </div>
  );
};

export default CardPlayer;
