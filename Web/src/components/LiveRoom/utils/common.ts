import { BasicMap } from '../types';

// 判断当前在哪个platform
export const UA = (() => {
  const ua = navigator.userAgent;
  const isAndroid = /(?:Android)/.test(ua);
  const isFireFox = /(?:Firefox)/.test(ua);
  const isPad =
    /(?:iPad|PlayBook)/.test(ua) ||
    (isAndroid && !/(?:Mobile)/.test(ua)) ||
    (isFireFox && /(?:Tablet)/.test(ua));
  const isiPad =
    /(?:iPad)/.test(ua) ||
    (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1);
  const isiPhone = /(?:iPhone)/.test(ua) && !isPad;
  const isPC = !isiPhone && !isAndroid && !isPad && !isiPad;
  // 判断夸克和UC
  const isQuark = /(?:Quark)/.test(ua);
  const isUC = /(?:UCBrowser)/.test(ua);
  return {
    isPad,
    isiPhone,
    isAndroid,
    isPC,
    isiPad,
    isQuark,
    isUC,
  };
})();

export const replaceHttps = (url: string) => {
  if (!url || typeof url !== 'string') return url;
  return url.replace(/^http:\/\//i, 'https://');
};


// 创建一个dom元素
export const createDom = (type = 'div', options: any, content = '') => {
  let dom = document.createElement(type);
  if (
    options &&
    options.toString() === '[object Object]' &&
    JSON.stringify(options) !== '{}'
  ) {
    Object.keys(options).forEach((item) => {
      dom.setAttribute(item, options[item]);
    });
  }
  if (content) dom.append(content);
  return dom;
};

// 获取一个max和min之间的随机数
export const randomNum = (max: number, min: number) => {
  return Math.floor(Math.random() * (max - min + 1) + min);
};

/**
   * 可根据参数数组浅拷贝对象
   * @param {object} obj 若非Object类型返回null
   * @param {array} params 若非数组或空数组拷贝对象的所有属性
   * @return {object}
   */
export function assignObjectByParams(obj: BasicMap<any>, params?: string[]) {
  if (typeof obj !== 'object') {
    return null;
  }
  if (!Array.isArray(params) || params.length === 0) {
    return Object.assign({}, obj);
  }
  const ret: BasicMap<any> = {};
  params.forEach((el) => {
    if (obj[el] !== undefined && obj[el] !== null) {
      ret[el] = obj[el];
    }
  });
  return ret;
}

/**
 * 通过昵称取颜色
 * @param {string} [name]
 * @return {string}
 */
export function getNameColor(name?: string) {
  const NicknameColors = ['#FFAB91', '#FED998', '#F6A0B5', '#CBED8E', '#95D8F8'];
  if (!name) {
    return '';
  }
  return NicknameColors[name.charCodeAt(0) % NicknameColors.length];
}

/**
 * 简单滚动到底部的实现
 * @param {HTMLDivElement} dom
 */
export function scrollToBottom(dom: HTMLElement) {
  // console.log(dom.offsetHeight, dom.scrollHeight, dom.scrollTop);
  dom.scrollTo({
    top: Math.max(dom.scrollHeight - dom.offsetHeight, 0),
    behavior: 'smooth',
  });
}

/**
 * 简单实现格式化日期，若需要使用更复杂的功能，建议使用如 momentjs 等库
 * @param {Date} date
 * @return {string} 
 */
export function formatDate(date: Date): string {
  if (!(date instanceof Date && !isNaN(date as any))) {
    return '';
  }

  const padZore = (str: string|number) => {
    return (`0${str}`).slice(-2);
  }

  return `${date.getFullYear()}-${padZore(date.getMonth() + 1)}-${padZore(date.getDate())} ${padZore(date.getHours())}:${padZore(date.getMinutes())}`;
}

/**
 * 判断当前设置是否支持constant(safe-area-inset-top)或env(safe-area-inset-top)或
 * constant(safe-area-inset-bottom)或env(safe-area-inset-bottom)
 * 部分Android设备，可以认识safa-area-inset-top、safe-area-inset-bottom，但会将其识别为0
 * @param {boolean} [top] 检查 top 或者 bottom
 * @returns {boolean} 当前设备是否支持安全距离
 */
export function supportSafeArea(side: 'top' | 'bottom'): boolean {
  const div = document.createElement('div');
  const id = 'check-safe-area-block';
  const styles = [
    'position: fixed',
    'z-index: -1',
  ];
  if (side === 'top') {
    styles.push(...[
      'height: constant(safe-area-inset-top)',
      'height: env(safe-area-inset-top)',
    ]);
  } else {
    styles.push(...[
      'height: constant(safe-area-inset-bottom)',
      'height: env(safe-area-inset-bottom)',
    ]);
  }
  div.style.cssText = styles.join(';');
  div.id = id;
  document.body.appendChild(div);
  const areaDiv = document.getElementById(id);
  let bool = false;
  if (areaDiv) {
    bool = areaDiv.offsetHeight > 0; // 该 div 的高度是否为 0
    areaDiv.parentNode?.removeChild(areaDiv);
  }
  return bool;
};
