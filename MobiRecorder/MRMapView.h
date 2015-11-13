//
//  MRMapView.h
//  MobRecorder
//
//  Created by GarY on 2014/8/27.
//  Copyright (c) 2014年 GarY WanG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import "MRCustomAnnotation.h"
#import "MRPlist.h"
#import <AddressBook/AddressBook.h>
#import "MRViewController.h"

@interface MRMapView : UIView <MKMapViewDelegate>
{
    // routes points
    NSMutableArray* points;
    
    // the data representing the route points.
    MKPolyline* routeLine;
    
    // the view we create for the line on the map
    MKPolylineView* routeLineView;
    
    // the rect that bounds the loaded points
    MKMapRect routeRect;
    
    // current location
    CLLocation* _currentLocation;
}

@property (nonatomic, retain) NSMutableArray* points;
@property (nonatomic, retain) MKPolyline* routeLine;
@property (nonatomic, retain) MKPolylineView* routeLineView;
@property (nonatomic, retain) CLLocation* currentLocation;
@property bool trackingMode;

+ (MRMapView *)sharedInstance;
- (void) configureMapview;
- (void) configureRoutes;
- (void) updateAll;
- (void) clearRoutingLine;
- (void) hidden:(UIView*)view;
- (void) show:(UIView*)view;
@end
