//
//  AUIBeautyResourceProtocol.h
//  AUIBeauty
//
//  Created by Bingo on 2023/11/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AUIBeautyResourceProtocol <NSObject>

- (BOOL)startCheck;
- (void)checkResource:(void (^)(BOOL completed))completed;

@end

NS_ASSUME_NONNULL_END
