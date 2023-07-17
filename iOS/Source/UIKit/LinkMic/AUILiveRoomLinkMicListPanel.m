//
//  AUILiveRoomLinkMicListPanel.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/28.
//

#import "AUILiveRoomLinkMicListPanel.h"
#import "AUIRoomMacro.h"
#import "AUIRoomUser.h"
#import "AUILiveRoomAvatarView.h"
#import "AUIRoomAccount.h"

@interface AUILiveRoomLinkMicCellItem : NSObject

@property (nonatomic, copy, readonly) AUIRoomUser *joinUser;
@property (nonatomic, assign, readonly) BOOL videoOff;
@property (nonatomic, assign, readonly) BOOL audioOff;

@property (nonatomic, assign) AUILiveRoomLinkMicItemType itemType;

@property (nonatomic, strong) id data;

@end

@implementation AUILiveRoomLinkMicCellItem

- (void)setData:(id)data {
    _data = data;
    if (self.itemType == AUILiveRoomLinkMicItemTypeApply) {
        _joinUser = (AUIRoomUser *)self.data;
    }
    else {
        _joinUser = [AUIRoomUser new];
        _joinUser.userId = [(AUIRoomLiveRtcPlayer *)self.data joinInfo].userId;
        _joinUser.nickName = [(AUIRoomLiveRtcPlayer *)self.data joinInfo].userNick;
        _joinUser.avatar = [(AUIRoomLiveRtcPlayer *)self.data joinInfo].userAvatar;
    }
}

- (BOOL)videoOff {
    if (self.itemType == AUILiveRoomLinkMicItemTypeJoined) {
        AUIRoomLiveLinkMicJoinInfoModel *joinInfo = [(AUIRoomLiveRtcPlayer *)self.data joinInfo];
        return !joinInfo.cameraOpened;
    }
    return NO;
}

- (BOOL)audioOff {
    if (self.itemType == AUILiveRoomLinkMicItemTypeJoined) {
        AUIRoomLiveLinkMicJoinInfoModel *joinInfo = [(AUIRoomLiveRtcPlayer *)self.data joinInfo];
        return !joinInfo.micOpened;
    }
    return NO;
}

@end

@interface AUILiveRoomLinkMicCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIView *lineView;
@property (nonatomic, strong, readonly) UILabel *nameLabel;
@property (nonatomic, strong, readonly) AUILiveRoomAvatarView *avatarView;

@property (nonatomic, strong, readonly) AVBlockButton *agreeBtn;
@property (nonatomic, strong, readonly) AVBlockButton *rejectBtn;
@property (nonatomic, copy) void (^onAgreeBtnClick)(AVBlockButton *, AUILiveRoomLinkMicCellItem *);
@property (nonatomic, copy) void (^onRejectBtnClick)(AVBlockButton *, AUILiveRoomLinkMicCellItem *);

@property (nonatomic, strong, readonly) AVBlockButton *leaveBtn;
@property (nonatomic, strong, readonly) AVBlockButton *micBtn;
@property (nonatomic, strong, readonly) AVBlockButton *cameraBtn;
@property (nonatomic, copy) void (^onMicBtnClick)(AVBlockButton *, AUILiveRoomLinkMicCellItem *);
@property (nonatomic, copy) void (^onCameraBtnClick)(AVBlockButton *, AUILiveRoomLinkMicCellItem *);
@property (nonatomic, copy) void (^onLeaveBtnClick)(AVBlockButton *, AUILiveRoomLinkMicCellItem *);



@property (nonatomic, strong) AUILiveRoomLinkMicCellItem *cellItem;

@end

@implementation AUILiveRoomLinkMicCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _lineView = [UIView new];
        _lineView.backgroundColor = AUIFoundationColor(@"border_weak");
        [self.contentView addSubview:_lineView];
        
        _avatarView = [AUILiveRoomAvatarView new];
        _avatarView.layer.cornerRadius = 24;
        _avatarView.layer.masksToBounds = YES;
        [self.contentView addSubview:_avatarView];
        
        _nameLabel = [UILabel new];
        _nameLabel.textColor = AUIFoundationColor(@"text_strong");
        _nameLabel.font = AVGetRegularFont(14);
        _nameLabel.numberOfLines = 1;
        _nameLabel.text = @"AAAAA";
        [self.contentView addSubview:_nameLabel];
        
        __weak typeof(self) weakSelf = self;
        _agreeBtn = [AVBlockButton new];
        [_agreeBtn setBackgroundColor:AUIRoomColourfulFillStrong forState:UIControlStateNormal];
        [_agreeBtn setTitleColor:[UIColor av_colorWithHexString:@"#FCFCFD"] forState:UIControlStateNormal];
        [_agreeBtn setTitle:@"同意" forState:UIControlStateNormal];
        _agreeBtn.titleLabel.font = AVGetRegularFont(12.0);
        _agreeBtn.layer.cornerRadius = 11;
        _agreeBtn.layer.masksToBounds = YES;
        _agreeBtn.clickBlock = ^(AVBlockButton * _Nonnull sender) {
            if (weakSelf.onAgreeBtnClick) {
                weakSelf.onAgreeBtnClick(sender, weakSelf.cellItem);
            }
        };
        [self.contentView addSubview:_agreeBtn];
        _agreeBtn.hidden = YES;
        
        _rejectBtn = [AVBlockButton new];
        _rejectBtn.layer.cornerRadius = 11;
        _rejectBtn.layer.masksToBounds = YES;
        [_rejectBtn av_setLayerBorderColor:AUIFoundationColor(@"border_strong") borderWidth:1];
        [_rejectBtn setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
        [_rejectBtn setTitle:@"拒绝" forState:UIControlStateNormal];
        _rejectBtn.titleLabel.font = AVGetRegularFont(12.0);
        _rejectBtn.clickBlock = ^(AVBlockButton * _Nonnull sender) {
            if (weakSelf.onRejectBtnClick) {
                weakSelf.onRejectBtnClick(sender, weakSelf.cellItem);
            }
        };
        [self.contentView addSubview:_rejectBtn];
        _rejectBtn.hidden = YES;
        
        _micBtn = [AVBlockButton new];
        [_micBtn setImage:AUIRoomGetImage(@"ic_living_linkmic_audio") forState:UIControlStateNormal];
        [_micBtn setImage:AUIRoomGetImage(@"ic_living_linkmic_audio_selected") forState:UIControlStateSelected];
        _micBtn.clickBlock = ^(AVBlockButton * _Nonnull sender) {
            if (weakSelf.onMicBtnClick) {
                weakSelf.onMicBtnClick(sender, weakSelf.cellItem);
            }
        };
        [self.contentView addSubview:_micBtn];
        _micBtn.hidden = YES;

        _cameraBtn = [AVBlockButton new];
        [_cameraBtn setImage:AUIRoomGetImage(@"ic_living_linkmic_camera") forState:UIControlStateNormal];
        [_cameraBtn setImage:AUIRoomGetImage(@"ic_living_linkmic_camera_selected") forState:UIControlStateSelected];
        _cameraBtn.clickBlock = ^(AVBlockButton * _Nonnull sender) {
            if (weakSelf.onCameraBtnClick) {
                weakSelf.onCameraBtnClick(sender, weakSelf.cellItem);
            }
        };
        [self.contentView addSubview:_cameraBtn];
        _cameraBtn.hidden = YES;
        
        _leaveBtn = [AVBlockButton new];
        _leaveBtn.layer.cornerRadius = 11;
        _leaveBtn.layer.masksToBounds = YES;
        [_leaveBtn av_setLayerBorderColor:AUIFoundationColor(@"border_strong") borderWidth:1];
        [_leaveBtn setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
        [_leaveBtn setTitle:@"下麦" forState:UIControlStateNormal];
        _leaveBtn.titleLabel.font = AVGetRegularFont(12.0);
        _leaveBtn.clickBlock = ^(AVBlockButton * _Nonnull sender) {
            if (weakSelf.onLeaveBtnClick) {
                weakSelf.onLeaveBtnClick(sender, weakSelf.cellItem);
            }
        };
        [self.contentView addSubview:_leaveBtn];
        _leaveBtn.hidden = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _lineView.frame = CGRectMake(16, self.contentView.av_height - 1, self.contentView.av_width - 16 - 16, 1);
    
    _agreeBtn.frame = CGRectMake(self.contentView.av_width - 50 - 16, (self.contentView.av_height - 22) / 2.0, 50, 22);
    _rejectBtn.frame = CGRectMake(_agreeBtn.av_left - 50 - 12, _agreeBtn.av_top, 50, 22);
    
    _leaveBtn.frame = CGRectMake(self.contentView.av_width - 50 - 16, (self.contentView.av_height - 22) / 2.0, 50, 22);
    _cameraBtn.frame = CGRectMake(_leaveBtn.av_left - 32 - 6, (self.contentView.av_height - 32) / 2.0, 32, 32);
    _micBtn.frame = CGRectMake(_cameraBtn.av_left - 32, (self.contentView.av_height - 32) / 2.0, 32, 32);

    
    CGFloat right = _micBtn.av_left;
    if (_cellItem.itemType == AUILiveRoomLinkMicItemTypeApply) {
        right = _rejectBtn.av_left - 12;
    }
    
    _avatarView.frame = CGRectMake(16, (self.contentView.av_height - 48) / 2.0, 48, 48);
    _nameLabel.frame = CGRectMake(_avatarView.av_right + 12, (self.contentView.av_height - 22) / 2.0, right - _avatarView.av_right - 12, 22);
}

- (void)setCellItem:(AUILiveRoomLinkMicCellItem *)cellItem {
    _cellItem = cellItem;
    
    _avatarView.user = _cellItem.joinUser;
    _nameLabel.text = _cellItem.joinUser.nickName;
    _agreeBtn.hidden = _cellItem.itemType != AUILiveRoomLinkMicItemTypeApply;
    _rejectBtn.hidden = _cellItem.itemType != AUILiveRoomLinkMicItemTypeApply;
    _leaveBtn.hidden = _cellItem.itemType != AUILiveRoomLinkMicItemTypeJoined;
    _cameraBtn.hidden = _cellItem.itemType != AUILiveRoomLinkMicItemTypeJoined;
    _micBtn.hidden = _cellItem.itemType != AUILiveRoomLinkMicItemTypeJoined;
    _cameraBtn.selected = _cellItem.videoOff;
    _micBtn.selected = _cellItem.audioOff;
}

@end

@interface AUILiveRoomLinkMicListPanel()

@property (nonatomic, strong) UIButton *joinedButton;
@property (nonatomic, strong) UIButton *applyButton;
@property (nonatomic, strong) UIView *selectedLine;

@property (nonatomic, strong) AUIRoomInteractionLiveManagerAnchor *manager;
@property (nonatomic, strong) NSMutableArray *list;
@property (nonatomic, strong) UILabel *emptyLabel;

@end


@implementation AUILiveRoomLinkMicListPanel

- (instancetype)initWithFrame:(CGRect)frame withManager:(AUIRoomInteractionLiveManagerAnchor *)manager {
    self = [super initWithFrame:frame];
    if (self) {
        _manager = manager;
        _tabType = AUILiveRoomLinkMicItemTypeJoined;

        self.headerView.hidden = YES;
        self.contentView.frame = self.bounds;
        
        UIView *selectedLine = [[UIView alloc] initWithFrame:CGRectMake(0, 42, 40, 2)];
        selectedLine.backgroundColor = AUIRoomColourfulFillStrong;
        [self.contentView addSubview:selectedLine];
        self.selectedLine = selectedLine;
        
        UIButton *joinedButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
        joinedButton.titleLabel.font = AVGetMediumFont(14);
        [joinedButton setTitle:@"麦上成员" forState:UIControlStateNormal];
        [joinedButton setTitleColor:AUIFoundationColor(@"text_medium") forState:UIControlStateNormal];
        [joinedButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateSelected];
        [self.contentView addSubview:joinedButton];
        self.joinedButton = joinedButton;
        
        UIButton *applyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
        applyButton.titleLabel.font = AVGetRegularFont(14);
        [applyButton setTitle:@"连麦申请" forState:UIControlStateNormal];
        [applyButton setTitleColor:AUIFoundationColor(@"text_medium") forState:UIControlStateNormal];
        [applyButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateSelected];
        [self.contentView addSubview:applyButton];
        self.applyButton = applyButton;
        
        [self.joinedButton sizeToFit];
        [self.applyButton sizeToFit];
        CGFloat margin = 40;
        CGFloat left = (self.contentView.av_width - self.joinedButton.av_width - self.applyButton.av_width - 40) / 2.0;
        self.joinedButton.av_left = left;
        self.joinedButton.av_height = 44;
        self.applyButton.av_left = self.joinedButton.av_right + margin;
        self.applyButton.av_height = 44;
        self.selectedLine.av_centerX = self.joinedButton.av_centerX;
        self.joinedButton.selected = YES;
        [self.joinedButton addTarget:self action:@selector(onJoinedButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.applyButton addTarget:self action:@selector(onApplyButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        self.collectionView.frame = CGRectMake(0, 44, self.contentView.av_width, self.contentView.av_height - 44);
        [self.collectionView registerClass:AUILiveRoomLinkMicCell.class forCellWithReuseIdentifier:AVCollectionViewCellIdentifier];

        _list = [NSMutableArray array];
        [self reload];
    }
    return self;
}

- (void)onJoinedButtonClick {
    self.tabType = AUILiveRoomLinkMicItemTypeJoined;
}

- (void)onApplyButtonClick {
    self.tabType = AUILiveRoomLinkMicItemTypeApply;
}

- (void)setTabType:(AUILiveRoomLinkMicItemType)tabType {
    if (_tabType == tabType) {
        return;
    }
    
    _tabType = tabType;
    self.joinedButton.selected = _tabType == AUILiveRoomLinkMicItemTypeJoined;
    self.joinedButton.titleLabel.font = self.joinedButton.selected ? AVGetMediumFont(14) : AVGetRegularFont(14);
    self.applyButton.selected = _tabType == AUILiveRoomLinkMicItemTypeApply;
    self.applyButton.titleLabel.font = self.applyButton.selected ? AVGetMediumFont(14) : AVGetRegularFont(14);
    UIButton *btn = _tabType == AUILiveRoomLinkMicItemTypeJoined ? self.joinedButton : self.applyButton;
    [UIView animateWithDuration:0.3 animations:^{
        self.selectedLine.av_centerX = btn.av_centerX;
    }];
    [self reload];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.list.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AUILiveRoomLinkMicCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:AVCollectionViewCellIdentifier forIndexPath:indexPath];
    cell.cellItem = [self.list objectAtIndex:indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    cell.onAgreeBtnClick = ^(AVBlockButton *sender, AUILiveRoomLinkMicCellItem *cellItem) {
        
        if (![weakSelf.manager checkCanLinkMic]) {
            [AVToastView show:@"当前连麦人数已经超过最大限制" view:weakSelf.manager.roomVC.view position:AVToastViewPositionMid];
            return;
        }
        
        [weakSelf.manager responseApplyLinkMic:cellItem.data agree:YES force:NO completed:^(BOOL success) {
            if (success) {
                [weakSelf reload];
            }
            else {
                [AVToastView show:@"失败了，请稍后重试" view:weakSelf.manager.roomVC.view position:AVToastViewPositionMid];
            }
        }];
    };
    cell.onRejectBtnClick = ^(AVBlockButton *sender, AUILiveRoomLinkMicCellItem *cellItem) {
        [weakSelf.manager responseApplyLinkMic:cellItem.data agree:NO force:NO completed:^(BOOL success) {
            if (success) {
                [weakSelf reload];
            }
            else {
                [AVToastView show:@"失败了，请稍后重试" view:weakSelf.manager.roomVC.view position:AVToastViewPositionMid];
            }
        }];
    };
    cell.onLeaveBtnClick = ^(AVBlockButton *sender, AUILiveRoomLinkMicCellItem *cellItem) {
        [weakSelf.manager kickoutLinkMic:[(AUIRoomLiveRtcPlayer *)cellItem.data joinInfo].userId completed:^(BOOL success) {
            if (success) {
                [weakSelf reload];
            }
            else {
                [AVToastView show:@"失败了，请稍后重试" view:weakSelf.manager.roomVC.view position:AVToastViewPositionMid];
            }
        }];
    };
    cell.onMicBtnClick = ^(AVBlockButton *sender, AUILiveRoomLinkMicCellItem *cellItem) {
        AUIRoomLiveLinkMicJoinInfoModel *joinInfo = [(AUIRoomLiveRtcPlayer *)cellItem.data joinInfo];
        [weakSelf.manager openMic:joinInfo.userId needOpen:!joinInfo.micOpened completed:^(BOOL success) {
            if (!success) {
                [AVToastView show:@"失败了，请稍后重试" view:weakSelf.manager.roomVC.view position:AVToastViewPositionMid];
            }
        }];
    };
    cell.onCameraBtnClick = ^(AVBlockButton *sender, AUILiveRoomLinkMicCellItem *cellItem) {
        AUIRoomLiveLinkMicJoinInfoModel *joinInfo = [(AUIRoomLiveRtcPlayer *)cellItem.data joinInfo];
        [weakSelf.manager openCamera:joinInfo.userId needOpen:!joinInfo.cameraOpened completed:^(BOOL success) {
            if (!success) {
                [AVToastView show:@"失败了，请稍后重试" view:weakSelf.manager.roomVC.view position:AVToastViewPositionMid];
            }
        }];
    };
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.contentView.av_width, 64);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (void)reload {
    [self.list removeAllObjects];
    
    if (self.tabType == AUILiveRoomLinkMicItemTypeApply) {
        [self.manager.currentApplyList enumerateObjectsUsingBlock:^(AUIRoomUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            AUILiveRoomLinkMicCellItem *cellItem = [AUILiveRoomLinkMicCellItem new];
            cellItem.itemType = AUILiveRoomLinkMicItemTypeApply;
            cellItem.data = obj;
            [self.list addObject:cellItem];
        }];
        
        // for test
//        for (NSUInteger i=0; i<0; i++) {
//            AUILiveRoomLinkMicCellItem *cellItem = [AUILiveRoomLinkMicCellItem new];
//            cellItem.itemType = AUILiveRoomLinkMicItemTypeApply;
//            cellItem.data = AUIRoomAccount.me;
//            [self.list addObject:cellItem];
//        }
        
    }
    else {
        [self.manager.currentJoinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            AUILiveRoomLinkMicCellItem *cellItem = [AUILiveRoomLinkMicCellItem new];
            cellItem.itemType = AUILiveRoomLinkMicItemTypeJoined;
            cellItem.data = obj;
            [self.list addObject:cellItem];
        }];
        
        // for test
//        for (NSUInteger i=0; i<0; i++) {
//            AUIRoomLiveRtcPlayer *pull = [AUIRoomLiveRtcPlayer new];
//            AUIRoomLiveLinkMicJoinInfoModel *joinInfo = [[AUIRoomLiveLinkMicJoinInfoModel alloc] init:AUIRoomAccount.me.userId userNick:@"哈哈水水水水水水水水哒哒哒哒哒哒多多哒哒哒哒哒哒多" userAvatar:AUIRoomAccount.me.avatar rtcPullUrl:@""];
//            pull.joinInfo = joinInfo;
//
//            AUILiveRoomLinkMicCellItem *cellItem = [AUILiveRoomLinkMicCellItem new];
//            cellItem.itemType = AUILiveRoomLinkMicItemTypeJoined;
//            cellItem.data = pull;
//            [self.list addObject:cellItem];
//        }
    }
    [self.collectionView reloadData];

    if (self.list.count > 0) {
        [self.emptyLabel removeFromSuperview];
        self.emptyLabel = nil;
    }
    else {
        if (!self.emptyLabel) {
            self.emptyLabel = [[UILabel alloc] initWithFrame:self.collectionView.bounds];
            self.emptyLabel.textAlignment = NSTextAlignmentCenter;
            self.emptyLabel.textColor = AUIFoundationColor(@"text_ultraweak");
            self.emptyLabel.font = AVGetRegularFont(12.0);
            [self.collectionView addSubview:self.emptyLabel];
        }
        self.emptyLabel.text = self.tabType == AUILiveRoomLinkMicItemTypeApply ? @"没有任何成员申请连麦~" : @"没有任何成员上麦~";
        self.emptyLabel.frame = self.collectionView.bounds;
    }
}

+ (CGFloat)panelHeight {
    return 472;
}

@end
