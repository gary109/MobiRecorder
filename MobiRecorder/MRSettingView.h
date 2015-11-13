//
//  MRSettingView.h
//  MobRecorder
//
//  Created by GarY on 2014/8/24.
//  Copyright (c) 2014年 GarY WanG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALDisk.h"
#import "MRPlist.h"

@interface MRSettingView : UIView

+ (MRSettingView *)sharedInstance;

- (void) updateAll;
- (void) hidden:(UIView*)view;
- (void) show:(UIView*)view;

@end
