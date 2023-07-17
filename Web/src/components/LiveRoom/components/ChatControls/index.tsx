import React, { useContext, useRef, useMemo, useState, KeyboardEvent } from 'react';
import { useTranslation } from 'react-i18next';
import { Toast } from 'antd-mobile';
import Icon from '@ant-design/icons';
import classNames from 'classnames';
import { ReplySvg, HeartSvg } from '../CustomIcon';
import { RoomContext } from '../../RoomContext';
import styles from './index.less';

interface IChatControlsProps {
  theme?: 'dark' | 'light';
  className?: string;
  heartIconActive?: boolean;
  allowChat: boolean;
}

const ChatControls: React.FC<IChatControlsProps> = (props) => {
  const { allowChat, className, heartIconActive, theme = 'dark' } = props;
  const { t: tr } = useTranslation();
  const operationRef = useRef<HTMLDivElement>(null);
  const { roomState, animeContainerEl, dispatch, sendComment, sendLike } = useContext(RoomContext);
  const { commentInput, groupMuted, selfMuted } = roomState;
  const [sending, setSending] = useState<boolean>(false);

  const commentPlaceholder = useMemo(() => {
    let text = tr('liveroom_talkto_anchor');
    if (groupMuted) {
      text = tr('chat_all_banned_start');
    } else if (selfMuted) {
      text = tr('chat_you_banned');
    }
    return text;
  }, [groupMuted, selfMuted]);

  const updateCommentInput = (text: string) => {
    dispatch({
      type: 'update',
      payload: { commentInput: text }
    });
  };

  const handleKeydown = (e: KeyboardEvent<HTMLInputElement>) => {
    const text = commentInput.trim();
    if (e.key !== 'Enter' || !text || sending || !allowChat) {
      return;
    }
    e.preventDefault();

    setSending(true);
    sendComment(text)
      .then(() => {
        console.log('发送成功');
        updateCommentInput('');
      })
      .catch((err: any) => {
        console.log('发送失败', err);
      })
      .finally(() => {
        setSending(false);
      });
  }

  const share = () => {
    // 请自行实现分享逻辑
    Toast.show(tr('share_tip'));
  };

  const touchInputHandler = () => {
    // 解决发送双击问题，增加scrollIntoView
    operationRef.current?.scrollIntoView(false);
  };

  return (
    <div
      className={classNames(
        styles['chat-controls'],
        className,
        { [styles['chat-controls-light']]: theme === 'light' }
      )}
      ref={operationRef}
    >
      <form
        action=""
        className="chat-input-form"
        style={{ visibility: allowChat ? 'visible' : 'hidden' }}
        onSubmit={(e: any) => e.preventDefault()}
      >
        <input
          type="text"
          enterKeyHint="send"
          className="chat-input"
          placeholder={commentPlaceholder}
          value={commentInput}
          disabled={!allowChat || sending || groupMuted || selfMuted}
          onKeyDown={handleKeydown}
          onChange={(e) => updateCommentInput(e.target.value)}
          onTouchStart={touchInputHandler}
        />
      </form>

      <span className="chat-btn-wrap">
        <span className="chat-btn" onClick={share}>
          <Icon component={ReplySvg} />
        </span>
      </span>

      <span className="chat-btn-wrap">
        <span className="chat-btn" onClick={() => sendLike()}>
          <Icon component={HeartSvg} className={heartIconActive ? 'active' : ''} />
        </span>
        <div ref={animeContainerEl} className="like-anime-container"></div>
      </span>
    </div>
  );
};

export default ChatControls;
