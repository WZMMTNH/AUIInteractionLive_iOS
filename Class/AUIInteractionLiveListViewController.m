//
//  AUIInteractionLiveListViewController.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/8/31.
//

#import "AUIInteractionLiveListViewController.h"
#import "AUIInteractionLiveMacro.h"
#import "AUIInteractionLiveService.h"
#import "AUIInteractionLiveUser.h"
#import "AUILiveRoomBeautyManager.h"

#import "AUILiveRoomAnchorViewController.h"
#import "AUIInteractionLiveManager.h"
#import "AUIInteractionAccountManager.h"

#import <MJRefresh/MJRefresh.h>

@interface AUIRoomItem : AVCommonListItem

@property (nonatomic, strong) AUIInteractionLiveInfoModel *roomModel;

@end

@implementation AUIRoomItem

- (instancetype)initWithRoomModel:(AUIInteractionLiveInfoModel *)roomModel {
    self = [super init];
    if (self) {
        _roomModel = roomModel;
    }
    return self;
}

- (NSString *)title {
    return _roomModel.title;
}

- (NSString *)info {
    return [NSString stringWithFormat:@"ID：%@", _roomModel.anchor_id];
}

- (UIImage *)icon {
    return AUIInteractionLiveGetImage(@"img-user-default");
}

- (NSString *)metrics {
    return [NSString stringWithFormat:@"%zd观看，%zd点赞", _roomModel.metrics.pv, _roomModel.metrics.like_count];
}

@end

@interface AUIRoomItemCell : AVCommonListItemCell

@property (nonatomic, strong, readonly) UILabel *metricsLabel;
@property (nonatomic, strong, readonly) UIImageView *bgImageView;

@end

@implementation AUIRoomItemCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        
        _bgImageView = [UIImageView new];
        _bgImageView.image = AUIInteractionLiveGetImage(@"列表页-背景");
        _bgImageView.alpha = 0.5;
        [self.contentView addSubview:_bgImageView];
        [self.contentView sendSubviewToBack:_bgImageView];
        
        self.layer.cornerRadius = 12.0;
        [self av_setLayerBorderColor:AUIFoundationColor(@"border_weak") borderWidth:1.0];
        self.infoLabel.textColor = AUIFoundationColor(@"text_strong");
        self.infoLabel.font = AVGetRegularFont(10);
        self.titleLabel.font = AVGetRegularFont(10);
        
        self.iconView.layer.cornerRadius = 15;
        self.iconView.layer.masksToBounds = YES;
        
        
        _metricsLabel = [UILabel new];
        _metricsLabel.textColor = AUIFoundationColor(@"text_strong");
        _metricsLabel.font = AVGetMediumFont(8);
        _metricsLabel.numberOfLines = 1;
        _metricsLabel.textAlignment = NSTextAlignmentRight;
        _metricsLabel.layer.cornerRadius = 9;
        _metricsLabel.layer.masksToBounds = YES;
        _metricsLabel.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.3];
        _metricsLabel.text = @"";
        [self.contentView addSubview:_metricsLabel];
        
        [self.contentView bringSubviewToFront:self.viewIconView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.bgImageView.frame = self.contentView.bounds;
    self.iconView.frame = CGRectMake(7, self.contentView.av_height - 16 - 30, 30, 30);
    self.titleLabel.frame = CGRectMake(self.iconView.av_right + 6, self.iconView.av_top, self.contentView.av_width - self.iconView.av_right - 6, 15);
    self.infoLabel.frame = CGRectMake(self.titleLabel.av_left, self.titleLabel.av_bottom, self.titleLabel.av_width, 15);
    
    [self.metricsLabel sizeToFit];
    self.metricsLabel.frame = CGRectMake(7, 10, self.metricsLabel.av_width + 30, 18);
    self.viewIconView.frame = CGRectMake(7 + 10, 10 + 4, 10, 10);
}

- (void)updateItem:(AUIRoomItem *)item {
    [super updateItem:item];
    self.viewIconView.image = AUIInteractionLiveGetImage(@"列表页-热度");
    self.metricsLabel.text = [item metrics];
}

@end



@interface AUIInteractionLiveListViewController ()

@property (nonatomic, strong) NSMutableArray<AUIRoomItem *> *roomList;
@property (nonatomic, assign) NSInteger lastPageNumber;

@end

@implementation AUIInteractionLiveListViewController

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
    
    self.view.backgroundColor = AUIFoundationColor(@"bg_medium");
    self.titleView.text = @"直播间";
    [self setHiddenMenuButton:YES];
    
    
    UIButton *add = [[UIButton alloc] initWithFrame:CGRectMake((self.contentView.av_width - 120) / 2, self.contentView.av_height - AVSafeBottom - 16 - 40, 120, 40)];
    [add setTitle:@"开播" forState:UIControlStateNormal];
    add.titleLabel.font = AVGetMediumFont(16);
    add.backgroundColor = AUIFoundationColor(@"colourful_text_strong");
    [add setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
    add.layer.cornerRadius = 20.0;
    [add addTarget:self action:@selector(onAddBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:add];
    
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

- (void)setupRefreshHeader {
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshMessage)];
    self.collectionView.mj_header = header;
    [header loadingView].activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    header.stateLabel.textColor = AUIFoundationColor(@"text_weak");
}

- (void)setupLoadMoreFooter {
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreMessage)];
    self.collectionView.mj_footer = footer;
    [footer setTitle:@"没有更多了" forState:MJRefreshStateNoMoreData];
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    footer.stateLabel.font = [UIFont systemFontOfSize:14.0f];
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
    
    [AUIInteractionLiveService fetchLiveList:1 pageSize:10 completed:^(NSArray<AUIInteractionLiveInfoModel *> * _Nullable models, NSError * _Nullable error) {
        
        [self.collectionView.mj_header endRefreshing];
        if (!error) {
            [self.roomList removeAllObjects];
            [models enumerateObjectsUsingBlock:^(AUIInteractionLiveInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                AUIRoomItem *item = [[AUIRoomItem alloc] initWithRoomModel:obj];
                [self.roomList addObject:item];
            }];
            [self.collectionView reloadData];
            
            if (models.count == 0) {
                self.lastPageNumber = 1;
                [self.collectionView.mj_footer endRefreshingWithNoMoreData];
            }
            else {
                self.lastPageNumber = 2;
            }
        }
        else {
            [AVAlertController show:[NSString stringWithFormat:@"出错了：%zd", error.code] vc:self];
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

    [AUIInteractionLiveService fetchLiveList:self.lastPageNumber pageSize:10 completed:^(NSArray<AUIInteractionLiveInfoModel *> * _Nullable models, NSError * _Nullable error) {
        
        [self.collectionView.mj_footer endRefreshing];
        if (!error) {
            
            if (models.count == 0) {
                [self.collectionView.mj_footer endRefreshingWithNoMoreData];
            }
            else {
                self.lastPageNumber++;
                [models enumerateObjectsUsingBlock:^(AUIInteractionLiveInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    AUIRoomItem *item = [[AUIRoomItem alloc] initWithRoomModel:obj];
                    [self.roomList addObject:item];
                }];
                [self.collectionView reloadData];
            }
        }
        else {
            [AVAlertController show:[NSString stringWithFormat:@"出错了：%@", error.userInfo] vc:self];
        }
    }];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AUIRoomItemCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:AVCollectionViewCellIdentifier forIndexPath:indexPath];
    [cell updateItem:self.itemList[indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((self.collectionView.av_width - 20 - 20 - 15) / 2.0, 192.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 15.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 15.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(15, 20, 44, 20);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AUIRoomItem *item = self.roomList[indexPath.row];
    [self joinLive:item.roomModel];
}

- (void)onAddBtnClicked:(UIButton *)sender {
    [self createLive];
}

#pragma mark - controll

- (NSArray<AVCommonListItem *> *)itemList {
    return _roomList;
}

- (void)createLive {
    [AVAlertController showInput:[NSString stringWithFormat:@"%@的直播", AUIInteractionAccountManager.me.nickName] title:@"输入直播标题" message:nil okTitle:@"连麦直播" cancelTitle:@"基础直播" vc:self onCompleted:^(NSString * _Nonnull input, BOOL isCancel) {
        if (input.length == 0) {
            return;
        }
        [AUILiveRoomBeautyManager checkResourceWithCurrentView:self.view completed:^(BOOL completed) {
            [[AUIInteractionLiveManager defaultManager] createLive:isCancel ? AUIInteractionLiveModeBase : AUIInteractionLiveModeLinkMic title:input currentVC:self];
        }];
    }];
}

- (void)joinLive:(AUIInteractionLiveInfoModel *)roomModel {
    [[AUIInteractionLiveManager defaultManager] joinLive:roomModel currentVC:self];
}

@end
