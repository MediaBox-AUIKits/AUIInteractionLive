//
//  AUIHomeViewController.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/10/24.
//

#import "AUIHomeViewController.h"
#import "AUILoginViewController.h"
#import "AUIRoomMacro.h"
#import "AUILiveListViewController.h"
#import "AUILiveRoomActionManager.h"
#import <objc/message.h>

@interface AUIHomeViewController ()

@end

@implementation AUIHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.hiddenBackButton = YES;
    self.titleView.text = @"App主界面";
    
    if ([self.class enableDebug]) {
        [self.class loadDebugConfig];
        self.hiddenMenuButton = NO;
        [self.menuButton setTitle:@"DEBUG" forState:UIControlStateNormal];
        [self.menuButton setImage:nil forState:UIControlStateNormal];
        [self.menuButton sizeToFit];
        self.menuButton.av_right = self.menuButton.superview.av_width - 16;
    }
    else {
        self.hiddenMenuButton = YES;
    }
    
    AVBlockButton *logout = [[AVBlockButton alloc] initWithFrame:CGRectMake(24, self.view.av_height - AVSafeBottom - 44, self.view.av_width - 24 * 2, 44)];
    logout.layer.cornerRadius = 22;
    logout.titleLabel.font = AVGetRegularFont(16);
    [logout setTitle:@"登出" forState:UIControlStateNormal];
    [logout setTitleColor:[UIColor av_colorWithHexString:@"#FCFCFD"] forState:UIControlStateNormal];
    [logout setBackgroundColor:AUIRoomColourfulFillStrong forState:UIControlStateNormal];
    [logout addTarget:self action:@selector(onLogoutClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logout];
    
    AVBlockButton *liveList = [[AVBlockButton alloc] initWithFrame:CGRectMake(24, logout.av_top - 44 - 24, self.view.av_width - 24 * 2, 44)];
    liveList.layer.cornerRadius = 22;
    liveList.titleLabel.font = AVGetRegularFont(16);
    [liveList setTitle:@"直播间列表" forState:UIControlStateNormal];
    [liveList setTitleColor:[UIColor av_colorWithHexString:@"#FCFCFD"] forState:UIControlStateNormal];
    [liveList setBackgroundColor:AUIRoomColourfulFillStrong forState:UIControlStateNormal];
    [liveList addTarget:self action:@selector(onLiveListClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:liveList];
    
    AVBlockButton *theme = [[AVBlockButton alloc] initWithFrame:CGRectMake(24, liveList.av_top - 44 - 24, self.view.av_width - 24 * 2, 44)];
    theme.layer.cornerRadius = 22;
    theme.titleLabel.font = AVGetRegularFont(16);
    [theme setTitle:@"切换主题" forState:UIControlStateNormal];
    [theme setTitleColor:[UIColor av_colorWithHexString:@"#FCFCFD"] forState:UIControlStateNormal];
    [theme setBackgroundColor:AUIRoomColourfulFillStrong forState:UIControlStateNormal];
    [theme addTarget:self action:@selector(changeTheme:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:theme];
    
    AUILiveRoomActionManager.defaultManager.followAnchorAction = ^(AUIRoomUser * _Nonnull anchor, BOOL isFollowed, UIViewController * _Nonnull roomVC, onActionCompleted  _Nonnull completed) {
        // 这里调用关注接口，然后返回结果
        if (completed) {
            completed(YES);
        }
    };
    AUILiveRoomActionManager.defaultManager.openShare = ^(AUIRoomLiveInfoModel * _Nonnull liveInfo, UIViewController * _Nonnull roomVC, onActionCompleted  _Nullable completed) {
        // 这里打开分享面板
        AVBaseControllPanel *panel = [[AVBaseControllPanel alloc] initWithFrame:CGRectMake(0, 0, roomVC.view.bounds.size.width, 0)];
        panel.titleView.text = @"分享面板";
        [panel showOnView:roomVC.view];
    };
    
    if ([AUILoginViewController isLogin]) {
        [self openLiveListVC:NO];
        return;
    }
    
    [self openLoginVC:NO];
}

- (void)onLogoutClicked:(AVBlockButton *)sender {
    [AUILoginViewController logout];
    [self openLoginVC:YES];
}

- (void)onLiveListClicked:(AVBlockButton *)sender {
    [self openLiveListVC:YES];
}

- (void)openLoginVC:(BOOL)animation {
    AUILoginViewController *login = [AUILoginViewController new];
    [self.navigationController pushViewController:login animated:animation];
    
    __weak typeof(self) weakSelf = self;
    login.onLoginSuccessHandler = ^(AUILoginViewController * _Nonnull sender) {
        [weakSelf openLiveListVC:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [sender removeFromParentViewController];
        });
    };
}

- (void)openLiveListVC:(BOOL)animation {
    AUILiveListViewController *roomListVC = [AUILiveListViewController new];
    __weak typeof(self) weakSelf = self;
    roomListVC.onLoginTokenExpired = ^{
        [AVAlertController showWithTitle:@"提示" message:@"登录已过期，请重新登录" needCancel:NO onCompleted:^(BOOL isCanced) {
            [weakSelf.navigationController popToRootViewControllerAnimated:NO];
            [AUILoginViewController logout];
            [weakSelf openLoginVC:YES];
        }];
    };
    // 直播列表的展示需要使用导航控制器，否则页面间无法跳转，建议AVNavigationController
    if (self.navigationController) {
        [self.navigationController pushViewController:roomListVC animated:animation];
    }
    else {
        AVNavigationController *nav =[[AVNavigationController alloc]initWithRootViewController:roomListVC];
        [self av_presentFullScreenViewController:nav animated:animation completion:nil];
    }
}

- (void)changeTheme:(AVBlockButton *)sender {
    [AVAlertController showSheet:@[@"跟随系统", @"浅色模式", @"暗黑模式"] alertTitle:@"切换主题" message:nil cancelTitle:@"取消" vc:self onCompleted:^(NSInteger idx) {
        AVTheme.currentMode = (AVThemeMode)idx;
    }];
}

- (void)onMenuClicked:(UIButton *)sender {
    [self.class openDebugVC:self];
}

#pragma - Debug

+ (BOOL)enableDebug {
#ifdef NDEBUG
    return NO;
#else
    return NSClassFromString(@"DebugViewController") != nil;
#endif
}

+ (void)loadDebugConfig {
    ((void (*)(id, SEL))objc_msgSend)((id)NSClassFromString(@"DebugViewController"), @selector(loadConfig));
}

+ (void)openDebugVC:(UIViewController *)current {
    id debugVC = ((id (*)(id, SEL))objc_msgSend)((id)NSClassFromString(@"DebugViewController"), @selector(new));
    [current.navigationController pushViewController:(UIViewController *)debugVC animated:YES];
}

@end
