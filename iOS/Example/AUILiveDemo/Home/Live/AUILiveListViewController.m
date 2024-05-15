//
//  AUILiveListViewController.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/8/31.
//

#import "AUILiveListViewController.h"
#import "AUIRoomMacro.h"
#import "AUIRoomAppServer.h"
#import "AUIRoomUser.h"
#import "AUIRoomMessageService.h"

#import <MJRefresh/MJRefresh.h>
#import <SDWebImage/SDWebImage.h>

#import "AUILiveManager.h"

#if LIVE_TYPE==INTERACTION_LIVE
#import "AUILiveCreateViewController.h"
#endif


@interface AUIRoomItem : NSObject

@property (nonatomic, strong) AUIRoomLiveInfoModel *roomModel;

@end

@implementation AUIRoomItem

- (instancetype)initWithRoomModel:(AUIRoomLiveInfoModel *)roomModel {
    self = [super init];
    if (self) {
        _roomModel = roomModel;
    }
    return self;
}

- (NSString *)cover {
    return _roomModel.cover;
}

- (BOOL)living {
    return _roomModel.status != AUIRoomLiveStatusFinished;
}

- (NSString *)title {
    return _roomModel.title;
}

- (NSString *)info {
    return _roomModel.anchor_nickName ?: _roomModel.anchor_id;
}

- (NSString *)metrics {
    if (_roomModel.metrics.pv > 10000) {
        return [NSString stringWithFormat:@"%.1f万观看", _roomModel.metrics.pv / 10000.0];
    }
    return [NSString stringWithFormat:@"%zd观看", _roomModel.metrics.pv];
}

@end

@interface AUIRoomItemCell : UICollectionViewCell

@property (nonatomic, strong, readonly) AUIRoomItem *item;

@property (nonatomic, strong, readonly) UIImageView *bgImageView;

@property (nonatomic, strong, readonly) CAGradientLayer *titleBgLayer;

@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *infoLabel;

@property (nonatomic, strong, readonly) UIView *metricsBgView;
@property (nonatomic, strong, readonly) UIImageView *stateView;
@property (nonatomic, strong, readonly) UILabel *metricsLabel;

@end

@implementation AUIRoomItemCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 4;

        _bgImageView = [UIImageView new];
        [self.contentView addSubview:_bgImageView];
        
        _titleBgLayer = [CAGradientLayer layer];
        _titleBgLayer.colors = @[(id)[UIColor av_colorWithHexString:@"#141416" alpha:0.0].CGColor,(id)[UIColor av_colorWithHexString:@"#141416" alpha:0.7].CGColor];
        _titleBgLayer.startPoint = CGPointMake(0.5, 0);
        _titleBgLayer.endPoint = CGPointMake(0.5, 1);
        [self.contentView.layer addSublayer:_titleBgLayer];

        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
        _titleLabel.font = AVGetMediumFont(14);
        _titleLabel.numberOfLines = 1;
        [self.contentView addSubview:_titleLabel];
        
        _infoLabel = [UILabel new];
        _infoLabel.textColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
        _infoLabel.font = AVGetRegularFont(12);
        _infoLabel.numberOfLines = 1;
        [self.contentView addSubview:_infoLabel];
        
        _metricsBgView = [UIView new];
        _metricsBgView.backgroundColor = [UIColor av_colorWithHexString:@"#000000" alpha:0.4];
        [self.contentView addSubview:_metricsBgView];
        
        _metricsLabel = [UILabel new];
        _metricsLabel.textAlignment = NSTextAlignmentCenter;
        _metricsLabel.textColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
        _metricsLabel.font = AVGetRegularFont(12);
        _metricsLabel.numberOfLines = 1;
        [self.contentView addSubview:_metricsLabel];
        
        _stateView = [UIImageView new];
        [self.contentView addSubview:_stateView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.bgImageView.frame = self.contentView.bounds;
    
    self.stateView.frame = CGRectMake(0, 0, 20, 20);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.stateView.bounds byRoundingCorners:UIRectCornerBottomRight cornerRadii:CGSizeMake(4, 4)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.stateView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.stateView.layer.mask = maskLayer;
    
    [self.metricsLabel sizeToFit];
    self.metricsLabel.frame = CGRectMake(self.stateView.av_right, 0, self.metricsLabel.av_width + 8, 20);
    
    self.metricsBgView.frame = CGRectMake(0, 0, self.metricsLabel.av_right, 20);
    UIBezierPath *maskPath2 = [UIBezierPath bezierPathWithRoundedRect:self.metricsBgView.bounds byRoundingCorners:UIRectCornerBottomRight cornerRadii:CGSizeMake(4, 4)];
    CAShapeLayer *maskLayer2 = [[CAShapeLayer alloc] init];
    maskLayer2.frame = self.metricsBgView.bounds;
    maskLayer2.path = maskPath2.CGPath;
    self.metricsBgView.layer.mask = maskLayer2;
    
    self.infoLabel.frame = CGRectMake(8, self.contentView.av_height - 4 - 18, self.contentView.av_width - 8 - 8, 18);
    self.titleLabel.frame = CGRectMake(8, self.infoLabel.av_top - 2 - 20, self.contentView.av_width - 8 - 8, 20);
    self.titleBgLayer.frame = CGRectMake(0, self.contentView.av_height - 50, self.contentView.av_width, 50);
}

- (void)updateItem:(AUIRoomItem *)item {
    _item = item;
    if ([item cover].length > 0) {
        [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:[item cover]] placeholderImage:AUIRoomGetCommonImage(@"ic_room_cover")];
    }
    else {
        self.bgImageView.image = AUIRoomGetCommonImage(@"ic_room_cover");
    }

    self.titleLabel.text = [item title];
    self.infoLabel.text = [item info];
    self.stateView.image = [item living] ? AVGetCommonImage(@"ic_list_living", @"Resource") : AVGetCommonImage(@"ic_list_finish", @"Resource");
    self.metricsLabel.text = [item metrics];
}

@end



@interface AUILiveListViewController ()

@property (nonatomic, strong) NSMutableArray<AUIRoomItem *> *roomList;
@property (nonatomic, assign) NSInteger lastPageNumber;

@property (nonatomic, strong) UIView *emptyView;

@property (nonatomic, copy) NSString *lastLiveId;

@end

@implementation AUILiveListViewController

- (void)dealloc {
    NSLog(@"dealloc:AUIInteractionLiveListViewController");
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _roomList = [NSMutableArray array];
        _lastPageNumber = 1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AUILiveListViewController loadLastLiveData];
    
    self.titleView.text = @"直播间列表";
    self.titleView.font = AVGetRegularFont(16);
    
    [self.menuButton setTitle:@"进入上场直播" forState:UIControlStateNormal];
    self.menuButton.titleLabel.font = AVGetRegularFont(14);
    [self.menuButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
    [self.menuButton setImage:nil forState:UIControlStateNormal];
    [self.menuButton sizeToFit];
    self.menuButton.av_height = 26;
    self.menuButton.av_right = self.headerView.av_width - 16;
    
#if LIVE_TYPE==INTERACTION_LIVE
    UIButton *add = [[UIButton alloc] initWithFrame:CGRectMake(72, self.contentView.av_height - AVSafeBottom - 26 - 44, self.contentView.av_width - 72 - 72, 44)];
    [add setTitle:@"创建直播间" forState:UIControlStateNormal];
    add.titleLabel.font = AVGetMediumFont(16);
    add.backgroundColor = AUIRoomColourfulFillStrong;
    [add setTitleColor:[UIColor av_colorWithHexString:@"#FCFCFD"] forState:UIControlStateNormal];
    add.layer.cornerRadius = 22.0;
    [add addTarget:self action:@selector(onAddBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:add];
#endif
    
    [self.collectionView registerClass:AUIRoomItemCell.class forCellWithReuseIdentifier:AVCollectionViewCellIdentifier];
    
    [self setupRefreshHeader];
    [self setupLoadMoreFooter];
    
    dispatch_after(0.2, dispatch_get_main_queue(), ^{
        [self.collectionView.mj_header beginRefreshing];
    });
}

- (void)onBackBtnClicked:(UIButton *)sender {
    if (self.navigationController) {
        if (self.navigationController.viewControllers.firstObject == self) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)showEmptyView {
    [self hideEmptyView];
    
    self.emptyView = [[UIView alloc] initWithFrame:self.contentView.bounds];
    self.emptyView.userInteractionEnabled = NO;
    [self.contentView insertSubview:self.emptyView aboveSubview:self.collectionView];
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 180, 116)];
    icon.image = AVGetImage(@"ic_list_bg_empty", @"Resource");
    icon.av_centerX = self.emptyView.av_width / 2.0;
    icon.av_centerY = (self.emptyView.av_height - 24 - 16 - AVSafeBottom - 26 - 44) / 2.0;
    [self.emptyView addSubview:icon];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, icon.av_bottom + 16, self.emptyView.av_width, 24)];
    title.text = @"暂无直播";
    title.textAlignment = NSTextAlignmentCenter;
    title.font = AVGetRegularFont(16);
    title.textColor = AUIFoundationColor(@"text_ultraweak");
    [self.emptyView addSubview:title];
}

- (void)hideEmptyView {
    [self.emptyView removeFromSuperview];
    self.emptyView = nil;
}

- (void)setupRefreshHeader {
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshMessage)];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.collectionView.mj_header = header;
    [header loadingView].activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    header.stateLabel.font = AVGetRegularFont(14);
    header.stateLabel.textColor = AUIFoundationColor(@"text_weak");
}

- (void)setupLoadMoreFooter {
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreMessage)];
    self.collectionView.mj_footer = footer;
    [footer setTitle:@"" forState:MJRefreshStateNoMoreData];
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    footer.stateLabel.font = AVGetRegularFont(14);
    footer.stateLabel.textColor = AUIFoundationColor(@"text_weak");
    [footer loadingView].activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
}


- (void)refreshMessage
{
    if ([self.collectionView.mj_footer isRefreshing])
    {
        [self.collectionView.mj_header endRefreshing];
        return;
    }
    
    [AUIRoomAppServer fetchLiveList:1 pageSize:10 completed:^(NSArray<AUIRoomLiveInfoModel *> * _Nullable models, NSError * _Nullable error) {
        
        [self.collectionView.mj_header endRefreshing];
        if (!error) {
            [self.roomList removeAllObjects];
            [models enumerateObjectsUsingBlock:^(AUIRoomLiveInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                AUIRoomItem *item = [[AUIRoomItem alloc] initWithRoomModel:obj];
                [self.roomList addObject:item];
            }];
            [self.collectionView reloadData];
            
            if (models.count == 0) {
                self.lastPageNumber = 1;
                [self.collectionView.mj_footer endRefreshingWithNoMoreData];
                [self showEmptyView];
            }
            else {
                self.lastPageNumber = 2;
                [self hideEmptyView];
            }
        }
        else {
            BOOL showAlert = YES;
            if (error.code == 401) {
                if (self.onLoginTokenExpired) {
                    self.onLoginTokenExpired();
                    showAlert = NO;
                }
            }
            if (showAlert) {
                [AVAlertController show:[NSString stringWithFormat:@"出错了：%zd", error.code] vc:self];
            }
        }
    }];
}

- (void)loadMoreMessage
{
    if ([self.collectionView.mj_header isRefreshing])
    {
        [self.collectionView.mj_footer endRefreshing];
        return;
    }
    
    if (self.lastPageNumber == 1) {
        [self.collectionView.mj_footer endRefreshing];
        return;
    }

    [AUIRoomAppServer fetchLiveList:self.lastPageNumber pageSize:10 completed:^(NSArray<AUIRoomLiveInfoModel *> * _Nullable models, NSError * _Nullable error) {
        
        [self.collectionView.mj_footer endRefreshing];
        if (!error) {
            
            if (models.count == 0) {
                [self.collectionView.mj_footer endRefreshingWithNoMoreData];
            }
            else {
                self.lastPageNumber++;
                [models enumerateObjectsUsingBlock:^(AUIRoomLiveInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    AUIRoomItem *item = [[AUIRoomItem alloc] initWithRoomModel:obj];
                    [self.roomList addObject:item];
                }];
                [self.collectionView reloadData];
            }
        }
        else {
            BOOL showAlert = YES;
            if (error.code == 401) {
                if (self.onLoginTokenExpired) {
                    self.onLoginTokenExpired();
                    showAlert = NO;
                }
            }
            if (showAlert) {
                [AVAlertController show:[NSString stringWithFormat:@"出错了：%zd", error.code] vc:self];
            }
        }
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.roomList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AUIRoomItemCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:AVCollectionViewCellIdentifier forIndexPath:indexPath];
    [cell updateItem:self.roomList[indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (self.collectionView.av_width - 16 - 16 - 13) / 2.0;
    return CGSizeMake(width, width);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 12.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 16.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
#if LIVE_TYPE==INTERACTION_LIVE
    return UIEdgeInsetsMake(8, 16, 26 + 44, 16);
#else
    return UIEdgeInsetsMake(8, 16, 26, 16);
#endif
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AUIRoomItem *item = self.roomList[indexPath.row];
    [self joinLive:item.roomModel];
}

#if LIVE_TYPE==INTERACTION_LIVE
- (void)onAddBtnClicked:(UIButton *)sender {
    [self createLive];
}

- (void)createLive {
    AUILiveCreateViewController *vc = [AUILiveCreateViewController new];
    __weak typeof(AUILiveCreateViewController *) weakVC = vc;
    vc.onCreateLiveBlock = ^(NSString * _Nonnull title, NSString * _Nullable notice, BOOL interactionMode) {
        
        [[AUILiveManager liveManager] createLive:interactionMode ? AUIRoomLiveModeLinkMic : AUIRoomLiveModeBase title:title notice:notice currentVC:weakVC completed:^(BOOL success, AUIRoomLiveInfoModel * _Nullable model) {
            if (success) {
                [AUILiveListViewController saveLastLiveData:model.live_id];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakVC removeFromParentViewController];
                });
            }
        }];
    };
    
    [self.navigationController pushViewController:vc animated:YES];
}
#endif

- (void)onMenuClicked:(UIButton *)sender {
    [AUILiveListViewController joinLastLive:self];
}

- (void)joinLive:(AUIRoomLiveInfoModel *)roomModel {
    [[AUILiveManager liveManager] joinLive:roomModel currentVC:self completed:^(BOOL success) {
        if (success) {
            [AUILiveListViewController saveLastLiveData:roomModel.live_id];
        }
    }];
}

#pragma mark - last live

static NSString *g_lastLiveId = nil;
+ (void)joinLastLive:(UIViewController *)currentVC {
    if (![self hasLastLive]) {
        [AVAlertController show:@"没有上场直播数据" vc:currentVC];
        return;
    }
    
    [[AUILiveManager liveManager] joinLiveWithLiveId:g_lastLiveId currentVC:currentVC completed:nil];
}

+ (BOOL)hasLastLive {
    return g_lastLiveId.length > 0;
}

+ (void)loadLastLiveData {
    NSString *last_live_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_live_id"];
    if (AUIRoomAccount.me.userId.length > 0 && [last_live_id hasPrefix:AUIRoomAccount.me.userId]) {
        g_lastLiveId = [last_live_id substringFromIndex:AUIRoomAccount.me.userId.length + 1];
    }
    else {
        g_lastLiveId = nil;
    }
}

+ (void)saveLastLiveData:(NSString *)lastLiveId {
    if ([g_lastLiveId isEqualToString:lastLiveId]) {
        return;
    }
    g_lastLiveId = lastLiveId;
    if (g_lastLiveId.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@_%@", AUIRoomAccount.me.userId, g_lastLiveId] forKey:@"last_live_id"];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"last_live_id"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
