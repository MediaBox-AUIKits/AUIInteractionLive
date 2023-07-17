//
//  AUILiveRoomMemberButton.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import "AUILiveRoomMemberButton.h"
#import "AUIFoundation.h"
#import "AUIRoomMacro.h"

@interface AUILiveRoomMemberButton ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation AUILiveRoomMemberButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor av_colorWithHexString:@"#1C1D22" alpha:0.4];
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(4, (self.av_height - 18) / 2.0, 18, 18)];
        iconView.image = AUIRoomGetCommonImage(@"ic_living_member");
        [self addSubview:iconView];
        self.iconView = iconView;
        
        UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconView.av_right + 5, 0, 10, self.av_height)];
        countLabel.font = AVGetRegularFont(12);
        countLabel.textColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
        countLabel.text = @"0";
        [self addSubview:countLabel];
        self.countLabel = countLabel;
    }
    return self;
}

- (void)updateMemberCount:(NSUInteger)count {
    NSString *text = [NSString stringWithFormat:@"%tu", count];;
    if (count > 10000) {
        text = [NSString stringWithFormat:@"%.1f万", count / 10000.0];
    }
    self.countLabel.text = text;
    self.countLabel.av_width = [self.countLabel sizeThatFits:CGSizeZero].width;

    CGFloat right = self.av_right;
    CGFloat width = self.countLabel.av_right + 4;
    self.av_width = width;
    self.av_right = right;
}

@end
