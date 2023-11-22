// 非 H5 执行以下代码
// #ifndef H5
import { InteractionEngine, InteractionEventNames, InteractionMessageTypes } from  '@/utils/aliyun-interaction-sdk.mini.esm.js';

export { InteractionEngine, InteractionEventNames, InteractionMessageTypes };
// #endif

// 是 H5 时执行这样
// #ifdef H5
const { InteractionEngine, InteractionEventNames, InteractionMessageTypes } = window.AliyunInteraction;

export { InteractionEngine, InteractionEventNames, InteractionMessageTypes };
// #endif