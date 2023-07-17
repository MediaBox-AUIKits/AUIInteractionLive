import { useParams, useNavigate } from 'umi';
import React, { useEffect, useMemo } from 'react';
import LiveRoom from '@/components/LiveRoom';
import services from '@/services';
import { LatestLiveidStorageKey } from '@/utils/constants';
import { LiveRoomTypeEnum } from '@/types/room';

const Room: React.FC = () => {
  const navigate = useNavigate();
  const { roomId } = useParams();

  const userInfo = useMemo(() => services.getUserInfo(), []);

  const roomType = useMemo(() => {
    return LiveRoomTypeEnum.Interaction;
  }, []);

  useEffect(() => {
    if (!roomId) {
      navigate('/room-list');
    }
  }, []);

  const getRoomInfo = () => {
    if (!roomId) {
      return Promise.reject();
    }
    return services.getRoomDetail(roomId).then((res) => {
      // console.log(res);
      // 存储直播间 id 至 localstorage ，方便后续从列表页中进入
      localStorage.setItem(LatestLiveidStorageKey, roomId);

      return res;
    });
  };

  const getToken = () => {
    return services.getToken().then((res: any) => {
      // TODO: 处理异常
      return res.access_token;
    });
  };

  const onExit = () => {
    navigate('/room-list');
  };

  if (!roomId) {
    return null;
  }

  return (
    <LiveRoom
      roomType={roomType}
      userInfo={userInfo}
      onExit={onExit}
      getRoomInfo={getRoomInfo}
      getToken={getToken}
    />
  )
}

export default Room;
