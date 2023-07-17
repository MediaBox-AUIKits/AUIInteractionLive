/** 
 * 该组件为移动端互动直播间，播放器为竖屏模式，适用于娱乐类型的直播场景
*/
import { useContext, useMemo, useState, useRef } from 'react';
import { RoomContext } from '../../RoomContext';
import { RoomStatusEnum } from '../../types';
import Player from "../Player";
import Banner from "./Banner";
import ChatBox from "./ChatBox";
import styles from "./index.less";

function MobileRoom() {
  const { roomState } = useContext(RoomContext);
  const { status, isPlayback } = roomState;
  const [controlHidden, setControlHidden] = useState(false);
  const [playerReady, setPlayerReady] = useState(false);
  const hiddenTimer = useRef<number|undefined>();

  const isInited = useMemo(() => {
    return status !== RoomStatusEnum.no_data;
  }, [status]);

  const wrapClass = useMemo(() => {
    let str = styles['room-wrap'];
    if (controlHidden) {
      str += ` ${styles['control-hidden']}`;
    }
    return str;
  }, [controlHidden]);

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
      <Player
        wrapClassName={styles['player-container']}
        device="mobile"
        onReady={isPlayback ? handleReady : undefined}
      />
      <Banner />
      {
        isInited && (<ChatBox hidden={controlHidden} />)
      }
    </div>
  );
}

export default MobileRoom;
