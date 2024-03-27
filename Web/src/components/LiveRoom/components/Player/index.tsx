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
import { useLatest } from '../../utils/hooks';
import './index.less';

interface PlayerProps {
  device: 'mobile' | 'pc';
  wrapClassName: string;
  onReady?: () => void;
  onBarVisibleChange?: (bool: boolean) => void;
  onError?: () => void;
}

export default function Player(props: PlayerProps) {
  const {
    device,
    wrapClassName,
    onReady,
    onBarVisibleChange,
    onError,
  } = props;
  const { roomState, roomType, dispatch } = useContext(RoomContext);
  const { status, vodInfo, isPlayback } = roomState;
  const { t } = useTranslation();
  const [errorDisplayVisible, setErrorDisplayVisible] = useState(true);
  const isLiving = status === RoomStatusEnum.started;
  const isLivingRef = useLatest(isLiving);

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

  /**
   * 获取直播流地址
   * @param {boolean} [excludeFlv=false] 是否排除FLV
   * @param {boolean} [excludeRts=false] 是否排除RTS
   * @return {{ source: string, rtsFallbackSource: string }} 
   */
  const getLiveSource = (excludeFlv = false, excludeRts = false) => {
    // hlsOriaacUrl 为模板转码流，请参考 https://help.aliyun.com/document_detail/2402111.html?spm=a2c4g.2401427.0.0.47b377b9UomvbA#section-h5o-tza-bo3  配置模板
    // 若非开播小助手推流，可以删掉 hlsOriaacUrl、flvOriaacUrl 的逻辑
    // 若是开播小助手推流，不配置转码，观看端直播流将会无声音
    const { hlsOriaacUrl, hlsUrl, flvOriaacUrl, flvUrl, rtsUrl } = roomState;
    // 因为目前 ios 设备不支持 FLV 因此若是 ios 直接使用 HLS
    let rtsFallbackSource = hlsOriaacUrl || hlsUrl;
    if (!(UA.isiPad || UA.isiPhone) && !excludeFlv) {
      rtsFallbackSource = flvOriaacUrl || flvUrl;
    }
    let source = '';
    // excludeRts 为 true 时，不使用 RTS
    // 因为 夸克、UC 有点问题，无法正常播放 rts，所以降级
    if (excludeRts || UA.isQuark || UA.isUC) {
      source = rtsFallbackSource;
      rtsFallbackSource = '';
    } else {
      source = rtsUrl || rtsFallbackSource;
    }
    if (window.location.protocol === 'https:' && (new URL(rtsFallbackSource)).protocol === 'http:') {
      rtsFallbackSource = replaceHttps(rtsFallbackSource) || '';
      source = replaceHttps(source) || '';
    }
    return { source, rtsFallbackSource };
  };

  const playLive = (excludeFlv = false) => {
    // 若不使用 RTS，可传入第二个参数 true
    const { source, rtsFallbackSource } = getLiveSource(excludeFlv);

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
      useFlvPlugOnMobile: !excludeFlv,
    });

    listenPlayerEvents();

    // 若未开播就进去直播间，等到开播后如果加载 hls 流，很大可能流内容未准备好，就会加载失败
    // 虽然live.ts中有自动重新加载的逻辑，但不想这时展示错误提示
    // 所以先通过 css 隐藏，10 秒后若还是有错误提示就展示
    setTimeout(() => {
      setErrorDisplayVisible(false);
    }, 10000);
  };

  useEffect(() => {
    const dispose = () => {
      // 销毁实例
      liveService.destroy();
    }

    if (isLiving) {
      playLive();
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

  const handlePlayerError = (e: any) => {
    if (
      e &&
      e.paramData &&
      e.paramData.error_code === 4011 &&
      typeof e.paramData.error_msg === 'string' &&
      e.paramData.error_msg.indexOf('format:flv')
    ) {
      console.log('4011 err ->', e);
      // 若错误码是 4011 且尝试播放 HLS
      if (isLivingRef.current) {
        // 目前只处理直播模式，因为点播返回一般都是 m3u8，不需要判断
        liveService.destroy();
        playLive(true);
      }
    } else {
      callbacksRef.current.onError &&
        callbacksRef.current.onError();
    }
  }

  const listenPlayerEvents = () => {
    liveService.on('ready', () => {
      callbacksRef.current.onReady && callbacksRef.current.onReady();
    });

    liveService.on('pause', () => {
      // ios 中退出全屏会自动暂停，但这时不会出现居中的播放 ICON，所以主动调一次暂停，触发展示
      liveService.pause();
    });

    liveService.on('error', handlePlayerError);

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
    <div
      className={containerClassNames}
    >
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
