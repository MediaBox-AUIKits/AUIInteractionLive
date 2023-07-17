//
//  AUILoginViewController.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/1.
//

#import <UIKit/UIKit.h>
#import "AUIFoundation.h"


NS_ASSUME_NONNULL_BEGIN

@interface AUILoginViewController : AVBaseViewController

@property (nonatomic, copy) void (^onLoginSuccessHandler)(AUILoginViewController *sender);

+ (BOOL)isLogin;
+ (void)logout;

@end

NS_ASSUME_NONNULL_END
