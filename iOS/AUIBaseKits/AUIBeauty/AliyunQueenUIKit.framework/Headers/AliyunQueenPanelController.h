//
//  AliyunQueenPanelController.h
//  AliyunQueenUIKit
//
//  Created by aliyun on 2021/12/14.
//  Copyright © 2021 alibaba-inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AQUFeatureID) {
    AQUFeatureIDFaceBeauty = 0,
    AQUFeatureIDFaceShape,
    AQUFeatureIDFaceMakeup,
    AQUFeatureIDFitler,
    AQUFeatureIDSticker,
    AQUFeatureIDBodyShape,
    AQUFeatureIDHairRecolor,
    AQUFeatureIDFaceEffect,
    AQUFeatureIDSegmentGreen,
    AQUFeatureIDSegmentAI
};

typedef NS_ENUM(NSInteger, AQUPanelSkinStyle) {
    AQUPanelSkinStyleTransparent = 0,
    AQUPanelSkinStyleDark,
    AQUPanelSkinStyleLight
};

@class QueenEngine;

@interface AliyunQueenPanelController : NSObject

/**
 * 赋值queenEngine之后，才能使面板驱动queenEngine来配置美颜效果
 */
@property (nonatomic, weak) QueenEngine *queenEngine;

/**
 * 面板是否展示
 */
@property (nonatomic, assign, readonly) BOOL panelOnShown;

/**
 * 面板样式
 */
@property (nonatomic, assign) AQUPanelSkinStyle panelSkinStyle;

/**
 * 贴纸名字本地化字符串前缀
 */
@property (nonatomic, copy) NSString *stickerItemNameLocalizedStrPreFix;

/**
 * 滤镜名字本地化字符串前缀
 */
@property (nonatomic, copy) NSString *filterItemNameLocalizedStrPreFix;

/**
 * 初始化面板
 * @param view 需要面板添加到上面的视图。
 */
- (instancetype)initWithParentView:(UIView *)view;

/**
 * 展示面板
 * @param animated 是否需要动画
 */
- (void)showPanel:(BOOL)animated;

/**
 * 隐藏面板
 * @param animated 是否需要动画
 */
- (void)hidePanel:(BOOL)animated;

/**
 * 从面板的父视图移除面板
 */
- (void)dismiss;

/**
 * 选中原图效果
 */
- (void)selectDefaultBeautyEffect;

/**
 * 选中默认美颜效果(基础美颜组合)
 */
- (void)selectEmptyBeautyEffect;

/**
 * 选中当前美颜效果
 * 重新赋值queenEngine后，调用此接口可以让销毁前选中的效果生效
 */
- (void)selectCurrentBeautyEffect;

/**
 * 选中功能项
 * @param featureID 功能ID
 */
- (void)selectTab:(AQUFeatureID)featureID;

/**
 * 是否隐藏/展示功能项（仅可操作当前QueenSDK版本支持的功能项）
 * @param featureID 功能ID
 */
- (void)setTabHidden:(BOOL)hidden withTabID:(AQUFeatureID)featureID;

@end

NS_ASSUME_NONNULL_END
