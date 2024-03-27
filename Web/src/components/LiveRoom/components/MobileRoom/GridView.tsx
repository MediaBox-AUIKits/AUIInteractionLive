import {
  useRef,
  useMemo,
  useEffect,
  useState,
  useContext
} from 'react';
import { RoomContext } from '../../RoomContext';
import CardPlayer from './CardPlayer';
import styles from './GridView.less';

enum PlayerSize {
  ItemPerRow2 = '3.6rem',
  ItemPerRow3 = '2.4rem',
}

const GridView: React.FC = () => {
  const { roomState } = useContext(RoomContext);
  const { connectedSpectators } = roomState;
  const wrapEl = useRef<HTMLDivElement | null>(null);
  const [playerSize, setPlayerSize] = useState(PlayerSize.ItemPerRow2);

  const spectatorLen = useMemo(
    () => connectedSpectators.length,
    [connectedSpectators]
  );

  useEffect(() => {
    if (spectatorLen > 4) {
      setPlayerSize(PlayerSize.ItemPerRow3);
    } else {
      setPlayerSize(PlayerSize.ItemPerRow2);
    }
  }, [spectatorLen]);

  return (
    <div ref={wrapEl} className={styles['grid-view-wrap']}>
      <div className={styles['grid-view-list']}>
        {connectedSpectators.map((item) => (
          <CardPlayer
            key={item.userId}
            info={item}
            size={{ width: playerSize , height: playerSize }}
            className={styles['grid-view-player']}
          />
        ))}
      </div>
    </div>
  );
};

export default GridView;
