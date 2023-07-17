import 'umi/typings';
import type { AliyunInteraction } from './AliyunInteraction.d.ts'

declare global {
  interface Window {
    AliyunInteraction: AliyunInteraction;
    Aliplayer: any;
  }
}