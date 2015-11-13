//
//  MRButton.m
//  MobiRecorder
//
//  Created by GarY on 2015/4/29.
//  Copyright (c) 2015年 gyhouse. All rights reserved.
//

#import "MRButton.h"

@implementation MRButton


+ (void) createButton:(UIView*)view :(CGRect)rect :(UIImage*)img :(int)tag :(SEL)action
{
    UIButton * btn = [[UIButton alloc] initWithFrame: rect];
    [btn setImage:img forState:UIControlStateNormal];
    [btn setTag:tag];
    [btn addTarget:view.self action:action forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
}

@end
