import 'umi/typings';
import * as IMLib from '@rongcloud/imlib-next';
import { AliVCInteraction } from './typings/AliVCInteraction.d.ts';
import type { AliyunInteraction } from './typings/AliyunInteraction.d.ts';
import { IConfig } from '@/config';

declare global {
  type RongIMLib = typeof IMLib;
  interface Window {
    AliyunInteraction: AliyunInteraction;
    Aliplayer: any;
    AliVCInteraction: typeof AliVCInteraction;
  }

  const CONFIG: IConfig;
  const ASSETS_VERSION: string;
}
