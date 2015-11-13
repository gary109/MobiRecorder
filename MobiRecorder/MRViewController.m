//
//  MRViewController.m
//  MobRecorder
//
//  Created by GarY on 2014/7/7.
//  Copyright (c) 2014年 GarY WanG. All rights reserved.
//


#import "MRViewController.h"
#import "PBJVisionView.h"
#import "MRBatteryView.h"
#import "MHAudioBufferPlayer.h"
#import "Synth.h"
#import "MRFileManagement.h"

#import "FBBitmapFontView.h"
#import "FBLCDFontView.h"
#import "FBSquareFontView.h"
#import "FBGlowLabel.h"

BOOL isPlayBlock = NO;
BOOL isRestartAudio=NO;

MRViewController *g_viewController;

typedef enum {
    kTCP = 0,
    kUDP
}kNetworkWay;

@interface MRViewController()
{
    
    MHAudioBufferPlayer *_player;
    Synth *_synth;
    NSLock *_synthLock;
   
}
@property (nonatomic) FBGlowLabel *label;
@property(strong,nonatomic)FBBitmapFontView *bfv;


@property (nonatomic,strong) LBScreenLockView * lbScreenView;
@property (nonatomic,strong) MRTableView * mrTableView;
@property (nonatomic,strong) MRBatteryView * mrBatteryView;
@property (nonatomic,strong) MRDashboardView * mrDashboardView;
@property (nonatomic,strong) MRSettingView * mrSettingView;
@property (nonatomic,strong) MRMapView * mrMapView;
@property (nonatomic,strong) MRAbout * mrAbout;
@property (nonatomic,strong) MRStoreView * mrStoreView;
@property (nonatomic,strong) MRMenuView * mrMenuView;
@property (nonatomic,strong) PBJVisionView * mrPBJVisionView;
@property (nonatomic,strong) MRPlist * mrPlist;

@property bool contentCreated;

@property (nonatomic,strong) UIImageView *batteryImageView;
@end


@implementation MRViewController
@synthesize mrPBJVisionView;
@synthesize mrMenuView;
@synthesize interstitial_;
@synthesize g_AdmobShowing;

@synthesize lbScreenView;
@synthesize bannerView_;
@synthesize mrStoreView;
@synthesize mrAbout;
@synthesize mrTableView;
@synthesize mrMapView;
@synthesize mrSettingView;
@synthesize mrBatteryView;
@synthesize mrDashboardView;
@synthesize mrPlist;
@synthesize batteryImageView;
@synthesize contentCreated;
#pragma mark
#pragma mark - AdMob
#define GAD_SIMULATOR_ID @"Simulator"
- (void)showInterstitialAdMob {
    interstitial_ = [[GADInterstitial alloc] init];
    interstitial_.delegate = self;
    interstitial_.adUnitID = @"ca-app-pub-2264368493541772/1957507109";
    [interstitial_ loadRequest:[self createRequest]];
}

- (void)showAdMob {
    g_AdmobShowing = NO;
    
    // 在螢幕上方建立標準大小的視圖，
    // 可用的 AdSize 常值已在 GADAdSize.h 中解釋。
    CGPoint origin = CGPointMake(0.0,0.0);
    
    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerLandscape origin:origin];
    
    // 指定廣告單元編號。
    bannerView_.adUnitID = @"ca-app-pub-2264368493541772/6099260308";
    
    // 通知執行階段，將使用者帶往廣告到達網頁後，該恢復哪一個 UIViewController，
    // 並將其加入檢視階層中。
    bannerView_.rootViewController = self;
    bannerView_.delegate = self;
    
    // 啟動一般請求，隨著廣告一起載入。
    [bannerView_ loadRequest:[self createRequest]];
    
}

// Here we're creating a simple GADRequest and whitelisting the application
// for test ads. You should request test ads during development to avoid
// generating invalid impressions and clicks.
- (GADRequest *)createRequest {
    GADRequest *request = [GADRequest request];
    
    // Make the request for a test ad. Put in an identifier for the simulator as
    // well as any devices you want to receive test ads.
//    request.testDevices = [NSArray arrayWithObjects:
//                           @[GAD_SIMULATOR_ID],
//                           @"d6b307ac0ee6cb52d2cd18fe7b3f6ed4c7c634b2",
//                           nil];
    
    request.testDevices = [NSArray arrayWithObjects:
                           nil];
    return request;
}


/// Called when an ad request loaded an ad.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"adViewDidReceiveAd");
    CGRect screenFrame3 = [[self.view layer] bounds];

    if ([[MRPlist readPlist:@"RemoveAds"] isEqualToString:@"0"]) {
        
        if(g_viewController.g_AdmobShowing==NO)
        {
            screenFrame3.origin.y = adView.frame.size.height;
            screenFrame3.size.height = [[self.view layer] bounds].size.height-adView.frame.size.height;
            [self.view addSubview:adView];
            adView.alpha = 0;
            [UIView animateWithDuration:1.0 animations:^{
                adView.alpha = 1;
            }];
            g_viewController.g_AdmobShowing = YES;
            
            [mrStoreView updateAll];
        }
    }
}

/// Called when an ad request failed.
- (void)adView:(GADBannerView *)adView didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"adViewDidFailToReceiveAdWithError: %@", [error localizedDescription]);
}

/// Called just before presenting the user a full screen view, such as
/// a browser, in response to clicking on an ad.
- (void)adViewWillPresentScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillPresentScreen");
}

/// Called just before dismissing a full screen view.
- (void)adViewWillDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillDismissScreen");
}

/// Called just after dismissing a full screen view.
- (void)adViewDidDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewDidDismissScreen");
}

/// Called just before the application will background or terminate
/// because the user clicked on an ad that will launch another
/// application (such as the App Store).
- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
    NSLog(@"adViewDidLeaveApplication");
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    NSLog(@"interstitialDidReceiveAd");
    [interstitial_ presentFromRootViewController:self];
}
- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"didFailToReceiveAdWithError");
}
#pragma mark - touch
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"Touches Began");
//    //[self logTouches: event];
//
//    [super touchesEnded: touches withEvent: event];
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"Touches Moved");
//    //[self logTouches: event];
//
//    [super touchesEnded: touches withEvent: event];
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"Touches Ended");
//    //[self logTouches: event];
//
//    [super touchesEnded: touches withEvent: event];
//}
//
//-(void)logTouchesFor: (UIEvent*)event
//{
//    int count = 1;
//
//    for (UITouch* touch in event.allTouches)
//    {
//        CGPoint location = [touch locationInView: self.view];
//
//        NSLog(@"%d: (%.0f, %.0f)", count, location.x, location.y);
//        count++;
//    }
//}


#pragma mark - 畫面布局相關
- (void) createBatteryView {
    mrBatteryView = [MRBatteryView sharedInstance];
    [self.view addSubview:mrBatteryView];
}
- (void) createAboutView {
    mrAbout =  [MRAbout sharedInstance];
}
- (void) createMenuView {
    mrMenuView = [MRMenuView sharedInstance];
    [self.view addSubview:mrMenuView];
}
- (void) createDashboardView {
    mrDashboardView = [MRDashboardView sharedInstance];
    [self.view addSubview:mrDashboardView];
}
- (void) createMoviesTableView {
    mrTableView = [MRTableView sharedInstance];
    [self.view addSubview:mrTableView];
}
- (void) createCameraView {
    mrPBJVisionView = [PBJVisionView sharedInstance];
    [self.view addSubview:mrPBJVisionView];
}
- (void) createSettingView {
    mrSettingView = [MRSettingView sharedInstance];
    [self.view addSubview:mrSettingView];
}
- (void) createMapView {
    mrMapView = [MRMapView sharedInstance];
    [self.view addSubview:mrMapView];
}
- (void) createScreenLockView {
    lbScreenView = [LBScreenLockView sharedInstance];
    [self.view addSubview:lbScreenView];
}
- (void) createStoreView {
    mrStoreView = [MRStoreView sharedInstance];
    [self.view addSubview:mrStoreView];
}

#pragma mark - MHAudioBufferPlayer
- (void)setUpAudioBufferPlayer
{
    // We need a lock because we update the Synth's state from the main thread
    // whenever the user presses a button, but we also read its state from an
    // audio thread in the MHAudioBufferPlayer callback. Doing both at the same
    // time is a bad idea and the lock prevents that.
    _synthLock = [[NSLock alloc] init];
    
    // The Synth and the MHAudioBufferPlayer must use the same sample rate.
    // Note that the iPhone is a lot slower than a desktop computer, so choose
    // a sample rate that is not too high and a buffer size that is not too low.
    // For example, a buffer size of 800 packets and a sample rate of 16000 Hz
    // means you need to fill up the buffer in less than 0.05 seconds. If it
    // takes longer, the sound will crack up.
    float sampleRate = 16000.0f;
    
    _synth = [[Synth alloc] initWithSampleRate:sampleRate];
    
    _player = [[MHAudioBufferPlayer alloc] initWithSampleRate:sampleRate
                                                     channels:1
                                               bitsPerChannel:16
                                             packetsPerBuffer:1024];
    _player.gain = 0.9f;
    
    __block __weak MRViewController *weakSelf = self;
    _player.block = ^(AudioQueueBufferRef buffer, AudioStreamBasicDescription audioFormat)
    {
        MRViewController *blockSelf = weakSelf;
        if (blockSelf != nil)
        {
            // Lock access to the synth. This callback runs on an internal
            // Audio Queue thread and we don't want to allow any other thread
            // to change the Synth's state while we're still filling up the
            // audio buffer.
            [blockSelf->_synthLock lock];
            
            // Calculate how many packets fit into this buffer. Remember that a
            // packet equals one frame because we are dealing with uncompressed
            // audio; a frame is a set of left+right samples for stereo sound,
            // or a single sample for mono sound. Each sample consists of one
            // or more bytes. So for 16-bit mono sound, each packet is 2 bytes.
            // For stereo it would be 4 bytes.
            int packetsPerBuffer = buffer->mAudioDataBytesCapacity / audioFormat.mBytesPerPacket;
            
            // Let the Synth write into the buffer. The Synth just knows how to
            // fill up buffers in a particular format and does not care where
            // they come from.
            int packetsWritten = [blockSelf->_synth fillBuffer:buffer->mAudioData frames:packetsPerBuffer];
            
            // We have to tell the buffer how many bytes we wrote into it. 
            buffer->mAudioDataByteSize = packetsWritten * audioFormat.mBytesPerPacket;	
            
            
            NSLog(@"GY..");
            
            [blockSelf->_synthLock unlock];
        }
    };
    
    //[[AVAudioSession sharedInstance] setDelegate:_player];
    
    [_player start];
}

//#pragma mark - 環境光源偵測
//- (void)proximityDidChange:(NSNotification *)n {
//    UIDevice *device = [n object];
//    
//    //感應物體接近時值為YES
//    if (device.proximityState)
//    {}
//}

#pragma mark - Viewcontroller init
- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if(!contentCreated)
    {
         NSLog(@"Google Mobile Ads SDK version: %@", [GADRequest sdkVersion]);
        
        [self showInterstitialAdMob];
        
//        //取得目前機器
//        UIDevice *device =[UIDevice currentDevice];
//        
//        //開啟環境光源感應器
//        device.proximityMonitoringEnabled = YES;
//        
//        //設定Observer通知
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(proximityDidChange:)
//                                                     name:@"UIDeviceProximityStateDidChangeNotification"
//                                                   object:device];
//    
//        
        // 不進入休眠
        UIApplication *app = [UIApplication sharedApplication];
        app.idleTimerDisabled = YES;
        
        mrPlist = [MRPlist sharedInstance];
        NSLog(@"before--->%@",mrPlist.plistDictionary);
        
        g_viewController = self;
        g_AdmobShowing = NO;
        
        
        // Configure the view.
        self.view.backgroundColor = [UIColor grayColor];
        //[self createAboutView];
        [self createMapView];
        [self createCameraView];
        [self createDashboardView];
        [self createBatteryView];
        [self createMenuView];
        [self createSettingView];
        [self createMoviesTableView];
        
        [[MRPlist sharedInstance] addObserver:self
                                   forKeyPath:@"g_key"
                                      options:NSKeyValueObservingOptionNew
                                      context:nil];
        
        // 觸發翻轉頁面到正確的設定值
        [MRPlist writePlist:@"MainScreen" content:[MRPlist readPlist:@"MainScreen"]];
       
        
        //        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        //        NSString *appName1 = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
        //
        
        
        //        float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
        //        if (ver >= 3.0) {
        //            // Only executes on version 3 or above.
        //        }
        //
        //                UIAlertView * myAlertView = [[UIAlertView alloc] initWithTitle:@"Version"
        //                                                                       message:[NSString stringWithFormat:@"os version:%f", ver]
        //                                                                      delegate:nil
        //                                                             cancelButtonTitle:@"OK"
        //                                                             otherButtonTitles: nil];
        //
        //                [myAlertView show];
        
        
//        UIButton * btnRadioPlay = [[UIButton alloc] initWithFrame: CGRectMake(CGRectGetMidX([[self.view layer] bounds]),
//                                                                              CGRectGetMidY([[self.view layer] bounds]),
//                                                                              _Menu_Icon_W_,
//                                                                              _Menu_Icon_H_)];
//        [btnRadioPlay setTag:_TAG_RADIO_PLAY_BTN_];
//        [btnRadioPlay setImage:[UIImage imageNamed:@"GPS_Record_Start"] forState:UIControlStateNormal];
//        [btnRadioPlay addTarget:self action:@selector(handleBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:btnRadioPlay];
//        
        
        contentCreated = YES;
        
//        NSString * removeAds = [NSString stringWithFormat:@"%@",[MRPlist readPlist:@"Setting" forkey:@"RemoveAds"]];
//        if ([removeAds isEqualToString:@"0"])
//            [self showAdMob];
        
        
        [self createStoreView];
        [self showAdMob];
        
//        [self setupLabel];
//        
//        [self setupBitmapFont];
//        [self setupLCDFont];
//        [self setupSquareFont];
//        [self setupSquareFont2];
        
        //[self createScreenLockView];
        //[self showScreenLockView];
        
        //[UIViewController attemptRotationToDeviceOrientation];//这行代码是关键
        
     
//                        NSArray *menuData = [MRJSON getJSONData:@"radio" categoryName:@"radioList-Taiwan"];
//                        NSDictionary *cellData = [menuData objectAtIndex:25];
//                        NSString * title = [cellData objectForKey:@"title"];
//                        NSString * uri = [cellData objectForKey:@"uri"];
//        
//                        NSLog(@"current volume = %f", [self getVolumeLevel]);
//        
//                        NSLog(@"title=%@, uri=%@", title,uri);
//                        channelAddr = uri;
//                
//                
//                        [self PlayAudioAll:YES];
 //////////////////////////////////////////////////////////////////////////////////////////////////////////



        /////////////////////////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(volumeChanged:)
//                                                     name:@"AVSystemController_SystemVolumeDidChangeNotification"
//                                                   object:nil];
//        
//        MPMusicPlayerController *ipodMusicPlayer = [MPMusicPlayerController iPodMusicPlayer];
//        [ipodMusicPlayer beginGeneratingPlaybackNotifications];
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(trackTheDeviceVolume:)
//                                                     name:MPMusicPlayerControllerVolumeDidChangeNotification
//                                                   object:nil];
//        
//  
        
    }
}



- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}
//- (BOOL) shouldAutorotate {
//    return YES;
//}
////- (NSUInteger)supportedInterfaceOrientations {
////    return UIInterfaceOrientationMaskLandscape;
////}
//- (NSUInteger) supportedInterfaceOrientations {
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//        return UIInterfaceOrientationMaskAllButUpsideDown;
//        //return UIInterfaceOrientationMaskLandscape;
//    //return UIInterfaceOrientationMaskLandscape; // 只支援橫螢幕
//    else
//        return UIInterfaceOrientationMaskAllButUpsideDown;
//        //return UIInterfaceOrientationMaskLandscape;
////    return UIInterfaceOrientationMaskLandscape; // 只支援橫螢幕
//    
//   // return UIInterfaceOrientationMaskLandscape;
//}
////- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
////{
////    return UIInterfaceOrientationLandscapeLeft|UIInterfaceOrientationLandscapeRight;
////}
//
////- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
////{
////    return (UIInterfaceOrientationMaskLandscape);
////}


// 隱藏Status Bar
- (BOOL) prefersStatusBarHidden {
    return YES;
}

- (void) removeAdmob {
    self.g_AdmobShowing = NO;
    [bannerView_ removeFromSuperview];
    [mrStoreView updateAll];
}

#pragma mark - KVO Main Screen
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@">>>>>>> keyPath:%@", keyPath);
    
    if([keyPath isEqualToString:@"g_key"]) {
        if([[change objectForKey:@"new"] isEqualToString:@"MainScreen"])
        {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
            hud.labelText = @"Please Wait...";
            hud.opacity = 0.5;
            hud.labelFont = [UIFont systemFontOfSize:10];
            
            if([mrPlist.g_content isEqualToString:@"Video"])
            {
                [mrMapView hidden:self.view];
                
                CGRect cameraFrame = [[self.view layer] bounds];
                if(g_viewController.g_AdmobShowing)
                    cameraFrame.origin.y = CGSizeFromGADAdSize(kGADAdSizeSmartBannerLandscape).height;
                else
                    cameraFrame.origin.y = 0;
                cameraFrame.size.height = [[self.view layer] bounds].size.height-cameraFrame.origin.y;
                
                [mrPBJVisionView setFrame:cameraFrame];
                [mrPBJVisionView show:self.view];
                
            }
            else if([mrPlist.g_content isEqualToString:@"Map"])
            {
                [mrPBJVisionView hidden:self.view];
                [mrMapView show:self.view];
            }
            else if([mrPlist.g_content isEqualToString:@"Hybrid"])
            {
                CGRect cameraFrame = [[self.view layer] bounds];
                cameraFrame.origin.x = CGRectGetMinX(cameraFrame);
                if(g_viewController.g_AdmobShowing)
                    cameraFrame.origin.y = CGSizeFromGADAdSize(kGADAdSizeSmartBannerLandscape).height;
                else
                    cameraFrame.origin.y = 0;
                
                cameraFrame.size.width = 150;
                cameraFrame.size.height = 150;
                
                [mrPBJVisionView hidden:self.view];
                [mrMapView show:self.view];
                
                [mrPBJVisionView setFrame:cameraFrame];

                [mrPBJVisionView show:self.view];
            }
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
        }
    }
}





- (void)setupLabel
{
    CGRect frame = CGRectMake(10, 0, 300, 50);
    FBGlowLabel *v = [[FBGlowLabel alloc] initWithFrame:frame];
    v.text = @"<>0123456789";
    v.textAlignment = NSTextAlignmentCenter;
    v.clipsToBounds = YES;
    v.backgroundColor = [UIColor clearColor];
    v.font = [UIFont fontWithName:@"Helvetica-Bold" size:40];
    v.alpha = 1.0;
    v.glowSize = 20;
    v.innerGlowSize = 4;
    v.textColor = UIColor.whiteColor;
    v.glowColor = UIColorFromRGB(0x00ffff);
    v.innerGlowColor = UIColorFromRGB(0x00ffff);
    self.label = v;
    [self.view addSubview:v];
}
- (void)setupBitmapFont
{
    CGRect frame = CGRectMake(10, 50, 300, 20);
    self.bfv = [[FBBitmapFontView alloc] initWithFrame:frame];
    self.bfv.text = @"MAS:100KMH";//[self time];
    self.bfv.dotType = FBFontDotTypeCircle;//FBFontDotTypeSquare;
    self.bfv.numberOfBottomPaddingDot = 1;
    self.bfv.numberOfTopPaddingDot    = 1;
    self.bfv.numberOfLeftPaddingDot   = 1;//2;
    self.bfv.numberOfRightPaddingDot  = 1;//2;
    self.bfv.glowSize = 20.0;
    self.bfv.innerGlowSize = 3.0;
    self.bfv.edgeLength = 3;//5.0;
    //self.bfv.onColor = UIColorFromRGB(0x00ffff);
    [self.view addSubview:self.bfv];
    [self.bfv resetSize];
   // [self.bfv centerizeInWidth:320];
}

- (void)setupLCDFont
{
//    CGRect frame = CGRectMake(10, 100, 300, 50);
//    FBLCDFontView *v = [[FBLCDFontView alloc] initWithFrame:frame];
//    v.text = @"100";
//    v.lineWidth = 2.0;//4.0;
//    v.drawOffLine = YES;
//    v.edgeLength = 10;//20;
//    v.margin = 5;//10.0;
//    v.backgroundColor = [UIColor clearColor];
//    v.horizontalPadding = 10;//20;
//    v.verticalPadding = 7;//14;
//    v.glowSize = 5;//10.0;
//    v.glowColor = UIColorFromRGB(0x00ffff);
//    v.innerGlowColor = UIColorFromRGB(0x00ffff);
//    v.innerGlowSize = 1.5;//3.0;
//    [self.view addSubview:v];
//    [v resetSize];
  
    
    CGRect frame = CGRectMake(CGRectGetMidX([[self.view layer] bounds]) ,
                              CGRectGetMidY([[self.view layer] bounds]) ,
                              50,
                              50);
    FBLCDFontView *v = [[FBLCDFontView alloc] initWithFrame:frame];
    [v setTag:_TAG_DASHBOARD_SPEED_LABEL_];
    v.text = @"---";
    v.lineWidth = 4.0;//4.0;
    v.drawOffLine = NO;
    v.edgeLength = 15;//20;
    v.margin = 8;//10.0;
    v.backgroundColor = [UIColor clearColor];
    v.horizontalPadding = 15;//20;
    v.verticalPadding = 10;//14;
    v.glowSize = 8;//10.0;
    v.glowColor = UIColorFromRGB(0x00ffff);
    v.innerGlowColor = UIColorFromRGB(0x00ffff);
    v.innerGlowSize = 2.5;//3.0;
    
    [self.view addSubview:v];
    
    [v resetSize];
    
    frame = v.frame;
    frame.origin.x = CGRectGetMidX([[self.view layer] bounds]) - v.frame.size.width/2;
    frame.origin.y = CGRectGetMidY([[self.view layer] bounds]) - v.frame.size.height/2;
    [v setFrame:frame];
}

- (void)setupSquareFont
{
    CGRect frame = CGRectMake(10, 150, 300, 50);
    FBSquareFontView *v = [[FBSquareFontView alloc] initWithFrame:frame];
    
    v.text = @"0123456789";
    v.lineWidth = 3.0;
    v.lineCap = kCGLineCapRound;
    v.lineJoin = kCGLineJoinRound;
    v.margin = 12.0;
    v.backgroundColor = [UIColor clearColor];
    v.horizontalPadding = 30;
    v.verticalPadding = 14;
    v.glowSize = 10.0;
    v.glowColor = UIColorFromRGB(0x00ffff);
    v.innerGlowColor = UIColorFromRGB(0x00ffff);
    v.lineColor = UIColorFromRGB(0xffffff); // 0xffdd66
    v.innerGlowSize = 2.0;
    v.verticalEdgeLength = 12;
    v.horizontalEdgeLength = 14;
    [self.view addSubview:v];
    [v resetSize];
   // [v centerizeInWidth:320];
}

- (void)setupSquareFont2
{
    CGRect frame = CGRectMake(10, 200, 300, 50);
    FBSquareFontView *v = [[FBSquareFontView alloc] initWithFrame:frame];
    v.text = @"0123456789";
    v.lineWidth = 3.0;
    v.margin = 12.0;
    v.lineCap = kCGLineCapSquare;
    v.lineJoin = kCGLineJoinMiter;
    v.backgroundColor = [UIColor clearColor];
    v.horizontalPadding = 10;
    v.verticalPadding = 10;
    v.glowSize = 10.0;
    v.glowColor = UIColorFromRGB(0x00ffff);
    v.innerGlowColor = UIColorFromRGB(0x00ffff);
    v.innerGlowSize = 2.0;
    v.horizontalEdgeLength = 6.0;
    v.verticalEdgeLength = 12.0;
    [self.view addSubview:v];
    [v resetSize];
   // [v centerizeInWidth:320];
}
@end
