//
//  MRViewController.h
//  MobRecorder
//

//  Copyright (c) 2014年 GarY WanG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRPlist.h"
#import "MRMenuView.h"
#import "MRDashboardView.h"
#import "MRSettingView.h"
#import "MRTableView.h"
#import "MRMapView.h"
#import "MRAbout.h"
#import "MRStoreView.h"
#import "MBProgressHUD.h"
#import "LBScreenLockView.h"
#import "MRJSON.h"

// 從 SDK 中匯入 GADInterstitial 的定義
@import GoogleMobileAds;



@interface MRViewController : UIViewController <GADBannerViewDelegate, GADInterstitialDelegate>
{
}

@property (strong,nonatomic) GADBannerView *bannerView_;
@property (strong,nonatomic) GADInterstitial *interstitial_; // 將其中一個宣告為執行個體變數
@property BOOL g_AdmobShowing;


- (void) removeAdmob;
- (void) showInterstitialAdMob;
//- (void) exchangeView:(BOOL)animation;
@end
