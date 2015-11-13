//
//  MRDashboardView.m
//  MobRecorder
//
//  Created by GarY on 2014/8/22.
//  Copyright (c) 2014年 GarY WanG. All rights reserved.
//

#import "MRDashboardView.h"
#import "MRViewController.h"
#import "NSTimer+Blocks.h"
#import "FBLCDFontView.h"
#import "FBGlowLabel.h"

MRDashboardView *g_mrDashboardView;
extern MRViewController *g_viewController;
extern MRPlist *g_mrPlist;

//static const CGFloat kSpeedLabelFontSize = 20.f;
static const CGFloat kSpeedUnitLabelFontSize = 18.f;

@interface MRDashboardView ()
{
    CGPoint originalLocation;
    BOOL isRunning;
    NSString * speedUnit;
    NSString * altitudeUnit;
    FBLCDFontView * fbSpeedLabel;
    FBLCDFontView * fbAltitudeLabel;
    FBGlowLabel * fbSpeedUnitLabel;
    FBGlowLabel * fbAltitudeUnitLabel;
    double speed;
    double altitude;
    CLLocation *currentLocation;
    CLLocationManager* locationManager;
}
//@property (nonatomic, strong) NSString * speedUnit;
//@property (nonatomic, strong) NSString * altitudeUnit;
@property (nonatomic, strong) FBLCDFontView * fbSpeedLabel;
@property (nonatomic, strong) FBLCDFontView * fbAltitudeLabel;
//@property (nonatomic, strong) FBGlowLabel * fbSpeedUnitLabel;
//@property (nonatomic, strong) FBGlowLabel * fbAltitudeUnitLabel;
//@property (nonatomic) double speed;
//@property (nonatomic) double altitude;
//@property (nonatomic, strong) CLLocation *currentLocation;
//@property (nonatomic, retain) CLLocationManager* locationManager;
@end

@implementation MRDashboardView
//@synthesize currentLocation = _currentLocation;
@synthesize fbSpeedLabel;// = _fbSpeedLabel;
//@synthesize fbSpeedUnitLabel = _fbSpeedUnitLabel;
@synthesize fbAltitudeLabel;// = _fbAltitudeLabel;
//@synthesize fbAltitudeUnitLabel = _fbAltitudeUnitLabel;
//@synthesize locationManager = _locationManager;
//@synthesize speed = _speed;
//@synthesize altitude = _altitude;
//@synthesize speedUnit = _speedUnit;

+ (MRDashboardView *)sharedInstance
{
    static MRDashboardView *singleton = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        
        CGRect frame = [[g_viewController.view layer] bounds];
        frame.origin.x = CGRectGetMaxX(frame)-DASHBOARD_WIDTH;//CGRectGetMinX(frame);
        frame.origin.y = CGRectGetMaxY(frame)-DASHBOARD_HEIGHT;
        frame.size.width = DASHBOARD_WIDTH;
        frame.size.height = DASHBOARD_HEIGHT;
        singleton = [[MRDashboardView alloc] initWithFrame:frame];
        g_mrDashboardView = singleton;
    });
    [g_mrDashboardView sizeToFit];
    return singleton;
}


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


#pragma mark
#pragma mark Dashboard 初始化
- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    
        isRunning = NO;
        
        // Initialization code
        
        
        
        
        speedUnit = [MRPlist readPlist:@"SpeedUnit"];
            
//        UIImageView * backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Dashboard-1"]];
//        backgroundImageView.frame =  [[self layer] bounds];
//        [backgroundImageView setTag:_TAG_DASHBOARD_BACKGROUND_IMAGE_];
//            
//        // Set the mask of the view.
//        [self layer].mask = backgroundImageView.layer;
//            
//        [self addSubview:backgroundImageView];
     
        [self createSpeedLabel];
        [self createAltitudeLabel];
        
        
        
//        [self createSpeedPointer:0];
        speed = 0;
        [self initGPS];
        
        if([[MRPlist readPlist:@"Dashboard"] isEqualToString:@"No"])
            [self hidden:g_viewController.view];
        else
            [self show:g_viewController.view];
        
        [[MRPlist sharedInstance] addObserver:self
                                   forKeyPath:@"g_key"
                                      options:NSKeyValueObservingOptionNew
                                      context:nil];
        
        
        UIDevice *device = [UIDevice currentDevice];
        device.batteryMonitoringEnabled = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(batteryChanged)
                                                     name:UIDeviceBatteryLevelDidChangeNotification
                                                   object:device];
    }
    return self;
}
#pragma mark - 螢幕觸控
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //    //UITouch *touch = [touches anyObject];
    //    //    CGPoint location = [touch locationInNode:self];
    //    //SKNode *node = [self nodeAtPoint:location];
    //    if(BrightnessSwitch == NO)
    //    {
    //        BrightnessSwitch = YES;
    //        currentStartData = [NSDate date];
    //        //[[UIScreen mainScreen] setBrightness:[[MRPlist readPlist:@"Setting" forkey:@"BrightnessSys"] floatValue]];
    //        [[UIScreen mainScreen] setBrightness:1.0f];
    //        [MRPlist writePlist:@"Setting" forkey:@"BrightnessMob" content:[[NSString alloc] initWithFormat:@"%f",
    //                                                                        [[UIScreen mainScreen] brightness]]];
    //    }
    //    else
    //    {
    //        currentStartData = [NSDate date];
    //        [self.gydelegate hiddenScene];
    //    }
    //
    //
    //    //    for (UITouch *touch in touches)
    //    //    {
    //    //        CGPoint location = [touch locationInNode:self];
    //    //    }

    
    UITouch *touch = [touches anyObject];
    originalLocation = [touch locationInView:self];
    
    self.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.5];
    
    NSLog(@"MRDashboard - Touches Began - x:%f y:%f",originalLocation.x, originalLocation.y);
    //[super touchesEnded: touches withEvent: event];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"MRDashboard - Touches Moved");
    UITouch *touch = [touches anyObject];
    CGPoint currentLocation_ = [touch locationInView:self];
    CGRect frame = self.frame;
    frame.origin.x += currentLocation_.x-originalLocation.x;
    frame.origin.y += currentLocation_.y-originalLocation.y;
    self.frame = frame;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"MRDashboard - Touches Ended");
    //[self logTouches: event];

    
    self.backgroundColor = [UIColor clearColor];
    
    //[super touchesEnded: touches withEvent: event];
}
#pragma mark - 建立海拔標籤
-(void) createAltitudeLabel {
    
    
    CGRect unitLabelFrame = [[self layer] bounds];
    unitLabelFrame.origin.x = CGRectGetMaxX(unitLabelFrame);
    unitLabelFrame.origin.y = fbSpeedLabel.frame.origin.y;
    unitLabelFrame.size.height = 20;
    unitLabelFrame.size.width = 50;
    
    fbAltitudeUnitLabel = [[FBGlowLabel alloc] initWithFrame:unitLabelFrame];
    [fbAltitudeUnitLabel setTag:_TAG_DASHBOARD_ALTITUDE_UNIT_LABEL_];
    
    fbAltitudeUnitLabel.text = @"m";
    fbAltitudeUnitLabel.textAlignment = NSTextAlignmentCenter;
    fbAltitudeUnitLabel.clipsToBounds = YES;
    fbAltitudeUnitLabel.backgroundColor = [UIColor clearColor];
    fbAltitudeUnitLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:kSpeedUnitLabelFontSize];
    fbAltitudeUnitLabel.alpha = 1.0;
    fbAltitudeUnitLabel.glowSize = 4;
    fbAltitudeUnitLabel.innerGlowSize = 4;
    fbAltitudeUnitLabel.textColor = UIColor.whiteColor;
    fbAltitudeUnitLabel.glowColor = UIColorFromRGB(0xee3300);
    fbAltitudeUnitLabel.innerGlowColor = UIColorFromRGB(0xee3300);
    
    
    [self addSubview:fbAltitudeUnitLabel];
    
    CGRect frame2 = fbAltitudeUnitLabel.frame;
    frame2.origin.x = frame2.origin.x - frame2.size.width;
    frame2.origin.y = frame2.origin.y - frame2.size.height;
    [fbAltitudeUnitLabel setFrame:frame2];
    
    CGRect frame = CGRectMake(CGRectGetMaxX([[self layer] bounds]) ,
                              fbAltitudeUnitLabel.frame.origin.y,
                              100,
                              80);
    fbAltitudeLabel = [[FBLCDFontView alloc] initWithFrame:frame];
    [fbAltitudeLabel setTag:_TAG_DASHBOARD_ALTITUDE_LABEL_];
    fbAltitudeLabel.text = @"88888";
    fbAltitudeLabel.lineWidth = 4.0;
    fbAltitudeLabel.drawOffLine = NO;
    fbAltitudeLabel.edgeLength = 15;
    fbAltitudeLabel.margin = 5.0;
    fbAltitudeLabel.backgroundColor = [UIColor clearColor];
    fbAltitudeLabel.horizontalPadding = 10;
    fbAltitudeLabel.verticalPadding = 5;
    fbAltitudeLabel.glowSize = 2.5;
    
    fbAltitudeLabel.innerGlowSize = 1.0;

    fbAltitudeLabel.glowColor = UIColorFromRGB(0xee3300);
    fbAltitudeLabel.innerGlowColor = UIColorFromRGB(0xee3300);
    fbAltitudeLabel.offColor = UIColorFromRGB(0xd0d0d0);//[UIColor clearColor];
    fbAltitudeLabel.lineColor = UIColorFromRGB(0xffdd66);
    
    [self addSubview:fbAltitudeLabel];
    
    [fbAltitudeLabel resetSize];
    
    frame = fbAltitudeLabel.frame;
    frame.origin.x = frame.origin.x - frame.size.width;
    frame.origin.y = frame.origin.y - frame.size.height;
    [fbAltitudeLabel setFrame:frame];
    
    

//
//
//    CGRect unitLabelFrame = [[self layer] bounds];
//    unitLabelFrame.origin.x = CGRectGetMidX(unitLabelFrame);
//    unitLabelFrame.origin.y = CGRectGetMaxY(unitLabelFrame);
//    unitLabelFrame.size.height = 20;
//    unitLabelFrame.size.width = 50;
//    
//    fbAltitudeUnitLabel = [[FBGlowLabel alloc] initWithFrame:unitLabelFrame];
//    [fbAltitudeUnitLabel setTag:_TAG_DASHBOARD_ALTITUDE_UNIT_LABEL_];
//    
//    fbAltitudeUnitLabel.text = @"m";
//    fbAltitudeUnitLabel.textAlignment = NSTextAlignmentCenter;
//    fbAltitudeUnitLabel.clipsToBounds = YES;
//    fbAltitudeUnitLabel.backgroundColor = [UIColor clearColor];
//    fbAltitudeUnitLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:kSpeedUnitLabelFontSize];
//    fbAltitudeUnitLabel.alpha = 1.0;
//    fbAltitudeUnitLabel.glowSize = 4;
//    fbAltitudeUnitLabel.innerGlowSize = 4;
//    fbAltitudeUnitLabel.textColor = UIColor.whiteColor;
//    fbAltitudeUnitLabel.glowColor = UIColorFromRGB(0xee3300);
//    fbAltitudeUnitLabel.innerGlowColor = UIColorFromRGB(0xee3300);
//    
//    
//    [self addSubview:fbAltitudeUnitLabel];
//    
//    CGRect frame2 = fbAltitudeUnitLabel.frame;
//    frame2.origin.x = frame.origin.x + frame.size.width - fbAltitudeLabel.horizontalPadding*2;
//    frame2.origin.y = frame.origin.y + frame.size.height - fbAltitudeLabel.verticalPadding*2 - frame2.size.height/2;
//    [fbAltitudeUnitLabel setFrame:frame2];
}
#pragma mark - 建立速度標籤
-(void) createSpeedLabel {
    speedUnit = [MRPlist readPlist:@"SpeedUnit"];
    
    CGRect unitLabelFrame = [[self layer] bounds];
    unitLabelFrame.origin.x = CGRectGetMaxX(unitLabelFrame);
    unitLabelFrame.origin.y = CGRectGetMaxY(unitLabelFrame);
    unitLabelFrame.size.height = 20;
    unitLabelFrame.size.width = 50;
    
    fbSpeedUnitLabel=[[FBGlowLabel alloc] initWithFrame:unitLabelFrame];
    [fbSpeedUnitLabel setTag:_TAG_DASHBOARD_SPEED_UNIT_LABEL_];

    if([speedUnit isEqualToString:@"km/h"])
        fbSpeedUnitLabel.text = @"km/h";
    else
        fbSpeedUnitLabel.text = @"MPH";
    fbSpeedUnitLabel.textAlignment = NSTextAlignmentCenter;
    fbSpeedUnitLabel.clipsToBounds = YES;
    fbSpeedUnitLabel.backgroundColor = [UIColor clearColor];
    fbSpeedUnitLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:kSpeedUnitLabelFontSize];
    fbSpeedUnitLabel.alpha = 1.0;
    fbSpeedUnitLabel.glowSize = 4;
    fbSpeedUnitLabel.innerGlowSize = 4;
    fbSpeedUnitLabel.textColor = UIColor.whiteColor;
    fbSpeedUnitLabel.glowColor = UIColorFromRGB(0x00ffff);
    fbSpeedUnitLabel.innerGlowColor = UIColorFromRGB(0x00ffff);
    
    [self addSubview:fbSpeedUnitLabel];
    
    CGRect frame2 = fbSpeedUnitLabel.frame;
    frame2.origin.x = frame2.origin.x - frame2.size.width;
    frame2.origin.y = frame2.origin.y - frame2.size.height;
    [fbSpeedUnitLabel setFrame:frame2];
    
    ////////////////////////////////////////////////////////////////
    
    CGRect frame = CGRectMake(CGRectGetMaxX([[self layer] bounds]),//fbSpeedUnitLabel.frame.origin.x ,
                              fbSpeedUnitLabel.frame.origin.y,
                              100,
                              80);
    fbSpeedLabel = [[FBLCDFontView alloc] initWithFrame:frame];
    [fbSpeedLabel setTag:_TAG_DASHBOARD_SPEED_LABEL_];
    fbSpeedLabel.text = @"888";
    fbSpeedLabel.lineWidth = 8.0;
    fbSpeedLabel.drawOffLine = NO;
    fbSpeedLabel.edgeLength = 30;
    fbSpeedLabel.margin = 10.0;
    fbSpeedLabel.backgroundColor = [UIColor clearColor];
    fbSpeedLabel.horizontalPadding = 10;
    fbSpeedLabel.verticalPadding = 10;
    fbSpeedLabel.glowSize = 5.0;
    fbSpeedLabel.glowColor = UIColorFromRGB(0x00ffff);
    fbSpeedLabel.innerGlowColor = UIColorFromRGB(0x00ffff);
    fbSpeedLabel.innerGlowSize = 2.0;
    fbSpeedLabel.offColor = [UIColor clearColor];//UIColorFromRGB(0xd0d0d0);
    fbSpeedLabel.lineColor = [UIColor whiteColor];
    [self addSubview:fbSpeedLabel];
    
    [fbSpeedLabel resetSize];
    
    
    frame = fbSpeedLabel.frame;
    frame.origin.x = frame.origin.x - frame.size.width;
    frame.origin.y = frame.origin.y - frame.size.height;
    [fbSpeedLabel setFrame:frame];
    
    
    
    
}

//#define angle_unit_offset_km        ((295.0-65.0)/260)
//
//- (double) SpeedPointerOffset:(double)angle {
//    double degrees = 65.0+angle_unit_offset_km*angle;
//    if(degrees > 295)
//        degrees = 295;
//    return degreesToRadians(degrees);
//}
//- (void) createSpeedPointer:(double)angle {
//    CGRect speedPointerFrame = [[self layer] bounds];
//    speedPointerFrame.origin.y = 30;
//
//    UIImageView * speedPointerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SpeedPointer4"]];
//    [speedPointerImage setTag:_TAG_DASHBOARD_SPEED_POINTER_IMAGE_];
//    speedPointerImage.alpha = 0.8f;
//    
//    [speedPointerImage setFrame:speedPointerFrame];
//    speedPointerImage.transform = CGAffineTransformMakeRotation(degreesToRadians(angle));
//    
//    
//    CGRect compassFrame = [[self layer] bounds];
//    compassFrame.origin.x = CGRectGetMidX(compassFrame)-10;
//    compassFrame.origin.y = CGRectGetMidY(compassFrame)+20;
//    compassFrame.size.height = 20;
//    compassFrame.size.width = 20;
//    UIImageView * compassCircleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Compass-iPhone-icon1"]];
//    
//    compassCircleImage.alpha = 1.0f;
//    [compassCircleImage setFrame:compassFrame];
//    
//    speedPointerImage.transform = CGAffineTransformMakeRotation([self SpeedPointerOffset:0]);
//    
//    [self addSubview:speedPointerImage];
//    [self addSubview:compassCircleImage];
//}

- (void) hidden:(UIView*)view {
    [UIView transitionWithView:self
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromTop
                    animations:^{
                        [self setHidden:YES];
//                        CGRect frame = self.frame;
//                        frame.origin.x = -frame.origin.x;
//                        frame.origin.y = -frame.origin.y;
//                        [self setFrame:frame];
                    }
                    completion:^(BOOL finished){
//                        if (finished)
//                            [self stop];
                    }];
    [self stop];
}
- (void) show:(UIView*)view {
    [UIView transitionWithView:self
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromTop
                    animations:^{
                        [self setHidden:NO];
//                        CGRect frame = self.frame;
//                        frame.origin.x = fabsf(frame.origin.x);
//                        frame.origin.y = fabsf(frame.origin.y);
//                        [self setFrame:frame];
                    }
                    completion:^(BOOL finished){
//                        if (finished)
//                            [self start];
                    }];
    [self start];
}

//-(void)updateUnit {
//    speedUnit = [MRPlist readPlist:@"SpeedUnit"];
//    UILabel * speedUnitLabel = (UILabel *)[self viewWithTag:_TAG_DASHBOARD_SPEED_UNIT_LABEL_];
//    
//    if([speedUnit isEqualToString:@"km/h"])
//        speedUnitLabel.text = @"km/h";
//    else
//        speedUnitLabel.text = @"MPH";
//    [speedUnitLabel sizeToFit];
//}

//-(void) dealloc {
//    [[MRGPS sharedInstance] removeObserver:self forKeyPath:@"speed"];
//}

#pragma mark - KVO speed
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"MRDashboard >>>>>>> keyPath:%@", keyPath);
    
    if([keyPath isEqualToString:@"g_key"])
    {
        if([[change objectForKey:@"new"] isEqualToString:@"SpeedUnit"])
        {
            speedUnit = [MRPlist readPlist:@"SpeedUnit"];
            UILabel * speedUnitLabel = (UILabel *)[self viewWithTag:_TAG_DASHBOARD_SPEED_UNIT_LABEL_];
            
            if([speedUnit isEqualToString:@"km/h"])
                speedUnitLabel.text = @"km/h";
            else
                speedUnitLabel.text = @"MPH";
            [speedUnitLabel sizeToFit];
        }
        else if([[change objectForKey:@"new"] isEqualToString:@"Dashboard"])
        {
            if([[MRPlist readPlist:[change objectForKey:@"new"]] boolValue])
                [self show:g_viewController.view];
            else
                [self hidden:g_viewController.view];
        }
    }
}

#pragma mark
#pragma mark - GPS 裝置初始化
-(void) initGPS {
    NSLog(@"Init GPS device!");
    
    locationManager = [[CLLocationManager alloc] init];
    // 通过测试定位管理器的 locationServicesEnabled属性来检查用户是否已经启用Core Location。
    // 用户可以从 设置->通用->定位服务选择关闭此功能
    
    //    if (![locationManager locationServicesEnabled])
    //    {
    //        NSLog(@"使用者退出了定位服務！");
    //        return self;
    //    }
    locationManager.delegate = self;
    //locationManager.distanceFilter = 1000;
    //locationManager.distanceFilter = 5.0f; // in meters
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    //    kCLLocationAccuracyBestForNavigation    // 最高的精度 最耗電 导航情况下最高精度，一般要有外接电源时才 能使用
    //    kCLLocationAccuracyNearestTenMeters     // 精度10米
    //    kCLLocationAccuracyHundredMeters        // 精度100米
    //    kCLLocationAccuracyKilometer            // 精度1000米
    //    kCLLocationAccuracyThreeKilometers      // 精度3000米
    //    kCLLocationAccuracyBest                 // 精度3000米
    
    if([UIDevice currentDevice].batteryState == UIDeviceBatteryStateCharging)
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    else
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    NSLog(@"locationManager.desiredAccuracy: %f",locationManager.desiredAccuracy);
    
    // Configure permission dialog
    //    [locationManager setPurpose:@"My Custom Purpose Message..."];
    //

    locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    
    // Start monitoring significant locations here as default, will switch to
    // update locations on enter foreground
    //[locationManager startMonitoringSignificantLocationChanges];
    
    //[locationManager startUpdatingLocation];
    //[locationManager startUpdatingHeading];
    //    [locationManager requestWhenInUseAuthorization]; // Add This Line
    
    
    // locationManager.distanceFilter = 2;
    
    
#ifdef __IPHONE_8_0
    NSUInteger code = [CLLocationManager authorizationStatus];
    if (code == kCLAuthorizationStatusNotDetermined && ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])) {
        // choose one request according to your business.
        if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
            [locationManager requestAlwaysAuthorization];
        } else if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
            [locationManager  requestWhenInUseAuthorization];
        } else {
            NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
        }
    }
#endif
    
    
    
}

#pragma mark
#pragma mark - GPS 用户改變方向時，進入
//-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
//{
//    // 取得行進方向
//    heading = newHeading.trueHeading;
//    //    //CLLocationDirection heading = newHeading.magneticHeading;
//    //    [self CompassAction:heading];
//    //    courseLable.text = [NSString stringWithFormat:@"行進方向：%3.5f", heading];
//
//}

#pragma mark
#pragma mark - GPS 無法獲得目前位置時，進入
//- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
//{
//    NSLog(@"Location manager error: %@",[error description]);
//
//}


#pragma mark
#pragma mark - GPS 取得所在位置
// 位置回调返回的每个CLLocation实例的属性说明：
// altitude－－返回当前检测的海拔。它返回一个以海平面为基准的浮点数(m为单位)；
// coordinate－－通过该属性获得设备已探测的地理位置－纬度 latitude，经度 longitude；
// course－－使用course 值确定该设备行进的一般方向，0度表示朝北，90度表示朝东，180度表示超南，270度表示朝西。要获得更高的精确度，应使用heading，heading通过磁力计获取磁性和真正的方向；
// horizontalAccuracy－－该属性表明当前坐标的精确度，将返回的坐标视为圆心，并将水平精确度视为半径。真正的设备位置落在此圆内的某处，圆越小位置越精确，精确度为负值表明测量失败；
// verticalAccuracy－－该属性提供水平精确度的纬度，它返回与纬度真实值有关的精确度，理论上它会在高度减去该数到高度加上该数之间变化；
// speed－－理论上，该值返回设备的速率，单位 m／s；
// timestamp－－标识进行位置测量时的时间。

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    /*
     CLLocation *newLocation = [locations lastObject];
     CLLocation *oldLocation = [locations objectAtIndex:locations.count-1];
     NSLog(@"didUpdateToLocation %@ from %@", newLocation, oldLocation);
     //MKCoordinateRegion userLocation = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 1500.0, 1500.0);
     //[regionsMapView setRegion:userLocation animated:YES];
     
     //*/
    
    
        if (locations.lastObject == nil)
        {
            NSLog(@"didUpdateToLocation: newLocation is nil");
            return;
        }
    
    
    
    currentLocation = locations.lastObject;
    //    latitude = currentLocation.coordinate.latitude; // 緯度
    //    longitude = currentLocation.coordinate.longitude; // 経度
    altitude = currentLocation.altitude; // 高度
    //    course = currentLocation.course; // 方角
    //    speed = currentLocation.speed; // 速度
    //    horizontalAccuracy = currentLocation.horizontalAccuracy; // 水平方向の精度
    //    verticalAccuracy = currentLocation.verticalAccuracy; // 水ty区方向の精度
    
        if(currentLocation.coordinate.latitude == 0.0f || currentLocation.coordinate.longitude == 0.0f)
            return;
    
    
    if(currentLocation.speed >= 0)
        speed = currentLocation.speed;
    else
        speed = 0.0;


        if([speedUnit isEqualToString:@"km/h"]) {
            fbSpeedLabel.text = [NSString stringWithFormat:@"%3.0f", CLLocationSpeedToKilometersPerHour(speed)];
            
            if(speed >= 40)
            {
                fbSpeedLabel.lineColor = UIColorFromRGB(0xff2020);
                fbSpeedLabel.glowColor = UIColorFromRGB(0xffd0d0);
                fbSpeedLabel.innerGlowColor = UIColorFromRGB(0xffd0d0);
            }
            else
            {
                fbSpeedLabel.lineColor = UIColorFromRGB(0xffffff);
                fbSpeedLabel.glowColor = UIColorFromRGB(0x00ffff);
                fbSpeedLabel.innerGlowColor = UIColorFromRGB(0x00ffff);
            }
            
            
            //            speedPointerImage.transform =
            //            CGAffineTransformMakeRotation([self SpeedPointerOffset:CLLocationSpeedToKilometersPerHour(g_mrGPS.speed)]);
            //    }else if([speedUnit isEqualToString:@"fph"]) {
            //        speedLabel.text = [NSString stringWithFormat:@"%3.0f", CLLocationSpeedToFeetPerSecond(currentLocation.speed)];
            //        speedPointerImage.transform = CGAffineTransformMakeRotation([self SpeedPointerOffset:CLLocationSpeedToFeetPerSecond(currentLocation.speed)]);
        }else { // mph
            fbSpeedLabel.text = [NSString stringWithFormat:@"%3.0f", CLLocationSpeedToMilesPerHour(speed)];
            
            
            
            //            speedPointerImage.transform =
            //            CGAffineTransformMakeRotation([self SpeedPointerOffset:CLLocationSpeedToMilesPerHour(g_mrGPS.speed)]);
        }
        [fbSpeedLabel resetSize];
        
        fbAltitudeLabel.text = [NSString stringWithFormat:@"%5.0f", altitude];
        [fbAltitudeLabel resetSize];

}

- (void) start
{
    [locationManager startUpdatingLocation];
    isRunning = YES;
}
- (void) stop
{
    [locationManager stopUpdatingLocation];
    isRunning = NO;
}

#pragma mark
#pragma mark - Battery
- (void) batteryChanged
{
    UIDevice *device = [UIDevice currentDevice];
    NSLog(@"State: %i Charge: %f", (int)device.batteryState, device.batteryLevel);
    
    switch (device.batteryState) {
            
        case UIDeviceBatteryStateCharging:
            if(isRunning)
            {
                [locationManager stopUpdatingLocation];
                [locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
                [locationManager startUpdatingLocation];
            }
            else
            {
                [locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
            }
            break;
        default:
            {
                if(isRunning)
                {
                    [locationManager stopUpdatingLocation];
                    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
                    [locationManager startUpdatingLocation];
                }
                else
                {
                    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
                }
            }
            break;
    }

}



@end
