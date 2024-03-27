import React, { useState } from 'react';
import { Popup } from 'antd-mobile';
import styles from './index.less';

const ShoppingList: React.FC = () => {
  const [shoppingListVisible, setShoppingListVisible] = useState<boolean>(false);

  const closeShoppingList = () => {
    setShoppingListVisible(false)
  };

  return (
    <>
      <Popup
        onMaskClick={() => closeShoppingList()}
        onClose={() => closeShoppingList()}
        visible={shoppingListVisible}
      >
        <div className={styles['shopping-list']}>
          <div className={styles['shopping-title']}>
            商品列表
          </div>
        </div>
      </Popup>

      <span className="chat-btn-wrap" onClick={() => setShoppingListVisible(true)}>
        <span className="chat-btn">
          <img src="https://img.alicdn.com/imgextra/i3/O1CN012R9g7P1F7ZCYy96rK_!!6000000000440-2-tps-108-108.png" />
        </span>
      </span>
    </>
  );
};

export default ShoppingList;
