//
//  AUILiveRoomLinkMicListPanel.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/28.
//

#import "AUILiveRoomLinkMicListPanel.h"
#import "AUILiveBlockButton.h"

typedef NS_ENUM(NSUInteger, AUILiveRoomLinkMicCellItemType) {
    AUILiveRoomLinkMicCellItemTypeApply,
    AUILiveRoomLinkMicCellItemTypeJoining,
    AUILiveRoomLinkMicCellItemTypeJoined,
};

@interface AUILiveRoomLinkMicCellItem : NSObject

@property (nonatomic, copy, readonly) NSString *nickName;
@property (nonatomic, copy, readonly) NSString *status;

@property (nonatomic, assign) AUILiveRoomLinkMicCellItemType itemType;

@property (nonatomic, strong) id data;

@end

@implementation AUILiveRoomLinkMicCellItem

- (NSString *)nickName {
    if (self.itemType != AUILiveRoomLinkMicCellItemTypeJoined) {
        return [(AUIInteractionLiveUser *)self.data nickName];
    }

    return [(AUILiveRoomRtcPull *)self.data pullInfo].userNick;
}

- (NSString *)status {
    if (self.itemType == AUILiveRoomLinkMicCellItemTypeApply) {
        return [NSString stringWithFormat:@"%@-申请连麦中...", [(AUIInteractionLiveUser *)self.data userId]];
    }
    
    if (self.itemType == AUILiveRoomLinkMicCellItemTypeJoining) {
        return [NSString stringWithFormat:@"%@-连麦中...", [(AUIInteractionLiveUser *)self.data userId]];
    }
    
    if (self.itemType == AUILiveRoomLinkMicCellItemTypeJoined) {
        return [NSString stringWithFormat:@"%@-已连麦", [(AUILiveRoomRtcPull *)self.data pullInfo].userId];
    }
    
    return @"";
}

@end

@interface AUILiveRoomLinkMicCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIView *lineView;

@property (nonatomic, strong, readonly) UILabel *nameLabel;
@property (nonatomic, strong, readonly) UILabel *infoLabel;
@property (nonatomic, strong, readonly) AUILiveBlockButton *agreeBtn;
@property (nonatomic, strong, readonly) AUILiveBlockButton *rejectBtn;
@property (nonatomic, strong, readonly) AUILiveBlockButton *leaveBtn;

@property (nonatomic, copy) void (^onAgreeBtnClick)(AUILiveBlockButton *, AUILiveRoomLinkMicCellItem *);
@property (nonatomic, copy) void (^onRejectBtnClick)(AUILiveBlockButton *, AUILiveRoomLinkMicCellItem *);
@property (nonatomic, copy) void (^onLeaveBtnClick)(AUILiveBlockButton *, AUILiveRoomLinkMicCellItem *);

@property (nonatomic, strong) AUILiveRoomLinkMicCellItem *cellItem;

@end

@implementation AUILiveRoomLinkMicCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = AUIFoundationColor(@"fg_strong");
        
        _lineView = [UIView new];
        _lineView.backgroundColor = AUIFoundationColor(@"fg_strong");
        [self.contentView addSubview:_lineView];
        
        _nameLabel = [UILabel new];
        _nameLabel.textColor = AUIFoundationColor(@"text_strong");
        _nameLabel.font = AVGetMediumFont(14);
        _nameLabel.numberOfLines = 1;
        _nameLabel.text = @"AAAAA";
        [self.contentView addSubview:_nameLabel];
        
        _infoLabel = [UILabel new];
        _infoLabel.textColor = AUIFoundationColor(@"text_weak");
        _infoLabel.font = AVGetMediumFont(10);
        _infoLabel.numberOfLines = 1;
        _infoLabel.text = @"xxxxx...";
        [self.contentView addSubview:_infoLabel];
        
        __weak typeof(self) weakSelf = self;
        _agreeBtn = [AUILiveBlockButton new];
        [_agreeBtn av_setLayerBorderColor:UIColor.cyanColor borderWidth:1];
        [_agreeBtn setTitleColor:UIColor.cyanColor forState:UIControlStateNormal];
        [_agreeBtn setTitle:@"同意" forState:UIControlStateNormal];
        _agreeBtn.titleLabel.font = AVGetMediumFont(10.0);
        _agreeBtn.clickBlock = ^(AUILiveBlockButton * _Nonnull sender) {
            if (weakSelf.onAgreeBtnClick) {
                weakSelf.onAgreeBtnClick(sender, weakSelf.cellItem);
            }
        };
        [self.contentView addSubview:_agreeBtn];
        
        _rejectBtn = [AUILiveBlockButton new];
        [_rejectBtn av_setLayerBorderColor:UIColor.redColor borderWidth:1];
        [_rejectBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        [_rejectBtn setTitle:@"拒绝" forState:UIControlStateNormal];
        _rejectBtn.titleLabel.font = AVGetMediumFont(10.0);
        _rejectBtn.clickBlock = ^(AUILiveBlockButton * _Nonnull sender) {
            if (weakSelf.onRejectBtnClick) {
                weakSelf.onRejectBtnClick(sender, weakSelf.cellItem);
            }
        };
        [self.contentView addSubview:_rejectBtn];
        
        _leaveBtn = [AUILiveBlockButton new];
        [_leaveBtn av_setLayerBorderColor:UIColor.redColor borderWidth:1];
        [_leaveBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        [_leaveBtn setTitle:@"下麦" forState:UIControlStateNormal];
        _leaveBtn.titleLabel.font = AVGetMediumFont(10.0);
        _leaveBtn.hidden = YES;
        _leaveBtn.clickBlock = ^(AUILiveBlockButton * _Nonnull sender) {
            if (weakSelf.onLeaveBtnClick) {
                weakSelf.onLeaveBtnClick(sender, weakSelf.cellItem);
            }
        };
        [self.contentView addSubview:_leaveBtn];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _lineView.frame = CGRectMake(0, self.av_height - 1, self.av_width, 1);
    
    _nameLabel.frame = CGRectMake(0, 6, self.av_width, 22);
    _infoLabel.frame = CGRectMake(0, _nameLabel.av_bottom, self.av_width, 16);
    
    _agreeBtn.frame = CGRectMake(self.av_width - 36, 14, 36, 18);
    _rejectBtn.frame = CGRectMake(_agreeBtn.av_left - 36 - 20, 14, 36, 18);
    _leaveBtn.frame = CGRectMake(self.av_width - 36 - 20, 14, 36, 18);
}

- (void)setCellItem:(AUILiveRoomLinkMicCellItem *)cellItem {
    _cellItem = cellItem;
    
    _nameLabel.text = _cellItem.nickName;
    _infoLabel.text = _cellItem.status;
    _agreeBtn.hidden = _cellItem.itemType != AUILiveRoomLinkMicCellItemTypeApply;
    _rejectBtn.hidden = _cellItem.itemType != AUILiveRoomLinkMicCellItemTypeApply;
    _leaveBtn.hidden = _cellItem.itemType != AUILiveRoomLinkMicCellItemTypeJoined;
}

@end

@interface AUILiveRoomLinkMicListPanel()

@property (nonatomic, strong) AUILiveRoomLinkMicManagerAnchor *manager;
@property (nonatomic, strong) NSMutableArray *list;
@property (nonatomic, strong) UILabel *emptyLabel;

@end


@implementation AUILiveRoomLinkMicListPanel

- (instancetype)initWithFrame:(CGRect)frame withManager:(AUILiveRoomLinkMicManagerAnchor *)manager {
    self = [super initWithFrame:frame];
    if (self) {
        _manager = manager;
        
        self.titleView.text = @"";
        self.showMenuButton = NO;
        self.showBackButton = YES;
        [self.menuButton setTitle:@"结束连麦" forState:UIControlStateNormal];
        [self.menuButton setImage:nil forState:UIControlStateNormal];
        
        [self.collectionView registerClass:AUILiveRoomLinkMicCell.class forCellWithReuseIdentifier:AVCollectionViewCellIdentifier];

        _list = [NSMutableArray array];
        [self reload];
    }
    return self;
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.list.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AUILiveRoomLinkMicCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:AVCollectionViewCellIdentifier forIndexPath:indexPath];
    cell.cellItem = [self.list objectAtIndex:indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    cell.onAgreeBtnClick = ^(AUILiveBlockButton *sender, AUILiveRoomLinkMicCellItem *cellItem) {
        
        if (![weakSelf.manager checkCanLinkMic]) {
            [AVToastView show:@"已经达到最大连麦数了，不能再上麦了" view:weakSelf.manager.roomVC.view position:AVToastViewPositionMid];
            return;
        }
        
        [weakSelf.manager responseApplyLinkMic:cellItem.data agree:YES force:NO completed:^(BOOL success) {
            if (success) {
                [weakSelf reload];
                [weakSelf hide];
            }
            else {
                [AVToastView show:@"操作失败了" view:weakSelf.manager.roomVC.view position:AVToastViewPositionMid];
            }
        }];
    };
    cell.onRejectBtnClick = ^(AUILiveBlockButton *sender, AUILiveRoomLinkMicCellItem *cellItem) {
        [weakSelf.manager responseApplyLinkMic:cellItem.data agree:NO force:NO completed:^(BOOL success) {
            if (success) {
                [weakSelf reload];
                [weakSelf hide];
            }
            else {
                [AVToastView show:@"操作失败了" view:weakSelf.manager.roomVC.view position:AVToastViewPositionMid];
            }
        }];
    };
    cell.onLeaveBtnClick = ^(AUILiveBlockButton *sender, AUILiveRoomLinkMicCellItem *cellItem) {
        [weakSelf.manager kickoutLinkMic:[(AUILiveRoomRtcPull *)cellItem.data pullInfo].userId completed:^(BOOL success) {
            if (success) {
                [weakSelf reload];
            }
            else {
                [AVToastView show:@"操作失败了" view:weakSelf.manager.roomVC.view position:AVToastViewPositionMid];
            }
        }];
    };
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.contentView.av_width - 20 - 20, 46.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 2.0f;
}

+ (CGFloat)panelHeight {
    return 240;
}

- (void)reload {
    [self.list removeAllObjects];
    [self.manager.currentApplyList enumerateObjectsUsingBlock:^(AUIInteractionLiveUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AUILiveRoomLinkMicCellItem *cellItem = [AUILiveRoomLinkMicCellItem new];
        cellItem.data = obj;
        cellItem.itemType = AUILiveRoomLinkMicCellItemTypeApply;
        [self.list addObject:cellItem];
    }];
    
    [self.manager.currentJoiningList enumerateObjectsUsingBlock:^(AUIInteractionLiveUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AUILiveRoomLinkMicCellItem *cellItem = [AUILiveRoomLinkMicCellItem new];
        cellItem.data = obj;
        cellItem.itemType = AUILiveRoomLinkMicCellItemTypeJoining;
        [self.list addObject:cellItem];
    }];
    
//    [self.manager.currentJoinList enumerateObjectsUsingBlock:^(AUILiveRoomRtcPull * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        AUILiveRoomLinkMicCellItem *cellItem = [AUILiveRoomLinkMicCellItem new];
//        cellItem.data = obj;
//        cellItem.itemType = AUILiveRoomLinkMicCellItemTypeJoined;
//        [self.list addObject:cellItem];
//    }];
    [self.collectionView reloadData];
    
    if (self.list.count > 0) {
        self.emptyLabel.hidden = YES;
    }
    else {
        if (!self.emptyLabel) {
            self.emptyLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
            self.emptyLabel.text = @"没有任何成员申请连麦~~~";
            self.emptyLabel.textAlignment = NSTextAlignmentCenter;
            self.emptyLabel.textColor = AUIFoundationColor(@"text_ultraweak");
            self.emptyLabel.font = AVGetRegularFont(12.0);
            [self.contentView addSubview:self.emptyLabel];
        }
        self.emptyLabel.frame = self.contentView.bounds;
        self.emptyLabel.hidden = NO;
    }
}

@end
