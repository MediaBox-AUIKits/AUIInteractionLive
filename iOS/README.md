# AUIInteractionLive
阿里云 · AUI Kits 互动直播场景（竖屏样式）

## 介绍
AUI Kits 互动直播场景（竖屏样式）集成工具是阿里云提供的跨平台直播服务，为业务方提供娱乐、秀场、电商等场景的能力，借助视频直播稳定、流畅、灵活的产品能力，以低代码的方式助力业务方快速发布直播应用。


## 源码说明

### 源码下载
下载地址[请参见](https://github.com/MediaBox-AUIKits/AUIInteractionLive/tree/main/iOS)

### 源码结构
```
├── iOS  // iOS平台的根目录
│   ├── AUIInteractionLive.podspec                // pod描述文件
│   ├── Source                                    // 源代码文件
│   ├── Resources                                 // 资源文件
│   ├── Example                                   // Demo代码
│   ├── AUIBaseKits                               // 基础UI组件   
│   ├── README.md                                 // Readme  

```

### 环境要求
- Xcode 12.0 及以上版本，推荐使用最新正式版本
- CocoaPods 1.9.3 及以上版本
- 准备 iOS 10.0 及以上版本的真机

### 前提条件
获取音视频终端SDK License和key，需要包含推流、播放、美颜的授权。
参考[获取License](https://help.aliyun.com/document_detail/438207.html)


## 跑通demo

- 源码下载后，进入Example目录
- 在Example目录里执行命令“pod install  --repo-update”，自动安装依赖SDK
- 打开工程文件“AUILiveDemo.xcworkspace”，修改包Id
- 在控制台上申请试用License，开通直播推流、播放、美颜等能力，获取License文件和LicenseKey，如果已开通License直接进入下一步
- 把License文件放到Example/AUILiveDemo/目录下，并修改文件名为“license.crt”
- 把“LicenseKey”（如果没有，请在控制台拷贝），打开“AUILiveDemo/Info.plist”，填写到字段“AlivcLicenseKey”的值中
- 编译运行


## 快速搭建自己的互动直播
可通过以下几个步骤快速集成AUIInteractionLive到你的APP中，让你的APP具备互动直播功能

### 集成源码
- 导入AUIInteractionLive：仓库代码下载后，拷贝iOS文件夹到你的APP代码目录下，改名为AUIInteractionLive，与你的Podfile文件在同一层级，可以删除Example目录
- 修改你的Podfile，引入：
  - AliVCSDK_PremiumLive：适用于互动直播的音视频终端SDK，也可以使用AliVCSDK_Premium，参考[快速集成](https://help.aliyun.com/document_detail/2412571.htm)
  - AUIFoundation：基础UI组件
  - AUIMessage：互动消息组件
  - AUIBeauty：美颜UI组件  
  - AUIInteractionLive：互动直播直播竖屏样式UI组件源码，根据自身的业务，有需要可以对组件代码进行修改
```ruby

#需要iOS10.0及以上才能支持
platform :ios, '10.0'

target '你的App target' do
    # 根据自己的业务场景，集成合适的音视频终端SDK
    # 如果你的APP中还需要频短视频编辑功能，可以使用音视频终端全功能SDK（AliVCSDK_Premium），可以把本文件中的所有AliVCSDK_PremiumLive替换为AliVCSDK_Premium
    pod 'AliVCSDK_PremiumLive', '~> 6.2.0'

    # 基础UI组件
    pod 'AUIFoundation/All', :path => "../AUIInteractionLive/AUIBaseKits/AUIFoundation/"

    # 互动消息组件
    pod 'AUIMessage/Alivc', :path => "../AUIInteractionLive/AUIBaseKits/AUIMessage/"
    
    # 美颜UI组件，如果终端SDK使用的是AliVCSDK_Premium，需要AliVCSDK_PremiumLive替换为AliVCSDK_Premium
    pod 'AUIBeauty/AliVCSDK_PremiumLive', :path => "../AUIInteractionLive/AUIBaseKits/AUIBeauty/"
    
    # 互动直播竖屏样式UI组件，如果终端SDK使用的是AliVCSDK_Premium，需要AliVCSDK_PremiumLive替换为AliVCSDK_Premium
    pod 'AUIInteractionLive/AliVCSDK_PremiumLive',  :path => "./AUIInteractionLive/"

end
```
- 执行“pod install --repo-update”
- 源码集成完成

### 工程配置
- 编译设置
  - 配置Build Setting > Linking > Other Linker Flags ，添加-ObjC。
  - 配置Build Setting > Build Options > Enable Bitcode，设为NO。
- 打开工程info.Plist，添加NSCameraUsageDescription和NSMicrophoneUsageDescription权限
- 如果你需要在APP后台时继续直播，那么需要在XCode中开启“Background Modes”
- 配置License，参考[License配置](https://help.aliyun.com/document_detail/2412571.html)


### API调用
- AppServer部署后，修改AppServer域名地址，找到AUIInteractionLiveManager.m文件，修改kLiveServiceDomainString的值，如下：
```ObjC
// AUIInteractionLiveManager.m

// 在部署AppServer部署后，修改AppServer域名地址
static NSString * const kLiveServiceDomainString =  @"你的AppServer域名";
```

- 初始化SDK配置
  - 注意需要引入头文件，必须确保在使用功能前进行注册
  - AUI组件页面的跳转需要依赖导航控制器，在App启动后进行SDK的初始化，建议你设置导航控制器（建议使用AVNavigationController）。以下是无Storyboard场景的启动初始化示例
```ObjC
#import "AUIInteractionLiveManager.h"


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    // 在这里进行初始化，注意需要引入头文件
    [[AUIInteractionLiveManager defaultManager] setup];

    // APP首页
    AUIHomeViewController *liveVC = [AUIHomeViewController new];

    // 需要使用导航控制器，否则页面间无法跳转，建议AVNavigationController
    // 如果使用系统UINavigationController作为APP导航控制器，需要你进行以下处理：
    // 1、隐藏导航控制器的导航栏：self.navigationBar.hidden = YES
    // 2、直播间（AUILiveRoomAnchorViewController和AUILiveRoomAudienceViewController）禁止使用向右滑动时关闭直播间操作。
    AVNavigationController *nav =[[AVNavigationController alloc]initWithRootViewController:liveVC];
    [self.window setRootViewController:nav];
    [self.window makeKeyAndVisible];

    // 你的其他初始化...


    
    return YES;
}
```

- 对接登录用户，必须在用户登录后才开启/观看直播，在用户登录账号后，进行互动直播当前用户的初始化，如下：
``` ObjC
// 在登录后进行，进行赋值
// 如果本次启动用户不需要重新登录（用户token未过期），可以在加载登录用户后进行赋值

AUIRoomUser *me = [AUIRoomUser new];
me.userId = @"当前登录用户id";
me.avatar = @"当前登录用户头像";
me.nickName = @"当前登录用户昵称";
me.token = @"当前登录用户token";   // 用于服务端用户有效性验证
[[AUIInteractionLiveManager defaultManager] setCurrentUser:me];

```

### 进入直播间
前面工作完成后，接下来可以根据自身的业务场景和交互，可以在你APP上通过AUIInteractionLiveManager接口快速主播开播，进入直播等功能，也可以根据自身的需求修改源码。
``` ObjC

// 主播开播（基础模式）
[[AUIInteractionLiveManager defaultManager] createLive:AUIRoomLiveModeBase title:@"直播间标题" notice:@"这是一个公告" currentVC:self completed:nil];

// 主播开播（连麦模式）
[[AUIInteractionLiveManager defaultManager] createLive:AUIRoomLiveModeLinkMic title:@"直播间标题" notice:@"这是一个公告" currentVC:self completed:nil];


// 进入直播
[[AUIInteractionLiveManager defaultManager] joinLiveWithLiveId:@"直播id" currentVC:self completed:nil];
```

### 运行结果
参考Demo

## 常见问题
更多AUIKits问题咨询及使用说明，请搜索钉钉群（35685013712）加入AUI客户支持群联系我们。
