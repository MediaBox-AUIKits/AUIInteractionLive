import { useState, useContext, useMemo, useRef, useEffect, useCallback, CSSProperties } from 'react';
import classNames from 'classnames';
import { useTranslation } from 'react-i18next';
import { throttle } from 'throttle-debounce';
import { RoomContext } from '../../RoomContext';
import { RoomStatusEnum } from '../../types';
import { ChevronsDownSvg } from '../CustomIcon';
import styles from './style.less';

interface IRoomAside {
  wrapStyle?: CSSProperties;
}

// 距离聊天列表底部最大值
const MaxBottomDistance = 60;

function scrollToBottom(dom: HTMLDivElement) {
  // console.log(dom.offsetHeight, dom.scrollHeight, dom.scrollTop);
  dom.scrollTo({
    top: Math.max(dom.scrollHeight - dom.offsetHeight, 0),
    behavior: 'smooth',
  });
}

function RoomAside(props: IRoomAside) {
  const { wrapStyle } = props;
  const { t: tr } = useTranslation();
  const { roomState, dispatch, sendComment } = useContext(RoomContext);
  const { notice, commentInput, status, messageList, groupMuted, selfMuted } = roomState;
  const [tabKey, setTabKey] = useState('chat');
  const [sending, setSending] = useState<boolean>(false);
  const [newTipVisible, setNewTipVisible] = useState<boolean>(false);
  const textareaRef = useRef<HTMLTextAreaElement|null>();
  const autoScroll = useRef<boolean>(true);
  const listRef = useRef<HTMLDivElement|null>(null);

  const allowChat = useMemo(() => {
    // 未开播、直播中时允许使用聊天功能，且非发送中、禁言中
    return [RoomStatusEnum.not_start, RoomStatusEnum.started].includes(status) &&
      !sending &&
      !groupMuted &&
      !selfMuted;
  }, [status, sending, groupMuted, selfMuted]);

  const commentPlaceholder = useMemo(() => {
    let text = tr('liveroom_talkto_anchor');
    if (groupMuted) {
      text = tr('chat_all_banned_start');
    } else if (selfMuted) {
      text = tr('chat_you_banned');
    } else if (status === RoomStatusEnum.ended) {
      text = tr('live_is_ended');
    }
    return text;
  }, [groupMuted, selfMuted, status]);

  useEffect(() => {
    if (!listRef.current) {
      return;
    }
    // 不允许自动滚动底部时不执行滚动，但显示新消息提示
    if (!autoScroll.current) {
      setNewTipVisible(true);
      return;
    }
    // 有新消息滚动到底部
    scrollToBottom(listRef.current);
  }, [messageList]);

  const updateCommentInput = (text: string) => {
    dispatch({
      type: 'update',
      payload: { commentInput: text },
    });
  };

  const handleSent = () => {
    const text = commentInput.trim();
    if (!text || sending || !allowChat) {
      return;
    }

    // 自行发消息就执行自动滚动
    autoScroll.current = true;
    setNewTipVisible(false);

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
        // 发送结束后聚焦输入框
        setTimeout(() => {
          textareaRef.current && textareaRef?.current.focus();
        }, 0);
      });
  }

  const handleScroll = useCallback(throttle(500, () => {
    if (!listRef.current) {
      return;
    }
    const dom = listRef.current;
    const diff = dom.scrollHeight - (dom.clientHeight + dom.scrollTop);
    // 与聊天列表底部的距离大于最大值，不允许自动滚动
    autoScroll.current = diff < MaxBottomDistance;
    // console.log('onWheelCapture', autoScroll.current, diff);
    // 若小于最大值需要隐藏新消息提示
    if (autoScroll.current) {
      setNewTipVisible(false);
    }
  }), []);

  const handleNewTipClick = () => {
    if (!listRef.current) {
      return;
    }
    setNewTipVisible(false);
    scrollToBottom(listRef.current);
    autoScroll.current = true;
  };

  const renderChatPanel = () => {
    return (
      <div className={styles['chat-panel']}>
        <div
          ref={listRef}
          className={styles['chat-list']}
          onScroll={handleScroll}
        >
          <div className={classNames(styles['chat-item'], styles['chat-item-notice'])}>
            {tr('liveroom_notice')}
          </div>
          {messageList.map((item) => (
            <div key={item.messageId} className={styles['chat-item']}>
              <div className={styles['chat-item-nickname']}>
                {item.nickName}:
              </div>
              <div className={styles['chat-item-content']}>{item.content}</div>
            </div>
          ))}
        </div>
        <div className={styles['chat-opetations']}>
          <textarea
            ref={(ref) => textareaRef.current = ref}
            value={commentInput}
            disabled={!allowChat}
            placeholder={commentPlaceholder}
            className={styles['chat-textarea']}
            onChange={(e) => updateCommentInput(e.target.value)}
            onKeyDown={(e) => {
              if (e.key !== 'Enter') {
                return;
              }
              e.preventDefault();
              handleSent();
            }}
          />
          <div
            className={classNames(styles['chat-send-btn'], { disabled: !allowChat })}
            onClick={handleSent}
          >
            {tr('send')}
          </div>
        </div>

        <div
          className={styles['chat-new-tip']}
          style={{ display: newTipVisible ? 'block' : 'none' }}
          onClick={handleNewTipClick}
        >
          <ChevronsDownSvg /> {tr('new_message_tip')}
        </div>
      </div>
    );
  };

  return (
    <aside className={styles.aside} style={wrapStyle}>
      <div className={styles['aside-tab']}>
        <span
          className={classNames(styles['aside-tab-item'], { active: tabKey === 'chat' })}
          onClick={() => setTabKey('chat')}
        >
          {tr('pc_room_chat_list')}
        </span>
        <span
          className={classNames(styles['aside-tab-item'], { active: tabKey === 'notice' })}
          onClick={() => setTabKey('notice')}
        >
          {tr('pc_room_notice')}
        </span>
      </div>

      {
        tabKey === 'chat' ? renderChatPanel() : (
          <div className={styles['notice-panel']}>
            {notice || tr('live_room_notice_empty')}
          </div>
        )
      }
    </aside>
  );
}

export default RoomAside;
