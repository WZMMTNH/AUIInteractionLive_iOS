//
//  AUIInteractionLiveCreateViewController.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/7.
//

#import "AUIInteractionLiveCreateViewController.h"
#import "AUILiveRoomInputTitleView.h"
#import "AUIInteractionLiveMacro.h"
#import "AUIInteractionAccountManager.h"
#import "AUILiveRoomDeviceAuth.h"

@interface AUIInteractionLiveCreateViewController () <UITextFieldDelegate>


@property (nonatomic, strong) AUILiveRoomInputTitleView *inputLiveTitle;
@property (nonatomic, strong) AUILiveRoomInputTitleView *inputLiveNotice;

@property (nonatomic, strong) AVBlockButton *createButton;

@property (nonatomic, strong) AVBlockButton *baseLiveButton;
@property (nonatomic, strong) AVBlockButton *interactionLiveButton;

@end

@implementation AUIInteractionLiveCreateViewController

- (void)dealloc {
    NSLog(@"dealloc:AUIInteractionLiveCreateViewController");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleView.text = @"创建直播间";
    self.titleView.font = AVGetRegularFont(16);
    self.hiddenMenuButton = YES;
    
    
    AUILiveRoomInputTitleView *inputLiveTitle = [[AUILiveRoomInputTitleView alloc] initWithFrame:CGRectMake(32, 44, self.contentView.av_width - 32 * 2, 56)];
    inputLiveTitle.placeHolder = @"直播间标题（请输入中文、字母、数字）";
    inputLiveTitle.titleName = @"直播间标题（请输入中文、字母、数字）";
    [self.contentView addSubview:inputLiveTitle];
    self.inputLiveTitle = inputLiveTitle;
    
    
    AUILiveRoomInputTitleView *inputLiveNotice = [[AUILiveRoomInputTitleView alloc] initWithFrame:CGRectMake(32, inputLiveTitle.av_bottom + 20, self.contentView.av_width - 32 * 2, 80)];
    inputLiveNotice.placeHolder = @"可选，输入直播间公告";
    inputLiveNotice.titleName = @"直播间公告";
    [self.contentView addSubview:inputLiveNotice];
    self.inputLiveNotice = inputLiveNotice;
    
    
    AVBlockButton *baseLiveButton = [[AVBlockButton alloc] initWithFrame:CGRectMake(32, inputLiveNotice.av_bottom + 36, 100, 22)];
    baseLiveButton.titleLabel.font = AVGetRegularFont(14);
    [baseLiveButton setImage:AUIInteractionLiveGetImage(@"ic_radio_unselected") forState:UIControlStateNormal];
    [baseLiveButton setImage:AUIInteractionLiveGetImage(@"ic_radio_selected") forState:UIControlStateSelected];
    [baseLiveButton setTitle:@"基础直播" forState:UIControlStateNormal];
    [baseLiveButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
    [baseLiveButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, -8)];
    baseLiveButton.selected = YES;
    [baseLiveButton sizeToFit];
    baseLiveButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    baseLiveButton.av_width = baseLiveButton.av_width + 8;
    [self.contentView addSubview:baseLiveButton];
    self.baseLiveButton = baseLiveButton;
    
    AVBlockButton *interactionLiveButton = [[AVBlockButton alloc] initWithFrame:CGRectMake(baseLiveButton.av_right + 20, inputLiveNotice.av_bottom + 36, 100, 22)];
    interactionLiveButton.titleLabel.font = AVGetRegularFont(14);
    [interactionLiveButton setImage:AUIInteractionLiveGetImage(@"ic_radio_unselected") forState:UIControlStateNormal];
    [interactionLiveButton setImage:AUIInteractionLiveGetImage(@"ic_radio_selected") forState:UIControlStateSelected];
    [interactionLiveButton setTitle:@"互动直播" forState:UIControlStateNormal];
    [interactionLiveButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
    [interactionLiveButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, -8)];
    interactionLiveButton.selected = NO;
    [interactionLiveButton sizeToFit];
    interactionLiveButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    interactionLiveButton.av_width = interactionLiveButton.av_width + 8;
    [self.contentView addSubview:interactionLiveButton];
    self.interactionLiveButton = interactionLiveButton;
    
    AVBlockButton *createButton = [[AVBlockButton alloc] initWithFrame:CGRectMake(32, baseLiveButton.av_bottom + 40, self.contentView.av_width - 32 * 2, 44)];
    createButton.layer.cornerRadius = 22;
    createButton.titleLabel.font = AVGetRegularFont(16);
    [createButton setTitle:@"创建直播间" forState:UIControlStateNormal];
    [createButton setTitleColor:[UIColor av_colorWithHexString:@"#FCFCFD"] forState:UIControlStateNormal];
    [createButton setBackgroundColor:AUIInteractionLiveColourfulFillStrong forState:UIControlStateNormal];
    [createButton setBackgroundColor:AUIInteractionLiveColourfulFillDisable forState:UIControlStateDisabled];
    createButton.enabled = NO;
    [self.contentView addSubview:createButton];
    self.createButton = createButton;
    [self.createButton addTarget:self action:@selector(onCreateButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    __weak typeof(self) weakSelf = self;
    self.inputLiveTitle.inputTextChangedBlock = ^(NSString * _Nonnull inputText) {
        weakSelf.createButton.enabled = weakSelf.inputLiveTitle.inputText.length > 0;
    };
    self.baseLiveButton.clickBlock = ^(AVBlockButton * _Nonnull sender) {
        weakSelf.baseLiveButton.selected = YES;
        weakSelf.interactionLiveButton.selected = NO;
    };
    self.interactionLiveButton.clickBlock = ^(AVBlockButton * _Nonnull sender) {
        weakSelf.baseLiveButton.selected = NO;
        weakSelf.interactionLiveButton.selected = YES;
    };
    self.inputLiveTitle.inputText = [NSString stringWithFormat:@"%@的直播", AUIInteractionAccountManager.me.nickName];
}

- (void)onCreateButtonClicked {
    [self.view endEditing:NO];
    
    [self startToCreatLive];
}

- (void)startToCreatLive {
    __weak typeof(self) weakSelf = self;
    BOOL ret = NO;
    ret = [AUILiveRoomDeviceAuth checkCameraAuth:^(BOOL auth) {
        if (auth) {
            [weakSelf startToCreatLive];
        }
    }];
    if (!ret) {
        return;
    }
    
    ret = [AUILiveRoomDeviceAuth checkMicAuth:^(BOOL auth) {
        if (auth) {
            [weakSelf startToCreatLive];
        }
    }];
    if (!ret) {
        return;
    }
    
    if (self.onCreateLiveBlock) {
        NSString *title = self.inputLiveTitle.inputText;
        NSString *notice = self.inputLiveNotice.inputText;
        BOOL isInteraction = self.interactionLiveButton.selected;
        self.onCreateLiveBlock(title, notice, isInteraction);
    }
}

@end
