import {
  CameraResolution,
  CameraFps,
} from '../../constants';
import {
  checkSystemRequirements,
  checkMediaDevicePermission,
} from '../common';

class AlivcPusher extends window.AlivcLivePush.AlivcLivePusher {
  init(config: any = {}) {
    return super.init({
      resolution: CameraResolution,
      fps: CameraFps,
      // 摄像头关闭时所推的静态帧
      cameraCloseImagePath:
        'https://img.alicdn.com/imgextra/i1/O1CN016R0NBp1CAp9mjlfRQ_!!6000000000041-0-tps-720-1280.jpg',
      connectRetryCount: 10,
      // logLevel: 1,
      extraInfo: JSON.stringify({
        scene: 'AUIInteractionLive',
        platform: 'web',
      }),
      ...config,
    });
  }

  checkSystemRequirements = checkSystemRequirements;

  checkMediaDevicePermission = checkMediaDevicePermission;

  async startPush(url: string) {
    await super.startPush(url);
  }

  async stopPush() {
    await super.stopPush();
  }

  async destroy() {
    await super.destroy();
  }
}

export default AlivcPusher;
