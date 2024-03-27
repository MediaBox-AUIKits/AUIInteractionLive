import React, { useState, useEffect, useMemo } from 'react';
import { useNavigate } from 'umi';
import { DotLoading, Toast } from 'antd-mobile';
import { useTranslation } from 'react-i18next';
import Icon from '@ant-design/icons';
import { LeftOutlineSvg, LiveSvg, PlaybackSvg } from '@/assets/CustomIcon';
import { LatestLiveidStorageKey } from '@/utils/constants';
import services from '@/services';
import { IRoomInfo, RoomStatusEnum } from '@/types/room';
import { convertToCamel, getIMServer } from '@/utils';
import { BasicMap } from '@/types/basic';
import styles from './index.less';

interface RoomBlockProps {
  info: IRoomInfo;
  onClick: React.MouseEventHandler<HTMLDivElement>;
}

function RoomBlock(props: RoomBlockProps) {
  const { t: tr } = useTranslation();
  const { info, onClick } = props;
  const { coverUrl } = info;

  const pvText = useMemo(() => {
    let pv = info.metrics && info.metrics.pv ? info.metrics.pv : 0;
    if (pv > 10000) {
      // 若需要国际化，这里得区分地域，比如 14000 国外格式化为 14K
      return (pv / 10000).toFixed(1) + 'w';
    }
    return pv;
  }, [info]);

  const extensionObj: BasicMap<string> = useMemo(() => {
    let ret = {};
    if (info.extends) {
      try {
        ret = JSON.parse(info.extends);
      } catch (error) {
        console.log('info.extends 解析失败！', error);
      }
    }
    return ret;
  }, [info]);

  return (
    <div className={styles['room-item-wrap']}>
      <div
        onClick={onClick}
        className={styles['room-item']}
        style={
          coverUrl
            ? { backgroundImage: `url(${coverUrl})` }
            : {}
        }
      >
        <div className={styles['room-item-top']}>
          <span className={styles['room-item-top-icon']}>
            <Icon component={info.status === RoomStatusEnum.ended ? PlaybackSvg : LiveSvg} />
          </span>
          <span className={styles['room-item-top-data']}>{pvText} {tr('views')}</span>
        </div>
        <div className={styles['room-item-bottom']}>
          <div className={styles['room-item-title']}>{info.title}</div>
          <div className={styles['room-item-id']}>{extensionObj.userNick || info.anchorId}</div>
        </div>
      </div>
    </div>
  )
}

// 此页面为测试列表页面
function RoomList() {
  const navigate = useNavigate();
  const { t: tr } = useTranslation();
  const [fetching, setFetching] = useState<boolean>(false);
  const [list, setList] = useState<IRoomInfo[]>([]);

  const lastLiveid = useMemo(() => {
    return localStorage.getItem(LatestLiveidStorageKey) || '';
  }, []);

  useEffect(() => {
    
    fetchList();
  }, []);

  const fetchList = () => {
    if (fetching) {
      return;
    }

    setFetching(true);
    services.getRoomList(1, 20, getIMServer())
      .then((res) => {
        if (Array.isArray(res)) {
          setList(res.map((item: any) => {
            const ret = convertToCamel(item) as IRoomInfo;
            return ret;
          }));
        }
      })
      .catch((err) => {
        console.log('获取列表失败', err);
      })
      .finally(() => {
        setFetching(false);
      });
  };

  const enterRoom = async (liveId: string) => {
    const { support } = await window.AlivcLivePush.AlivcLivePusher.checkSystemRequirements();
    if (!support) {
      Toast.show({
        icon: 'fail',
        content: '当前环境不支持webrtc',
      });
      return;
    }
    navigate(`/room/${liveId}`);
  }

  const goBack = () => {
    navigate('/');
  }

  return (
    <section className={styles['room-list-page']}>
      <div className={styles['room-list-header']}>
        <span>{tr('liveroom-list')}</span>
        <Icon
          component={LeftOutlineSvg}
          className={styles['room-list-header__back']}
          onClick={goBack}
        />
        {
          lastLiveid ? (
            <span
              className={styles['room-list-header__last']}
              onClick={() => enterRoom(lastLiveid)}
            >
              {tr('last-live')}
            </span>
          ) : null
        }
      </div>
      <div className={styles['room-list-content']}>
        <div className={styles['room-list-container']}>
          <div className={styles['room-list']}>
            {list.map((item) => (
              <RoomBlock
                key={item.id}
                info={item}
                onClick={() => enterRoom(item.id)}
              />
            ))}
          </div>
        </div>
      </div>

      {
        !fetching && list.length === 0 ? (
          <div className={styles['room-list-empty']}>
            {tr('liveroom_empty')}
          </div>
        ) : null
      }

      {
        fetching ? (
          <div className={styles['loading-block']}>
            <DotLoading />
          </div>
        ) : null
      }
    </section>
  );
}

export default RoomList;
