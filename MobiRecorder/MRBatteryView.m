//
//  MRBatteryView.m
//  MobiRecorder
//
//  Created by GarY on 2015/5/1.
//  Copyright (c) 2015年 gyhouse. All rights reserved.
//
#import "MRViewController.h"
#import "MRBatteryView.h"
#import <QuartzCore/QuartzCore.h>

MRBatteryView * g_mrBatteryView;
extern MRViewController *g_viewController;

@interface MRBatteryView ()
{
    UIImageView *_batteryView;
}
@end

@implementation MRBatteryView

+ (MRBatteryView *)sharedInstance
{
    static MRBatteryView *singleton = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        CGRect frame = [[g_viewController.view layer] bounds];
        singleton = [[MRBatteryView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(frame)-30,
                                                                    CGRectGetMinY(frame),
                                                                    30,
                                                                    20)];
        g_mrBatteryView = singleton;
    });
    return singleton;
}


- (UIImageView *)_batteryView
{
    UIImageView *batteryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Battery-H-0"]];
    return batteryView;
}

- (void) batteryChanged:(NSNotification *)notification {
    [self updateBatteryImage];
}
#pragma mark - KVO frame
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@">>>>>>> keyPath:%@", keyPath);
    
    if([keyPath isEqualToString:@"g_AdmobShowing"])
    {
        CGRect frame = self.frame;
        if([[change objectForKey:@"new"] boolValue])
            frame.origin.y = CGSizeFromGADAdSize(kGADAdSizeSmartBannerLandscape).height;
        else
            frame.origin.y = 0;
        self.frame = frame;
    }
}
#pragma mark - 初始化視窗
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
        [g_viewController addObserver:self forKeyPath:@"g_AdmobShowing" options:NSKeyValueObservingOptionNew context:nil];
        
        
        UIDevice *device = [UIDevice currentDevice];
        device.batteryMonitoringEnabled = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(batteryChanged:)
                                                     name:UIDeviceBatteryLevelDidChangeNotification
                                                   object:device];
      
        _batteryView = [self _batteryView];
        CGRect batteryFrame = _batteryView.frame;
        batteryFrame.origin = CGPointMake(0,0);
        batteryFrame.size = CGSizeMake(30,20);
        _batteryView.frame = batteryFrame;
        //_batteryView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
        [self addSubview:_batteryView];
        [self updateBatteryImage];
        
    }
    return self;
}

- (UIImage *)inverseColor:(UIImage *)image
{
    CIImage *coreImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorInvert"];
    [filter setValue:coreImage forKey:kCIInputImageKey];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    return [UIImage imageWithCIImage:result];
}


#pragma mark - 電池相關
- (void) updateBatteryImage {
    UIDevice *device = [UIDevice currentDevice];
    NSLog(@"State: %i Charge: %f", (int)device.batteryState, device.batteryLevel);
    
    switch (device.batteryState) {
        case UIDeviceBatteryStateUnknown:
            [_batteryView setImage:[UIImage imageNamed:@"Battery-H-0"]];
            break;
        case UIDeviceBatteryStateFull:
            [_batteryView setImage:[UIImage imageNamed:@"Battery-H-100"]];
            break;
        case UIDeviceBatteryStateUnplugged:
            if(device.batteryLevel <= 0.25)
                [_batteryView setImage:[UIImage imageNamed:@"Battery-H-25"]];
            else if(device.batteryLevel <= 0.5)
                [_batteryView setImage:[UIImage imageNamed:@"Battery-H-50"]];
            else if(device.batteryLevel <= 0.75)
                [_batteryView setImage:[UIImage imageNamed:@"Battery-H-75"]];
            else
                [_batteryView setImage:[UIImage imageNamed:@"Battery-H-100"]];
            break;
        case UIDeviceBatteryStateCharging:
            [_batteryView setImage:[UIImage imageNamed:@"Battery-H-Charge"]];
            break;
        default:
            break;
    }
}

@end
