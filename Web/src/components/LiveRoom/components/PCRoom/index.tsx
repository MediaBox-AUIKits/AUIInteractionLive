import { useState, useContext } from 'react';
import classNames from 'classnames';
import { ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import { RoomContext } from '../../RoomContext';
import { LeftOutlineSvg } from '../CustomIcon';
import RoomHeader from './header';
import RoomAside from './aside';
import Player from "../Player";
import styles from './style.less';

function PCRoom() {
  const { roomState } = useContext(RoomContext);
  const { pcTheme } = roomState;
  const [expanded, setExpanded] = useState(false);

  const toggleExpanded = () => {
    setExpanded(!expanded);
  }

  return (
    <section className={classNames(styles.wrap, { dark: pcTheme === 'dark' })}>
      <RoomHeader wrapClassName={styles.header} />

      <div className={styles.container}>
        <main className={classNames(styles.main, { [styles.expanded]: expanded })}>
          <Player device="pc" wrapClassName={styles['player-container']} />

          <div
            className={styles['expand-btn']}
            onClick={toggleExpanded}
          >
            <LeftOutlineSvg />
          </div>
        </main>

        <RoomAside wrapStyle={expanded ? { display: 'none' } : undefined} />
      </div>

      <ToastContainer
        position="top-center"
        closeButton={false}
        autoClose={3000}
        hideProgressBar={true}
        theme={pcTheme}
        className={styles['pc-toast']}
        style={{
          top: '50vh',
          transform: 'translate(-50%, -50%)',
        }}
      />
    </section>
  );
}

export default PCRoom;
