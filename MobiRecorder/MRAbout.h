//
//  MRAbout.h
//  MobiRecorder
//
//  Created by GarY on 2014/9/5.
//  Copyright (c) 2014年 gyhouse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRAbout : UIView

+ (MRAbout *)sharedInstance;

- (void) updateAll;
- (void) hidden:(UIView*)view;
- (void) show:(UIView*)view;

@end
