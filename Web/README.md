# AUIInteractionLive
阿里云 · AUI Kits 互动直播场景（竖屏样式）

## 介绍
AUI Kits 互动直播场景（竖屏样式）集成工具是阿里云提供的跨平台直播服务，为业务方提供娱乐、秀场、电商等场景的能力，借助视频直播稳定、流畅、灵活的产品能力，以低代码的方式助力业务方快速发布直播应用。

## 前提
请先接入、运行、部署开源的 Appserver 服务
## 开发框架
本项目使用 UmiJS 框架开发，技术栈为 React + TypeScript ，详细请了解 [UmiJS 官方文档](https://umijs.org/docs/introduce/introduce)。
## 集成流程
### 环境准备
若您本地已经安装好 Node 环境请跳过此步骤，否则请参考[ UmiJS 快速上手教程](https://umijs.org/docs/tutorials/getting-started) 将环境准备好。
### 配置 Appserver 域名
项目中依赖使用了多个 Appserver 接口，所以需要根据配置您所运行的 Appserver 服务的域名。根据不同页面部署方式可以按下面两种不同的方案，选择选择适合的方式。
#### 方式1：配置 proxy
若前端页面与 Appserver 服务部署在同一域名路径下时，只需要本地开发时进行接口代理即可，请打开根目录下的 .umirc.ts 文件，参考下面伪代码根据您实际情况配置 proxy 。
```typescript
export default {
  // 省略其他配置参数
  proxy: {
    '/api': {
      'target': '您的接口域名路径',
      'changeOrigin': true,
    },
  },
}
```
#### 方式2：在代码中写入 Appserver 服务域名
若前端页面需要与 Appserver 服务部署在不同域名路径下时，就无法使用 proxy 解决，这时请修改 src/config.ts 文件，在 origin 字段内配置对应的 Appserver 服务域名。另外，页面、接口在不同环境下时 Appserver 服务端需要开启跨域设置，当前开源的 Appserver 服务已开启。
```typescript
const config: IConfig = {
  // 配置 APPServer
  appServer: {
    origin: '', // 配置 APPServer 服务域名，例子: https://xxx.xxx.xxx
  },
  imServer: {
    aliyunIMV1: {
      enable: false,
      primary: false,
    },
    aliyunIMV2: {
      enable: true,
      primary: true,
    },
  },
};
```
若测试环境与线上环境使用的接口域名不一致时，可以打开 src/services/base.ts 根据当前域名来设置 ServicesOrigin 。
```typescript
export const ServicesOrigin = 
  location.hostname === '页面测试域名' ? 'APPServer 测试域名' : 'APPServer 线上域名';
```
### 本地运行
配置完接口域名后，打开终端，进入工程文件夹，执行下方指令，即可在本地运行起来。
```bash
// 安装 npm 包（安装速度慢）
npm install
// 若已安装 cnpm 、pnpm、tnpm 等工具，请使用选择以下某个指令安装
cnpm install
pnpm install
tnpm install

// 安装完成后，执行 dev 指令，运行成功后根据提示使用浏览器访问即可
npm run dev
```
### 构建配置
```bash
// 运行 build 指令即可构建最终产物至 ./dist 目录下
npm run build
```
构建的文件主要为 index.html 、umi.js、umi.css ，其余的是按需加载的资源文件。<br />请根据您部署生产环境、加载资源的情况配置 .umirc.ts 的 publicPath 。若您最终访问的页面是单独加载生成的 js、css 资源的话，无需配置 publicPath；但若是直接使用 index.html 则请参考下面的例子，根据您实际情况进行配置。
```typescript
import fs from 'fs';
import path from 'path';

const packagejson = fs.readFileSync(path.resolve('./package.json'));
const json = JSON.parse(packagejson.toString());

export default {
  // 省略其他配置参数
  
  // 生成的 index.html 里使用的 umi.js 、umi.css 地址的公共路径的默认值是 /
  // 若 index.html 部署的地址是 http://g.alicdn.com/publicPath/aui-web-liveroom/0.0.1/index.html
  // 若不配置 publicPath 直接访问测试、线上环境 index.html，所加载的 umi.js 将会是 http://g.alicdn.com/umi.js
  // 显然不是跟 index.html 目录下了，所以请根据您实际情况配置
  // 例子中使用了项目的 name 、version 在部署目录中，请根据您实际情况配置
  publicPath:
    process.env.NODE_ENV === 'production'
      ? `/publicPath/${json.name}/${json.version}/`
      : '/',
}
```
## 由您实现
本项目着重直播间模块的开发，其余配套的模块还需要您自行完善才能真正对外服务 C 端用户。
### 登录
当前项目中的登录模块为示例代码，Appserver 服务提供了以明文发送用户名及密码的 login 接口来获取身份 token，这部分逻辑仅仅只能作为本地开发、体验使用，切勿在实际生产环境中使用，请自行请接入 SSO 单点登录、OAuth2 等方案。<br />当前项目中的进入直播列表、直播间页面时会先校验是否已登录，若未登录会先重定向到登录页，该部分逻辑位于 src -> wrappers -> auth -> index.tsx 中，请自行按您实际情况进行修改。
### 直播列表
项目直播列表页面代码位于 src -> pages -> room-list 文件夹中，当前逻辑比较简单，需要您按实际情况自行优化。
## 依赖服务及三方包
本项目通过 npm 包以及在 plugin.ts 中引入前端方式使用了多个三方包及服务，下面将介绍重点项。
### VConsole
plugin.ts 中引入 VConsole SDK ，用于在移动端测试，目前默认不会开启，当 url 中包含 vconsole=1 的参数时才会开启。
### AliPlayer
plugin.ts 中引入 AliPlayer SDK，用于在直播间中播放直播流，详细内容请至 [官网](https://help.aliyun.com/document_detail/125548.html) 了解。
### aliyun-interaction-sdk
plugin.ts 中引入了 aliyun-interaction-sdk 用于直播间互动消息的收发，Appserver 所提供的 token 接口会返回互动sdk 认证所需的 token。
### axios
开源的 http 请求 npm 包，用于调用 Appserver 接口，详细文档请至 [官网](https://github.com/axios/axios) 了解。
