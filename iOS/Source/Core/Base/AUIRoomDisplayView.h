//
//  AUIRoomDisplayView.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIRoomDisplayView : UIView

@property (nonatomic, strong, readonly) UIView *renderView;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, assign) BOOL isAnchor;
@property (nonatomic, assign) BOOL isAudioOff;
@property (nonatomic, copy) void (^onLayoutUpdated)(void);

@property (nonatomic, assign) BOOL showLoadingIndicator;
@property (nonatomic, copy) NSString *loadingText;
- (void)startLoading;
- (void)endLoading;

@end

@interface AUIRoomDisplayLayoutView : UIView

@property (nonatomic, assign) CGSize resolution;
@property (nonatomic, assign) UIEdgeInsets contentInsets;
@property (nonatomic, copy) void (^onlayoutChangedBlock)(AUIRoomDisplayLayoutView *sender);

- (NSArray<AUIRoomDisplayView *> *)displayViewList;

- (CGRect)renderRect:(AUIRoomDisplayView *)displayView;

- (void)insertDisplayView:(AUIRoomDisplayView *)displayView atIndex:(NSUInteger)index;
- (void)addDisplayView:(AUIRoomDisplayView *)displayView;
- (void)removeDisplayView:(AUIRoomDisplayView *)displayView;

- (void)layoutAll;

@end

NS_ASSUME_NONNULL_END
