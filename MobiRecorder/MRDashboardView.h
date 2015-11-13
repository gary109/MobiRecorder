//
//  MRDashboardView.h
//  MobRecorder
//
//  Created by GarY on 2014/8/22.
//  Copyright (c) 2014年 GarY WanG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRPlist.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>

@interface MRDashboardView : UIView <CLLocationManagerDelegate>
{

}
+ (MRDashboardView *)sharedInstance;
- (void) hidden:(UIView*)view;
- (void) show:(UIView*)view;


- (void) start;
- (void) stop;
@end
