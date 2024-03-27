import { Fragment, useMemo, useContext } from 'react';
import { useTranslation } from 'react-i18next';
import ChatControls from '../ChatControls';
import ConnectingManager from './ConnectingManager';
import { RoomContext } from '../../RoomContext';
import { RoomModeEnum, RoomStatusEnum } from '../../types';
import { getNameColor } from '../../utils/common';
import styles from './ChatBox.less';

interface ChatBoxProps {
  hidden?: boolean;
}

function ChatBox(props: ChatBoxProps) {
  const { hidden } = props;
  const { roomState, bulletContainerEl } = useContext(RoomContext);
  const { t: tr } = useTranslation();
  const { status, messageList, isPlayback, mode } = roomState;

  const allowChat = useMemo(() => {
    // 未开播、直播中时允许使用聊天功能
    return [RoomStatusEnum.not_start, RoomStatusEnum.started].includes(status);
  }, [status]);

  return (
    <Fragment>
      <div
        className={styles['chat-box']}
        style={{
          display: !!hidden ? 'none' : 'block',
          bottom: isPlayback ? '80px' : 0, // 回看时有控制条，需要往上提，以免遮挡
        }}
      >
        <div
          className={styles['chat-list']}
          style={{ display: allowChat ? 'flex' : 'none' }}
        >
          {messageList.map((data, index: number) => (
            <div className={styles['chat-item']} key={data.messageId || index}>
              <span style={{ color: getNameColor(data.nickName) }}>
                {data.nickName ? data.nickName + ': ' : ''}
              </span>
              <span>{data.content}</span>
            </div>
          ))}
          <div className={`${styles['chat-item']} ${styles['chat-item-notice']}`}>
            {tr('liveroom_notice')}
          </div>
        </div>
        
        {
          status === RoomStatusEnum.started && mode === RoomModeEnum.rtc ?
            <ConnectingManager
              className={styles['connecting-manager']}
            /> : null
        }

        <ChatControls
          className={styles['operations-wrap']}
          allowChat={allowChat}
          theme="dark"
        />

        {/* 用于会消失的消息 */}
        <div
          ref={bulletContainerEl}
          className={styles['bullet-list']}
          style={{ display: allowChat ? 'flex' : 'none' }}
        ></div>
      </div>
    </Fragment>
  )
}

export default ChatBox;
