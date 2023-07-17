//
//  AUILiveRoomInputTitleView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/7.
//

#import "AUILiveRoomInputTitleView.h"
#import "AUIFoundation.h"
#import "AUIRoomMacro.h"

@interface AUILiveRoomInputTitleView () <UITextViewDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *placeLabel;
@property (nonatomic, strong) UITextView *inputTextView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *clearButton;

@end

@implementation AUILiveRoomInputTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.av_height - 1, self.av_width, 1)];
        line.backgroundColor = AUIFoundationColor(@"border_weak");
        [self addSubview:line];
        self.lineView = line;
        
        UITextView *inputTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.av_width, 36)];
        inputTextView.backgroundColor = UIColor.clearColor;
        inputTextView.textColor = AUIFoundationColor(@"text_strong");
        inputTextView.font = AVGetRegularFont(16);
        inputTextView.keyboardType = UIKeyboardTypeDefault;
        inputTextView.returnKeyType = UIReturnKeyDone;
        inputTextView.showsVerticalScrollIndicator = NO;
        inputTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 24);
        inputTextView.textContainer.lineFragmentPadding = 0;
        inputTextView.delegate = self;
        [self addSubview:inputTextView];
        self.inputTextView = inputTextView;
        self.inputTextView.av_bottom = self.lineView.av_bottom;
        
        UILabel *placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.av_width - 24, 24)];
        placeLabel.textColor = AUIFoundationColor(@"text_weak");
        placeLabel.font = AVGetRegularFont(16);
        [self addSubview:placeLabel];
        self.placeLabel = placeLabel;
        self.placeLabel.av_top = self.inputTextView.av_top;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.av_width, 18)];
        titleLabel.textColor = AUIFoundationColor(@"text_weak");
        titleLabel.font = AVGetRegularFont(12);
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        self.titleLabel.hidden = YES;
        self.titleLabel.av_bottom = self.inputTextView.av_top - 2;
        
        UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(self.inputTextView.av_right - 24, 0, 24, 24)];
        [clearButton setImage:AUIRoomGetImage(@"ic_input_clear") forState:UIControlStateNormal];
        [clearButton setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
        [clearButton addTarget:self action:@selector(onClearInput) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clearButton];
        self.clearButton = clearButton;
        self.clearButton.hidden = YES;
        self.clearButton.av_top = self.inputTextView.av_top;

        [self updateInputLayout];
    }
    return self;
}

- (void)updateInputLayout {
    CGSize size = [self.inputTextView sizeThatFits:CGSizeMake(self.av_width, 0)];
    CGFloat height = size.height;
    if (height < 36) {
        self.inputTextView.av_height = 36;
    }
    else {
        self.inputTextView.av_height = 24 * 2;
    }
    self.inputTextView.av_bottom = self.lineView.av_bottom;
    self.placeLabel.av_top = self.inputTextView.av_top;
    self.titleLabel.av_bottom = self.inputTextView.av_top - 2;
}

- (void)setTitleName:(NSString *)titleName {
    _titleName = titleName;
    self.titleLabel.text = titleName;
}

- (void)setInputText:(NSString *)inputText {
    self.inputTextView.text = inputText;
    [self textViewDidChange:self.inputTextView];
}

- (NSString *)inputText {
    return self.inputTextView.text;
}

- (void)setPlaceHolder:(NSString *)placeHolder {
    _placeHolder = placeHolder;
    self.placeLabel.text = _placeHolder;
}

- (void)onClearInput {
    self.inputText = @"";
}

- (void)textViewDidChange:(UITextView *)textView {
    [self updateInputLayout];
    self.clearButton.hidden = self.inputTextView.text.length == 0;
    self.titleLabel.hidden = self.inputTextView.text.length == 0;
    self.placeLabel.hidden = self.inputTextView.text.length > 0;
    if (self.inputTextChangedBlock) {
        self.inputTextChangedBlock(self.inputTextView.text);
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self endEditing:NO];
        return NO;
    }
    return YES;
}

@end
