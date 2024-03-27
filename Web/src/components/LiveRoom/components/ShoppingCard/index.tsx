import React, { 
  useContext, 
  useEffect, 
  useState, 
} from 'react';
import { Popover } from 'antd-mobile';
import { CloseOutline } from 'antd-mobile-icons'
import { RoomContext } from '../../RoomContext';
import { AUIMessageEvents } from '@/BaseKits/AUIMessage/types';
import { CustomMessageTypes } from '../../types';
import styles from './index.less';

const ShoppingCard: React.FC = () => {
  const { auiMessage } = useContext(RoomContext);
  const [shoppingCardVisible, setShoppingCardVisible] = useState<boolean>(false);

  const handleShoppingProduct = (data: any) => {
    setShoppingCardVisible(true);
    // 更多业务逻辑自行实现
  };

  useEffect(() => {
    const handleReceivedMessage = (eventData: any) => {
      console.log('收到信息啦', eventData);
      const { type, senderInfo, data } = eventData || {};
  
      switch (type) {
        case CustomMessageTypes.ShoppingProduct:
          // 电商卡片消息
          handleShoppingProduct(data);
          break;
        default:
          break;
      }
    };
    auiMessage.addListener(AUIMessageEvents.onMessageReceived, handleReceivedMessage);

    return () => {
      auiMessage.removeListener(AUIMessageEvents.onMessageReceived, handleReceivedMessage);
    };
  }, [auiMessage]);

  return (
    <Popover
      placement='top'
      mode='light'
      content={
        <div className={styles['shopping-card']}>
          <div
            className={styles['shopping-close-icon']}
            onClick={() => setShoppingCardVisible(false)}
          >
            <CloseOutline />
          </div>
        </div>
      }
      visible={shoppingCardVisible}
      style={{ '--arrow-size': '0' }}
    >
      <div></div>
    </Popover>
  );
};

export default ShoppingCard;
