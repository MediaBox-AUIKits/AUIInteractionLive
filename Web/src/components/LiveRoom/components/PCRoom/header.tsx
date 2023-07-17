import { useContext, useState, useRef, useCallback, useMemo, Fragment } from 'react';
import { useTranslation } from 'react-i18next';
import classNames from 'classnames';
import { RoomContext } from '../../RoomContext';
import { RoomStatusEnum } from '../../types';
import { ExitSvg, LeftOutlineSvg, CrescentSvg, SunSvg } from '../CustomIcon';
import copyText from '../../utils/copyText';
import styles from './header.less';

interface IRoomHeader {
  wrapClassName: string;
}

function RoomHeader(props: IRoomHeader) {
  const { wrapClassName } = props;
  const { t: tr } = useTranslation();
  const { roomState, dispatch, exit } = useContext(RoomContext);
  const { title, pv, status, pcTheme } = roomState;
  const [copyTipVisible, setCopyVisible] = useState(false);
  const [copyTipType, setCopyTipType] = useState('');
  const copyTipTimer = useRef<number>();

  const pvText = useMemo(() => {
    if (pv > 10000) {
      // 若需要国际化，这里得区分地域，比如 14000 国外格式化为 14K
      return (pv / 10000).toFixed(1) + 'w';
    }
    return pv;
  }, [pv]);

  const toggleTheme = useCallback(() => {
    dispatch({
      type: 'update',
      payload: { pcTheme: pcTheme === 'dark' ? 'light' : 'dark' },
    });
  }, [pcTheme]);

  const renderStatusBlock = () => {
    if (status === RoomStatusEnum.no_data) {
      return null;
    }
    if (status === RoomStatusEnum.ended) {
      return (
        <span className={classNames(styles['status-block'], 'playback')}>
          {tr('playback')}
        </span>
      );
    }
    return (
      <span className={classNames(styles['status-block'], 'live')}>
        {tr('live')}
      </span>
    );
  }

  const renderTitleBlock = () => {
    if (!title) {
      return;
    }
    const linkText = `${tr('link')}: ${location.href}`;
    const map: any = {
      success: tr('copy_success'),
      fail: tr('copy_fail'),
    }
    return (
      <div className={styles['title-block']}>
        <span className={styles['title-block-text']}>{title}</span>
        <LeftOutlineSvg />

        <div className={styles['title-block-popover']}>
          <div className={styles['title-block-popover-content']}>
            <p>{title}</p>
            <p className={styles['title-block-popover-link']}>{linkText}</p>

            <span
              className={styles['title-block-popover-copy']}
              onClick={() => {
                const bool = copyText(`${title}\n${linkText}`);
                setCopyVisible(true);
                setCopyTipType(bool ? 'success' : 'fail');
                
                if (copyTipTimer.current) {
                  window.clearTimeout(copyTipTimer.current);
                }
                copyTipTimer.current = window.setTimeout(() => {
                  setCopyVisible(false);
                }, 2000);
              }}
            >
              {tr('copy_info')}
            </span>
            
            {
              copyTipVisible ? (
                <span className={classNames(styles['title-block-popover-copy-tip'], copyTipType)}>
                  {map[copyTipType]}
                </span>
              ) : null
            }
          </div>
        </div>
      </div>
    );
  }
  
  return (
    <div className={wrapClassName}>
      <span className={styles.logo}></span>

      {renderTitleBlock()}
      {renderStatusBlock()}
      {status !== RoomStatusEnum.no_data ? (
        <span className={styles['base-block']}>
          {pvText} {tr('views')}
        </span>
      ) : null}

      <div className={styles.right}>
        <span
          className={styles['right-item']}
          onClick={toggleTheme}
        >
          { pcTheme === 'dark' ? (
            <Fragment>
              <SunSvg /> {tr('switch_light_theme')}
            </Fragment>
          ) : (
            <Fragment>
              <CrescentSvg /> {tr('switch_dark_theme')}
            </Fragment>
          )}
        </span>
        <span
          className={styles['right-item']}
          onClick={() => exit()}
        >
          <ExitSvg /> {tr('exit_live_room')}
        </span>
      </div>
    </div>
  )
}

export default RoomHeader;
