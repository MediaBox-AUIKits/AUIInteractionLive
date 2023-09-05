本文介绍微信小程序集成AUI Kits互动直播场景SDK的操作方式、注意事项及相关代码示例等内容。
# 前提条件
## AppServer

- 您已经搭建AppServer并获取了访问域名。搭建步骤，请参见[快速搭建AppServer](https://help.aliyun.com/document_detail/462753.htm?spm=a2c4g.11186623.0.0.16226274w8j0zy#task-2266772)。
> 部署后，请将域名填入 config.js 文件中的 appServer 字段值内

## 主播端
目前微信小程序仅包含观众端模块，暂未支持推流、连麦，如需体验完整的功能，需要您接入移动端的AUI Kits。接入方式请参见Android端接入、iOS端接入。
## 微信小程序权限
由于AUI Kits互动直播场景SDK所使用的小程序标签有更苛刻的权限要求，因此集成的前提是需要开通小程序的类目和标签使用权限，否则无法使用。
包括如下步骤：

1. 注册企业类小程序：小程序推拉流标签仅支持企业类小程序申请，需要在[注册](https://developers.weixin.qq.com/community/business/doc/000200772f81508894e94ec965180d)时填写主体类型为企业，如下图所示： 

![](https://intranetproxy.alipay.com/skylark/lark/0/2023/jpeg/40992/1677656688335-52cd0c38-2ac6-410b-b8e0-325e03dc772a.jpeg)

2. 申请标签权限：小程序推拉流标签使用权限暂时只开放给有限[类目](https://developers.weixin.qq.com/miniprogram/dev/component/live-pusher.html)。符合类目要求的小程序，需要在[微信公众平台](https://mp.weixin.qq.com/) > 开发 > 开发管理 > 接口设置中自助开通该组件权限，如下图所示：

![](https://intranetproxy.alipay.com/skylark/lark/0/2023/jpeg/40992/1677656874389-82a060d5-ffbc-4ca9-bde8-0546977b58d2.jpeg)
# 开发框架
本项目为能实现一套代码支持多个小程序平台，选用了 uni-app 框架进行开发，技术栈为 Vue，如需了解更多框架信息，请参见 [uni-app 官网文档](https://uniapp.dcloud.net.cn/)。目前已支持微信小程序平台，后续支持更多的平台。
# 快速集成
## 环境准备
### 开发环境准备
推荐下载使用可视化编辑器 [HBuilderX](https://www.dcloud.io/hbuilderx.html) 进行开发，并且下载安装 [微信开发者工具](https://developers.weixin.qq.com/miniprogram/dev/devtools/download.html)，参见 [快速上手文档 ](https://uniapp.dcloud.net.cn/quickstart-hx.html)配置相关程序路径。
### 微信版本要求

- 微信 App iOS 最低版本要求：7.0.9
- 微信 App Android 最低版本要求：7.0.8
- 小程序基础库最低版本要求：2.10.0
- 由于小程序测试号不具备 [<live-pusher>](https://developers.weixin.qq.com/miniprogram/dev/component/live-pusher.html) 和[ <live-player> ](https://developers.weixin.qq.com/miniprogram/dev/component/live-player.html)的使用权限，请使用企业小程序账号申请相关权限进行开发。
- 由于微信开发者工具不支持原生组件（即[ <live-pusher>](https://developers.weixin.qq.com/miniprogram/dev/component/live-pusher.html) 和[ <live-player> ](https://developers.weixin.qq.com/miniprogram/dev/component/live-player.html)标签），需要在真机上进行运行体验。

## 本地开发运行
开发环境搭建完成后，在 HBuilderX 中打开下载的源码工程，配置以下数据：

- 在 utils/services.js 中的 ServicesOrigin 参数填入前提条件中所部署的 Appserver 的域名
- 在 manifest.json 中配置您的小程序 appid，项目初期没有时可不填，或者也可以在小程序开发者工具设置

![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2023/png/5470/1677486208933-7d0cca52-dfda-4a51-a420-c4b1f84d944e.png#clientId=uecbe8470-b6f4-4&from=paste&height=557&id=u7a261805&name=image.png&originHeight=1114&originWidth=1702&originalType=binary&ratio=2&rotation=0&showTitle=false&size=1500469&status=done&style=none&taskId=u7a786129-57b7-4cad-817a-3f97f09162f&title=&width=851)
![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2023/png/5470/1677486280233-11086180-6ba9-4810-8758-69d426c891e5.png#clientId=uecbe8470-b6f4-4&from=paste&height=431&id=u51070f83&name=image.png&originHeight=861&originWidth=1256&originalType=binary&ratio=2&rotation=0&showTitle=false&size=687875&status=done&style=none&taskId=u050fe0e9-563c-43df-9ce3-c466ff0b8c6&title=&width=628)
配置完成后点击菜单栏中的 运行 -> 运行到小程序模拟器 -> 微信开发中工具 就会对代码进行打包，并自动打开微信开发者工具运行该项目。
![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2023/png/5470/1677486426826-ba041977-6e71-4094-a711-b47532cc0cfa.png#clientId=uecbe8470-b6f4-4&from=paste&height=441&id=uc19d187a&name=image.png&originHeight=882&originWidth=1158&originalType=binary&ratio=2&rotation=0&showTitle=false&size=1396921&status=done&style=none&taskId=u9838b0bb-be5f-4911-bf2f-b20225fc384&title=&width=579)
## 发布
### 域名配置
必需事先在小程序后台设置服务器域名，小程序才能正常调通相关接口，页面路径为 开发管理 > 开发设置 > 服务器域名 。
request合法域名中需要填入上面的 Appserver 域名，注意小程序要求必须是 https 协议。若配置后接口仍然失败，可以参数这份 [文档](https://developers.weixin.qq.com/community/develop/doc/000a245d954fe852fdad4d0a456409?_at=1676429364596) ，同时在微信上将小程序先删除重新加载打开。
socket 合法域名需要配置阿里云互动消息所使用的 wss 域名才能正常使用互动消息服务，域名为： wss://metapath.aliyuncs.com
![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2023/png/5470/1677487274241-8a79bd61-a484-4e7a-b89e-39c1ce3d5389.png#clientId=uecbe8470-b6f4-4&from=paste&height=704&id=u0344a0bf&name=image.png&originHeight=1408&originWidth=2908&originalType=binary&ratio=2&rotation=0&showTitle=false&size=1945957&status=done&style=none&taskId=u71b0f7db-efb1-4d48-87f0-ea8114a07be&title=&width=1454)
### 代码发布
您可以选择在 HBuilderX 中发布，也可以选择在微信开发工具中上传，详情请参考 [uni-app 发布至微信小程序文档](https://uniapp.dcloud.net.cn/quickstart-hx.html#%E5%8F%91%E5%B8%83%E4%B8%BA%E5%BE%AE%E4%BF%A1%E5%B0%8F%E7%A8%8B%E5%BA%8F) 以及 [微信小程序官方文档](https://developers.weixin.qq.com/miniprogram/dev/framework/quickstart/release.html#%E5%8F%91%E5%B8%83%E4%B8%8A%E7%BA%BF) 。
# 由您实现
本项目着重直播间模块的开发，其余配套的模块还需要集成方自行完善才能真正对外服务终端用户。
## 登录
当前项目中的登录模块为示例代码，直播间AppServer服务提供了以明文发送用户名及密码的login接口来获取身份Token，这部分逻辑仅仅只能作为本地开发、体验使用，切勿在实际生产环境中使用，登录功能实现请参考 [微信小程序登录文档](https://developers.weixin.qq.com/miniprogram/dev/framework/open-ability/login.html) 自行实现。
## 直播列表
项目直播列表页面代码位于  pages > roomList文件夹中，当前逻辑比较简单，需要您按实际情况自行优化。
