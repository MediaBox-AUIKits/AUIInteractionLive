import { createInstance } from 'i18next';
import translation_en from './en.json';
import translation_zh from './zh.json';

let lng = 'zh';
if (!navigator.language.includes('zh')) {
  // 除了传入zh以外，其他都搞成en
  lng = 'en';
}

const resources = {
  en: {
    translation: translation_en,
  },
  zh: {
    translation: translation_zh,
  },
};

const i18n = createInstance({
  lng,

  interpolation: {
    escapeValue: false, // not needed for react as it escapes by default
  },

  resources,
});

i18n.init();

export default i18n;
