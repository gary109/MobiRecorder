//
//  MRMenuView.m
//  MobRecorder
//
//  Created by GarY on 2014/8/22.
//  Copyright (c) 2014年 GarY WanG. All rights reserved.
//
#import "MRViewController.h"
#import "MRMenuView.h"
#import "MRPlist.h"
#import "MRButton.h"
#import "MRTableView.h"
#import "MRSettingView.h"
#import "MRStoreView.h"
#import "MRDashboardView.h"
#import "PBJVisionView.h"
#import "PBJVision.h"
#import "MRMapView.h"
#import "MRAppDelegate.h"

MRMenuView *g_mrMenuView;
extern PBJVisionView* g_mrPBJVisionView;
extern MRDashboardView *g_mrDashboardView;
extern MRViewController *g_viewController;
extern MRTableView *g_mrTableView;
extern MRSettingView *g_mrSettingView;
extern MRStoreView *g_mrStoreView;
extern MRMapView *g_mrMapView;
extern MRAppDelegate *g_mrAppDelegate;

@interface MRMenuView ()

@end

@implementation MRMenuView

float test_angle;

+ (MRMenuView *)sharedInstance
{
    static MRMenuView *singleton = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        CGRect frame = [[g_viewController.view layer] bounds];
        frame.origin.x = CGRectGetMinX(frame);//CGRectGetMaxX(frame)-_Menu_Icon_W_*_MenuIconCounts_;
        frame.origin.y = CGRectGetMaxY(frame)-_Menu_Icon_H_;
        frame.size.height = _Menu_Icon_H_;
        frame.size.width = _Menu_Icon_W_*_MenuIconCounts_;
        singleton = [[MRMenuView alloc] initWithFrame:frame];
        g_mrMenuView = singleton;
    });
    return singleton;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 將圖層的邊框設置為圓腳
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
            
        // 給圖層添加一個有色邊框
        self.layer.borderWidth = 2;
        self.layer.borderColor = [[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.5] CGColor];

        UIImageView * backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG"]];
        backgroundImageView.frame =  [[self layer] bounds];
        backgroundImageView.alpha = 0.8;
            
        [self addSubview:backgroundImageView];
        [self createBtn];
        
        [[MRPlist sharedInstance] addObserver:self
                                   forKeyPath:@"g_key"
                                      options:NSKeyValueObservingOptionNew
                                      context:nil];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
//-(void) updateView:(NSTimer *)theTimer
//{
//    //NSLog(@"Menu updateView..");
//    
//    btnSetting.transform = CGAffineTransformMakeRotation(degreesToRadians(test_angle));
//    test_angle+=3;
//}


#pragma mark - 螢幕觸控
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    //    //UITouch *touch = [touches anyObject];
//    //    //    CGPoint location = [touch locationInNode:self];
//    //    //SKNode *node = [self nodeAtPoint:location];
//    //    if(BrightnessSwitch == NO)
//    //    {
//    //        BrightnessSwitch = YES;
//    //        currentStartData = [NSDate date];
//    //        //[[UIScreen mainScreen] setBrightness:[[MRPlist readPlist:@"Setting" forkey:@"BrightnessSys"] floatValue]];
//    //        [[UIScreen mainScreen] setBrightness:1.0f];
//    //        [MRPlist writePlist:@"Setting" forkey:@"BrightnessMob" content:[[NSString alloc] initWithFormat:@"%f",
//    //                                                                        [[UIScreen mainScreen] brightness]]];
//    //    }
//    //    else
//    //    {
//    //        currentStartData = [NSDate date];
//    //        [self.gydelegate hiddenScene];
//    //    }
//    //
//    //
//    //    //    for (UITouch *touch in touches)
//    //    //    {
//    //    //        CGPoint location = [touch locationInNode:self];
//    //    //    }
//    
//    NSLog(@"Touches Began - MRCameraview");
//    //[super touchesEnded: touches withEvent: event];
//}
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"Touches Moved - MRCameraview");
//    //[self logTouches: event];
//    
//    //[super touchesEnded: touches withEvent: event];
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"Touches Ended - MRCameraview");
//    //[self logTouches: event];
//    
//    //[super touchesEnded: touches withEvent: event];
//}




#pragma mark - 按鍵宣告
- (void) handleBtnClicked:(id)sender {
    if(_TAG_MENU_DASHBOARD_BTN_ == ((UIButton *)sender).tag)
    {
        if([[MRPlist readPlist:@"Dashboard"] boolValue])
        {
            [((UIButton *)sender) setImage:[UIImage imageNamed:@"dashboard-off"] forState:UIControlStateNormal];
           
            [MRPlist writePlist:@"Dashboard" content:@"No"];
        }
        else
        {
            [((UIButton *)sender) setImage:[UIImage imageNamed:@"dashboard-on"] forState:UIControlStateNormal];
            
            [MRPlist writePlist:@"Dashboard" content:@"Yes"];
        }

    }
    else if(_TAG_MENU_MONITOR_BTN_ == ((UIButton *)sender).tag)
    {
        NSLog(@"handleMapBtnClicked...");

        NSString * mainScreen = [MRPlist readPlist:@"MainScreen"];
        
        if([mainScreen isEqualToString:@"Map"])
            [MRPlist writePlist:@"MainScreen" content:@"Hybrid"];
        else if([mainScreen isEqualToString:@"Hybrid"])
            [MRPlist writePlist:@"MainScreen" content:@"Video"];
        else
            [MRPlist writePlist:@"MainScreen" content:@"Map"];


        //[g_viewController exchangeView:YES];
    
        // Lauch Apple Map
        //     // Check for iOS 6
        //     Class mapItemClass = [MKMapItem class];
        //     if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
        //     {
        //     // Create an MKMapItem to pass to the Maps app
        //     CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([self.gydelegate GetLatitude] , [self.gydelegate GetLongitude]);
        //     MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
        //     MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        //     [mapItem setName:@"My Place"];
        //     // Pass the map item to the Maps app
        //     [mapItem openInMapsWithLaunchOptions:nil];
        //     }
        
        
        //*/
        
        // 打個電話
        //        NSURL *url = [NSURL URLWithString:@"telprompt://123-4567-890"];
        //        [[UIApplication  sharedApplication] openURL:url];
        
    }
    else if(_TAG_MENU_FOLDER_BTN_ == ((UIButton *)sender).tag)
    {
        NSLog(@"handleFolderBtnClicked...");
        //[MRPlist writePlist:@"WeAreRecording" content:[NSString stringWithFormat:@"%d",0]];
        //[g_mrCameraView StopRecordingProcess];
        [g_mrPBJVisionView stopRecording];
        [g_mrTableView show:g_viewController.view];
    }
    else if(_TAG_MENU_SETTING_BTN_ == ((UIButton *)sender).tag)
    {
        NSLog(@"handleSettingBtnClicked...");
        //[MRPlist writePlist:@"WeAreRecording" content:[NSString stringWithFormat:@"%d",0]];
        //[g_mrCameraView StopRecordingProcess];
        [g_mrPBJVisionView stopRecording];
        [g_mrSettingView show:g_viewController.view];
    }
    else if(_TAG_MENU_STORE_BTN_ == ((UIButton *)sender).tag)
    {
        NSLog(@"handleStoreBtnClicked...");
        //[MRPlist writePlist:@"WeAreRecording" content:[NSString stringWithFormat:@"%d",0]];
        //[g_mrCameraView StopRecordingProcess];
        [g_mrPBJVisionView stopRecording];
        
        [g_mrStoreView show:g_viewController.view];
    }
    else if(_TAG_MAP_SNAPSHOT_BTN_ == ((UIButton *)sender).tag)
    {
        NSLog(@"handleSnapshopBtnClicked...");
//        float brightness = [UIScreen mainScreen].brightness;
//        [UIView animateWithDuration:5.0f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//            [[UIScreen mainScreen] setBrightness:0.1f];
//            
////            UIGraphicsBeginImageContext(g_viewController.view.bounds.size);
////            [g_viewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
////            [g_mrPBJVisionView.layer renderInContext:(__bridge CGContextRef)(UIGraphicsGetImageFromCurrentImageContext())];
////            UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
////            UIGraphicsEndImageContext();
////            UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
//            
//            
//        
//            
//            // create graphics context with screen size
//            CGRect screenRect = [[UIScreen mainScreen] bounds];
//            //UIGraphicsBeginImageContext(screenRect.size);
//            UIGraphicsBeginImageContextWithOptions(screenRect.size,YES,0.0f);
//            CGContextRef ctx = UIGraphicsGetCurrentContext();
//            [[UIColor blackColor] set];
//            CGContextFillRect(ctx, screenRect);
//            
//            // grab reference to our window
//            UIWindow *window = [UIApplication sharedApplication].keyWindow;
//            
//            
//            
//            
//            
//            // transfer content into our context
//            [window.layer renderInContext:ctx];
//            UIImage *screengrab = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();
//            UIImageWriteToSavedPhotosAlbum(screengrab, nil, nil, nil);
//            
//            
//        } completion:^(BOOL finished) {
//        }];
//        [[UIScreen mainScreen] setBrightness:brightness];
        
        
        UIWindow *keyWindow =  [[UIApplication sharedApplication] keyWindow];
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        {
            // checking for Retina display
            UIGraphicsBeginImageContextWithOptions(keyWindow.bounds.size, YES, [UIScreen mainScreen].scale);
            //if this method is not used for Retina device, image will be blurr.
        }
        else
        {
            UIGraphicsBeginImageContext(keyWindow.bounds.size);
        }
//
//        
//        
//        [g_mrAppDelegate.window.layer renderInContext:UIGraphicsGetCurrentContext()];
//        //[[[PBJVision sharedInstance] previewLayer] renderInContext:(__bridge CGContextRef)(UIGraphicsGetImageFromCurrentImageContext())];
//        
//        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        // now storing captured image in Photo Library of device
//        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        
        UIImageWriteToSavedPhotosAlbum([self captureScreenInRect:keyWindow.bounds], nil, nil, nil);
      
        
    }
    else if(_TAG_MAP_GPS_RECORD_BTN_ == ((UIButton *)sender).tag)
    {
        NSLog(@"handleGPSRecordBtnClicked...");
        if(g_mrMapView.trackingMode)
        {
            [((UIButton *)sender) setImage:[UIImage imageNamed:@"GPS_Record_Start.png"] forState:UIControlStateNormal];
            g_mrMapView.trackingMode = NO;
        }
        else
        {
            [((UIButton *)sender) setImage:[UIImage imageNamed:@"GPS_Record_Stop.png"] forState:UIControlStateNormal];
            g_mrMapView.trackingMode = YES;
        }
    }
    else if(_TAG_MAP_DELETE_BTN_ == ((UIButton *)sender).tag)
    {
        NSLog(@"handleDeleteBtnClicked...");
        [g_mrMapView clearRoutingLine];
    }
}

- (void)takePhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    picker.showsCameraControls = NO;
    
    [picker takePicture];
    
//    [g_viewController presentViewController:picker animated:YES
//                     completion:^ {
//                         [picker takePicture];
//                     }];
}

-(UIImage *)captureScreenInRect:(CGRect)captureFrame {
    CALayer *layer;
    layer = g_viewController.view.layer;
    UIGraphicsBeginImageContext(g_viewController.view.bounds.size);
    CGContextClipToRect (UIGraphicsGetCurrentContext(),captureFrame);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenImage;
}

- (void) createBtn {
    [MRButton createButton:self
                          :CGRectMake(_Menu_Icon_W_*0,
                                      [[self layer] bounds].size.height/2-_Menu_Icon_H_/2,
                                      _Menu_Icon_W_,
                                      _Menu_Icon_H_)
                          :[UIImage imageNamed:@"yellow-monitor-icon"]
                          :_TAG_MENU_MONITOR_BTN_
                          :@selector(handleBtnClicked:)];
    
    [MRButton createButton:self
                          :CGRectMake(_Menu_Icon_W_*1,
                                      [[self layer] bounds].size.height/2-_Menu_Icon_H_/2,
                                      _Menu_Icon_W_,
                                      _Menu_Icon_H_)
                          :[[MRPlist readPlist:@"Dashboard"] boolValue] ? [UIImage imageNamed:@"dashboard-on"] : [UIImage imageNamed:@"dashboard-off"]
                          :_TAG_MENU_DASHBOARD_BTN_
                          :@selector(handleBtnClicked:)];
    
    [MRButton createButton:self
                          :CGRectMake(_Menu_Icon_W_*2,
                                      [[self layer] bounds].size.height/2-_Menu_Icon_H_/2,
                                      _Menu_Icon_W_,
                                      _Menu_Icon_H_)
                          :[UIImage imageNamed:@"Photo-Video-Camera-icon"]
                          :_TAG_MAP_SNAPSHOT_BTN_
                          :@selector(handleBtnClicked:)];
    
    [MRButton createButton:self
                          :CGRectMake(_Menu_Icon_W_*3,
                                      [[self layer] bounds].size.height/2-_Menu_Icon_H_/2,
                                      _Menu_Icon_W_,
                                      _Menu_Icon_H_)
                          :g_mrMapView.trackingMode ? [UIImage imageNamed:@"GPS_Record_Stop.png"] : [UIImage imageNamed:@"GPS_Record_Start"]
                          :_TAG_MAP_GPS_RECORD_BTN_
                          :@selector(handleBtnClicked:)];
    
    [MRButton createButton:self
                          :CGRectMake(_Menu_Icon_W_*4,
                                      [[self layer] bounds].size.height/2-_Menu_Icon_H_/2,
                                      _Menu_Icon_W_,
                                      _Menu_Icon_H_)
                          :[UIImage imageNamed:@"Delete-icon1"]
                          :_TAG_MAP_DELETE_BTN_
                          :@selector(handleBtnClicked:)];
    
    [MRButton createButton:self
                          :CGRectMake(_Menu_Icon_W_*5,
                                      [[self layer] bounds].size.height/2-_Menu_Icon_H_/2,
                                      _Menu_Icon_W_,
                                      _Menu_Icon_H_)
                          :[UIImage imageNamed:@"Folder-Camera-icon"]
                          :_TAG_MENU_FOLDER_BTN_
                          :@selector(handleBtnClicked:)];
    
    [MRButton createButton:self
                          :CGRectMake(_Menu_Icon_W_*6,
                                      [[self layer] bounds].size.height/2-_Menu_Icon_H_/2,
                                      _Menu_Icon_W_,
                                      _Menu_Icon_H_)
                          :[UIImage imageNamed:@"Store"]
                          :_TAG_MENU_STORE_BTN_
                          :@selector(handleBtnClicked:)];
    
    [MRButton createButton:self
                          :CGRectMake(_Menu_Icon_W_*7,
                                      [[self layer] bounds].size.height/2-_Menu_Icon_H_/2,
                                      _Menu_Icon_W_,
                                      _Menu_Icon_H_)
                          :[UIImage imageNamed:@"settings-icon"]
                          :_TAG_MENU_SETTING_BTN_
                          :@selector(handleBtnClicked:)];
 
}



- (void) updateAll{
    
}

- (void) hidden:(UIView*)view
{
    [self updateAll];
    [UIView transitionWithView:view
                      duration:0.25
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^{
                        CGRect frame = self.frame;
                        frame.origin.x = -frame.size.width;
                        [self setFrame:frame];
                    }
                    completion:NULL];
}
- (void) show:(UIView*)view
{
    [self updateAll];
    [UIView transitionWithView:view
                      duration:0.25
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^{
                        CGRect frame = self.frame;
                        frame.origin.x = CGRectGetMinX([[g_viewController.view layer] bounds]);
                        [self setFrame:frame];
                    }
                    completion:NULL];
}

#pragma mark - KVO
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@">>>>>>> keyPath:%@", keyPath);
    
    if([keyPath isEqualToString:@"g_key"])
    {
        if([[change objectForKey:@"new"] isEqualToString:@"Dashboard"])
        {
            UIButton * button = (UIButton *)[self viewWithTag:_TAG_MENU_DASHBOARD_BTN_];
            if([[MRPlist readPlist:[change objectForKey:@"new"]] boolValue])
                [button setImage:[UIImage imageNamed:@"dashboard-on"] forState:UIControlStateNormal];
            else
                [button setImage:[UIImage imageNamed:@"dashboard-off"] forState:UIControlStateNormal];
        }
    }
    else if([keyPath isEqualToString:@"g_ScreenTouch"])
    {
        
    }
}

@end
