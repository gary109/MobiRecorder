//
//  MRCustomAnnotation.m
//  MobRecorder
//
//  Created by GarY on 2014/8/27.
//  Copyright (c) 2014年 GarY WanG. All rights reserved.
//

#import "MRCustomAnnotation.h"


@implementation MRCustomAnnotation
@synthesize myCoordinate;
@synthesize myTitle;
@synthesize mySubTitle;

//-(id) initWithCoordinate:(CLLocationCoordinate2D) coords
//{
//    if (self = [super init]) {
//        coordinate = coords;
//    }
//    return self;
//}

- (CLLocationCoordinate2D)coordinate
{
    return self.myCoordinate;
}

- (NSString *)title
{
    return self.myTitle;
}

- (NSString *)subtitle
{
    return self.mySubTitle;
}

@end