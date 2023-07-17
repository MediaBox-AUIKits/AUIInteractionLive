import fs from 'fs';
import path from 'path';

const packagejson = fs.readFileSync(path.resolve('./package.json'));
const json = JSON.parse(packagejson.toString());

// 详细配置文档请阅读官方文档：https://umijs.org/docs/api/config
export default {
  alias: {
    '@': './src'
  },
  history: {
    type: 'hash'
  },
  metas: [
    {
      name: 'Viewport',
      content: 'width=device-width,initial-scale=1,maximum-scale=1,user-scalable=0,viewport-fit=cover',
    },
    {
      name: 'description',
      content: '阿里云互动直播',
    },
  ],
  // 路由配置，详细文档请阅读官方文档：https://umijs.org/docs/guides/routes
  routes: [
    {
      exact: true,
      path: '/room/:roomId',
      component: 'room',
      wrappers: ['@/wrappers/auth'],
    },
    {
      exact: true,
      path: '/room-list',
      component: 'room-list',
      wrappers: ['@/wrappers/auth'],
    },
    { exact: true, path: '/', component: 'index' },
  ],
  // 这里是修改打包的 index.html 要使用的 umi.js 、umi.css 地址的公共路径，默认是 /
  // 若并非直接访问 index.html，而是其他页面加载生成的 umi.js 、umi.css 的话，可以删去 publicPath、chainWebpack
  // 若需要定义，请按你实际情况，区分使用线上、预发等环境
  publicPath:
    process.env.NODE_ENV === 'production'
      ? `/publicPath/${json.name}/${json.version}/`
      : '/',
  // 兼容 es5，使用这两个压缩工具
  jsMinifier: 'terser',
  cssMinifier: 'cssnano',
  // 本地开发是可以使用代理，详细文档请阅读官方文档：https://umijs.org/docs/guides/proxy
  // proxy: {
  //   '/api': {
  //     'target': '您的Appserver服务域名',
  //     'changeOrigin': true,
  //   },
  // },
};
