//
//  AUILiveRoomFinishView.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/8.
//

#import <UIKit/UIKit.h>
#import "AUIRoomLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomFinishView : UIView

@property (strong, nonatomic) AUIRoomLiveVodInfoModel *vodModel;
@property (assign, nonatomic) BOOL isFullScreen;
@property (assign, nonatomic) BOOL isAnchor;
@property (copy, nonatomic) void (^onLikeButtonClickedBlock)(AUILiveRoomFinishView *sender);
@property (copy, nonatomic) void (^onShareButtonClickedBlock)(AUILiveRoomFinishView *sender);

@property (copy, nonatomic) void (^onPlayImmerseBlock)(AUILiveRoomFinishView *sender, BOOL immerse);
@property (copy, nonatomic) void (^onPlayFullScreenBlock)(AUILiveRoomFinishView *sender, BOOL fullScreen);


- (instancetype)initWithFrame:(CGRect)frame landscapeMode:(BOOL)landscapeMode;

@end

NS_ASSUME_NONNULL_END
