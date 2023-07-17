import { throttle } from 'throttle-debounce';
import { createDom, randomNum } from './common';
import { BroadcastTypeEnum } from '../types';

const MaxAnameCount = 6;
const DelayDuration = 1500;

class LikeProcessor {
  count: number = 0;
  likeBubbleCount: number = 0;
  groupId: string = '';
  animeContainerEl?: HTMLDivElement;
  interactionInstance: any;

  constructor() {
    this.sendLike = throttle(DelayDuration, this.sendLike.bind(this), { noLeading: true });
  }

  setAnimeContainerEl (el: HTMLDivElement) {
    this.animeContainerEl = el;
  }

  setInteractionInstance (instance: any) {
    this.interactionInstance = instance;
  }

  setGroupId (id: string) {
    this.groupId = id;
  }

  send() {
    this.count += 1;

    this.showBubble();

    this.sendLike();
  }

  sendLike() {
    if (this.interactionInstance) {
      const count = this.count;
      const data = {
        groupId: this.groupId,
        count,
        broadCastType: BroadcastTypeEnum.all,
      };
      this.count = 0;
      return this.interactionInstance.sendLike(data).then(() => {
        //
      }).catch(() => {
        // 若是失败了，加回 count
        this.count += count;
      });
    }
  }

  showBubble() {
    if (!this.animeContainerEl) {
      return;
    }
    const animeRdm = randomNum(MaxAnameCount, 1);
    const bubble = createDom('div', {
      class: `bubble anime-${animeRdm} bg${animeRdm}`,
      id: `bubble-${this.likeBubbleCount}`,
    });
    let nowCount = this.likeBubbleCount;
    this.likeBubbleCount++;
    this.animeContainerEl.append(bubble);
    setTimeout(() => {
      this.animeContainerEl?.removeChild(
        document.querySelector(`#bubble-${nowCount}`) as HTMLDivElement,
      );
    }, DelayDuration);
  }
}

export default LikeProcessor;
