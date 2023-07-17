//
//  AUILiveRoomAvatarView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/8.
//

#import "AUILiveRoomAvatarView.h"
#import "AUIRoomMacro.h"
#import <SDWebImage/SDWebImage.h>

@interface AUILiveRoomAvatarView ()

@property (nonatomic, strong) UIImageView *iconView;

@end

@implementation AUILiveRoomAvatarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.iconView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.iconView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.iconView.frame = self.bounds;
}

- (void)setUser:(AUIRoomUser *)user {
    _user = user;
    
    if ([user.avatar hasPrefix:@"http"]) {
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:AUIRoomGetImage(@"ic_avatar_default")];
        
    }
    else if (user.avatar.length > 0) {
        self.iconView.image = [UIImage imageNamed:user.avatar];
    }
    else {
        self.iconView.image = AUIRoomGetImage(@"ic_avatar_default");
    }
}

@end
