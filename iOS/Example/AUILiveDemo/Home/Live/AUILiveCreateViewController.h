//
//  AUILiveCreateViewController.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/7.
//

#import <UIKit/UIKit.h>
#import "AUIFoundation.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveCreateViewController : AVBaseViewController

@property (nonatomic, copy) void (^onCreateLiveBlock)(NSString *title, NSString * _Nullable notice, BOOL interactionMode);

@end

NS_ASSUME_NONNULL_END
