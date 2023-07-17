//
//  AUILiveListViewController.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/8/31.
//

#import <UIKit/UIKit.h>
#import "AUIFoundation.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveListViewController : AVBaseCollectionViewController

@property (nonatomic, copy) void (^onLoginTokenExpired)(void);

@end

NS_ASSUME_NONNULL_END
