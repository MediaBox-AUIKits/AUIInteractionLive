//
//  AUILiveRoomMorePanel.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import "AUILiveRoomMorePanel.h"
#import "AUIFoundation.h"
#import "AUIRoomMacro.h"


@interface AUILiveRoomMorePanelButton : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *selectedTitle;
@property (nonatomic, copy) NSString *iconName;
@property (nonatomic, copy) NSString *selectedIconName;

@property (nonatomic, assign) BOOL selected;

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, copy) void (^onClickedAction)(AUILiveRoomMorePanelButton *sender, BOOL selected);

- (void)applyAppreance;

@end

@implementation AUILiveRoomMorePanelButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 8, 40, 40)];
        icon.backgroundColor = AUIFoundationColor(@"fill_weak");
        icon.contentMode = UIViewContentModeCenter;
        icon.layer.cornerRadius = 20;
        icon.layer.masksToBounds = YES;
        icon.av_centerX = self.av_width / 2;
        [self addSubview:icon];
        self.iconView = icon;
        
        UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(0, icon.av_bottom + 8, self.av_width, 18)];
        text.font = AVGetRegularFont(12.0);
        text.textColor = AUIFoundationColor(@"text_weak");
        text.textAlignment = NSTextAlignmentCenter;
        [self addSubview:text];
        self.textLabel = text;
        
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)]];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    [self applyAppreance];
}

- (void)applyAppreance {
    if (self.selected) {
        self.textLabel.text = self.selectedTitle ?: self.title;
        self.iconView.image = AUIRoomGetImage((self.selectedIconName ?: self.iconName));
    }
    else {
        self.textLabel.text = self.title;
        self.iconView.image = AUIRoomGetImage(self.iconName);
    }
}

- (void)onTap:(UITapGestureRecognizer *)recognizer {
    if (self.onClickedAction) {
        self.onClickedAction(self, self.selected);
    }
}

@end

@interface AUILiveRoomMorePanel()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, AUILiveRoomMorePanelButton *> *buttonDict;

@end

@implementation AUILiveRoomMorePanel

- (void)dealloc {
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.headerView.hidden = YES;
        self.contentView.frame = self.bounds;
        
        self.buttonDict = [NSMutableDictionary dictionary];
        
        __weak typeof(self) weakSelf = self;
        CGFloat height = 84;
        CGFloat width = (frame.size.width - 16 * 2) / 4.0;
        
        AUILiveRoomMorePanelButton *muteBtn = [[AUILiveRoomMorePanelButton alloc] initWithFrame:CGRectMake(self.buttonDict.count % 4 * width + 16, self.buttonDict.count / 4 * (height + 12) + 8, width, height)];
        muteBtn.title = @"静音";
        muteBtn.selectedTitle = @"取消静音";
        muteBtn.iconName = @"ic_living_more_mute";
        muteBtn.selectedIconName = @"ic_living_more_mute_selected";
        muteBtn.selected = NO;
        muteBtn.onClickedAction = ^(AUILiveRoomMorePanelButton *sender, BOOL selected) {
            if (weakSelf.onClickedAction) {
                sender.selected = weakSelf.onClickedAction(self, AUILiveRoomMorePanelActionTypeMute, selected);
            }
        };
        [self.contentView addSubview:muteBtn];
        [self.buttonDict setObject:muteBtn forKey:@(AUILiveRoomMorePanelActionTypeMute)];

        AUILiveRoomMorePanelButton *audioOnlyBtn = [[AUILiveRoomMorePanelButton alloc] initWithFrame:CGRectMake(self.buttonDict.count % 4 * width + 16, self.buttonDict.count / 4 * (height + 12) + 8, width, height)];
        audioOnlyBtn.title = @"关闭摄像头";
        audioOnlyBtn.selectedTitle = @"开启摄像头";
        audioOnlyBtn.iconName = @"ic_living_more_audioonly";
        audioOnlyBtn.selectedIconName = @"ic_living_more_audioonly_selected";
        audioOnlyBtn.selected = NO;
        audioOnlyBtn.onClickedAction = ^(AUILiveRoomMorePanelButton *sender, BOOL selected) {
            if (weakSelf.onClickedAction) {
                sender.selected = weakSelf.onClickedAction(self, AUILiveRoomMorePanelActionTypeAudioOnly, selected);
            }
        };
        [self.contentView addSubview:audioOnlyBtn];
        [self.buttonDict setObject:audioOnlyBtn forKey:@(AUILiveRoomMorePanelActionTypeAudioOnly)];
        
        AUILiveRoomMorePanelButton *cameraButton = [[AUILiveRoomMorePanelButton alloc] initWithFrame:CGRectMake(self.buttonDict.count % 4 * width + 16, self.buttonDict.count / 4 * (height + 12) + 8, width, height)];
        cameraButton.title = @"翻转镜头";
        cameraButton.iconName = @"ic_living_more_camera";
        cameraButton.selected = NO;
        cameraButton.onClickedAction = ^(AUILiveRoomMorePanelButton *sender, BOOL selected) {
            if (weakSelf.onClickedAction) {
                sender.selected = weakSelf.onClickedAction(self, AUILiveRoomMorePanelActionTypeCamera, selected);
            }
        };
        [self.contentView addSubview:cameraButton];
        [self.buttonDict setObject:cameraButton forKey:@(AUILiveRoomMorePanelActionTypeCamera)];
        
        AUILiveRoomMorePanelButton *mirrorButton = [[AUILiveRoomMorePanelButton alloc] initWithFrame:CGRectMake(self.buttonDict.count % 4 * width + 16, self.buttonDict.count / 4 * (height + 12) + 8, width, height)];
        mirrorButton.title = @"开启镜像";
        mirrorButton.selectedTitle = @"关闭镜像";
        mirrorButton.iconName = @"ic_living_more_mirror";
        mirrorButton.selectedIconName = @"ic_living_more_mirror_selected";
        mirrorButton.selected = NO;
        mirrorButton.onClickedAction = ^(AUILiveRoomMorePanelButton *sender, BOOL selected) {
            if (weakSelf.onClickedAction) {
                sender.selected = weakSelf.onClickedAction(self, AUILiveRoomMorePanelActionTypeMirror, selected);
            }
        };
        [self.contentView addSubview:mirrorButton];
        [self.buttonDict setObject:mirrorButton forKey:@(AUILiveRoomMorePanelActionTypeMirror)];
        
        AUILiveRoomMorePanelButton *banAllCommentsButton = [[AUILiveRoomMorePanelButton alloc] initWithFrame:CGRectMake(self.buttonDict.count % 4 * width + 16, self.buttonDict.count / 4 * (height + 12) + 8, width, height)];
        banAllCommentsButton.title = @"全员禁言";
        banAllCommentsButton.selectedTitle = @"取消禁言";
        banAllCommentsButton.iconName = @"ic_living_more_ban";
        banAllCommentsButton.selectedIconName = @"ic_living_more_ban_selected";
        banAllCommentsButton.selected = NO;
        banAllCommentsButton.onClickedAction = ^(AUILiveRoomMorePanelButton *sender, BOOL selected) {
            if (weakSelf.onClickedAction) {
                sender.selected = weakSelf.onClickedAction(self, AUILiveRoomMorePanelActionTypeBan, selected);
            }
        };
        [self.contentView addSubview:banAllCommentsButton];
        [self.buttonDict setObject:banAllCommentsButton forKey:@(AUILiveRoomMorePanelActionTypeBan)];
        
    }
    return self;
}

- (void)updateClickedSelected:(AUILiveRoomMorePanelActionType)type selected:(BOOL)selected {
    AUILiveRoomMorePanelButton *btn = [self.buttonDict objectForKey:@(type)];
    if (!btn) {
        return;
    }
    btn.selected = selected;
}

+ (CGFloat)panelHeight {
    return 238;
}

@end
