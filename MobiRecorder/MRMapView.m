//
//  MRMapView.m
//  MobRecorder
//
//  Created by GarY on 2014/8/27.
//  Copyright (c) 2014年 GarY WanG. All rights reserved.
//

#import "MRMapView.h"
#import "MRMenuView.h"


MRMapView *g_mrMapView;
extern MRViewController *g_viewController;
extern MRMenuView  *g_mrMenuView;

@interface MRMapView () {
    bool trackingMode;
    double DST;
    double AVS;
    double AVS_TMP;
    double MXS;
    CLLocationCoordinate2D coordinate;
}
@property NSString * speedUnit;
@property (nonatomic,retain) NSDate* trackingStartDate;
@property (nonatomic,strong) MRCustomAnnotation *mrStartAnnotation;
@property (nonatomic,strong) NSTimer* updateTimer;
@property (nonatomic,strong) MKMapView *map;
@end

@implementation MRMapView
@synthesize trackingMode;
@synthesize speedUnit;
@synthesize trackingStartDate;
@synthesize mrStartAnnotation;
@synthesize map;
@synthesize updateTimer;
@synthesize points = _points;
@synthesize routeLine = _routeLine;
@synthesize routeLineView = _routeLineView;

#pragma mark
#pragma mark 速度轉換
static double const kTTTMetersPerSecondToKilometersPerHourCoefficient = 3.6;
//static double const kTTTMetersPerSecondToFeetPerSecondCoefficient = 3.2808399;
static double const kTTTMetersPerSecondToMilesPerHourCoefficient = 2.23693629;
static inline double CLLocationSpeedToKilometersPerHour(CLLocationSpeed speed) {
    return speed * kTTTMetersPerSecondToKilometersPerHourCoefficient;
}
//static inline double CLLocationSpeedToFeetPerSecond(CLLocationSpeed speed)
//{
//    return speed * kTTTMetersPerSecondToFeetPerSecondCoefficient;
//}
static inline double CLLocationSpeedToMilesPerHour(CLLocationSpeed speed)
{
    return speed * kTTTMetersPerSecondToMilesPerHourCoefficient;
}

+ (MRMapView *)sharedInstance
{
    static MRMapView *singleton = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        singleton = [[MRMapView alloc] initWithFrame:[[g_viewController.view layer] bounds]];
        g_mrMapView = singleton;
    });
    return singleton;
}

#pragma mark - KVO
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@">>>>>>> keyPath:%@", keyPath);
    
    if([keyPath isEqualToString:@"g_AdmobShowing"])
    {
        UIView * trackingInfoView = (UIView*)[self viewWithTag:_TAG_MAP_TRACKING_INFO_VIEW_];
        
        CGRect trackingInfoViewFrame = trackingInfoView.frame;
        
        if(g_viewController.g_AdmobShowing)
            trackingInfoViewFrame.origin.y = CGSizeFromGADAdSize(kGADAdSizeSmartBannerLandscape).height;
        else
            trackingInfoViewFrame.origin.y = 0;
        [trackingInfoView setFrame:trackingInfoViewFrame];
    }
    else if([keyPath isEqualToString:@"g_key"])
    {
        if([[change objectForKey:@"new"] isEqualToString:@"SpeedUnit"])
        {
            speedUnit = [MRPlist readPlist:@"SpeedUnit"];
            [self performSelectorOnMainThread:@selector(updateTrackingInfo) withObject:nil waitUntilDone:NO];
        }
    }
    else if([keyPath isEqualToString:@"trackingMode"])
    {
        if(trackingMode)
        {
            DST = 0.0;
            AVS = 0.0;
            MXS = 0.0;
            
            //        map.userInteractionEnabled = NO;
            //        map.rotateEnabled = NO;
            //        map.zoomEnabled = NO;
            //        map.multipleTouchEnabled = NO;
            //        map.scrollEnabled = NO;
            //
            
            [map setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
            trackingStartDate = [NSDate date];
            trackingMode = YES;
            
            [self createAnnotationWithCoords:coordinate];
        }
        else
        {
            map.userInteractionEnabled = YES;
            [map setRotateEnabled:YES];
            [map setZoomEnabled:YES];
            [map setMultipleTouchEnabled:YES];
            [map setScrollEnabled:YES];
            
            [map setUserTrackingMode:MKUserTrackingModeNone animated:YES];
        }
    }
}


#pragma mark
#pragma mark 螢幕截圖
- (void) snapshotMapView {
    float brightness = [UIScreen mainScreen].brightness;
    [[UIScreen mainScreen] setBrightness:0.1f];
    UIGraphicsBeginImageContext(map.bounds.size);
    [map.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
    [[UIScreen mainScreen] setBrightness:brightness];
}
#pragma mark
#pragma mark 按鍵事件處理
- (void) handleSnapshotBtnClicked:(id)sender {
    NSLog(@"%@ handleSnapshotBtnClicked.",sender);
    [self snapshotMapView];
}
- (void) handleDeleteBtnClicked:(id)sender {
    NSLog(@"%@ handleDeleteBtnClicked.",sender);
    [self clearRoutingLine];
}
- (void) clearRoutingLine
{
    DST = 0.0;
    AVS = 0.0;
    MXS = 0.0;
    
    [self performSelectorOnMainThread:@selector(updateTrackingInfo) withObject:nil waitUntilDone:NO];
    //    [self updateTrackingInfo];
    
    [_points removeAllObjects];
    _points = nil;
    [map removeAnnotations:map.annotations];
    [map removeOverlays:map.overlays];
    if(trackingMode)
        [self createAnnotationWithCoords:coordinate];
}
- (void) handleGPSTrackingStartStopBtnClicked:(id)sender {
    NSLog(@"%@ handleGPSTrackingStartStopBtnClicked.",sender);
    
    UIButton * button = (UIButton *)[self viewWithTag:_TAG_MAP_GPS_RECORD_BTN_];
    
    if(NO == trackingMode){
        [button setImage: [UIImage imageNamed:@"GPS_Record_Stop.png"] forState:UIControlStateNormal];
      
        DST = 0.0;
        AVS = 0.0;
        MXS = 0.0;
        
//        map.userInteractionEnabled = NO;
//        map.rotateEnabled = NO;
//        map.zoomEnabled = NO;
//        map.multipleTouchEnabled = NO;
//        map.scrollEnabled = NO;
//
        
        [map setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
        trackingStartDate = [NSDate date];
        trackingMode = YES;
            
        [self createAnnotationWithCoords:coordinate];
        
    }else{
        [button setImage: [UIImage imageNamed:@"GPS_Record_Start.png"] forState:UIControlStateNormal];
        
    
        
        map.userInteractionEnabled = YES;
        [map setRotateEnabled:YES];
        [map setZoomEnabled:YES];
        [map setMultipleTouchEnabled:YES];
        [map setScrollEnabled:YES];
        
        [map setUserTrackingMode:MKUserTrackingModeNone animated:YES];
      
        trackingMode = NO;
    }
    NSLog(@"Latitude:%f Longitude:%f",coordinate.latitude, coordinate.longitude);
}
- (void) mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    dispatch_async(dispatch_get_main_queue(),^{
//        if ([CLLocationManager locationServicesEnabled]) {
//            if ([CLLocationManager headingAvailable]) {
//                [map setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
//            }else{
//                [map setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
//            }
//        }else{
//            [map setUserTrackingMode:MKUserTrackingModeNone animated:YES];
//        }
        if(trackingMode) {
            [map setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
        }else{
            [map setUserTrackingMode:MKUserTrackingModeNone animated:YES];
        }
        
    });
}


#pragma mark
#pragma mark Annotation事件處理
- (MKAnnotationView *) mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if ([annotation isKindOfClass:[MRCustomAnnotation class]]){
        static NSString *MyAnnotationIdentifier = @"myAnnotation";
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[map dequeueReusableAnnotationViewWithIdentifier:MyAnnotationIdentifier];
        
        
        
        if (!pinView){
            MKPinAnnotationView* myPinView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:MyAnnotationIdentifier];
            myPinView.pinColor = MKPinAnnotationColorGreen;
            myPinView.animatesDrop = YES;
            myPinView.canShowCallout = YES;
            return myPinView;
            
//            MKAnnotationView *newAnimation = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annotation.title];
//            newAnimation.canShowCallout =YES;
//            newAnimation.image = [UIImage imageNamed:@"GPS_Record_Start.png"];
//            return newAnimation;
            
            
        }else{
            return pinView;
        }
    }
    return nil;
}
- (void) createAnnotationWithCoords:(CLLocationCoordinate2D) coords {
    mrStartAnnotation.myCoordinate = coords;
    mrStartAnnotation.myTitle = @"Start";
//    mrAnnotation.mySubTitle = subtitle;
    [map addAnnotation:mrStartAnnotation];
    
}
#pragma mark
#pragma mark Annotation事件處理
- (void) findDirectionsFrom:(MKMapItem *)source to:(MKMapItem *)destination {
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = source;
    request.destination = destination;
    request.requestsAlternateRoutes = YES;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         
         if (error) {
             
             NSLog(@"error:%@", error);
         }
         else {
             
             MKRoute *route = response.routes[0];
             
             [self.map addOverlay:route.polyline];
         }
     }];
}
#pragma mark
#pragma mark Tracking Info 初始化
- (void) createTrackingInfoView {
    UIView * trackingInfoView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.frame)-80,CGRectGetMinY(self.frame),150,65)];
    
    [trackingInfoView setTag:_TAG_MAP_TRACKING_INFO_VIEW_];
    [trackingInfoView sizeToFit];
    //---------------------------------------------------------------------------
    // trackingInfoView - 設定邊框
    //---------------------------------------------------------------------------
    // 將圖層的邊框設置為圓腳
    trackingInfoView.layer.cornerRadius = 5;
    trackingInfoView.layer.masksToBounds = YES;
    
    // 給圖層添加一個有色邊框
    trackingInfoView.layer.borderWidth = 2;
    trackingInfoView.layer.borderColor = [[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.5] CGColor];
   
    //---------------------------------------------------------------------------
    // trackingInfoView - 設定背景
    //---------------------------------------------------------------------------
    UIImageView * backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG"]];
    backgroundImageView.frame =  [[trackingInfoView layer] bounds];
    backgroundImageView.alpha = 0.8;
    
    [trackingInfoView addSubview:backgroundImageView];
    //---------------------------------------------------------------------------
    // trackingInfoView - DST
    //---------------------------------------------------------------------------
    CGRect dstLabelFrame = trackingInfoView.bounds;
    dstLabelFrame.origin.x = CGRectGetMinX(dstLabelFrame)+25;
    dstLabelFrame.origin.y = CGRectGetMinY(dstLabelFrame)+20*0;
    dstLabelFrame.size.height = 20;
    dstLabelFrame.size.width = dstLabelFrame.size.width;
    
    UILabel * dstLabel = [[UILabel alloc] initWithFrame:dstLabelFrame];
    [dstLabel setTag:_TAG_MAP_TRACKING_DST_LABEL_];
    dstLabel.textColor=[UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0];
    [dstLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    dstLabel.transform = CGAffineTransformMakeScale(1.25f, 1.25f);
    dstLabel.backgroundColor=[UIColor clearColor];
    dstLabel.text = [NSString stringWithFormat:@"DST:%3.0f m",DST];
    [trackingInfoView addSubview:dstLabel];
    //---------------------------------------------------------------------------
    // trackingInfoView - MXS
    //---------------------------------------------------------------------------
    CGRect mxsLabelFrame = trackingInfoView.bounds;
    mxsLabelFrame.origin.x = CGRectGetMinX(mxsLabelFrame)+25;
    mxsLabelFrame.origin.y = CGRectGetMinY(mxsLabelFrame)+20*1;
    mxsLabelFrame.size.height = 20;
    mxsLabelFrame.size.width = mxsLabelFrame.size.width;
    
    UILabel * mxsLabel = [[UILabel alloc] initWithFrame:mxsLabelFrame];
    [mxsLabel setTag:_TAG_MAP_TRACKING_MXS_LABEL_];
    mxsLabel.textColor=[UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0];
    [mxsLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    mxsLabel.transform = CGAffineTransformMakeScale(1.25f, 1.25f);
    mxsLabel.backgroundColor=[UIColor clearColor];
    speedUnit = [MRPlist readPlist:@"SpeedUnit"];
    if([speedUnit isEqualToString:@"km/h"])
        mxsLabel.text = [NSString stringWithFormat:@"MXS:%3.0f km/h",MXS];
    else
        mxsLabel.text = [NSString stringWithFormat:@"MXS:%3.0f MPH",MXS];
    [trackingInfoView addSubview:mxsLabel];
    //---------------------------------------------------------------------------
    // trackingInfoView - AVS
    //---------------------------------------------------------------------------
    CGRect avsLabelFrame = trackingInfoView.bounds;
    avsLabelFrame.origin.x = CGRectGetMinX(avsLabelFrame)+25;
    avsLabelFrame.origin.y = CGRectGetMinY(avsLabelFrame)+20*2;
    avsLabelFrame.size.height = 20;
    avsLabelFrame.size.width = avsLabelFrame.size.width;
    
    UILabel * avsLabel = [[UILabel alloc] initWithFrame:avsLabelFrame];
    [avsLabel setTag:_TAG_MAP_TRACKING_AVS_LABEL_];
    avsLabel.textColor=[UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0];
    [avsLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    avsLabel.transform = CGAffineTransformMakeScale(1.25f, 1.25f);
    avsLabel.backgroundColor=[UIColor clearColor];
    if([speedUnit isEqualToString:@"km/h"])
        avsLabel.text = [NSString stringWithFormat:@"AVS:%3.0f km/h",AVS];
    else
        avsLabel.text = [NSString stringWithFormat:@"AVS:%3.0f MPH",AVS];
    [trackingInfoView addSubview:avsLabel];
    //---------------------------------------------------------------------------
    [map addSubview:trackingInfoView];
    
    
}
#pragma mark
#pragma mark 工具列初始化
- (void) createToolbarView {
    UIView * toolbarView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.frame)-_Menu_Icon_W_,CGRectGetMidY(self.frame)-_Menu_Icon_H_*3/2,_Menu_Icon_W_,_Menu_Icon_H_*3)];
    
//    [toolbarView setTag:_TAG_MAP_TRACKING_INFO_VIEW_];
//    [toolbarView sizeToFit];
    //---------------------------------------------------------------------------
    // toolbarView - 設定邊框
    //---------------------------------------------------------------------------
    // 將圖層的邊框設置為圓腳
    toolbarView.layer.cornerRadius = 5;
    toolbarView.layer.masksToBounds = YES;
    
    // 給圖層添加一個有色邊框
    toolbarView.layer.borderWidth = 2;
    toolbarView.layer.borderColor = [[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.5] CGColor];
    
    //---------------------------------------------------------------------------
    // toolbarView - 設定背景
    //---------------------------------------------------------------------------
    UIImageView * backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG"]];
    backgroundImageView.frame =  [[toolbarView layer] bounds];
    backgroundImageView.alpha = 0.8;
    [toolbarView addSubview:backgroundImageView];
    //---------------------------------------------------------------------------
    // toolbarView - btnSnapstop
    //---------------------------------------------------------------------------
    CGRect btnSnapstopFrame = toolbarView.bounds;
    btnSnapstopFrame.origin.x = CGRectGetMinX(btnSnapstopFrame);
    btnSnapstopFrame.origin.y = CGRectGetMinY(btnSnapstopFrame)+_Menu_Icon_H_*0;
    btnSnapstopFrame.size.height = _Menu_Icon_H_;
    btnSnapstopFrame.size.width = _Menu_Icon_W_;
    
    UIButton * btnSnapstop = [[UIButton alloc] initWithFrame:btnSnapstopFrame];
    [btnSnapstop setTag:_TAG_MAP_SNAPSHOT_BTN_];
    [btnSnapstop setImage: [UIImage imageNamed:@"Photo-Video-Camera-icon"] forState:UIControlStateNormal];
    [btnSnapstop addTarget:self action:@selector(handleSnapshotBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [toolbarView addSubview:btnSnapstop];
    //---------------------------------------------------------------------------
    // toolbarView - GPSTrackingStartStopButton
    //---------------------------------------------------------------------------
    CGRect btnGPSTrackingStartStopButtonFrame = toolbarView.bounds;
    btnGPSTrackingStartStopButtonFrame.origin.x = CGRectGetMinX(btnGPSTrackingStartStopButtonFrame);
    btnGPSTrackingStartStopButtonFrame.origin.y = CGRectGetMinY(btnGPSTrackingStartStopButtonFrame)+_Menu_Icon_H_*1;
    btnGPSTrackingStartStopButtonFrame.size.height = _Menu_Icon_H_;
    btnGPSTrackingStartStopButtonFrame.size.width = _Menu_Icon_W_;
    UIButton * btnGPSTrackingStartStopButton = [[UIButton alloc] initWithFrame:btnGPSTrackingStartStopButtonFrame];
    [btnGPSTrackingStartStopButton setTag:_TAG_MAP_GPS_RECORD_BTN_];
    [btnGPSTrackingStartStopButton setImage: [UIImage imageNamed:@"GPS_Record_Start"] forState:UIControlStateNormal];
    [btnGPSTrackingStartStopButton addTarget:self action:@selector(handleGPSTrackingStartStopBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [toolbarView addSubview:btnGPSTrackingStartStopButton];
    //---------------------------------------------------------------------------
    // toolbarView - DeleteButton
    //---------------------------------------------------------------------------
    CGRect btnDeleteAllPinFrame = toolbarView.bounds;
    btnDeleteAllPinFrame.origin.x = CGRectGetMinX(btnDeleteAllPinFrame);
    btnDeleteAllPinFrame.origin.y = CGRectGetMinY(btnDeleteAllPinFrame)+_Menu_Icon_H_*2;
    btnDeleteAllPinFrame.size.height = _Menu_Icon_H_;
    btnDeleteAllPinFrame.size.width = _Menu_Icon_W_;
    UIButton * btnDeleteAllPin = [[UIButton alloc] initWithFrame:btnDeleteAllPinFrame];
    [btnDeleteAllPin setTag:_TAG_MAP_DELETE_BTN_];
    [btnDeleteAllPin setImage: [UIImage imageNamed:@"Delete-icon1"] forState:UIControlStateNormal];
    [btnDeleteAllPin addTarget:self action:@selector(handleDeleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnDeleteAllPin.tag = 3;
    [toolbarView addSubview:btnDeleteAllPin];
    //---------------------------------------------------------------------------
    [self addSubview:toolbarView];
}
#pragma mark
#pragma mark 地圖初始化
- (void) createMapView {
    map = [[MKMapView alloc] initWithFrame:[self.layer bounds]];
    map.delegate = self;
    map.showsUserLocation = YES;
    map.mapType = MKMapTypeStandard;
    
    trackingMode = NO;

    map.userInteractionEnabled = YES;
    [map setRotateEnabled:YES];
    [map setZoomEnabled:YES];
    [map setMultipleTouchEnabled:YES];
    [map setScrollEnabled:YES];
    [map setUserTrackingMode:MKUserTrackingModeNone animated:YES];
    
    [self addSubview:map];
    
    CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(24.987328, 121.444333);
    
    float zoomLevel = 0.02;
    MKCoordinateRegion region = MKCoordinateRegionMake(coords, MKCoordinateSpanMake(zoomLevel, zoomLevel));
    [map setRegion:[map regionThatFits:region] animated:YES];
}
#pragma mark
#pragma mark 地圖視圖更新
- (void) updateMapView{
//    float zoomLevel = 0.02;
//    CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
//    MKCoordinateRegion region = MKCoordinateRegionMake(coords, MKCoordinateSpanMake(zoomLevel, zoomLevel));
//    [map setRegion:[map regionThatFits:region] animated:YES];
}

#pragma mark
#pragma mark 按鍵視圖更新
- (void) updateSnapshotButton{
    UIButton * button = (UIButton *)[self viewWithTag:_TAG_MAP_SNAPSHOT_BTN_];
    [button setFrame:CGRectMake(CGRectGetMaxX(self.frame)-_Menu_Icon_W_,CGRectGetMinY(self.frame)+20+_Menu_Icon_H_*0,_Menu_Icon_W_,_Menu_Icon_H_)];
}
- (void) updateGPSTrackingStartStopButton{
    UIButton * button = (UIButton *)[self viewWithTag:_TAG_MAP_GPS_RECORD_BTN_];
    [button setFrame:CGRectMake(CGRectGetMaxX(self.frame)-_Menu_Icon_W_,CGRectGetMinY(self.frame)+20+_Menu_Icon_H_*1,_Menu_Icon_W_,_Menu_Icon_H_)];
}
- (void) updateDeleteButton{
    UIButton * button = (UIButton *)[self viewWithTag:_TAG_MAP_DELETE_BTN_];
    [button setFrame:CGRectMake(CGRectGetMaxX(self.frame)-_Menu_Icon_W_,CGRectGetMidY(self.frame)+20+_Menu_Icon_H_*2,_Menu_Icon_W_,_Menu_Icon_H_)];
}
#pragma mark
#pragma mark 設定地圖起始位置
- (void) configureMapview {
    // 蓋瑞王的家
    CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(24.987328, 121.444333);
    float zoomLevel = 0.02;
    MKCoordinateRegion region = MKCoordinateRegionMake(coords, MKCoordinateSpanMake(zoomLevel, zoomLevel));
    [map setRegion:[map regionThatFits:region] animated:YES];
}
#pragma mark
#pragma mark 視框初始化
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [g_viewController addObserver:self
                           forKeyPath:@"g_AdmobShowing"
                              options:NSKeyValueObservingOptionNew
                              context:nil];
        
        [[MRPlist sharedInstance] addObserver:self
                                   forKeyPath:@"g_key"
                                      options:NSKeyValueObservingOptionNew
                                      context:nil];
        DST = 0.0;
        AVS = 0.0;
        MXS = 0.0;
        
        speedUnit = [MRPlist readPlist:@"SpeedUnit"];
        if([speedUnit isEqualToString:@"km/h"])
            speedUnit = @"km/h";
        else
            speedUnit = @"MPH";
        
        
        mrStartAnnotation = [[MRCustomAnnotation alloc] init];
        [self createMapView];
        [self configureMapview];
        
        
        
        [self createTrackingInfoView];
        //[self createToolbarView];
        if(trackingMode)
            [self configureRoutes];
        [self updateTrackingInfo];
        
        [self addObserver:self
                                   forKeyPath:@"trackingMode"
                                      options:NSKeyValueObservingOptionNew
                                      context:nil];
    }
    return self;
}
#pragma mark
#pragma mark 所有元件布局更新
- (void) updateAll {
    [self updateDeleteButton];
    [self updateGPSTrackingStartStopButton];
    [self updateSnapshotButton];
    [self updateMapView];
    [self updateTrackingInfo];
}
- (void) hidden:(UIView*)view {
    [UIButton beginAnimations:nil context:nil];
    [UIButton setAnimationDuration:0.5];
    [UIButton setAnimationBeginsFromCurrentState:YES];
    [UIButton setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                             forView:self cache:YES];
    self.hidden = YES;
    [UIButton commitAnimations];
}
- (void) show:(UIView*)view {
    [UIButton beginAnimations:nil context:nil];
    [UIButton setAnimationDuration:0.5];
    [UIButton setAnimationBeginsFromCurrentState:YES];
    [UIButton setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                             forView:self cache:YES];
    self.hidden = NO;
    [UIButton commitAnimations];
}
#pragma mark
#pragma mark 路線設定與繪製
- (void) configureRoutes {
    // define minimum, maximum points
    MKMapPoint northEastPoint = MKMapPointMake(0.f, 0.f);
    MKMapPoint southWestPoint = MKMapPointMake(0.f, 0.f);
    
    // create a c array of points.
    MKMapPoint* pointArray = malloc(sizeof(CLLocationCoordinate2D) * _points.count);
    
    // for(int idx = 0; idx < pointStrings.count; idx++)
    for(int idx = 0; idx < _points.count; idx++)
    {
        CLLocation *location = [_points objectAtIndex:idx];
        CLLocationDegrees latitude  = location.coordinate.latitude;
        CLLocationDegrees longitude = location.coordinate.longitude;
        
        // create our coordinate and add it to the correct spot in the array
        coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        MKMapPoint point = MKMapPointForCoordinate(coordinate);
        
        // if it is the first point, just use them, since we have nothing to compare to yet.
        if (idx == 0) {
            northEastPoint = point;
            southWestPoint = point;
        } else {
            if (point.x > northEastPoint.x)
                northEastPoint.x = point.x;
            if(point.y > northEastPoint.y)
                northEastPoint.y = point.y;
            if (point.x < southWestPoint.x)
                southWestPoint.x = point.x;
            if (point.y < southWestPoint.y)
                southWestPoint.y = point.y;
        }
        
        pointArray[idx] = point;
    }
    
//    if (self.routeLine) {
//        [self.map removeOverlay:self.routeLine];
//    }
    
    self.routeLine = [MKPolyline polylineWithPoints:pointArray count:_points.count];
    
    // add the overlay to the map
    if (nil != self.routeLine) {
        [self.map addOverlay:self.routeLine];
    }
    
    // clear the memory allocated earlier for the points
    free(pointArray);
    if(_points.count > _MAP_DrawPointsMax)
        [_points removeAllObjects];
    
//     double width = northEastPoint.x - southWestPoint.x;
//     double height = northEastPoint.y - southWestPoint.y;
//     
//     routeRect = MKMapRectMake(southWestPoint.x, southWestPoint.y, width, height);
//     
//     // zoom in on the route. 
//     [map setVisibleMapRect:routeRect];
    NSLog(@"_points.count:%lu",(unsigned long)_points.count);
}

//- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
//{
//    if ([overlay isKindOfClass:[MKPolyline class]]) {
//        MKPolyline *route = overlay;
//        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
//        routeRenderer.strokeColor = [UIColor blueColor];
//        return routeRenderer;
//    }
//    else return nil;
//}



#pragma mark
#pragma mark MKMapViewDelegate
- (void) mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews {
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    NSLog(@"overlayViews: %@", overlayViews);
}
- (MKOverlayView *) mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    
    MKOverlayView* overlayView = nil;
    
    if(overlay == self.routeLine)
    {
        //if we have not yet created an overlay view for this overlay, create it now.
        if (self.routeLineView) {
            [self.routeLineView removeFromSuperview];
        }
        
        self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
        self.routeLineView.fillColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.8];
        self.routeLineView.strokeColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.8];
        self.routeLineView.lineWidth = 10;
        
        overlayView = self.routeLineView;
    }
    
    return overlayView;
}
// 隱藏Status Bar
- (BOOL) prefersStatusBarHidden {
    return YES;
}
- (void) mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    NSLog(@"annotation views: %@", views);
}
- (void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    
    
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude
                                                      longitude:userLocation.coordinate.longitude];
//    // check the zero point
    if  (userLocation.coordinate.latitude == 0.0f ||
         userLocation.coordinate.longitude == 0.0f){
//        trackingStartDate = [NSDate date];
        return;
    }
    
    if (_points.count > 0) {
        CLLocationDistance distance = [location distanceFromLocation:_currentLocation];
        if (_MAP_DISTANCE_5M > distance)
            return;
        else if (_MAP_DISTANCE_1000M < distance)
            return;
        else
            DST += distance;
    }

    if(trackingMode) {
        if (nil == _points) {
            _points = [[NSMutableArray alloc] init];
        }
        [_points addObject:location];
        
        double speed;
        
        
        if([speedUnit isEqualToString:@"km/h"])
            speed = CLLocationSpeedToKilometersPerHour(userLocation.location.speed);
        else
            speed = CLLocationSpeedToMilesPerHour(userLocation.location.speed);
            
        if(speed < 0)
            speed = 0;
        
        if(speed > MXS)
            MXS = speed;
        
//        if(distance)
//        {
//            trackingEndDate = [[NSDate date] timeIntervalSinceDate:trackingStartDate]
//        }
//        else
//        {
//            
//        }
        
//        AVS = (AVS + speed)/2; //GY11282014
    }
    else
    {
//        trackingStartDate = [NSDate date];
//        trackingInvDate = [NSDate date];
    }
    

    _currentLocation = location;
    
    NSLog(@"points: %@", _points);
    
    if(trackingMode)
        [self configureRoutes];
    
    coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    if(NO == trackingMode)
        [self.map setCenterCoordinate:coordinate animated:YES];
    
    
//    [self updateTrackingInfo];
    [self performSelectorOnMainThread:@selector(updateTrackingInfo) withObject:nil waitUntilDone:NO];
}
- (void) updateTrackingInfo {
    if(_MAP_DISTANCE_1000M > DST)
        ((UILabel *)[map viewWithTag:_TAG_MAP_TRACKING_DST_LABEL_]).text = [NSString stringWithFormat:@"DST:%3.0f m",DST];
    else
        ((UILabel *)[map viewWithTag:_TAG_MAP_TRACKING_DST_LABEL_]).text = [NSString stringWithFormat:@"DST:%.2f km",DST/_MAP_DISTANCE_1000M];
    
    if([speedUnit isEqualToString:@"km/h"])
        ((UILabel *)[map viewWithTag:_TAG_MAP_TRACKING_MXS_LABEL_]).text = [NSString stringWithFormat:@"MXS:%3.0f km/h",MXS];
    else
        ((UILabel *)[map viewWithTag:_TAG_MAP_TRACKING_MXS_LABEL_]).text = [NSString stringWithFormat:@"MXS:%3.0f MPH",MXS];
    
    if(trackingMode) {
        if([speedUnit isEqualToString:@"km/h"])
            AVS = CLLocationSpeedToKilometersPerHour(DST/[[NSDate date] timeIntervalSinceDate:trackingStartDate]);
        else
            AVS = CLLocationSpeedToMilesPerHour(DST/[[NSDate date] timeIntervalSinceDate:trackingStartDate]);
//        if([speedUnit isEqualToString:@"km/h"])
//            AVS = CLLocationSpeedToKilometersPerHour(AVS);
//        else
//            AVS = CLLocationSpeedToMilesPerHour(AVS);
    }
    if([speedUnit isEqualToString:@"km/h"])
        ((UILabel *)[map viewWithTag:_TAG_MAP_TRACKING_AVS_LABEL_]).text = [NSString stringWithFormat:@"AVS:%3.0f km/h",AVS];
    else
        ((UILabel *)[map viewWithTag:_TAG_MAP_TRACKING_AVS_LABEL_]).text = [NSString stringWithFormat:@"AVS:%3.0f MPH",AVS];
}

@end
