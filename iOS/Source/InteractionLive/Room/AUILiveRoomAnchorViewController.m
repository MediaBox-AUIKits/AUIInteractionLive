//
//  AUILiveRoomAnchorViewController.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/2.
//

#import "AUILiveRoomAnchorViewController.h"
#import "AUIFoundation.h"
#import "AUIRoomMacro.h"

#import "AUILiveRoomInfoView.h"
#import "AUILiveRoomPushStatusView.h"
#import "AUILiveRoomMemberButton.h"
#import "AUILiveRoomAnchorBottomView.h"
#import "AUILiveRoomMorePanel.h"
#import "AUILiveRoomCommentView.h"
#import "AUILiveRoomAnchorPrestartView.h"
#import "AUILiveRoomFinishView.h"
#import "AUIRoomDisplayView.h"
#import "AUILiveRoomLivingContainerView.h"
#import "AUILiveRoomNoticeButton.h"
#import "AUILIveRoomNoticePanel.h"

#import "AUIRoomAccount.h"
#import "AUIRoomBaseLiveManagerAnchor.h"
#import "AUIRoomInteractionLiveManagerAnchor.h"
#import "AUILiveRoomLinkMicListPanel.h"


@interface AUILiveRoomAnchorViewController () <
AVUIViewControllerInteractivePopGesture
>

@property (strong, nonatomic) AVBlockButton* exitButton;

@property (strong, nonatomic) AUIRoomDisplayLayoutView *liveDisplayView;

@property (strong, nonatomic) AUILiveRoomLivingContainerView *livingContainerView;
@property (strong, nonatomic) AUILiveRoomInfoView *liveInfoView;
@property (strong, nonatomic) AUILiveRoomNoticeButton *noticeButton;
@property (strong, nonatomic) AUILiveRoomMemberButton *membersButton;
@property (strong, nonatomic) AUILiveRoomPushStatusView *pushStatusView;
@property (strong, nonatomic) AUILiveRoomCommentView *liveCommentView;
@property (strong, nonatomic) AUILiveRoomAnchorBottomView *bottomView;

@property (strong, nonatomic) AUILiveRoomAnchorPrestartView *livePrestartView;
@property (strong, nonatomic) AUILiveRoomFinishView *liveFinishView;


@property (strong, nonatomic) id<AUIRoomLiveManagerAnchorProtocol> liveManager;

@property (strong, nonatomic) AUILiveRoomLinkMicListPanel* linkMicPanel;

@end



@implementation AUILiveRoomAnchorViewController

#pragma mark -- UI控件懒加载

- (AVBlockButton *)exitButton {
    if (!_exitButton) {
        AVBlockButton* button = [[AVBlockButton alloc] initWithFrame:CGRectMake(self.view.av_right - 16 - 24, AVSafeTop + 10, 24, 24)];
        button.layer.cornerRadius = 12;
        button.layer.masksToBounds = YES;
        [button setImage:AUIRoomGetCommonImage(@"ic_living_close") forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor av_colorWithHexString:@"#1C1D22" alpha:0.4] forState:UIControlStateNormal];
        [self.view addSubview:button];
        
        __weak typeof(self) weakSelf = self;
        button.clickBlock = ^(AVBlockButton * _Nonnull sender) {
            NSString *tips = @"还有观众正在路上，确定要结束直播吗？";
            if (weakSelf.liveManager.liveInfoModel.status == AUIRoomLiveStatusFinished) {
                tips = @"确定要离开吗？";
            }
            [AVAlertController showWithTitle:tips message:@"" needCancel:YES onCompleted:^(BOOL isCanced) {
                if (!isCanced) {
                    [weakSelf.liveManager leaveRoom:nil];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }];
        };
        _exitButton = button;
    }
    return _exitButton;
}

- (AUIRoomDisplayLayoutView *)liveDisplayView {
    if (!_liveDisplayView) {
        _liveDisplayView = [[AUIRoomDisplayLayoutView alloc] initWithFrame:self.view.bounds];
        _liveDisplayView.resolution = CGSizeMake(720, 1280);
        [self.view addSubview:_liveDisplayView];
    }
    return _liveDisplayView;
}

- (AUILiveRoomLivingContainerView *)livingContainerView {
    if (!_livingContainerView) {
        _livingContainerView = [[AUILiveRoomLivingContainerView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_livingContainerView];
    }
    return _livingContainerView;
}

- (AUILiveRoomMemberButton *)membersButton {
    if (!_membersButton) {
        _membersButton = [[AUILiveRoomMemberButton alloc] initWithFrame:CGRectMake(self.livingContainerView.av_right - 48 - 55, AVSafeTop + 10, 55, 24)];
        _membersButton.layer.cornerRadius = 12;
        _membersButton.layer.masksToBounds = YES;
        [_membersButton updateMemberCount:self.liveManager.pv];
        [self.livingContainerView addSubview:_membersButton];
    }
    return _membersButton;
}

- (AUILiveRoomInfoView *)liveInfoView {
    if(!_liveInfoView) {
        AUILiveRoomInfoView* view = [[AUILiveRoomInfoView alloc] initWithFrame:CGRectMake(16, AVSafeTop + 2, 150, 40) withModel:self.liveManager.liveInfoModel];
        [self.livingContainerView addSubview:view];
        view.layer.cornerRadius = 20;
        view.layer.masksToBounds = YES;
        _liveInfoView = view;
    }
    return _liveInfoView;
}


- (AUILiveRoomNoticeButton *)noticeButton {
    if (!_noticeButton) {
        AUILiveRoomNoticeButton* button = [[AUILiveRoomNoticeButton alloc] initWithFrame:CGRectMake(16, AVSafeTop + 52, 0, 0)];
        button.enableEdit = YES;
        [self.livingContainerView addSubview:button];
        button.noticeContent = self.liveManager.notice;
        
        __weak typeof(self) weakSelf = self;
        button.onEditNoticeContentBlock = ^{
            
            AUILIveRoomNoticePanel *panel = [[AUILIveRoomNoticePanel alloc] initWithFrame:CGRectMake(0, weakSelf.livingContainerView.av_height - AUILIveRoomNoticePanel.panelHeight, weakSelf.livingContainerView.av_width, AUILIveRoomNoticePanel.panelHeight)];
            panel.input = weakSelf.liveManager.notice;
            panel.onInputCompletedBlock = ^(AUILIveRoomNoticePanel *sender, NSString * _Nonnull input) {
                if ([input isEqualToString:weakSelf.liveManager.notice]) {
                    return;
                }
                AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:weakSelf.view animated:YES];
                [weakSelf.liveManager updateNotice:input?:@"" completed:^(BOOL success) {
                    if (success) {
                        loading.labelText = @"公告已更新";
                        loading.iconType = AVProgressHUDIconTypeSuccess;
                        [loading hideAnimated:YES afterDelay:1];
                        weakSelf.noticeButton.noticeContent = weakSelf.liveManager.notice;
                        [sender hide];
                    }
                    else {
                        loading.labelText = @"公告更新失败";
                        loading.iconType = AVProgressHUDIconTypeWarn;
                        [loading hideAnimated:YES afterDelay:3];
                    }
                }];
            };
            [panel showOnView:weakSelf.livingContainerView withBackgroundType:AVControllPanelBackgroundTypeModal];
            panel.bgViewOnShowing.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        };
        
        _noticeButton = button;
    }
    return _noticeButton;
}

- (AUILiveRoomPushStatusView *)pushStatusView {
    if (!_pushStatusView) {
        _pushStatusView = [[AUILiveRoomPushStatusView alloc] initWithFrame:CGRectMake(self.livingContainerView.av_width - 16 - 48, AVSafeTop + 55, 48, 16)];
        [self.livingContainerView addSubview:_pushStatusView];
    }
    return _pushStatusView;
}

- (AUILiveRoomCommentView *)liveCommentView {
    if(!_liveCommentView){
        _liveCommentView = [[AUILiveRoomCommentView alloc] initWithFrame:CGRectMake(0, self.livingContainerView.av_height - AVSafeBottom - 44 - 214 - 8, 240, 214)];
        [self.livingContainerView addSubview:_liveCommentView];
        
        AUILiveRoomCommentModel* model = [[AUILiveRoomCommentModel alloc] init];
        model.sentContent = @"欢迎来到直播间，直播内容和评论禁止政治、低俗色情、吸烟酗酒或发布虚假信息等内容，若有违反将禁播、封停账号。";
        model.sentContentColor = [UIColor av_colorWithHexString:@"#A4E0A7"];
        [_liveCommentView insertLiveComment:model];
    }
    return _liveCommentView;
}

- (AUILiveRoomAnchorBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[AUILiveRoomAnchorBottomView alloc] initWithFrame:CGRectMake(0, self.livingContainerView.av_height - AVSafeBottom - 50, self.livingContainerView.av_width, AVSafeBottom + 50) linkMic:self.liveManager.liveInfoModel.mode == AUIRoomLiveModeLinkMic];
        [self.livingContainerView addSubview:_bottomView];
        
        __weak typeof(self) weakSelf = self;
        _bottomView.onMoreButtonClickedBlock = ^(AUILiveRoomAnchorBottomView * _Nonnull sender) {
            [weakSelf openMorePanel];
        };
        _bottomView.onBeautyButtonClickedBlock = ^(AUILiveRoomAnchorBottomView * _Nonnull sender) {
            [weakSelf.liveManager openBeautyPanel];
        };
        _bottomView.onLinkMicButtonClickedBlock = ^(AUILiveRoomAnchorBottomView * _Nonnull sender) {
            [weakSelf openLinkMicPanel:YES needJump:YES onApplyTab:NO];
        };
        _bottomView.sendCommentBlock = ^(AUILiveRoomAnchorBottomView * _Nonnull sender, NSString * _Nonnull comment) {
            [weakSelf.liveManager sendComment:comment completed:nil];
        };
    }
    return _bottomView;
}

- (AUILiveRoomAnchorPrestartView *)livePrestartView {
    if (!_livePrestartView) {
        _livePrestartView = [[AUILiveRoomAnchorPrestartView alloc] initWithFrame:self.view.bounds withModel:self.liveManager.liveInfoModel];
        _livePrestartView.hidden = YES;
        [self.view insertSubview:_livePrestartView aboveSubview:self.livingContainerView];
        
        __weak typeof(self) weakSelf = self;
        _livePrestartView.onBeautyBlock = ^(AUILiveRoomAnchorPrestartView * _Nonnull sender) {
            [weakSelf.liveManager openBeautyPanel];
        };
        _livePrestartView.onSwitchCameraBlock = ^(AUILiveRoomAnchorPrestartView * _Nonnull sender) {
            [weakSelf.liveManager switchLivePusherCamera];
        };
        _livePrestartView.onWillStartLiveBlock = ^BOOL(AUILiveRoomAnchorPrestartView * _Nonnull sender) {
            weakSelf.exitButton.hidden = YES;
            return YES;
        };
        _livePrestartView.onStartLiveBlock = ^(AUILiveRoomAnchorPrestartView * _Nonnull sender) {
            weakSelf.exitButton.hidden = NO;
            [weakSelf startLive];
        };
    }
    return _livePrestartView;
}

- (AUILiveRoomFinishView *)liveFinishView {
    if (!_liveFinishView) {
        _liveFinishView = [[AUILiveRoomFinishView alloc] initWithFrame:self.livingContainerView.bounds];
        _liveFinishView.hidden = YES;
        _liveFinishView.isAnchor = YES;
        [self.livingContainerView insertSubview:_liveFinishView atIndex:0];
        
        __weak typeof(self) weakSelf = self;
        _liveFinishView.onPlayImmerseBlock = ^(AUILiveRoomFinishView * _Nonnull sender, BOOL immerse) {
            weakSelf.liveInfoView.hidden = immerse;
            weakSelf.membersButton.hidden = immerse;
            weakSelf.noticeButton.hidden = immerse;
            weakSelf.exitButton.hidden = immerse;
        };
    }
    return _liveFinishView;
}

#pragma mark - AVUIViewControllerInteractivePopGesture

- (BOOL)disableInteractivePopGesture {
    return YES;
}

#pragma mark - LifeCycle

- (void)dealloc {
    NSLog(@"dealloc:AUILiveRoomAnchorViewController");
}

- (instancetype)initWithModel:(AUIRoomLiveInfoModel *)model withJoinList:(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *)joinList {
    self = [super init];
    if (self) {
        [self createLiveManager:model withJoinList:joinList];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBackground];
    [self setupLiveManager];
    [self setupRoomUI];
    
    __weak typeof(self) weakSelf = self;
    [self.liveManager enterRoom:^(BOOL success) {
        if (!success) {
            [AVAlertController showWithTitle:nil message:@"进入直播间失败，请稍后重试~" needCancel:NO onCompleted:^(BOOL isCanced) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
        }
    }];
}

- (void)setupBackground {
    self.view.backgroundColor = AUIFoundationColor(@"bg_weak");
    CAGradientLayer *bgLayer = [CAGradientLayer layer];
    bgLayer.frame = self.view.bounds;
    bgLayer.colors = @[(id)[UIColor colorWithRed:0x39 / 255.0 green:0x1a / 255.0 blue:0x0f / 255.0 alpha:1.0].CGColor,(id)[UIColor colorWithRed:0x1e / 255.0 green:0x23 / 255.0 blue:0x26 / 255.0 alpha:1.0].CGColor];
    bgLayer.startPoint = CGPointMake(0, 0.5);
    bgLayer.endPoint = CGPointMake(1, 0.5);
    [self.view.layer addSublayer:bgLayer];
}

- (void)setupRoomUI {
    [self livingContainerView];
    [self membersButton];
    [self liveInfoView];
    [self noticeButton];
    [self pushStatusView];
    [self bottomView];
    [self liveCommentView];
    [self liveFinishView];
    [self exitButton];
    
    if (self.liveManager.liveInfoModel.status == AUIRoomLiveStatusNone) {
        [self showPrestartUI];
    }
    else if (self.liveManager.liveInfoModel.status == AUIRoomLiveStatusFinished) {
        [self showFinishUI];
    }
    else {
        [self showLivingUI];
    }
}

- (void)showPrestartUI {
    self.livingContainerView.hidden = YES;
    self.livePrestartView.hidden = NO;
}

- (void)showLivingUI {
    self.livingContainerView.hidden = NO;
    _livePrestartView.hidden = YES;
    
    self.liveFinishView.hidden = YES;
    self.pushStatusView.hidden = NO;
    self.bottomView.hidden = NO;
    self.liveCommentView.hidden = NO;
}

- (void)showFinishUI {
    self.livingContainerView.hidden = NO;
    _livePrestartView.hidden = YES;
    
    self.liveFinishView.hidden = NO;
    self.pushStatusView.hidden = YES;
    self.bottomView.hidden = YES;
    self.liveCommentView.hidden = YES;
    
    self.liveFinishView.vodModel = self.liveManager.liveInfoModel.vod_info;
    self.noticeButton.enableEdit = NO;
}

- (void)openMorePanel {
    AUILiveRoomMorePanel *morePanel = [[AUILiveRoomMorePanel alloc] initWithFrame:CGRectMake(0, 0, self.livingContainerView.av_width, 0)];
    [morePanel updateClickedSelected:AUILiveRoomMorePanelActionTypeMute selected:!self.liveManager.isMicOpened];
    [morePanel updateClickedSelected:AUILiveRoomMorePanelActionTypeAudioOnly selected:!self.liveManager.isCameraOpened];
    [morePanel updateClickedSelected:AUILiveRoomMorePanelActionTypeCamera selected:self.liveManager.isBackCamera];
    [morePanel updateClickedSelected:AUILiveRoomMorePanelActionTypeMirror selected:self.liveManager.isMirror];
    [morePanel updateClickedSelected:AUILiveRoomMorePanelActionTypeBan selected:self.liveManager.isMuteAll];
    __weak typeof(self) weakSelf = self;
    morePanel.onClickedAction = ^BOOL(AUILiveRoomMorePanel *sender, AUILiveRoomMorePanelActionType type, BOOL selected) {
        BOOL ret = selected;
        switch (type) {
            case AUILiveRoomMorePanelActionTypeMute:
            {
                [weakSelf.liveManager openLivePusherMic:selected];
                ret = !weakSelf.liveManager.isMicOpened;
            }
                break;
            case AUILiveRoomMorePanelActionTypeAudioOnly:
            {
                [weakSelf.liveManager openLivePusherCamera:selected];
                ret = !weakSelf.liveManager.isCameraOpened;
            }
                break;
            case AUILiveRoomMorePanelActionTypeCamera:
            {
                [weakSelf.liveManager switchLivePusherCamera];
                ret = weakSelf.liveManager.isBackCamera;
            }
                break;
            case AUILiveRoomMorePanelActionTypeMirror:
            {
                [weakSelf.liveManager openLivePusherMirror:!selected];
                ret = weakSelf.liveManager.isMirror;
            }
                break;
            case AUILiveRoomMorePanelActionTypeBan:
            {
                void (^completedBlock)(BOOL, NSString *, NSString *, AVProgressHUD *) = ^(BOOL success, NSString *successText, NSString *warnText, AVProgressHUD *loading) {
                    if (success) {
                        loading.labelText = successText;
                        loading.iconType = AVProgressHUDIconTypeSuccess;
                        [loading hideAnimated:YES afterDelay:1];
                    }
                    else {
                        loading.labelText = warnText;
                        loading.iconType = AVProgressHUDIconTypeWarn;
                        [loading hideAnimated:YES afterDelay:3];
                    }
                    [sender updateClickedSelected:AUILiveRoomMorePanelActionTypeBan selected:weakSelf.liveManager.isMuteAll];
                };
                if (selected) {
                    AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:weakSelf.view animated:YES];
                    [weakSelf.liveManager cancelMuteAll:^(BOOL result) {
                        completedBlock(result, @"已取消全员禁言", @"取消全员禁言失败，请稍后再试", loading);
                    }];
                }
                else {
                    [AVAlertController showWithTitle:nil message:@"是否开启全员禁言？" needCancel:YES onCompleted:^(BOOL isCanced) {
                        if (!isCanced) {
                            AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:weakSelf.view animated:YES];
                            [weakSelf.liveManager muteAll:^(BOOL result) {
                                completedBlock(result, @"已全员禁言", @"全员禁言失败，请稍后再试", loading);
                            }];
                        }
                    }];
                }
            }
                break;
            default:
                break;
        }
        
        return ret;
    };
    [morePanel showOnView:self.livingContainerView];
    morePanel.bgViewOnShowing.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
}

#pragma mark - orientation

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - live & pusher

- (void)startLive {
    __weak typeof(self) weakSelf = self;
    [self.liveManager startLive:^(BOOL success) {
        NSLog(@"开始直播：%@", success ? @"成功" : @"失败");
        if (success) {
            [weakSelf showLivingUI];
            [weakSelf.livePrestartView removeFromSuperview];
            weakSelf.livePrestartView = nil;
            return;
        }
        
        [AVToastView show:@"开始直播失败了" view:weakSelf.view position:AVToastViewPositionMid];
        [weakSelf.livePrestartView restore];
    }];
}

- (void)createLiveManager:(AUIRoomLiveInfoModel *)liveInfoModel withJoinList:(nullable NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *)joinList {
    if (liveInfoModel.mode == AUIRoomLiveModeLinkMic) {
        self.liveManager = [[AUIRoomInteractionLiveManagerAnchor alloc] initWithModel:liveInfoModel withJoinList:joinList];
    }
    else {
        self.liveManager = [[AUIRoomBaseLiveManagerAnchor alloc] initWithModel:liveInfoModel];
    }
}

- (void)setupLiveManager {
    
    __weak typeof(self) weakSelf = self;
    
    self.liveManager.displayLayoutView = self.liveDisplayView;
    self.liveManager.onReceivedComment = ^(AUIRoomUser * _Nonnull sender, NSString * _Nonnull content) {
        if (content.length > 0) {
            NSString *senderNick = sender.nickName;
            NSString *senderId = sender.userId;
            [weakSelf.liveCommentView insertLiveComment:content commentSenderNick:senderNick commentSenderID:senderId];
        }
    };
    
    self.liveManager.onReceivedMuteAll = ^(BOOL isMuteAll) {
        weakSelf.bottomView.commentTextField.commentState = isMuteAll ?  AUILiveRoomCommentStateMute : AUILiveRoomCommentStateDefault;
    };
    
    self.liveManager.onReceivedLike = ^(AUIRoomUser * _Nonnull sender, NSInteger likeCount) {
        NSLog(@"收到来自观众（%@）的点赞，总数：%zd", sender.nickName ?: sender.userId, likeCount);
    };
    
    self.liveManager.onReceivedPV = ^(NSInteger pv) {
        [weakSelf.membersButton updateMemberCount:pv];
    };
    
    self.liveManager.onReceivedGift = ^(AUIRoomUser * _Nonnull sender, AUIRoomGiftModel * _Nonnull gift) {
        // 处理接收到的礼物
    };
    
    [self linkMicManager].applyListChangedBlock = ^(AUIRoomInteractionLiveManagerAnchor * _Nonnull sender) {
        [weakSelf.bottomView updateLinkMicNumber:sender.currentApplyList.count];
    };
    
    [self linkMicManager].onReceivedMicOpened = ^(AUIRoomUser * _Nonnull sender, BOOL opened) {
        [weakSelf openLinkMicPanel:NO needJump:NO onApplyTab:NO];
    };
    
    [self linkMicManager].onReceivedCameraOpened = ^(AUIRoomUser * _Nonnull sender, BOOL opened) {
        [weakSelf openLinkMicPanel:NO needJump:NO onApplyTab:NO];
    };
    
    [self linkMicManager].onReceivedApplyLinkMic = ^(AUIRoomUser * _Nonnull sender) {
        [weakSelf openLinkMicPanel:YES needJump:YES onApplyTab:YES];
    };
    
    [self linkMicManager].onReceivedCancelApplyLinkMic = ^(AUIRoomUser * _Nonnull sender) {
        [weakSelf.linkMicPanel reload];
    };
    
    [self linkMicManager].onReceivedJoinLinkMic = ^(AUIRoomUser * _Nonnull sender) {
        [weakSelf.linkMicPanel reload];
    };
    
    [self linkMicManager].onReceivedLeaveLinkMic = ^(NSString * _Nonnull userId) {
        [weakSelf.linkMicPanel reload];
    };
    
    self.liveManager.onStartedBlock = ^{
        weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusFluent;
    };
    self.liveManager.onRestartBlock = ^{
        weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusFluent;
    };
    self.liveManager.onConnectionPoorBlock = ^{
        weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusStuttering;
    };
    self.liveManager.onConnectionLostBlock = ^{
        weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusBrokenOff;
    };
    self.liveManager.onConnectionRecoveryBlock = ^{
        weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusFluent;
    };
    self.liveManager.onConnectErrorBlock = ^{
        weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusBrokenOff;
    };
    self.liveManager.onReconnectStartBlock = ^{
        weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusBrokenOff;
    };
    self.liveManager.onReconnectSuccessBlock = ^{
        weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusFluent;
    };
    self.liveManager.onReconnectErrorBlock = ^{
        weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusBrokenOff;
    };
    self.liveManager.roomVC = self;
    [self.liveManager setupLivePusher];
}

#pragma mark - link mic

- (AUIRoomInteractionLiveManagerAnchor *)linkMicManager {
    if ([self.liveManager isKindOfClass:AUIRoomInteractionLiveManagerAnchor.class]) {
        return self.liveManager;
    }
    return nil;
}

- (void)openLinkMicPanel:(BOOL)open needJump:(BOOL)jump onApplyTab:(BOOL)applyTab {
    
    if (![self linkMicManager].isLiving) {
        return;
    }
    
    AUILiveRoomLinkMicItemType tab = applyTab ? AUILiveRoomLinkMicItemTypeApply : AUILiveRoomLinkMicItemTypeJoined;
    if (self.linkMicPanel) {
        if (self.linkMicPanel.tabType == tab) {
            [self.linkMicPanel reload];
            return;
        }
        if (jump) {
            self.linkMicPanel.tabType = tab;
        }
        return;
    }
    if (open) {
        __weak typeof(self) weakSelf = self;
        AUILiveRoomLinkMicListPanel *panel = [[AUILiveRoomLinkMicListPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.av_width, 0) withManager:[self linkMicManager]];
        [panel showOnView:self.view];
        panel.bgViewOnShowing.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        panel.onShowChanged = ^(AVBaseControllPanel * _Nonnull sender) {
            if (!weakSelf.linkMicPanel.isShowing) {
                weakSelf.linkMicPanel = nil;
            }
        };
        weakSelf.linkMicPanel = panel;
        weakSelf.linkMicPanel.tabType = tab;
    }
}

@end
