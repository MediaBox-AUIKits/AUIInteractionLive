//
//  AUILoginViewController.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/1.
//

#import "AUILoginViewController.h"
#import "AUIRoomMacro.h"
#import "AUILiveRoomInputTitleView.h"

#import "AUIRoomAppServer.h"
#import "AUILiveManager.h"

#import "AUILiveManager.h"

@interface AUILoginViewController ()

@property (nonatomic, strong) AUILiveRoomInputTitleView *inputTextField;
@property (nonatomic, strong) AVBlockButton *loginButton;

@end

@implementation AUILoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.headerView removeFromSuperview];
    self.contentView.frame = self.view.bounds;
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    bg.contentMode = UIViewContentModeScaleAspectFill;
    bg.image = AVGetImage(@"ic_login_bg.jpg", @"Resource");
    [self.contentView addSubview:bg];
    
    UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(32, 118, 50, 50)];
    logo.image = AVGetCommonImage(@"ic_aliyun", @"Resource");
    [self.contentView addSubview:logo];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(32, logo.av_bottom + 11, self.contentView.av_width, 37)];
#if LIVE_TYPE==INTERACTION_LIVE
    title.text = @"阿里云互动直播";
#else
    title.text = @"阿里云企业直播";
#endif
    title.font = AVGetMediumFont(26);
    title.textColor = AUIFoundationColor(@"text_strong");
    [self.contentView addSubview:title];
    
    AUILiveRoomInputTitleView *input = [[AUILiveRoomInputTitleView alloc] initWithFrame:CGRectMake(32, title.av_bottom + 112, self.contentView.av_width - 32 * 2, 56)];
    input.placeHolder = @"请输入用户名（英文字母或数字）";
    input.titleName = @"请输入用户名（英文字母或数字）";
    [self.contentView addSubview:input];
    self.inputTextField = input;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(32, title.av_bottom + 132 + 36, input.av_width, 1)];
    line.backgroundColor = AUIFoundationColor(@"border_weak");
    [self.contentView addSubview:line];
    
    AVBlockButton *login = [[AVBlockButton alloc] initWithFrame:CGRectMake(32, line.av_bottom + 64, self.contentView.av_width - 32 * 2, 44)];
    login.layer.cornerRadius = 22;
    login.titleLabel.font = AVGetRegularFont(16);
    [login setTitle:@"进入" forState:UIControlStateNormal];
    [login setTitleColor:[UIColor av_colorWithHexString:@"#FCFCFD"] forState:UIControlStateNormal];
    [login setBackgroundColor:AUIRoomColourfulFillStrong forState:UIControlStateNormal];
    [login setBackgroundColor:AUIRoomColourfulFillDisable forState:UIControlStateDisabled];
    login.enabled = NO;
    [self.contentView addSubview:login];
    self.loginButton = login;
    
    __weak typeof(self) weakSelf = self;
    self.inputTextField.inputTextChangedBlock = ^(NSString * _Nonnull inputText) {
        weakSelf.loginButton.enabled = weakSelf.inputTextField.inputText.length > 0;
    };
    self.loginButton.clickBlock = ^(AVBlockButton * _Nonnull sender) {
        [weakSelf onLoginButtonClicked];
    };
    self.inputTextField.inputText = g_lastLoginName;
}

- (BOOL)disableInteractivePopGesture {
    return YES;
}

- (void)onLoginButtonClicked {
    [self.view endEditing:NO];
    NSString *uid = self.inputTextField.inputText;
    if (![self validateNickName:uid]) {
        [AVAlertController show:@"用户名仅支持字母、数字" vc:self];
        return;
    }
    
    [self onLogin:uid];
}

- (BOOL)validateNickName:(NSString*)nickName {
    // 限制昵称在英文字符和数字的原因是：在demo里登录的昵称与用户id保持一致，这样能在后续的直播中快速定位，实际操作中可以不用保持一致
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"];
    int i = 0;
    while (i < nickName.length) {
        NSString * string = [nickName substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}

- (void)onLogin:(NSString *)uid {
    if (uid.length > 0) {
        AVProgressHUD *hud = [AVProgressHUD ShowHUDAddedTo:self.contentView animated:YES];
        hud.iconType = AVProgressHUDIconTypeLoading;
        hud.labelText = @"登录中...";
        __weak typeof(self) weakSelf = self;
        self.contentView.userInteractionEnabled = NO;
        [AUIRoomAppServer requestWithPath:@"/api/v1/live/login" bodyDic:@{@"password":uid, @"username":uid} completionHandler:^(NSURLResponse * _Nonnull response, id  _Nonnull responseObject, NSError * _Nonnull error) {
            weakSelf.contentView.userInteractionEnabled = YES;
            [hud hideAnimated:YES];
            if (!error) {
                AUIRoomUser *me = [AUIRoomUser new];
                me.userId = uid;
                me.avatar = [AUILoginViewController defaultAvatarWithUid:uid];
                me.nickName = uid;
                me.token = [responseObject objectForKey:@"token"];
                [[AUILiveManager liveManager] setCurrentUser:me];

                g_lastLoginName = me.nickName;
                [AUILoginViewController saveCurrentUser];
                if (weakSelf.onLoginSuccessHandler) {
                    weakSelf.onLoginSuccessHandler(weakSelf);
                }
            }
            else {
                [AVAlertController show:@"登录失败" vc:weakSelf];
            }
        }];
    }
}

#pragma mark - Account

+ (void)initialize {
    [self loadCurrentUser];
}

+ (BOOL)isLogin {
    AUIRoomUser *me = [[AUILiveManager liveManager] currentUser];
    return me.userId.length > 0;
}

+ (void)logout {
    [[AUILiveManager liveManager] logout];
    [[AUILiveManager liveManager] setCurrentUser:nil];
    [self saveCurrentUser];
}

static NSString *g_lastLoginName = nil;

+ (void)loadCurrentUser {
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"my_user_id"];
    NSString *nickName = [[NSUserDefaults standardUserDefaults] objectForKey:@"my_user_name"];
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"my_user_token"];
    if (userId.length > 0) {
        AUIRoomUser *me = [AUIRoomUser new];
        me.userId = userId;
        me.avatar = [AUILoginViewController defaultAvatarWithUid:userId];
        me.nickName = nickName;
        me.token = token;
        [[AUILiveManager liveManager] setCurrentUser:me];
    }
    g_lastLoginName = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_login_name"];;
}

+ (void)saveCurrentUser {
    AUIRoomUser *me = [[AUILiveManager liveManager] currentUser];
    [[NSUserDefaults standardUserDefaults] setObject:me.userId forKey:@"my_user_id"];
    [[NSUserDefaults standardUserDefaults] setObject:me.token forKey:@"my_user_token"];
    [[NSUserDefaults standardUserDefaults] setObject:me.nickName forKey:@"my_user_name"];

    [[NSUserDefaults standardUserDefaults] setObject:g_lastLoginName forKey:@"last_login_name"];

    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)defaultAvatarList {
    static NSArray *_avatarList = nil;
    if (!_avatarList) {
        _avatarList = @[
            @"https://img.alicdn.com/imgextra/i1/O1CN01chynzk1uKkiHiQIvE_!!6000000006019-2-tps-80-80.png",
            @"https://img.alicdn.com/imgextra/i4/O1CN01kpUDlF1sEgEJMKHH8_!!6000000005735-2-tps-80-80.png",
            @"https://img.alicdn.com/imgextra/i4/O1CN01ES6H0u21ObLta9mAF_!!6000000006975-2-tps-80-80.png",
            @"https://img.alicdn.com/imgextra/i1/O1CN01KWVPkd1Q9omnAnzAL_!!6000000001934-2-tps-80-80.png",
            @"https://img.alicdn.com/imgextra/i1/O1CN01P6zzLk1muv3zymjjD_!!6000000005015-2-tps-80-80.png",
            @"https://img.alicdn.com/imgextra/i2/O1CN01ZDasLb1Ca0ogtITHO_!!6000000000096-2-tps-80-80.png",
        ];
    }
    return _avatarList;
}

+ (NSString *)defaultAvatarWithUid:(NSString *)uid {
    if (uid.length > 0) {
        unsigned short first = [uid characterAtIndex:0];
        NSArray *array = [self defaultAvatarList];
        return array[first % array.count];
    }
    return @"";
}

@end
