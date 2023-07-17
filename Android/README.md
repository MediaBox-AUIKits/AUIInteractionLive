# AUIInteractionLive
阿里云 · AUI Kits 互动直播场景（竖屏样式）

## 介绍
AUI Kits 互动直播场景（竖屏样式）集成工具是阿里云提供的跨平台直播服务，为业务方提供娱乐、秀场、电商等场景的能力，借助视频直播稳定、流畅、灵活的产品能力，以低代码的方式助力业务方快速发布直播应用。


## 源码说明

### 源码下载
下载地址[请参见](https://github.com/MediaBox-AUIKits/AUIInteractionLive/tree/main/Android)


### 目录结构

```html
├── Android                        // Android平台根目录
│   ├── AUIBaseKits                // AUI基础组件依赖库
│   ├── AUICore                    // AUI业务核心依赖库
│   ├── AUIInteractionLiveApp      // AUI互动直播
│   └── AUIUikit                   // AUI业务UI组件库
```

### 环境要求
Android 5.0（SDK API Level 21）及以上版本。
建议使用Android Studio 4.0以及以上版本。
Android 5.0或以上版本的真机，暂不支持模拟器调试。

### 前提条件
您已经搭建AppServer并获取了访问域名。搭建步骤，请参见官网文档[https://help.aliyun.com/document_detail/462753.htm?spm=a2c4g.609765.0.0.5ebf4caeKGOMxe#task-2266772]
您已获取音视频终端SDK的直播推流和播放器的License授权和License Key。获取方法，请参见License文档[https://help.aliyun.com/document_detail/438207.htm?spm=a2c4g.609765.0.0.5ebf1a58AJSQmH#task-2227754]

## 跑通Demo（可选）
本节介绍如何编译运行Demo。
1.下载并解压Demo文件，目录说明如下。下载地址请参见Demo下载[https://help.aliyun.com/document_detail/462751.html?spm=a2c4g.462750.0.0]
2.配置工程文件:使用Android Studio，选择File > Open，选择上一步下载的Demo工程文件。
3.链接Android真机,连接成功,单击绿色运行按钮，构建工程文件。
4.安装到Android真机上，运行互动直播应用。

### 配置License
license获取请参考文档[https://help.aliyun.com/zh/live/user-guide/preparations-for-aui-kits?spm=a2c4g.11186623.0.0#p-dyu-f9f-qit]。
1. 在AUIInteractionLiveApp/src/main/AndroidManifest.xml里配置 license key
```html
<meta-data
  android:name="com.aliyun.alivc_license.licensekey"
  android:value="配置licenseKey"
  tools:node="replace" />
```
2.将.crt文件重命名为release.crt，并复制到AUInteractionLiveApp/src/main/assets/cert/文件夹中

### 替换 Server 地址
在AUIInteractionLiveApp工程下找到AUIInteractionLiveManager文件，建议在application进行setup调用，并check实际注册到配置RetrofitManager的APP Server地址。
```text
com.aliyun.auiappserver.RetrofitManager#setAppServerUrl
```

## 常见问题
常见问题[https://help.aliyun.com/document_detail/609775.html?spm=a2c4g.609774.0.0.13822b23zxoR7x]

## maven 仓库地址
```text
maven { url 'https://maven.aliyun.com/nexus/content/repositories/releases' }
```

## gradle 依赖
```text
api 'com.aliyun.sdk.android:aliinteraction-cxx:1.0.2'
api 'com.aliyun.sdk.android:aliinteraction-android:1.1.1'
api 'com.aliyun.aio:AliVCSDK_Premium:6.2.0'
```

## 混淆配置
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

## 权限申请
```text

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
