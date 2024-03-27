interface IQueueItem {
  resolve: (res: any) => any;
  reject: (res: any) => any;
  args: any[];
  executeFunc: Function;
}

class PlayQueue {
  private queue: IQueueItem[] = [];
  private executing: boolean = false;

  private execute(ignoreExecuting = false) {
    if (!ignoreExecuting && this.executing) {
      return;
    }

    const nextItem = this.queue.shift();
    if (!nextItem) {
      this.executing = false;
      return;
    }

    this.executing = true;
    const { reject, resolve, args, executeFunc } = nextItem;
    // console.log('execute start play');
    executeFunc(...args)
      .then((res: any) => {
        // console.log('start play success');
        resolve(res);
      })
      .catch((err: any) => {
        // console.error('start play error', err);
        reject(err);
      })
      .finally(() => {
        this.execute(true);
      });
  }

  add(item: IQueueItem) {
    this.queue.push(item);
    this.execute();
  }

  remove(item: IQueueItem) {
    const index = this.queue.indexOf(item);
    if (index !== -1) {
      this.queue.splice(index, 1);
    }
  }
}

const playQueueIns = new PlayQueue();

class AlivcPlayer extends window.AlivcLivePush.AlivcLivePlayer {
  private argsCache: IQueueItem | null = null;

  private async executeStartPlay(...args: any[]) {
    const playInfo = await super.startPlay(...args);
    this.argsCache = null;
    return playInfo;
  }

  startPlay(
    url: string,
    elementOrId: string | HTMLVideoElement,
    secondaryElementOrId?: string | HTMLVideoElement
  ): Promise<any> {
    const args = [...arguments];

    return new Promise((resolve, reject) => {
      const options = {
        reject,
        resolve,
        args,
        executeFunc: this.executeStartPlay.bind(this),
      };
      this.argsCache = options;
      playQueueIns.add(options);
    });
  }

  stopPlay(elementOrId?: string | HTMLVideoElement) {
    if (this.argsCache) {
      playQueueIns.remove(this.argsCache);
    }

    super.stopPlay(elementOrId);
  }

  destroy() {
    if (this.argsCache) {
      playQueueIns.remove(this.argsCache);
    }

    super.destroy();
  }
}

export default AlivcPlayer;
