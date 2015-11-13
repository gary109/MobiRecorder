//
//  MRMenuView.h
//  MobRecorder
//
//  Created by GarY on 2014/8/22.
//  Copyright (c) 2014年 GarY WanG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRMenuView : UIView <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
+ (MRMenuView *)sharedInstance;
- (void) hidden:(UIView*)view;
- (void) show:(UIView*)view;
@end
