# **AUIBeauty**

## **一、模块介绍**

### **模块职责**

**AUIBeauty**模块，为**美颜前处理**模块，主要负责对Queen SDK的封装，一站式使用美颜处理。

## **二、前置条件**

**1、申请License**

参考文档：[License管理](https://help.aliyun.com/document_detail/2391301.html)

**2、配置License**

参考项目README.md文档里面的**配置License**环节。

## **三、模块实现**

### **实现逻辑**

* 对外接口：BeautyInterface
* 核心实现：QueenBeautyImpl
* 创建实例：BeautyFactory

由于模块实现了插件化，因此beauty实例是通过反射进行实例化，即：

BeautyInterface类，负责抽象出一套统一的对外接口；

```java
private BeautyInterface mBeautyManager;
```

BeautyFactory类，通过反射创建实例；

```java
mBeautyManager = BeautyFactory.createBeauty(BeautySDKType.QUEEN, mContext);
// initialize in texture thread.
mBeautyManager.init();
mBeautyManager.setBeautyEnable(isBeautyEnable);
```

QueenBeautyImpl类，为Queen SDK美颜实现；**（核心逻辑）**

**注意：如果QueenBeautyImpl的包名被修改，请注意同步在代码中修改包名，否则在实例化失败，导致美颜调用无效！**

```java
public class BeautyConstant {
    // 由于beauty模块是插件化，因此beauty实例是通过反射进行实例化，请注意修改美颜具体实现（impl）类名，以免出现美颜初始化失败导致美颜失效的问题
    public static final String BEAUTY_QUEEN_MANAGER_CLASS_NAME = "com.alivc.auibeauty.queenbeauty.QueenBeautyImpl";
}
```

### **依赖关系**

```groovy
dependencies {
    implementation "com.aliyunsdk.components:queen_menu:2.4.1-official-menu-ultimate-tiny"
    implementation "com.aliyun.aio:AliVCSDK_PremiumLive:6.2.0"
}
```

* **queen_menu**

Queen SDK官网提供的UI库，美颜UI面板及美颜资源加载库

**注意：请注意需要在较早位置初始化加载美颜资源，否则第一次加载美颜效果可能会不生效**

```java
//提前初始化Beauty ，防止部分贴纸失效
BeautyMenuMaterial.getInstance().prepare(context);
```

* **AliVCSDK_PremiumLive**

一体化SDK，包含Queen SDK。

### **可扩展**

BeautyInterface为抽象化的美颜接口类，客户可以基于该接口类，对接其它美颜SDK，实现一套基于其它美颜SDK的实现（参考QueenBeautyImpl）。

在BeautyConstant里面定义实现类的包路径，在BeautySDKType里面定义美颜SDK类型，通过BeautyFactory指定美颜SDK类型，完成反射实例化。

## 四、用户指引

### **文档**

[AUI Kits低代码应用方案](https://help.aliyun.com/document_detail/2391314.html)

[音视频终端SDK](https://help.aliyun.com/product/261167.html)

[美颜特效SDK](https://help.aliyun.com/document_detail/2392303.html)

[美颜特效SDK通用问题](https://help.aliyun.com/document_detail/2400372.html)

### **FAQ**

如果您在使用AUI Kits有任何问题或建议，欢迎通过钉钉搜索群号35685013712加入AUI客户支持群。

您在美颜特效SDK使用过程中有任何问题或建议，请通过开发者支持群联系我们，钉钉搜索群号34197869加入。