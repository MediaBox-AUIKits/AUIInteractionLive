//
//  AVLoginViewController.m
//  AUIFoundation
//
//  Created by Bingo on 2024/2/21.
//

#import "AVLoginViewController.h"
#import "AUIFoundationMacro.h"
#import "UIView+AVHelper.h"
#import "AVBlockButton.h"
#import "AVLoginManager.h"
#import "AVAlertController.h"
#import "AVProgressHUD.h"

@implementation AVLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hiddenMenuButton = YES;
    self.titleView.text = @"登录";
    
    AVBlockButton *btn = [[AVBlockButton alloc] initWithFrame:CGRectMake(20.0, self.contentView.av_height - UIView.av_safeBottom - 44.0, self.contentView.av_width - 40.0, 44.0)];
    btn.layer.cornerRadius = 22.0;
    btn.layer.masksToBounds = YES;
    btn.enabled = NO;
    [btn setTitle:@"登录" forState:UIControlStateNormal];
    [btn setBackgroundColor:AVTheme.colourful_fill_strong forState:UIControlStateNormal];
    [btn setBackgroundColor:AVTheme.colourful_fill_disabled forState:UIControlStateDisabled];
    [btn setTitleColor:AVTheme.text_strong forState:UIControlStateNormal];
    btn.titleLabel.font = [AVTheme regularFont:16];
    
    __weak typeof(self) weakSelf = self;
    btn.clickBlock = ^(AVBlockButton * _Nonnull sender) {
        [weakSelf tryLogin:weakSelf.inputIdView.inputText];
    };
    
    _inputIdView = [[AVInputView alloc] initWithFrame:CGRectMake(16.0, 30.0, self.contentView.av_width - 32.0, 70.0)];
    _inputIdView.titleLabel.text = @"我的用户ID";
    _inputIdView.placeLabel.text = @"请输入字母、数字、下划线";
    _inputIdView.inputTextChanged = ^(AVInputView * _Nonnull inputView) {
        btn.enabled = inputView.inputText.length > 0;
    };
    
    [self.contentView addSubview:_inputIdView];
    [self.contentView addSubview:btn];
    
    self.inputIdView.inputText = AVLoginManager.shared.lastLoginUId ?: @"";
}

- (void)tryLogin:(NSString *)uid {
    if (![AVLoginManager.shared validateUid:uid]) {
        [AVAlertController show:@"用户ID仅支持字母、数字和下划线" vc: self];
        return;
    }
    
    AVProgressHUD *hud = [AVProgressHUD ShowHUDAddedTo:self.view animated:YES];
    hud.backgroundColor = AVTheme.tsp_fill_medium;
    hud.iconType = AVProgressHUDIconTypeLoading;
    hud.labelText = @"登录中...";
    
    [AVLoginManager.shared login:uid completed:^(NSError * _Nullable error) {
        [hud hideAnimated:NO];
        if (error) {
            [AVAlertController show:@"登录失败" vc: self];
        }
        else {
            if (self.loginSuccessBlock) {
                self.loginSuccessBlock(self);
            }
        }
    }];
}

@end
