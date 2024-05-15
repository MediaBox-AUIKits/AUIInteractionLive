//
//  AUIRoomGiftPanel.m
//  AUIInteractionLiveDemo
//
//  Created by Bingo on 2024/2/28.
//

#import "AUIRoomGiftPanel.h"
#import "AUIRoomGiftManager.h"
#import <SDWebImage/SDWebImage.h>

@interface AUIRoomGiftCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) AUIRoomGiftModel *giftModel;

@property (nonatomic, assign) BOOL isDownload;

@end


@implementation AUIRoomGiftCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.contentView.backgroundColor = AVTheme.fill_weak;
        self.contentView.layer.cornerRadius = 8;
        self.contentView.layer.borderWidth = 1;
        self.contentView.layer.borderColor = AVTheme.border_weak.CGColor;
        self.contentView.layer.masksToBounds = YES;
        
        _nameLabel = [UILabel new];
        _nameLabel.textColor = AVTheme.text_strong;
        _nameLabel.font = AVGetRegularFont(12);
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_nameLabel];
        
        _imageView = [UIImageView new];
        [self.contentView addSubview:_imageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _imageView.frame = CGRectMake(0, 0, self.contentView.av_width, self.contentView.av_width);
    _nameLabel.frame = CGRectMake(0, self.contentView.av_height - 18, self.contentView.av_width, 18);
}

- (void)setGiftModel:(AUIRoomGiftModel *)giftModel {
    if (_giftModel != giftModel) {
        _giftModel = giftModel;
        _nameLabel.text = _giftModel.name;
        [_imageView sd_setImageWithURL:[NSURL URLWithString:_giftModel.imageUrl]];
    }
}

@end


@implementation AUIRoomGiftPanel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleView.text = @"礼物";
        
        [self.collectionView registerClass:AUIRoomGiftCell.class forCellWithReuseIdentifier:@"cell"];
    }
    return self;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [AUIRoomGiftManager.sharedInstance giftList].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AUIRoomGiftCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.giftModel = [[AUIRoomGiftManager.sharedInstance giftList] objectAtIndex:indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(76, 96);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AUIRoomGiftModel *gift = [[AUIRoomGiftManager.sharedInstance giftList] objectAtIndex:indexPath.row];
    if (gift.filePath.length == 0) {
        [AUIRoomGiftManager.sharedInstance downloadGift:gift];
    }
    else {
        if (self.onSendGiftBlock) {
            self.onSendGiftBlock(self, gift);
        }
    }
}

@end
