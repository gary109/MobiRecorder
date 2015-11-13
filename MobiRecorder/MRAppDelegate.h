//
//  MRAppDelegate.h
//  MobRecorder
//
//  Created by GarY on 2014/7/7.
//  Copyright (c) 2014年 GarY WanG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRViewController.h"

@interface MRAppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>
{
    

}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MRViewController *mrViewController;

@end
