/* eslint-disable no-underscore-dangle */
function isNotEmptyString(str: string) {
  return typeof str === 'string' && str;
}

function isFunction(func: any) {
  return typeof func === 'function';
}

function fastApply(func: Function, that: any, args: any) {
  const len = args ? args.length : 0;
  switch (len) {
    case 0:
      return func.call(that);
    case 1:
      return func.call(that, args[0]);
    case 2:
      return func.call(that, args[0], args[1]);
    case 3:
      return func.call(that, args[0], args[1], args[2]);
    case 4:
      return func.call(that, args[0], args[1], args[2], args[3]);
    default:
      return func.apply(that, args);
  }
}

class EventBus {
  _handlers: any = {};

  constructor() {
    this._handlers = {};
  }

  /**
   * 绑定事件
   * @param {string} event 事件名
   * @param {function} callback 回调函数
   * @memberof EventBus
   */
  addListener(event: string, callback: Function) {
    if (!isNotEmptyString(event) || !isFunction(callback)) {
      return;
    }
    if (this._handlers[event]) {
      this._handlers[event].push(callback);
    } else {
      this._handlers[event] = [callback];
    }
  }

  /**
   * 解绑某个事件，若 !callback 为 false，仅解绑该函数，否则解绑该事件所有函数
   * @param {string} event 事件名
   * @param {Function} [callback] 回调函数，可为空
   * @memberof EventBus
   */
  removeListener(event: string, callback?: Function) {
    if (!isNotEmptyString(event)) {
      return;
    }
    if (callback) {
      const handlers = this._handlers[event] || [];
      for (let i = 0; i < handlers.length; i++) {
        if (handlers[i] === callback) {
          handlers.splice(i, 1);
          break;
        }
      }
    } else {
      this._handlers[event] = [];
    }
  }

  /**
   * 解绑所有事件
   * @memberof EventBus
   */
  removeAllEvent() {
    this._handlers = {};
  }

  /**
   * 仅绑定一次事件
   * @param {string} event 事件名
   * @param {function} callback 回调函数
   * @memberof EventBus
   */
  once(event: string, callback: Function) {
    if (!isNotEmptyString(event) || !isFunction(callback)) {
      return;
    }
    const self = this;

    function g(...args: any[]) {
      self.removeListener(event, g);
      fastApply(callback, self, args);
    }

    this.addListener(event, g);
  }

  /**
   * 触发事件，执行回调函数
   * @param {string} event 事件名
   * @param {array} args 参数数组
   * @memberof EventBus
   */
  emit(event: string, ...args: any[]) {
    if (!isNotEmptyString(event)) {
      return;
    }
    const handlers = this._handlers[event] || [];
    handlers.forEach((handler: Function) => {
      fastApply(handler, this, args);
    });
  }
}

export default EventBus;
