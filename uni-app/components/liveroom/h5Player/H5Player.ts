import { PlayerParams } from './interface';

// H5自定义错误UI：https://help.aliyun.com/document_detail/63069.htm
// 配置skinLayout属性：https://help.aliyun.com/document_detail/62948.htm
const skinLayoutLive = [
  { name: 'bigPlayButton', align: 'cc' },
  { name: 'H5Loading', align: 'cc' },
  // 注释下一行 errorDisplay 以隐藏默认的报错信息
  { name: 'errorDisplay', align: 'tlabs', x: 0, y: 100 },
  { name: 'infoDisplay' },
];

const skinLayoutPlayback = [
  { name: 'bigPlayButton', align: 'cc' },
  { name: 'H5Loading', align: 'cc' },
  // 注释下一行 errorDisplay 以隐藏默认的报错信息
  { name: 'errorDisplay', align: 'tlabs', x: 0, y: 100 },
  { name: 'infoDisplay' },
  { name: "thumbnail" },
  { name: 'tooltip', align: 'blabs', x: 0, y: 56 },
  {
      name: 'controlBar',
      align: 'blabs',
      x: 0,
      y: 0,
      children: [
        {name: "progress", align: "tlabs", x: 0, y: 0},
        {name: "playButton", align: "tl", x: 20, y: 15},
        {name: "timeDisplay", align: "tl", x: 20, y: 7},
      ],
  },
];

// 最大重试次数
const MAX_RETRY_COUNT = 5;
// 重试时间间隔
const RETRY_INTERVAL = 2000;

export class H5Player {
  private player: any;
  private source?: string;
  private retryCount = 0;
  
  public play(config: Partial<PlayerParams>) {
    const options: PlayerParams = {
      id: 'h5player',
      isLive: true,
      width: '100%',
      height: '100%',
      autoplay: true,
      rePlay: false,
      playsinline: true,
      preload: true,
      controlBarVisibility: 'never',
      useH5Prism: true,
      ...config,
    };

    if (!options.skinLayout) {
      options.skinLayout = skinLayoutLive;
    }

    this.source = options.source;
    // console.log('player options->', options);
    this.player = new (window as any).Aliplayer(options, () => {
      console.log('created');
    });

    this.player.on('error', (e: any) => {
      console.log('player error', e);
      // 处理 4004 逻辑（一般是因为 HLS 有延时，推流已经开始但播流还拉不到），自动重试
      if (e.paramData.error_code === 4004 && this.retryCount < MAX_RETRY_COUNT) {
        window.setTimeout(() => {
          this.retryCount++;
          this.player.loadByUrl(this.source || '', 0, true, true)
        }, RETRY_INTERVAL);
      }
    })
  }

  public playback(config: Partial<PlayerParams>) {
    const options: PlayerParams = {
      id: 'h5player',
      width: '100%',
      height: '100%',
      autoplay: true,
      playsinline: true,
      preload: true,
      controlBarVisibility: 'click',
      useH5Prism: true,
      keyShortCuts: true,
      keyFastForwardStep: 5,
      ...config,
    };

    if (!options.skinLayout) {
      options.skinLayout = skinLayoutPlayback;
    }

    this.player = new (window as any).Aliplayer(options, () => {
      console.log('playback created');
    });
  }

  public pause() {
    if (this.player) {
      this.player.pause(true);
    }
  }

  public on(eventName: string, callback: Function) {
    if (this.player) {
      this.player.on(eventName, callback);
    }
  }

  public off(eventName: string, callback: Function) {
    if (this.player) {
      this.player.off(eventName, callback);
    }
  }

  public destroy() {
    if (this.player) {
      this.player.dispose();
      this.player = null;
    }
  }
}
