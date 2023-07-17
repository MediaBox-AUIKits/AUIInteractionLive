//
//  AUIRoomDeviceAuth.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/23.
//

#import "AUIRoomDeviceAuth.h"
#import "AUIFoundation.h"
#import <AVFoundation/AVFoundation.h>

@implementation AUIRoomDeviceAuth

+ (BOOL)checkCameraAuth:(void(^)(BOOL auth))completed {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completed) {
                    completed(granted);
                }
            });
        }];
        return NO;
    }
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        [AVAlertController showWithTitle:@"提示" message:@"需要相机权限以开启直播功能" cancelTitle:@"取消" okTitle:@"前往" onCompleted:^(BOOL isCanced) {
            if (!isCanced) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
            }
        }];
        return NO;
    }
    
    return YES;
}

+ (BOOL)checkMicAuth:(void(^)(BOOL auth))completed {
    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completed) {
                    completed(granted);
                }
            });
        }];
        return NO;
    }
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        [AVAlertController showWithTitle:@"提示" message:@"需要麦克风权限以开启直播功能" cancelTitle:@"取消" okTitle:@"前往" onCompleted:^(BOOL isCanced) {
            if (!isCanced) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
            }
        }];
        return NO;
    }
    
    return YES;
}

@end
