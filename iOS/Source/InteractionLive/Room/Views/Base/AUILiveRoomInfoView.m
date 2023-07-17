//
//  AUILiveRoomInfoView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import "AUILiveRoomInfoView.h"
#import "AUIRoomMacro.h"

#import "AUILiveRoomAvatarView.h"

#import "AUIRoomAccount.h"

@interface AUILiveRoomInfoView ()

@property (strong, nonatomic) AUILiveRoomAvatarView *avatarView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *infoLabel;
@property (strong, nonatomic) AVBlockButton *followButton;

@end

@implementation AUILiveRoomInfoView

- (instancetype)initWithFrame:(CGRect)frame withModel:(AUIRoomLiveInfoModel *)model {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor av_colorWithHexString:@"#1C1D22" alpha:0.4];
        
        AUILiveRoomAvatarView *avatarView = [[AUILiveRoomAvatarView alloc] initWithFrame:CGRectMake(4, 4, 32, 32)];
        avatarView.layer.cornerRadius = 16;
        avatarView.layer.masksToBounds = YES;
        [self addSubview:avatarView];
        self.avatarView = avatarView;
        
        AUIRoomUser *user = [AUIRoomUser new];
        user.userId = model.anchor_id;
        user.nickName = model.anchor_nickName;
        user.avatar = model.anchor_avatar;
        self.avatarView.user = user;
        
        if (![model.anchor_id isEqualToString:AUIRoomAccount.me.userId]) {
            AVBlockButton *followButton = [[AVBlockButton alloc] initWithFrame:CGRectMake(self.av_width - 50 - 8, (self.av_height - 22) / 2.0, 50, 22)];
            followButton.layer.cornerRadius = 11;
            followButton.titleLabel.font = AVGetRegularFont(12);
            [followButton setTitle:@"+关注" forState:UIControlStateNormal];
            [followButton setTitle:@"取消" forState:UIControlStateSelected];
            [followButton setTitleColor:[UIColor av_colorWithHexString:@"#FCFCFD"] forState:UIControlStateNormal];
            [followButton setTitleColor:[UIColor av_colorWithHexString:@"#FCFCFD"] forState:UIControlStateSelected];
            [followButton setBackgroundColor:AUIRoomColourfulFillStrong forState:UIControlStateNormal];
            [followButton setBackgroundColor:AUIRoomColourfulFillDisable forState:UIControlStateSelected];
            
            [self addSubview:followButton];
            self.followButton = followButton;
            
            __weak typeof(self) weakSelf = self;
            self.followButton.clickBlock = ^(AVBlockButton * _Nonnull sender) {
                if (weakSelf.onFollowButtonClickedBlock) {
                    weakSelf.onFollowButtonClickedBlock(weakSelf, weakSelf.followButton);
                }
            };
        }

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(avatarView.av_right + 4, avatarView.av_top, (self.followButton ? (self.followButton.av_left - 8) : (self.av_width - 12)) - avatarView.av_right - 4, 20)];
        title.text = model.title;
        title.textColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
        title.font = AVGetRegularFont(14);
        [self addSubview:title];
        self.titleLabel = title;
        
        UILabel *anchor = [[UILabel alloc] initWithFrame:CGRectMake(avatarView.av_right + 4, avatarView.av_bottom - 14, title.av_width, 14)];
        anchor.text = model.anchor_nickName;
        anchor.textColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
        anchor.font = AVGetRegularFont(10);
        [self addSubview:anchor];
    }
    return self;
}

@end
