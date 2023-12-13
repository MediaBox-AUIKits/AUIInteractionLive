import { useParams, useNavigate } from 'umi';
import React, { useEffect, useMemo } from 'react';
import LiveRoom from '@/components/LiveRoom';
import services from '@/services';
import { LatestLiveidStorageKey } from '@/utils/constants';
import { getIMServer } from '@/utils';

const Room: React.FC = () => {
  const navigate = useNavigate();
  const { roomId } = useParams();

  const userInfo = useMemo(() => services.getUserInfo(), []);

  useEffect(() => {
    if (!roomId) {
      navigate('/room-list');
    }
  }, []);

  const getRoomInfo = () => {
    if (!roomId) {
      return Promise.reject();
    }

    return services.getRoomDetail(roomId, getIMServer()).then((res) => {
      // console.log(res);
      // 存储直播间 id 至 localstorage ，方便后续从列表页中进入
      localStorage.setItem(LatestLiveidStorageKey, roomId);

      return res;
    });
  };

  const getToken = (role?: string) => {
    return services.getToken(getIMServer(), role);
  };

  const onExit = () => {
    navigate('/room-list');
  };

  if (!roomId) {
    return null;
  }

  return (
    <LiveRoom
      roomType="interaction"
      userInfo={userInfo}
      onExit={onExit}
      getRoomInfo={getRoomInfo}
      getToken={getToken}
    />
  )
}

export default Room;
