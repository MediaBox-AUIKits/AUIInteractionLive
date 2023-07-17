/**
 * 本组件为测试逻辑，userId 与输入的昵称一样，方便测试
 * 实际生产环境的登录由您自行实现
*/
import { useState, useMemo } from 'react';
import { Toast, Input, Button, Dialog } from 'antd-mobile';
import { useTranslation } from 'react-i18next';
import services from '@/services';
import styles from './index.less';

interface LoginProps {
  onLoginSuccess: () => void;
}

function Login(props: LoginProps) {
  const { onLoginSuccess } = props;
  const { t: tr } = useTranslation();
  const [nickname, setNickname] = useState<string>('');
  const [logging, setLogging] = useState<boolean>(false);
  const [nickFocus, setNickFocus] = useState<boolean>(false);

  const nickTipClassNames = useMemo(() => {
    const classNames: string[] = [styles['nick-tip']];
    if (nickFocus || nickname) {
      classNames.push('focus');
    }
    return classNames.join(' ');
  }, [nickFocus, nickname]);

  const loginClickHandler = () => {
    const userName = nickname.trim();
    if (logging) {
      return;
    }
    if (!/^[a-zA-Z0-9]+$/.test(userName)) {
      Dialog.alert({
        content: tr('nickname_error'),
        confirmText: tr('confirm'),
      });
      return;
    }
    setLogging(true);

    const userId = userName;
    services.login(userId, userName)
      .then(() => {
        onLoginSuccess();
      })
      .catch((err) => {
        console.log('login fail', err);
        Toast.show({
          icon: 'fail',
          content: tr('login_fail'),
        });
      })
      .finally(() => {
        setLogging(false);
      });
  };

  return (
    <div className={styles['login-page']}>
      <div className={styles['login-form']}>
        <img
          src="https://img.alicdn.com/imgextra/i1/O1CN01i8XGei1UJflU9uYSW_!!6000000002497-2-tps-96-64.png"
          alt="logo"
          className={styles.logo}
        />
        <div className={styles['login-title']}>
          {tr('page_title')}
        </div>
        <div className={styles['nick-block']}>
          <Input
            clearable
            id="aui-interaction-live-nickname"
            autoComplete="off"
            onChange={(value) => setNickname(value)}
            onFocus={() => setNickFocus(true)}
            onBlur={() => setNickFocus(false)}
          />
          <div className={nickTipClassNames}>{tr('nickname_tip')}</div>
        </div>
        <div className={styles['login-btn']}>
          <Button
            disabled={!nickname}
            loading={logging}
            block
            color="primary"
            shape="rounded"
            size="large"
            onClick={loginClickHandler}
          >
            {tr('enter')}
          </Button>
        </div>
      </div>
    </div>
  );
}

export default Login;
