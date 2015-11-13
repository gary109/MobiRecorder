//
//  MRCustomAnnotation.h
//  MobRecorder
//
//  Created by GarY on 2014/8/27.
//  Copyright (c) 2014年 GarY WanG. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CLLocationManager.h>

@interface MRCustomAnnotation : NSObject <MKAnnotation>
{
    CLLocationCoordinate2D myCoordinate;
    NSString *mytitle;
    NSString *mysubtitle;
}

@property(nonatomic,assign) CLLocationCoordinate2D myCoordinate;
@property(retain, nonatomic) NSString *myTitle;
@property(retain, nonatomic) NSString *mySubTitle;

@end
