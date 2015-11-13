//
//  LBScreenLockView.h
//  LightingBomb
//
//  Created by GarY on 2014/10/18.
//  Copyright (c) 2014年 gyhouse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBSliderView.h"
#import "MRViewController.h"


@interface LBScreenLockView : UIView <MBSliderViewDelegate>
+ (LBScreenLockView *)sharedInstance;
- (void) updateAll;
- (void) hidden:(UIView*)view;
- (void) show:(UIView*)view;

- (BOOL) isScreenLock;
- (void) setScreenLock:(BOOL)sw;

@end
