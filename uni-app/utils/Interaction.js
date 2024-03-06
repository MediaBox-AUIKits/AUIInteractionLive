// 非 H5 执行以下代码
// #ifndef H5
import { ImEngine, ImLogLevel } from '@/lib/alivc-im.js';
console.log('当前为非 H5 环境');
export { ImEngine, ImLogLevel };
// #endif

// 是 H5 时执行这样
// #ifdef H5
const { ImEngine } = window.AliVCInteraction;
console.log('当前为 H5 环境');

export { ImEngine };
// #endif