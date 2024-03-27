import AlivcPusher from './AlivcPusher';
import AlivcPlayer from './AlivcPlayer';
type SDKType = 'alivc';

class LivePushFactory {
  livePusher?: AlivcPusher;

  getInstance(type: SDKType = 'alivc') {
    if (type === 'alivc') {
      if (!this.livePusher) {
        const ins = new AlivcPusher();
        this.livePusher = ins;
      }

      return this.livePusher;
    }

    return null;
  }

  async destroyInstance(type: SDKType = 'alivc') {
    if (type === 'alivc') {
      if (this.livePusher) {
        await this.livePusher.destroy();
        this.livePusher = undefined;
      }
    }
  }

  createPlayerInstance() {
    return new AlivcPlayer();
  }
}

const factory = new LivePushFactory();

export default factory;
