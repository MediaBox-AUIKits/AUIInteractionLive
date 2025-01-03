# AUIInteractionLive
阿里云 · AUI Kits 互动直播场景（竖屏样式）

## 介绍
AUI Kits 互动直播场景（[竖屏样式](https://help.aliyun.com/zh/apsara-video-sdk/use-cases/portrait-mode-for-android)）集成工具是阿里云提供的跨平台直播服务，为业务方提供娱乐、秀场、电商等场景的能力，借助视频直播稳定、流畅、灵活的产品能力，以低代码的方式助力业务方快速发布直播应用。


## 源码说明

### 源码下载
下载地址请参见GitHub开源项目[MediaBox-AUIKits](https://github.com/MediaBox-AUIKits/AUIInteractionLive)


### 目录结构

```html
├── Android                        // Android平台根目录
│   ├── AUIBaseKits                // AUI基础组件依赖库
│   ├── AUICore                    // AUI业务核心依赖库
│   ├── AUIInteractionLiveApp      // AUI互动直播
│   └── AUIUikit                   // AUI业务UI组件库
```

### 环境要求
* Gradle 7.5-bin，插件版本7.1.2

* **JDK 11**

> JDK 11设置方法：Preferences -> Build, Execution, Deployment -> Build Tools -> Gradle -> Gradle JDK -> 选择 11（如果没有11，请升级你的Android Studio版本）

* 适用于 Android 5.0（Lollipop，SDK API Level 21）及以上版本的设备。

* 推荐使用 Android Studio 4.0 或更高版本的开发环境。
* 建议使用运行 Android 5.0 或更高版本的真机进行调试，暂不支持模拟器调试。

### 前提条件
* 您已经搭建AppServer并获取了访问域名。搭建步骤，请参见官网文档[服务端配置与运行](https://help.aliyun.com/zh/apsara-video-sdk/use-cases/how-to-integrate-the-server-side-into-live-streaming)
* 您已获取[音视频终端SDK](https://help.aliyun.com/zh/apsara-video-sdk/)的直播推流和播放器的License授权和License Key；获取方法，请参见官网文档[获取License](https://help.aliyun.com/zh/apsara-video-sdk/user-guide/license-authorization-and-management)

## 跑通Demo（可选）

本节介绍如何编译运行Demo。

1.下载并解压Demo文件，目录说明如下。

2.配置工程文件:使用Android Studio，选择File > Open，选择上一步下载的Demo工程文件。

3.链接Android真机,连接成功,单击绿色运行按钮，构建工程文件。

4.安装到Android真机上，运行互动直播应用。

**注意**：Demo源码里面的相关配置，如License以及APP Server地址，需要手动填写才可完整体验功能。

## 快速集成

### 导入源码

从阿里云产品官网或GitHub上获取互动直播的代码仓库，并将对应的基础组件模块，导入到自己的项目工程中。

### 配置License
MediaBox AUI Kits和MediaBox SDKs拥有统一的License获取方式。您可以在控制台申请如直播推流、短视频、播放器、美颜特效等模块的License使用权限，也可以对各个模块的License进行管理。

配置License的前提是您已获取音视频终端SDK的直播推流和播放器的License授权和License Key。获取方法，请参考文档[获取License](https://help.aliyun.com/zh/apsara-video-sdk/user-guide/license-authorization-and-management)。

1. 在AUIInteractionLiveApp/src/main/AndroidManifest.xml里配置 license key

   ```xml
   <meta-data
     android:name="com.aliyun.alivc_license.licensekey"
     android:value="配置licenseKey"
     tools:node="replace" />
   ```

1. 将.crt文件重命名为release.crt，并复制到AUInteractionLiveApp/src/main/assets/cert/文件夹中
### 初始化调用

初始化调用包含几部分，注册项目类型，和替换APP Server地址。每个工程中App模块下都有一个Manager类，参考setup()方法，即可完成这部分的初始化调用。

在AUIInteractionLiveApp工程下找到AUIInteractionLiveManager文件，参考setup方法，建议在application进行调用，包含以下步骤：

#### 注册项目类型

```java
private static final String TAG_PROJECT_INTERACTION_LIVE = "aui-live-interaction";

AlivcBase.setIntegrationWay(TAG_PROJECT_INTERACTION_LIVE);
```

#### 替换APP Server地址

检查实际注册到配置RetrofitManager的APP Server地址

```java
RetrofitManager.setAppServerUrl("$YOU NEED TO CHECK THE APP SERVER URL HERE$");
```

### 其它工程配置

#### maven仓库地址

```groovy
maven { url 'https://maven.aliyun.com/nexus/content/repositories/releases' }
```

#### gradle依赖

```groovy
// 互动信令SDK
implementation "com.aliyun.sdk.android:AliVCInteractionMessage:${latest_version}"
// 一体化SDK（请参考 AndroidThirdParty 目录下的 config.gradle 文件，获取 externalAllInOne 最新版本）
// 建议使用最新版本，详情参考官网：https://help.aliyun.com/zh/apsara-video-sdk/download-sdks
implementation "com.aliyun.aio:AliVCSDK_InteractiveLive:${latest_version}"
```

> 如果您的 APP 中需要短视频编辑功能，请使用音视频终端全功能SDK（AliVCSDK_Standard）
>
> 如果您的 APP 中不需要短视频编辑功能，请使用音视频终端互动直播SDK（AliVCSDK_InteractiveLive）

#### 混淆配置

```text
-keep class com.alivc.** { *; }
-keep class com.aliyun.** { *; }
-keep class com.aliyun.rts.network.* { *; }
-keep class org.webrtc.** { *; }
-keep class com.alibaba.dingpaas.** { *; }
-keep class com.dingtalk.mars.** { *; }
-keep class com.dingtalk.bifrost.** { *; }
-keep class com.dingtalk.mobile.** { *; }
-keep class org.android.spdy.** { *; }
-keep class com.alibaba.dingpaas.interaction.** { *; }
-keep class com.cicada.**{*;}
```

#### 权限申请

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

## 常见问题

[Android端集成AUI Kits常见问题](https://help.aliyun.com/zh/apsara-video-sdk/support/faq-for-low-code-integration-tools-for-android)

## 技术支持

如果您在使用 AUI Kits 有任何问题或建议，欢迎通过提交工单获取技术支持。

[音视频终端SDK](https://help.aliyun.com/zh/apsara-video-sdk/)

[AUI Kits低代码应用方案](https://help.aliyun.com/zh/apsara-video-sdk/use-cases/aui-kits-application-solution/)

[MediaBox-AUIKits](https://github.com/orgs/MediaBox-AUIKits/repositories)
