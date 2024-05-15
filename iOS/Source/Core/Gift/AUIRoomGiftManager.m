//
//  AUIRoomGiftManager.m
//  AUIInteractionLiveDemo
//
//  Created by Bingo on 2024/2/28.
//

#import "AUIRoomGiftManager.h"
#import "AUIRoomTheme.h"
#import <AFNetworking/AFNetworking.h>

@interface AUIRoomGiftDownloadItem : NSObject

@property (nonatomic, strong) AUIRoomGiftModel *gift;
@property (nonatomic, assign) CGFloat progress;

@end

@implementation AUIRoomGiftDownloadItem

@end

@interface AUIRoomGiftManager ()

@property (nonatomic, copy) NSArray<AUIRoomGiftModel *> *giftList;
@property (nonatomic, strong) AFURLSessionManager *sessionManager;
@property (nonatomic, copy) NSMutableArray<AUIRoomGiftDownloadItem *> *downloadingList;

@end

@implementation AUIRoomGiftManager

+ (instancetype)sharedInstance {
    static AUIRoomGiftManager *_instance = nil;
    if (!_instance) {
        _instance = [AUIRoomGiftManager new];
        [_instance loadList];
    }
    return _instance;
}

- (void)loadList {
    NSMutableArray *modelList = [NSMutableArray array];
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@.bundle", AUIRoomTheme.resourceName] ofType:nil];
    NSString *jsonString = [bundlePath stringByAppendingPathComponent:@"gift.json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonString];
    NSError *parseError = nil;
    NSDictionary *configDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&parseError];
    if (!parseError) {
        [[configDic av_dictArrayValueForKey:@"gifts"] enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            AUIRoomGiftModel *model = [[AUIRoomGiftModel alloc] initWithData:obj];
            [self updateGiftFilePath:model];
            [modelList addObject:model];
        }];
    }
    self.giftList = modelList;
}

- (AUIRoomGiftModel *)getGift:(NSString *)giftId {
    __block AUIRoomGiftModel *model = nil;
    [self.giftList enumerateObjectsUsingBlock:^(AUIRoomGiftModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([giftId isEqualToString:obj.giftId]) {
            model = obj;
            *stop = YES;
        }
    }];
    return model;
}

- (NSMutableArray<AUIRoomGiftDownloadItem *> *)downloadingList {
    if (!_downloadingList) {
        _downloadingList = [NSMutableArray array];
    }
    return _downloadingList;
}

- (void)downloadAllGiftResourceIfNeed {
    __weak typeof(self) weakSelf = self;
    [self.giftList enumerateObjectsUsingBlock:^(AUIRoomGiftModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf downloadGift:obj];
    }];
}

- (void)downloadGift:(AUIRoomGiftModel *)model {
    if (model.filePath.length == 0) {
        if ([self isDownloading:model]) {
            return;
        }
        AUIRoomGiftDownloadItem *item = [AUIRoomGiftDownloadItem new];
        item.progress = 0;
        item.gift = model;
        if (self.downloadingList.count == 0) {
            [self.downloadingList addObject:item];
            [self startDownload:item];
        }
        else {
            [self.downloadingList addObject:item];
        }
    }
}

- (BOOL)isDownloading:(AUIRoomGiftModel *)model {
    __block BOOL find = NO;
    [self.downloadingList enumerateObjectsUsingBlock:^(AUIRoomGiftDownloadItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.gift == model) {
            find = YES;
            *stop = YES;
        }
    }];
    return find;
}

#pragma mark - download imp

- (NSString *)rootPath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"com.live.aui"];
}

// Documents/com.live.aui/gifts
- (NSString *)resourceDownloadPath {
    return [[self rootPath] stringByAppendingPathComponent:@"gifts"];
}

- (void)updateGiftFilePath:(AUIRoomGiftModel *)model {
    NSString *fileName = [NSString stringWithFormat:@"%@.mp4", model.giftId];
    NSString *path = [[self resourceDownloadPath] stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        model.filePath = path;
    }
}

- (AFURLSessionManager *)sessionManager {
    if (!_sessionManager) {
        _sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
    }
    return _sessionManager;
}

- (void)startDownload:(AUIRoomGiftDownloadItem *)item {
    __weak typeof(self) weakSelf = self;
    [self download:item completed:^(BOOL result) {
        [weakSelf.downloadingList removeObject:item];
        AUIRoomGiftDownloadItem *next = weakSelf.downloadingList.firstObject;
        if (next) {
            [weakSelf startDownload:next];
        }
    }];
}

- (void)download:(AUIRoomGiftDownloadItem *)item completed:(nullable void(^)(BOOL result))completed {
    if (item.gift.filePath.length > 0) {
        if (completed) {
            completed(YES);
        }
        return;
    }
    
    NSString *urlString = item.gift.sourceUrl;
    if (urlString.length == 0) {
        if (completed) {
            completed(NO);
        }
        return;
    }

    NSFileManager *myFileManager = [NSFileManager defaultManager];
    NSString *dir = [self resourceDownloadPath];
    if (![myFileManager fileExistsAtPath:dir]) {
        [myFileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *fileName = [NSString stringWithFormat:@"%@.mp4", item.gift.giftId];
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        if (completed) {
            completed(NO);
        }
        return;
    }

    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *task = [self.sessionManager downloadTaskWithRequest:req progress:^(NSProgress * _Nonnull downloadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            item.progress = downloadProgress.completedUnitCount * 1.0 / downloadProgress.totalUnitCount;
        });
        
    } destination:^NSURL * (NSURL *targetPath, NSURLResponse *response) {
        NSString *path = [[self resourceDownloadPath] stringByAppendingPathComponent:fileName];
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *path = filePath.path;
            if ([path hasPrefix:@"file://"]) {
                path = [path substringFromIndex:@"file://".length];
            }
            item.gift.filePath = path;
            if (completed) {
                completed(YES);
            }
        });
    }];
    [task resume];
}



@end
