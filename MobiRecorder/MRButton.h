//
//  MRButton.h
//  MobiRecorder
//
//  Created by GarY on 2015/4/29.
//  Copyright (c) 2015年 gyhouse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRButton : NSObject

+ (void) createButton:(UIView*)view :(CGRect)rect :(UIImage*)img :(int)tag :(SEL)action;

@end
