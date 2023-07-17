//
//  AUILiveRoomCommentModel.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import "AUILiveRoomCommentModel.h"
#import "AUIFoundation.h"

@interface AUILiveRoomCommentModel()

@end

@implementation AUILiveRoomCommentModel

- (instancetype) init {
    self = [super init];
    if (self) {
        _cellInsets = UIEdgeInsetsMake(2, 0, 2, 0);

        _sentContentColor = [UIColor whiteColor];
        _sentContentFontSize = 14;
        _sentContentInsets = UIEdgeInsetsMake(2, 8, 2, 8);
    }
    return self;
}

+ (UIColor *)nickColorWithUid:(NSString *)uid {
    static NSArray *_array = nil;
    if (!_array) {
        _array = @[
            [UIColor av_colorWithHexString:@"#FFAB91"],
            [UIColor av_colorWithHexString:@"#FED998"],
            [UIColor av_colorWithHexString:@"#F6A0B5"],
            [UIColor av_colorWithHexString:@"#CBED8E"],
            [UIColor av_colorWithHexString:@"#95D8F8"],
        ];
    }
    
    if (uid.length > 0) {
        unsigned short first = [uid characterAtIndex:0];
        return _array[first % _array.count];
    }
    
    return nil;
}

+ (UIColor *)anchorFlagForegroundColor {
    return [UIColor av_colorWithLightColor:[UIColor av_colorWithHexString:@"#FC8800"] darkColor:[UIColor av_colorWithHexString:@"#FC8800"]];
}

+ (UIColor *)anchorFlagBackgroundColor {
    return [UIColor av_colorWithLightColor:[UIColor av_colorWithHexString:@"#FFF8EA"] darkColor:[UIColor av_colorWithHexString:@"#FEEECC"]];
}

+ (UIColor *)meFlagForegroundColor {
    return [UIColor av_colorWithLightColor:[UIColor av_colorWithHexString:@"#FF5722"] darkColor:[UIColor av_colorWithHexString:@"#FF5722"]];
}

+ (UIColor *)meFlagBackgroundColor {
    return [UIColor av_colorWithLightColor:[UIColor av_colorWithHexString:@"#FBE9E7"] darkColor:[UIColor av_colorWithHexString:@"#FFCCBC"]];
}

+ (UIImage *)flagImage:(NSString *)title textColor:(UIColor *)textColor bgColor:(UIColor *)bgColor {
    UILabel *label = [UILabel new];
    label.text = title;
    label.font = AVGetRegularFont(12.0);
    label.textColor = textColor;
    label.backgroundColor = bgColor;
    label.clipsToBounds = YES;
    label.layer.cornerRadius = 2;
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    label.av_width = label.av_width + 8;
    label.av_height = 18;
    
    UIGraphicsBeginImageContext(label.bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [label.layer renderInContext:ctx];
    UIImage* tImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tImage;
}

+ (UIImage *)anchorFlagImage {
    static UIImage *_image = nil;
    if (!_image) {
        _image = [self flagImage:@"主播" textColor:[self anchorFlagForegroundColor] bgColor:[self anchorFlagBackgroundColor]];
    }
    return _image;
}

+ (UIImage *)meFlagImage {
    static UIImage *_image = nil;
    if (!_image) {
        _image = [self flagImage:@"自己" textColor:[self meFlagForegroundColor] bgColor:[self meFlagBackgroundColor]];
    }
    return _image;
}

- (NSAttributedString *)renderContent {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] init];
    
    if (self.useFlag) {
        if (self.isAnchor) {
            
            NSTextAttachment *attach = [[NSTextAttachment alloc] init];
            attach.image = [self.class anchorFlagImage];
            attach.bounds = CGRectMake(0, -4, attach.image.size.width, attach.image.size.height);
            if (@available(iOS 15.0, *)) {
                attach.lineLayoutPadding = 2;
            }
            [attributeString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
        }
        if (self.isMe) {
            
            NSTextAttachment *attach = [[NSTextAttachment alloc] init];
            attach.image = [self.class meFlagImage];
            attach.bounds = CGRectMake(0, -4, attach.image.size.width, attach.image.size.height);
            if (@available(iOS 15.0, *)) {
                attach.lineLayoutPadding = 2;
            }
            [attributeString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
        }
    }
    
    NSString *nickName = self.senderNick ?: self.senderID;
    if (nickName.length > 0) {
        UIColor *nickColor = self.senderNickColor;
        if (!nickColor) {
            nickColor = [self.class nickColorWithUid:self.senderID ?: @"2"];
        }
        [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:[nickName stringByAppendingString:@"："] attributes:@{NSForegroundColorAttributeName:nickColor, NSFontAttributeName:AVGetRegularFont(self.sentContentFontSize)}]];
    }
    if (self.sentContent.length > 0) {
        UIColor *sentContentColor = self.sentContentColor;
        if (!sentContentColor) {
            sentContentColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
        }
        [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:self.sentContent attributes:@{NSForegroundColorAttributeName:sentContentColor, NSFontAttributeName:AVGetRegularFont(self.sentContentFontSize)}]];
    }
    return attributeString;
}

@end
