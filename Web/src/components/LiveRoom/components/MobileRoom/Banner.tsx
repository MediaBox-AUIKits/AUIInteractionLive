import { useContext, useState, useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import Icon from '@ant-design/icons';
import { AudienceSvg, NoticeSvg, LeftOutlineSvg } from '../CustomIcon';
import { RoomContext } from '../../RoomContext';
import { BasicMap } from '../../types';
import styles from './index.less';

export default function Banner() {
  const { roomState, exit } = useContext(RoomContext);
  const { extends: extension, title, pv, notice, anchorId } = roomState;
  const [showNotice, setShowNotice] = useState(false);
  const { t } = useTranslation();

  const extensionObj: BasicMap<string> = useMemo(() => {
    let ret = {};
    if (extension) {
      try {
        ret = JSON.parse(extension);
      } catch (error) {
        console.log('extension 解析失败！', error);
      }
    }
    return ret;
  }, [extension]);

  const pvText = useMemo(() => {
    if (pv > 10000) {
      // 若需要国际化，这里得区分地域，比如 14000 国外格式化为 14K
      return (pv / 10000).toFixed(1) + 'w';
    }
    return pv;
  }, [pv]);

  const closeRoom = () => {
    exit();
  };

  return (
    <div className={styles.top}>
      <div className={styles['room-info-container']}>
        <div className={styles['room-info']}>
          <div
            className={styles.avatar}
            style={{
              backgroundImage: `url('${
                extensionObj?.userAvatar ||
                  'https://img.alicdn.com/imgextra/i4/O1CN01BQZKz41EGtPZp3U5P_!!6000000000325-2-tps-1160-1108.png'
              }')`,
            }}
          ></div>
          <div className={styles['info-wrap']}>
            <div className={styles['info-title']}>
              {title}
            </div>
            <div className={styles['info-id']}>
              {extensionObj?.userNick || anchorId}
            </div>
          </div>
          <button className={styles['follow-btn']}>+{t('follow')}</button>
        </div>
        <div className={styles.notice} onClick={() => setShowNotice(!showNotice)}>
          <NoticeSvg />
          <span className={styles['notice-title']}>{t('live_room_notice')}</span>
          <Icon
            component={LeftOutlineSvg}
            style={{
              verticalAlign: 'middle',
              transform: `rotate(${showNotice ? '' : '-'}90deg)`,
            }}
          />
          {showNotice && (
            <div className={styles['notice-content']}>{notice || t('live_room_notice_empty')}</div>
          )}
        </div>
      </div>

      <span className={styles.audience}>
        <AudienceSvg />
        <span>{pvText}</span>
      </span>
      <div className={styles.close} onClick={closeRoom}>&times;</div>
    </div>
  );
}