import { Outlet } from 'umi';
import { useEffect, useMemo } from 'react';
import { getParamFromSearch } from '@/utils';
import styles from './index.less';

export default function Layout() {
  const env = useMemo(() => getParamFromSearch('env'), []);

  useEffect(() => {
    const updateBodyFontSize = () => {
      const width = document.documentElement.clientWidth;
      let value = Math.floor(width / 15);
      value = Math.floor(value / 5) * 5 + 25;
      value = Math.min(value, 75);
      document.documentElement.style.fontSize = `${value}px`;
    };

    updateBodyFontSize();
    
    window.onresize = () => {
      updateBodyFontSize();
    };

    return () => {
      document.documentElement.style.fontSize = '16px';
    };
  }, []);

  return (
    <div className={styles['app-layout']}>
      {
        env === 'staging' ? (
          <div className={styles['app-env']}>预发环境</div>
        ) : null
      }
      <Outlet />
    </div>
  );
}
