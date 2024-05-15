//
//  AUILiveRoomShoppingPanel.m
//  AUIInteractionLiveDemo
//
//  Created by Bingo on 2024/2/8.
//

#import "AUILiveRoomShoppingPanel.h"

@interface AUIRoomProductCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *infoLabel;

@property (nonatomic, strong) AUIRoomProductModel *productModel;

@end


@implementation AUIRoomProductCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = AVTheme.text_strong;
        _titleLabel.font = AVGetRegularFont(16);
        [self.contentView addSubview:_titleLabel];
        
        _infoLabel = [UILabel new];
        _infoLabel.textColor = UIColor.redColor;
        _infoLabel.font = AVGetRegularFont(12);
        [self.contentView addSubview:_infoLabel];
        
        _imageView = [UIImageView new];
        _imageView.backgroundColor = AVTheme.fill_weak;
        _imageView.layer.cornerRadius = 4;
        _imageView.layer.borderWidth = 1;
        _imageView.layer.borderColor = AVTheme.border_weak.CGColor;
        _imageView.layer.masksToBounds = YES;
        [self.contentView addSubview:_imageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _imageView.frame = CGRectMake(0, 0, 48, 48);
    _titleLabel.frame = CGRectMake(_imageView.av_right + 8, 6, self.contentView.av_width - 48 - 8, 20);
    _infoLabel.frame = CGRectMake(_imageView.av_right + 8, _titleLabel.av_bottom, self.contentView.av_width - 48 - 8, 16);
}

- (void)setProductModel:(AUIRoomProductModel *)productModel {
    if (_productModel != productModel) {
        _productModel = productModel;
        _titleLabel.text = _productModel.title;
        _infoLabel.text = _productModel.info;
    }
}

@end

@interface AUILiveRoomShoppingPanel ()

@property (nonatomic, copy) NSArray<AUIRoomProductModel *> *productList;

@end

@implementation AUILiveRoomShoppingPanel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleView.text = @"商品列表";
        [self.collectionView registerClass:AUIRoomProductCell.class forCellWithReuseIdentifier:@"cell"];
        
        AUIRoomProductModel *product = [AUIRoomProductModel new];
        product.productId = @"001";
        product.title = @"xxx牌子按摩器";
        product.info = @"全场9.9元";
        product.coverUrl = @"https://xxx.com";
        product.sellUrl = @"https://yyy.com";
        
        AUIRoomProductModel *product2 = [AUIRoomProductModel new];
        product2.productId = @"002";
        product2.title = @"xxx牌子洗脚盆";
        product2.info = @"全场9.9元";
        product2.coverUrl = @"https://xxx1.com";
        product2.sellUrl = @"https://yyy1.com";
        
        self.productList = @[
            product, product2
        ];
    }
    return self;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.productList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AUIRoomProductCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.productModel = [self.productList objectAtIndex:indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.collectionView.av_width - 24, 48);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.onSelectProductBlock) {
        self.onSelectProductBlock(self, [self.productList objectAtIndex:indexPath.row]);
    }
}

@end
