import { useContext, useEffect, useMemo, useState, useRef } from 'react';
import { useTranslation } from 'react-i18next';
import Icon from '@ant-design/icons';
import {
  LiveService,
  PCSkinLayoutLive,
  PCSkinLayoutPlayback,
  EnterpriseSkinLayoutLive,
  EnterpriseSkinLayoutPlayback,
} from './live';
import { ResetSvg } from '../CustomIcon';
import { RoomContext } from '../../RoomContext';
import { RoomStatusEnum, VODStatusEnum, LiveRoomTypeEnum } from '../../types';
import { replaceHttps, UA } from '../../utils/common';
import './index.less';

interface PlayerProps {
  device: 'mobile' | 'pc';
  wrapClassName: string;
  onReady?: () => void;
  onBarVisibleChange?: (bool: boolean) => void;
  onError?: () => void;
}

export default function Player(props: PlayerProps) {
  const { device, wrapClassName, onReady, onBarVisibleChange, onError } = props;
  const { roomState, roomType, dispatch } = useContext(RoomContext);
  const { status, vodInfo, isPlayback } = roomState;
  const { t } = useTranslation();
  const [errorDisplayVisible, setErrorDisplayVisible] = useState(true);
  const isLiving = status === RoomStatusEnum.started;

  const callbacksRef = useRef({ onReady, onBarVisibleChange, onError }); // 解决闭包问题

  useEffect(() => {
    callbacksRef.current = { onReady, onBarVisibleChange, onError };
  }, [onReady, onBarVisibleChange]);

  const statusText = useMemo(() => {
    const TextMap: any = {
      [RoomStatusEnum.no_data]: t('liveroom_initing'),
      [RoomStatusEnum.not_start]: t('live_anchor_iscoming'),
      [RoomStatusEnum.ended]: t('live_is_ended'),
    }

    return TextMap[status];
  }, [status]);

  const allowPlayback = useMemo(() => {
    if (
      status === RoomStatusEnum.ended
      && vodInfo
      && vodInfo.status === VODStatusEnum.success
      && vodInfo.playlist[0]
      && vodInfo.playlist[0].playUrl
    ) {
      return true;
    }
    return false;
  }, [status, vodInfo]);

  const liveService = useMemo(() => (new LiveService()), []);

  const containerClassNames = useMemo(() => {
    const arr: string[] = [wrapClassName];
    if (errorDisplayVisible) {
      arr.push('prism-ErrorMessage-hidden');
    }
    return arr.join(' ');
  }, [errorDisplayVisible]);

  useEffect(() => {

    const dispose = () => {
      // 销毁实例
      liveService.destroy();
    }

    if (isLiving) {
      // PC 环境优先用 flv，因为延时比 hls 小
      // flvOriaacUrl 、hlsOriaacUrl 是音频转码为 aac 之后的播放地址，若有问题，请改用 flvUrl、hlsUrl
      let arr: string[] = [];
      if (UA.isPC) {
        arr = [roomState.flvOriaacUrl || roomState.flvUrl, roomState.hlsOriaacUrl || roomState.hlsUrl];
      } else {
        arr = [roomState.hlsOriaacUrl || roomState.hlsUrl, roomState.flvOriaacUrl || roomState.flvUrl];
      }

      let rtsFallbackSource = arr[0] || arr[1];
      let source = roomState.rtsUrl || rtsFallbackSource;
      
      // 因为 夸克、UC 有点问题，无法正常播放 rts，所以降级
      if (UA.isQuark || UA.isUC) {
        source = rtsFallbackSource;
      }
      if (window.location.protocol === 'https:' && (new URL(rtsFallbackSource)).protocol === 'http:') {
        rtsFallbackSource = replaceHttps(rtsFallbackSource) || '';
        source = replaceHttps(source) || '';
      }

      let skinLayout: any = undefined;
      let controlBarVisibility: string = 'never';
      if (device === 'pc') {
        skinLayout = PCSkinLayoutLive;
        controlBarVisibility = 'hover';
      } else if (roomType === LiveRoomTypeEnum.Enterprise) {
        // 企业直播
        skinLayout = EnterpriseSkinLayoutLive;
        controlBarVisibility = 'click';
      }
      liveService.play({
        source,
        rtsFallbackSource,
        skinLayout,
        controlBarVisibility,
      });

      listenPlayerEvents();

      // 若未开播就进去直播间，等到开播后如果加载 hls 流，很大可能流内容未准备好，就会加载失败
      // 虽然live.ts中有自动重新加载的逻辑，但不想这时展示错误提示
      // 所以先通过 css 隐藏，10 秒后若还是有错误提示就展示
      setTimeout(() => {
        setErrorDisplayVisible(false);
      }, 10000);
    } else {
      dispose()
    }

    return dispose;
  }, [isLiving]);

  const playbackHandler = () => {
    if (!vodInfo || isPlayback) {
      return;
    }
    // 更新context
    dispatch({
      type: 'update',
      payload: { isPlayback: true },
    });

    // 当前例子直播回看使用第一个播放地址，可根据您业务调整
    let source = vodInfo.playlist[0].playUrl;
    if (window.location.protocol === 'https:' && (new URL(source)).protocol === 'http:') {
      source = replaceHttps(source);
    }

    let skinLayout: any = undefined;
    let controlBarVisibility: string = 'always';
    if (device === 'pc') {
      skinLayout = PCSkinLayoutPlayback;
      controlBarVisibility = 'hover';
    } else if (roomType === LiveRoomTypeEnum.Enterprise) {
      // 企业直播
      skinLayout = EnterpriseSkinLayoutPlayback;
      controlBarVisibility = 'click';
    }
    liveService.playback({
      source,
      format: vodInfo.playlist[0].format,
      skinLayout,
      controlBarVisibility,
    });

    listenPlayerEvents();
  };

  const listenPlayerEvents = () => {
    liveService.on('ready', () => {
      callbacksRef.current.onReady && callbacksRef.current.onReady();
    });

    liveService.on('pause', () => {
      // ios 中退出全屏会自动暂停，但这时不会出现居中的播放 ICON，所以主动调一次暂停，触发展示
      liveService.pause();
    });

    liveService.on('error', () => {
      callbacksRef.current.onError &&
        callbacksRef.current.onError();
    });

    liveService.on('hideBar', () => {
      callbacksRef.current.onBarVisibleChange &&
        callbacksRef.current.onBarVisibleChange(false);
    });

    liveService.on('showBar', () => {
      callbacksRef.current.onBarVisibleChange &&
        callbacksRef.current.onBarVisibleChange(true);
    });
  };

  return (
    <div className={containerClassNames}>
      <div id="player"></div>
      {!isLiving && !isPlayback && (
        <div className="player-nolive">
          <div>{statusText}</div>
          {
            allowPlayback ? (
              <div className="player-playback" onClick={playbackHandler}>
                <Icon component={ResetSvg} />
                {t('view_playback')}
              </div>
            ) : null
          }
        </div>
      )}
    </div>
  )
}
