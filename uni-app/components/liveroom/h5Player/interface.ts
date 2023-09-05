// 配置参考：https://help.aliyun.com/document_detail/125572.htm
export interface PlayerParams {
  // AliPlayer参数
  rtsFallbackSource?: string;
  id?: string;
  source?: string;
  playauth?: string;
  width?: string;
  height?: string;
  videoWidth?: string;
  videoHeight?: string;
  preload?: boolean;
  cover?: string;
  useH5Prism?: boolean;
  autoplay?: boolean;
  isLive?: boolean;
  playsinline?: boolean;
  skinLayout?: any;
  rePlay?: boolean;
  format?: string;
  showBuffer?: boolean;
  controlBarVisibility?: string;
  playerShortCuts?: boolean;
  aliplayerSdkVer?: string;
  showBarTime?: string;
  enableSystemMenu?: boolean;
  autoPlayDelay?: number;
  autoPlayDelayDisplayText?: string;
  language?: 'zh-cn' | 'en-us';
  languageTexts?: string; // JSON
  snapshotWatermark?: object;
  useHlsPluginForSafari?: boolean;
  enableStashBufferForFlv?: boolean;
  stashInitialSizeForFlv?: number;
  loadDataTimeout?: number;
  waitingTimeout?: number;
  liveStartTime?: string;
  liveOverTime?: string;
  liveTimeShiftUrl?: string;
  liveShiftSource?: string;
  diagnosisButtonVisible?: boolean;
  encryptType?: 0 | 1;
  progressMarkers?: progressMarker[];
  vodRetry?: number;
  liveRetry?: number;
  keyShortCuts?: boolean;
  keyFastForwardStep?: number;
}

interface progressMarker {
  offset: number;
  text: string;
  isCustomized: boolean;
}

export enum H5_PLAYER_EVENTS {
  ready = 'ready', // 播放器视频初始化按钮渲染完毕。播放器UI初始设置需要此事件后触发，避免UI被初始化所覆盖。播放器提供的方法需要在此事件发生后才可以调用。
  play = 'play', // 视频由暂停恢复为播放时触发。
  pause = 'pause', // 视频暂停时触发。
  canplay = 'canplay', // 能够开始播放音频和视频时发生，会多次触发，仅H5播放器。
  playing = 'playing', // 播放中，会触发多次。
  ended = 'ended', // 当前视频播放完毕时触发。
  liveStreamStop = 'liveStreamStop', // 直播流中断时触发。M3U8、FLV、RTMP在重试5次未成功后触发。提示上层流中断或需要重新加载视频。如果M3U8、FLV、RTMP的直播流断流或者出错，播放器会自动重试5次，不需要上层添加重试逻辑。
  onM3u8Retry = 'onM3u8Retry', // M3U8直播流中断后重试事件，每次断流只触发一次。
  hideBar = 'hideBar', // 控制栏自动隐藏事件。
  showBar = 'showBar', // 控制栏自动显示事件。
  waiting = 'waiting', // 数据缓冲事件。
  timeupdate = 'timeupdate', // 播放位置发生改变时触发，仅H5播放器。可通过getCurrentTime方法，得到当前播放时间。
  snapshoted = 'snapshoted', // 截图完成事件。
  requestFullScreen = 'requestFullScreen', // 全屏事件，仅H5支持。
  cancelFullScreen = 'cancelFullScreen', // 取消全屏事件，iOS下不会触发，仅H5支持。
  error = 'error', // 错误事件。
  startSeek = 'startSeek', // 开始拖拽，参数返回拖拽点的时间。
  completeSeek = 'completeSeek', // 完成拖拽，参数返回拖拽点的时间。
  resolutionChange = 'resolutionChange', // 直播情况下，推流端切换了分辨率。
  seiFrame = 'seiFrame', // HLS或FLV收到sei消息。
  videoSecond = 'videoSecond', // 首帧时长
  videoStuck = 'videoStuck', // 卡顿
}
