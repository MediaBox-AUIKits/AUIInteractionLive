import 'umi/typings';
import * as IMLib from '@rongcloud/imlib-next';
import { AliVCInteraction } from './typings/AliVCInteraction.d.ts';
import { IConfig } from '@/config';

declare global {
  type RongIMLib = typeof IMLib;
  interface Window {
    Aliplayer: any;
    AliVCInteraction: typeof AliVCInteraction;
    AlivcLivePush: any;
  }

  const CONFIG: IConfig;
  const ASSETS_VERSION: string;
}
