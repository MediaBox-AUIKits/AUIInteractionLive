import { BasicMap } from '@/types/basic';
import { DefaultAvatars } from './constants';

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

// 把search分割成对象
export const splitSearch = (search: string): BasicMap<any> => {
  const result: BasicMap<string> = {};
  try {
    search
      .split('?')[1]
      .split('&')
      .forEach((item: string) => {
        const itemSplit = item.split('=');
        result[itemSplit[0]] = itemSplit[1];
      });
    return result;
  } catch (err) {
    return {};
  }
};

export const getUrlWithString = (str: string) => {
  const reg = new RegExp(
    '(https?|http|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]',
  );
  if (reg.test(str)) {
    const match = str.match(reg);
    let newStr;
    if (match && match[0]) newStr = match[0];
    return str.replace(
      reg,
      `<a href="${newStr}" target="_blank">${newStr}</a>`,
    );
  }
  return str;
};

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

// 从下划线格式转为驼峰
export function convertToCamel(data: any): any {
  if (typeof data !== 'object' || !data) return data
  
  if (Array.isArray(data)) {
    return data.map(item => convertToCamel(item));
  }

  let newObj: BasicMap<any> = {};
  for (const key in data) {
    if (Object.prototype.hasOwnProperty.call(data, key)) {
      let newKey = key.replace(/_([a-z])/g, res => res[1].toUpperCase());
      newObj[newKey] = convertToCamel(data[key]);
    }
  }
  return newObj;
}

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
 * 深克隆
 * @template T
 * @param {T} obj
 * @return {T}
 */
export function deepClone<T>(obj: T): T {
  if (!obj || typeof obj !== 'object') {
    return obj;
  }
  if (obj instanceof RegExp) {
    // See https://github.com/Microsoft/TypeScript/issues/10990
    return obj as any;
  }
  const result: any = Array.isArray(obj) ? [] : {};
  Object.keys(<any>obj).forEach((key: string) => {
    if ((<any>obj)[key] && typeof (<any>obj)[key] === 'object') {
      result[key] = deepClone((<any>obj)[key]);
    } else {
      result[key] = (<any>obj)[key];
    }
  });
  return result;
}

/**
 * 从当前 location.search 中获取某个参数值
 * @param {string} key
 * @return {*} 
 */
export function getParamFromSearch(key: string) {
  const url = window.location.search;
  const reg = new RegExp(`(^|&)${key}=([^&]*)(&|$)`);
  const result = url.substring(1).match(reg);
  return result ? decodeURIComponent(result[2]) : null;
}

/**
 * 根据 userId 首字母取用户头像
 * @param {string} userId
 * @return {string} 
 */
export function getRandomAvatar(userId: string) {
  if (!userId) {
    return DefaultAvatars[0];
  }
  return DefaultAvatars[userId.charCodeAt(0) % DefaultAvatars.length];
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
