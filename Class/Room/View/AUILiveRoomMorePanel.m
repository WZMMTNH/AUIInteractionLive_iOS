//
//  AUILiveRoomMorePanel.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import "AUILiveRoomMorePanel.h"
#import "AUIFoundation.h"
#import "AUIInteractionLiveMacro.h"
#import <Masonry/Masonry.h>

@interface AUILiveRoomMorePanelButton : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *selectedTitle;
@property (nonatomic, copy) NSString *iconName;
@property (nonatomic, assign) BOOL selected;

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIImageView *markView;

@property (nonatomic, copy) void (^onClickedAction)(AUILiveRoomMorePanelButton *sender, BOOL selected);

- (void)applyAppreance;

@end

@implementation AUILiveRoomMorePanelButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
        icon.contentMode = UIViewContentModeScaleAspectFit;
        icon.av_centerX = self.av_width / 2;
        [self addSubview:icon];
        self.iconView = icon;
        
        UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(0, 28, self.av_width, 11)];
        text.font = AVGetRegularFont(8.0);
        text.textColor = [UIColor whiteColor];
        text.textAlignment = NSTextAlignmentCenter;
        [self addSubview:text];
        self.textLabel = text;
        
        UIImageView *mark = [[UIImageView alloc] initWithFrame:CGRectMake(icon.av_width - 8, icon.av_height - 8, 8, 8)];
        mark.contentMode = UIViewContentModeScaleAspectFit;
        mark.image = AUIInteractionLiveGetImage(@"直播-更多-选择");
        mark.hidden = YES;
        [icon addSubview:mark];
        self.markView = mark;
        
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)]];
    }
    return self;
}

- (void)applyAppreance {
    self.iconView.image = AUIInteractionLiveGetImage(self.iconName);
    if (self.selected) {
        self.textLabel.text = self.selectedTitle ?: self.title;
        self.markView.hidden = NO;
    }
    else {
        self.textLabel.text = self.title;
        self.markView.hidden = YES;
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
        self.titleView.text = @"更多";
        self.buttonDict = [NSMutableDictionary dictionary];
        
        __weak typeof(self) weakSelf = self;
        CGFloat height = 44;
        CGFloat width = (frame.size.width - 0 * 2) / 4.0;
        
        AUILiveRoomMorePanelButton *muteBtn = [[AUILiveRoomMorePanelButton alloc] initWithFrame:CGRectMake(self.buttonDict.count % 4 * width, self.buttonDict.count / 4 * (height + 17) + 15, width, height)];
        muteBtn.title = @"静音";
        muteBtn.selectedTitle = @"取消静音";
        muteBtn.iconName = @"直播-更多-静音";
        muteBtn.onClickedAction = ^(AUILiveRoomMorePanelButton *sender, BOOL selected) {
            if (weakSelf.onClickedAction) {
                sender.selected = weakSelf.onClickedAction(self, AUILiveRoomMorePanelActionTypeMute, selected);
                [sender applyAppreance];
            }
        };
        [muteBtn applyAppreance];
        [self.contentView addSubview:muteBtn];
        [self.buttonDict setObject:muteBtn forKey:@(AUILiveRoomMorePanelActionTypeMute)];

//        AUILiveRoomMorePanelButton *pauseButton = [[AUILiveRoomMorePanelButton alloc] initWithFrame:CGRectMake(self.buttonDict.count % 4 * width, self.buttonDict.count / 4 * (height + 17) + 15, width, height)];
//        pauseButton.title = @"暂停直播";
//        pauseButton.selectedTitle = @"取消暂停";
//        pauseButton.iconName = @"直播-更多-暂停";
//        pauseButton.onClickedAction = ^(AUILiveRoomMorePanelButton *sender, BOOL selected) {
//            if (weakSelf.onClickedAction) {
//                sender.selected = weakSelf.onClickedAction(self, AUILiveRoomMorePanelActionTypePause, selected);
//                [sender applyAppreance];
//            }
//        };
//        [pauseButton applyAppreance];
//        [self.contentView addSubview:pauseButton];
//        [self.buttonDict setObject:pauseButton forKey:@(AUILiveRoomMorePanelActionTypePause)];
        
        AUILiveRoomMorePanelButton *cameraButton = [[AUILiveRoomMorePanelButton alloc] initWithFrame:CGRectMake(self.buttonDict.count % 4 * width, self.buttonDict.count / 4 * (height + 17) + 15, width, height)];
        cameraButton.title = @"镜头翻转";
        cameraButton.iconName = @"直播-更多-镜头翻转";
        cameraButton.onClickedAction = ^(AUILiveRoomMorePanelButton *sender, BOOL selected) {
            if (weakSelf.onClickedAction) {
                sender.selected = weakSelf.onClickedAction(self, AUILiveRoomMorePanelActionTypeCamera, selected);
                [sender applyAppreance];
            }
        };
        [cameraButton applyAppreance];
        [self.contentView addSubview:cameraButton];
        [self.buttonDict setObject:cameraButton forKey:@(AUILiveRoomMorePanelActionTypeCamera)];
        
        AUILiveRoomMorePanelButton *mirrorButton = [[AUILiveRoomMorePanelButton alloc] initWithFrame:CGRectMake(self.buttonDict.count % 4 * width, self.buttonDict.count / 4 * (height + 17) + 15, width, height)];
        mirrorButton.title = @"关闭镜像";
        mirrorButton.selectedTitle = @"开启镜像";
        mirrorButton.iconName = @"直播-更多-镜相开";
        mirrorButton.onClickedAction = ^(AUILiveRoomMorePanelButton *sender, BOOL selected) {
            if (weakSelf.onClickedAction) {
                sender.selected = weakSelf.onClickedAction(self, AUILiveRoomMorePanelActionTypeMirror, selected);
                [sender applyAppreance];
            }
        };
        [mirrorButton applyAppreance];
        [self.contentView addSubview:mirrorButton];
        [self.buttonDict setObject:mirrorButton forKey:@(AUILiveRoomMorePanelActionTypeMirror)];
        
//        AUILiveRoomMorePanelButton *editButton = [[AUILiveRoomMorePanelButton alloc] initWithFrame:CGRectMake(self.buttonDict.count % 4 * width, self.buttonDict.count / 4 * (height + 17) + 15, width, height)];
//        editButton.title = @"编辑公告";
//        editButton.iconName = @"直播-更多-修改标题";
//        editButton.onClickedAction = ^(AUILiveRoomMorePanelButton *sender, BOOL selected) {
//            if (weakSelf.onClickedAction) {
//                sender.selected = weakSelf.onClickedAction(self, AUILiveRoomMorePanelActionTypeNotice, selected);
//                [sender applyAppreance];
//            }
//        };
//        [editButton applyAppreance];
//        [self.contentView addSubview:editButton];
//        [self.buttonDict setObject:editButton forKey:@(AUILiveRoomMorePanelActionTypeNotice)];
        
        AUILiveRoomMorePanelButton *banAllCommentsButton = [[AUILiveRoomMorePanelButton alloc] initWithFrame:CGRectMake(self.buttonDict.count % 4 * width, self.buttonDict.count / 4 * (height + 17) + 15, width, height)];
        banAllCommentsButton.title = @"全员禁言";
        banAllCommentsButton.selectedTitle = @"取消禁言";
        banAllCommentsButton.iconName = @"直播-更多-取消禁言";
        banAllCommentsButton.onClickedAction = ^(AUILiveRoomMorePanelButton *sender, BOOL selected) {
            if (weakSelf.onClickedAction) {
                sender.selected = weakSelf.onClickedAction(self, AUILiveRoomMorePanelActionTypeBan, selected);
                [sender applyAppreance];
            }
        };
        [banAllCommentsButton applyAppreance];
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
    [btn applyAppreance];
}

+ (CGFloat)panelHeight {
    return 200;
}

@end
