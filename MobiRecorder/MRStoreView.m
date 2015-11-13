//
//  MRStoreView.m
//  MobiRecorder
//
//  Created by GarY on 2014/10/14.
//  Copyright (c) 2014年 gyhouse. All rights reserved.
//

#import "MRStoreView.h"
#import <StoreKit/StoreKit.h>
#import "MRViewController.h"
#import "MRSettingView.h"
#import "MRTableView.h"
#import "MRMapView.h"
#import "PBJVisionView.h"

MRStoreView *g_mrStoreView;
extern MRMapView *g_mrMapView;
extern MRViewController *g_viewController;
extern MRSettingView *g_mrSettingView;
extern MRTableView *g_mrTableView;
extern PBJVisionView* g_mrPBJVisionView;

#define IAP_RemoveAds_PRODUCT_ID @"gyhouse.MobiRecorder.RemoveAds1"

static const CGFloat kLabelFontSize = 18.f;


@implementation MRStoreView

+ (MRStoreView *)sharedInstance
{
    static MRStoreView *singleton = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        CGRect frame = [[g_viewController.view layer] bounds];
        frame.origin.y = CGRectGetMinY(frame);
        singleton = [[MRStoreView alloc] initWithFrame:frame];
        g_mrStoreView = singleton;
    });
    return singleton;
}

#pragma mark
#pragma mark - 当用户点击了一个IAP项目，我们先查询用户是否允许应用内付费，如果不允许则不用进行以下步骤了。代码如下：
- (void) handleBtnClicked:(id)sender
{
    if(_TAG_STORE_BACK_BTN_ == ((UIButton *)sender).tag) {
        [g_mrPBJVisionView recordProcessing];
        [self hidden:g_viewController.view];
    }else if(_TAG_STORE_IAP_REMOVE_ADS_BTN_ == ((UIButton *)sender).tag) {

        if ([[MRPlist readPlist:@"RemoveAds"] isEqualToString:@"0"]){
            if ([SKPaymentQueue canMakePayments]) {
                // 执行下面提到的第5步：
                [self getProductInfo:IAP_RemoveAds_PRODUCT_ID];
            } else {
                NSLog(@"失败，用户禁止应用内付费购买.");
            }
        }else{
            
        }
        
    }else if(_TAG_STORE_RESTROE_PURCHASES_BTN_ == ((UIButton *)sender).tag) {
        
        [self alertUserRestorePayment];
    }
}


/*
 #pragma mark
 #pragma mark - 在viewDidLoad方法中，将购买页面设置成购买的Observer。
 - (void)viewDidLoad {
 [super viewDidLoad];
 // Do any additional setup after loading the view.
 // 監聽購買結果
 [[SKPaymentQueue defaultQueue] addTransactionObserver:(id)self];
 }
 
 - (void)viewDidUnload {
 [super viewDidUnload];
 [[SKPaymentQueue defaultQueue] removeTransactionObserver:(id)self];
 }

//*/

#pragma mark
#pragma mark - 我们先通过该IAP的ProductID向AppStore查询，获得SKPayment实例，然后通过SKPaymentQueue的 addPayment方法发起一个购买的操作。
// 下面的ProductId应该是事先在itunesConnect中添加好的，已存在的付费项目。否则查询会失败。
- (void)getProductInfo:(NSString*)productID {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated: YES];
    hud.labelText = @"Please Wait...";
    hud.opacity = 0.5;
    hud.labelFont = [UIFont systemFontOfSize:10];
    
    NSSet * set = [NSSet setWithArray:@[productID]];
    SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    request.delegate = (id)self;
    [request start];
    
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError");
    [MBProgressHUD hideHUDForView:self animated:YES];
    UIAlertView * myAlertView = [[UIAlertView alloc] initWithTitle:@"Store Error !"
                                                           message:[NSString stringWithFormat:@"%@", error]
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles: nil];
    [myAlertView show];

}

// 以上查询的回调函数
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *myProduct = response.products;
    if (myProduct.count == 0) {
        NSLog(@"無法獲取商品訊息，購買失敗。");
        [MBProgressHUD hideHUDForView:self animated:YES];
        return;
    }
    SKPayment * payment = [SKPayment paymentWithProduct:myProduct[0]];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark
#pragma mark - restoreCompletedTransactionsFailedWithError
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
 
    NSLog(@"restoreCompletedTransactionsFailedWithError error: %@", error);
    
//    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//        // Do something...
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [MBProgressHUD hideHUDForView:self animated:YES];
//        });
//    });
    
    [MBProgressHUD hideHUDForView:self animated:YES];
    
    UIAlertView * myAlertView = [[UIAlertView alloc] initWithTitle:@"Restore error !"
                                                           message:[NSString stringWithFormat:@"%@", error]
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles: nil];
    [myAlertView show];
    //[myAlertView dismissWithClickedButtonIndex:0 animated:YES];
    
    
    
}
#pragma mark
#pragma mark - paymentQueueRestoreCompletedTransactionsFinished
- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSMutableArray *purchasedItemIDs = [[NSMutableArray alloc] init];
    
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        NSString *productID = transaction.payment.productIdentifier;
        
        NSLog(@"received restored transactions productID: %@", productID);
        
        if([productID isEqualToString:IAP_RemoveAds_PRODUCT_ID]) {
            [MRPlist writePlist:@"RemoveAds" content:[NSString stringWithFormat:@"%@", @"1"]];
            [self updateAll];
            [g_viewController removeAdmob];
        }
        
        [purchasedItemIDs addObject:productID];
    }
    
//    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//        // Do something...
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [MBProgressHUD hideHUDForView:self animated:YES];
//        });
//    });
    
    [MBProgressHUD hideHUDForView:self animated:YES];
    
    UIAlertView * myAlertView = [[UIAlertView alloc] initWithTitle:@"Restore Completed !"
                                                           message:nil
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles: nil];
    [myAlertView show];
    
    
}

#pragma mark
#pragma mark - 当用户购买的操作有结果时，就会触发下面的回调函数，相应进行处理即可。
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:    //交易完成
                NSLog(@"transactionIdentifier = %@", transaction.transactionIdentifier);
                [self completeTransaction:transaction];
                
                [MRPlist writePlist:@"RemoveAds" content:[NSString stringWithFormat:@"%@", @"1"]];
                [self updateAll];
                [g_viewController removeAdmob];
                [MBProgressHUD hideHUDForView:self animated:YES];
                break;
            case SKPaymentTransactionStateFailed:       //交易失败
                [self failedTransaction:transaction];
                [self updateAll];
                
                break;
            case SKPaymentTransactionStateRestored:     //已经购买过该商品
                [self restoreTransaction:transaction];
                NSLog(@"已購買過此項商品");
                [self updateAll];
                //[MBProgressHUD hideHUDForView:self animated:YES];
                break;
            case SKPaymentTransactionStatePurchasing:   //商品添加进列表
                NSLog(@"商品添加进列表");
                [self updateAll];
                //[MBProgressHUD hideHUDForView:self animated:YES];
                break;
            default:
                break;
        }
    }
//    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//        // Do something...
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [MBProgressHUD hideHUDForView:self animated:YES];
//        });
//    });
}
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    // Your application should implement these two methods.
    NSString * productIdentifier = transaction.payment.productIdentifier;
    //NSString * receipt = [transaction.transactionReceipt base64EncodedString];
    if ([productIdentifier length] > 0) {
        // 向自己的服务器验证购买凭证
    }
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    

}
- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    if(transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"購買失敗");
        [MBProgressHUD hideHUDForView:self animated:YES];
    } else {
        NSLog(@"用户取消交易");
        [MBProgressHUD hideHUDForView:self animated:YES];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}
- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    // 对于已购商品，处理恢复购买的逻辑
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
   
            [self setHidden:YES];
            
            int separator_X         = 25;
            int separator_W         = [[self layer] bounds].size.width - separator_X*2;
            int separator_H         = 2;
            int contentStart_Y      = 10;
            int titleView_H         = 60;
            int contentInterval_H   = 10;
            int contentStart_X      = 20;//(self.frame.size.width/2)-60;
            int icon_W              = 64;
            int icon_H              = 64;
            
            //---------------------------------------------------------------------------
            // Background View
            //---------------------------------------------------------------------------
            UIImageView * backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG"]];
            CGRect backgroundFrame = [[self layer] bounds];
            backgroundImageView.frame = backgroundFrame;
            backgroundImageView.alpha = 1.0;
            [self addSubview:backgroundImageView];
        
            //---------------------------------------------------------------------------
            // titleView View
            //---------------------------------------------------------------------------
            UIView* titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, titleView_H)];
            titleView.backgroundColor=[UIColor clearColor];
            titleView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
            [titleView setTag:_TAG_STORE_TITLE_VIEW_];
            [self addSubview:titleView];
            //////////////
            // 我是分隔線 //
            //////////////
            UIImageView * SeparatorImageView0 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Separator"]];
            SeparatorImageView0.frame = CGRectMake(0,
                                                   titleView.frame.size.height-separator_H,
                                                   [[self layer] bounds].size.width,
                                                   separator_H);
            [titleView addSubview:SeparatorImageView0];
            //---------------------------------------------------------------------------
            // Title Icon
            //---------------------------------------------------------------------------
            UIImageView * titleIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Store"]];
            CGRect titleIconFrame = CGRectMake(CGRectGetMidX(self.frame)-titleView_H/2,
                                               0,
                                               titleView_H,
                                               titleView_H);
            titleIconImageView.frame = titleIconFrame;
            titleIconImageView.alpha = 1.0;
            [titleView addSubview:titleIconImageView];
            
            //---------------------------------------------------------------------------
            // Back 按鍵布局
            //---------------------------------------------------------------------------
            UIButton * btnBack = [[UIButton alloc] initWithFrame: CGRectMake(0,
                                                                             0,
                                                                             titleView_H,
                                                                             titleView_H)];
            
            [btnBack setTag:_TAG_STORE_BACK_BTN_];
            [btnBack setImage:[UIImage imageNamed:@"back-icon1"] forState:UIControlStateNormal];
            
            // 設定按鍵的觸發動作
            [btnBack addTarget:self action:@selector(handleBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [titleView addSubview:btnBack];
            //---------------------------------------------------------------------------
            // Back 按鍵布局
            //---------------------------------------------------------------------------
            UIButton * btnRestorePurchases = [[UIButton alloc] initWithFrame: CGRectMake(CGRectGetMaxX(titleView.frame)-titleView_H,
                                                                             0,
                                                                             titleView_H,
                                                                             titleView_H)];
            
            [btnRestorePurchases setTag:_TAG_STORE_RESTROE_PURCHASES_BTN_];
            [btnRestorePurchases setImage:[UIImage imageNamed:@"RestorePurchases"] forState:UIControlStateNormal];
            
            // 設定按鍵的觸發動作
            [btnRestorePurchases addTarget:self action:@selector(handleBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [titleView addSubview:btnRestorePurchases];
           
            //---------------------------------------------------------------------------
            // scrollView
            //---------------------------------------------------------------------------
            UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                                       titleView_H,
                                                                                       self.frame.size.width,
                                                                                       self.frame.size.height-titleView_H)];
            
            
            scrollView.backgroundColor = [UIColor clearColor];
            [scrollView setTag:_TAG_STORE_SCROLL_VIEW_];
            [self addSubview:scrollView];
            
            //---------------------------------------------------------------------------
            // contentView
            //---------------------------------------------------------------------------
            UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                            0,
                                                                            self.frame.size.width,
                                                                            self.frame.size.height)];
            [contentView setTag:_TAG_STORE_CONTENT_VIEW_];
            contentView.backgroundColor = [UIColor clearColor];
            
            
            
            
            //---------------------------------------------------------------------------
            // IAP - Remove Ads
            //---------------------------------------------------------------------------
            UIButton * btnRemoveAds = [[UIButton alloc] initWithFrame: CGRectMake(contentStart_X, contentStart_Y, icon_W, icon_H)];
            
            [btnRemoveAds setTag:_TAG_STORE_IAP_REMOVE_ADS_BTN_];
            [btnRemoveAds setImage:[UIImage imageNamed:@"RemoveAds0"] forState:UIControlStateNormal];
            
            // 設定按鍵的觸發動作
            [btnRemoveAds addTarget:self action:@selector(handleBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:btnRemoveAds];
            
            
            UILabel * removeAdsLabel=[[UILabel alloc] init];
            removeAdsLabel.textColor=[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
            [removeAdsLabel setFont:[UIFont fontWithName:@"Arial" size:kLabelFontSize]];
            removeAdsLabel.text=@"Remove Ads";
            CGSize labelSize = [removeAdsLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kLabelFontSize]}];
            removeAdsLabel.backgroundColor=[UIColor clearColor];
            
            [removeAdsLabel setFrame:CGRectMake(CGRectGetMidX(btnRemoveAds.frame)-labelSize.width/2,
                                                CGRectGetMaxY(btnRemoveAds.frame),
                                                labelSize.width,
                                                labelSize.height)];
            
            [contentView  addSubview:removeAdsLabel];
            
            //---------------------------------------------------------------------------
            //---------------------------------------------------------------------------
            //---------------------------------------------------------------------------
            contentStart_Y += removeAdsLabel.frame.origin.y + removeAdsLabel.frame.size.height+contentInterval_H;
            //---------------------------------------------------------------------------
            //---------------------------------------------------------------------------
            //---------------------------------------------------------------------------
            //////////////
            // 我是分隔線 //
            //////////////
            UIImageView * SeparatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Separator"]];
            SeparatorImageView.frame = CGRectMake(separator_X,
                                                  contentStart_Y-contentInterval_H/2,
                                                  separator_W,
                                                  separator_H);
            [contentView addSubview:SeparatorImageView];
            //---------------------------------------------------------------------------
            //---------------------------------------------------------------------------
            //---------------------------------------------------------------------------
            [contentView setFrame:CGRectMake(0,
                                             0,
                                             self.frame.size.width,
                                             contentStart_Y)];
            
            scrollView.contentSize = contentView.bounds.size;
            [scrollView addSubview:contentView];
            //---------------------------------------------------------------------------
            // 監聽購買結果
            //---------------------------------------------------------------------------
            [[SKPaymentQueue defaultQueue] addTransactionObserver:(id)self];
            
            
            
            [self updateAll];
        
    }
    return self;
}


- (void) addTransactionObserver {
    // 監聽購買結果
    [[SKPaymentQueue defaultQueue] addTransactionObserver:(id)self];
}
- (void) removeTransactionObserver {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:(id)self];
}
- (void) updateRemoveAds {
    UIView * contentView = (UIView*)[self viewWithTag:_TAG_STORE_CONTENT_VIEW_];
    UIButton * btnRemoveAds = (UIButton*)[contentView viewWithTag:_TAG_STORE_IAP_REMOVE_ADS_BTN_];
    NSString * removeAds = [MRPlist readPlist:@"RemoveAds"];

    if ([removeAds isEqualToString:@"0"]){
        [btnRemoveAds setImage:[UIImage imageNamed:@"RemoveAds0"] forState:UIControlStateNormal];
    }else if ([removeAds isEqualToString:@"1"]){
        [btnRemoveAds setImage:[UIImage imageNamed:@"RemoveAds1"] forState:UIControlStateNormal];
    }else{
        [btnRemoveAds setImage:[UIImage imageNamed:@"RemoveAds0"] forState:UIControlStateNormal];
        [MRPlist writePlist:@"RemoveAds" content:[NSString stringWithFormat:@"%@", @"0"]];
    }
    UIScrollView * scrollView = (UIScrollView*)[self viewWithTag:_TAG_STORE_SCROLL_VIEW_];
    UIView * titleView = (UIView*)[self viewWithTag:_TAG_STORE_TITLE_VIEW_];
    CGRect titleViewFrame = titleView.frame;
    CGRect scrollViewFrame = scrollView.frame;
    //    if ([removeAds isEqualToString:@"0"])
    //        scrollViewFrame.origin.y =  titleViewFrame.size.height + CGSizeFromGADAdSize(kGADAdSizeSmartBannerLandscape).height;
    //    else
    //        scrollViewFrame.origin.y = titleViewFrame.size.height;
    //
    if(g_viewController.g_AdmobShowing)
    {
        titleViewFrame.origin.y = CGSizeFromGADAdSize(kGADAdSizeSmartBannerLandscape).height;
    }
    else
    {
        titleViewFrame.origin.y = 0;
    }
    [titleView setFrame:titleViewFrame];
    
    if(g_viewController.g_AdmobShowing)
    {
        scrollViewFrame.origin.y =  titleViewFrame.size.height + CGSizeFromGADAdSize(kGADAdSizeSmartBannerLandscape).height;
    }
    else
    {
        scrollViewFrame.origin.y = titleViewFrame.size.height;
    }
    [scrollView setFrame:scrollViewFrame];
}
- (void) updateAll {
    [self updateRemoveAds];
}
- (void) hidden:(UIView*)view {
    [UIView transitionWithView:self
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{[self setHidden:YES];}
                    completion:NULL];
    
    
    
}
- (void) show:(UIView*)view {
    [self updateAll];
    [UIView transitionWithView:self
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{[self setHidden:NO];}
                    completion:NULL];
}

- (void)alertUserRestorePayment {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Restore Purchases"
                                                    message:@"You can restore your purchase history !"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"//NSLocalizedString(@"Cancel", @"離開")
                                          otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //Code.....
    switch (buttonIndex) {
        case 0:
            NSLog(@"Cancel Button Pressed");
            break;
        case 1:
        {
            NSLog(@"OK Button Pressed");
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated: YES];
            hud.labelText = @"Please Wait...";
            hud.opacity = 0.5;
            hud.labelFont = [UIFont systemFontOfSize:10];
            [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
            break;
        }
        case 2:
            NSLog(@"Button 2 Pressed");
            break;
        case 3:
            NSLog(@"Button 3 Pressed");
            break;
        default:
            break;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
