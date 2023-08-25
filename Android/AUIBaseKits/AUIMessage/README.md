# **AUIMessage**

## **一、模块介绍**

### **模块职责**

**AUIMessage**模块，为消息信令模块，主要负责对各个IM SDK的消息、信令的封装，一站式使用消息信令。

## **二、前置条件**

**1、配置APP Server**

参考项目的README.md，或者AUIKits官网文档，完成服务端集成。

**2、按需申请使用IM SDK的相关配置**

* 如果使用融云的IM SDK（RongCloud），需要在[融云后台](https://www.rongcloud.cn/product/im)申请APP Key，并填写到项目中；

```java
interface RongCloudConsts {
    String APP_KEY = "xxx";
}
```

## **三、模块实现**

### **实现逻辑**

* 对外接口：MessageService
* 核心实现：分两个模块，每个模块里面都有一个实现类MessageServiceImpl，阿里云内部的IM SDK走AUIMessageImpl-Internal模块，融云的IM SDK走AUIMessageImpl-RongCloud模块。
* 创建实例：MessageServiceFactory

由于模块实现了插件化，因此message service实例是通过反射进行实例化，即：

MessageService类，负责抽象出一套统一的对外接口；

```java
messageService = (MessageService) implType.newInstance();
```

MessageServiceFactory类，通过反射创建实例；

```java
public static boolean useInternal() {
  String messageServiceClassName = getMessageService().getClass().getName();
  return TextUtils.equals(messageServiceClassName, ServiceImpl.INTERNAL.className);
}

public static boolean useRongCloud() {
  String messageServiceClassName = getMessageService().getClass().getName();
  return TextUtils.equals(messageServiceClassName, ServiceImpl.RONG_CLOUD.className);
}

private enum ServiceImpl {
  // 内部SDK
  INTERNAL("com.alivc.auimessage.internal.MessageServiceImpl"),

  // 融云SDK
  RONG_CLOUD("com.alivc.auimessage.rongcloud.MessageServiceImpl"),
  ;

  final String className;

  ServiceImpl(String className) {
    this.className = className;
  }
}
```

INTERNAL对应所在的类，为阿里云内部的IM SDK实现；RONG_CLOUD对应所在的类，为融云的IM SDK实现；

**核心逻辑在不同的MessageServiceImpl中**

**注意：**

* 如果MessageServiceImpl的包名被修改，请注意同步在代码中修改包名，否则在实例化失败，导致消息信令调用无效！
* 当前项目提供了基于不同IM SDK的模块实现，可以选其一使用，其它IM SDK的模块实现可以从项目中剔除；
* 当前项目中，通过BUILD_IM_TYPE编译配置，实现工程IM SDK类型的可配置，动态使用不同的IM SDK实现；

```groovy
// IMType, internal->内部IM，rongcloud->融云IM
ext.BUILD_IM_TYPE = getEnvValue("BUILD_IM_TYPE", 'internal')
```

### **依赖关系**

```groovy
dependencies {
    api project(':AUIBaseKits:AUIMessage')
  
    implementation '${each own im sdk dependencies}'
}
```

其它模块可直接依赖对应的IM SDK实现模块，无需直接引用到AUIMessage模块：

```groovy
// 切换消息SDK引擎
if (BUILD_IM_TYPE == "rongcloud") {
  implementation project(':AUIBaseKits:AUIMessage:AUIMessageImpl-RongCloud')
} else {
  implementation project(':AUIBaseKits:AUIMessage:AUIMessageImpl-Internal')
}
```

### **可扩展**

MessageService为抽象化的消息服务接口类，客户可以基于该接口类，对接其它IM SDK，实现一套基于其它IM SDK的实现（参考MessageServiceImpl）。

在enum ServiceImpl里面定义IM SDK类型，以及实现类的包路径，通过MessageServiceFactory指定IM SDK类型，完成反射实例化。

### **注意事项**

在AUILiveMessage模块，某些功能在不同IM SDK方案下，走的逻辑不同。

如：禁言群组，使用融云IM SDK时，走的是APP Server方案；而阿里云内部的IM SDK，可以直接通过IM SDK接口调用进行；请注意通过以下if-else来区分：

```java
if (MessageServiceFactory.useRongCloud()) {
  // 融云方案走App Server
} else if (MessageServiceFactory.useInternal()) {
  // 内部消息组件走IM方案
} else {
  interactionCallback.onError(new InteractionError(""));
}
```

## 四、用户指引

### **文档**

[AUI Kits低代码应用方案](https://help.aliyun.com/document_detail/2391314.html)

[音视频终端SDK](https://help.aliyun.com/product/261167.html)

[融云IM](https://www.rongcloud.cn/product/im)

### **FAQ**

如果您在使用AUI Kits有任何问题或建议，欢迎通过钉钉搜索群号35685013712加入AUI客户支持群。
