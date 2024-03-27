import { AUIMessageServerProps } from '@/BaseKits/AUIMessage/types';

export interface IConfig {
  appServer: {
    origin: string;
  };
  imServer: AUIMessageServerProps;
  isShoppingMode: boolean;
}

// 在 .umirc.ts 中将 config 对象挂在全局的 CONFIG 下
// 工程逻辑代码中请使用 CONFIG 访问相关配置项，例：CONFIG.appServer.appServer
const config: IConfig = {
  // 配置 APPServer
  appServer: {
    origin: '', // 配置 APPServer 服务域名，例子: https://xxx.xxx.xxx
  },
  imServer: {
    aliyunIMV2: {
      enable: true,
      primary: true,
    },
  },
  // 是否是电商直播间模式
  isShoppingMode: false,
};

export default config;
