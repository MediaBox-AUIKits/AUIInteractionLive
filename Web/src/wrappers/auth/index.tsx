/**
 * 校验是否登录的demo组件，请结合自身情况修改校验逻辑
 */

import { useState, useEffect } from 'react';
import { Navigate, Outlet } from 'umi';
import services from '@/services';
 
export default () => {
  const [isLogin, setIsLogin] = useState<boolean>();

  useEffect(() => {
    services.checkLogin()
      .then((res) => {
        console.log('已登录', res);
        setIsLogin(true);
      })
      .catch(() => {
        console.log('未登录');
        setIsLogin(false);
      });
  }, []);
  
  if (isLogin === true) {
    return <Outlet />;
  }

  if (isLogin === false) {
    return <Navigate to="/" />;
  }
}
