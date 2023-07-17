//
//  AUILIveRoomNoticePanel.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/10.
//

#import "AUILIveRoomNoticePanel.h"
#import "AUILiveRoomInputTitleView.h"

@interface AUILIveRoomNoticePanel ()

@property (nonatomic, strong) AUILiveRoomInputTitleView *inputLiveNotice;


@end

@implementation AUILIveRoomNoticePanel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.titleView.text = @"公告";
        
        self.showBackButton = YES;
        [self.backButton setTitle:@"取消" forState:UIControlStateNormal];
        [self.backButton setImage:nil forState:UIControlStateNormal];
        [self.backButton sizeToFit];
        self.backButton.av_height = 26;
        
        self.showMenuButton = YES;
        [self.menuButton setTitle:@"确定" forState:UIControlStateNormal];
        [self.menuButton setImage:nil forState:UIControlStateNormal];
        [self.menuButton sizeToFit];
        self.menuButton.av_height = 26;
        self.menuButton.av_right = self.headerView.av_width - 18;
        
        AUILiveRoomInputTitleView *inputLiveNotice = [[AUILiveRoomInputTitleView alloc] initWithFrame:CGRectMake(16, 16, self.contentView.av_width - 16 * 2, 80)];
        inputLiveNotice.placeHolder = @"输入直播间公告";
        inputLiveNotice.titleName = @"";
        [self.contentView addSubview:inputLiveNotice];
        self.inputLiveNotice = inputLiveNotice;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)setInput:(NSString *)input {
    self.inputLiveNotice.inputText = input;
}

- (NSString *)input {
    return self.inputLiveNotice.inputText;
}

- (void)onMenuBtnClicked:(UIButton *)sender {
    [self endEditing:NO];
    if (self.onInputCompletedBlock) {
        self.onInputCompletedBlock(self, self.input);
    }
    else {
        [self hide];
    }
}

- (void)keyBoardWillShow:(NSNotification *)notification {
    if (!self.inputLiveNotice.inputTextView.isFirstResponder) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notification.userInfo];
    CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    double duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
      
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationDelay:0];
    self.transform = CGAffineTransformMakeTranslation(0, -keyboardEndFrame.size.height);
    [UIView commitAnimations];
}

- (void)keyBoardWillHide:(NSNotification *)note {
    self.transform = CGAffineTransformIdentity;
}

+ (CGFloat)panelHeight {
    return 194;
}

@end
