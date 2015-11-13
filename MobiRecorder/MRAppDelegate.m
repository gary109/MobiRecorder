//
//  MRAppDelegate.m
//  MobRecorder
//
//  Created by GarY on 2014/7/7.
//  Copyright (c) 2014年 GarY WanG. All rights reserved.
//

#import "MRAppDelegate.h"
#import "MRViewController.h"
#import "MRPlist.h"
#import "PBJVision.h"
#import "PBJVisionView.h"

//#import "YISplashScreen.h"
//#import "YISplashScreen+Migration.h" // optional
//#import "YISplashScreenAnimation.h"
//
//#define SHOWS_MIGRATION_ALERT   1
//#define HIDE_ANIMATION_TYPE     3

MRAppDelegate *g_mrAppDelegate;

@implementation MRAppDelegate
@synthesize window;// = _window;
@synthesize mrViewController;// = _mrViewController;

/*
 1.  點選 icon 啓動 app
 application:didFinishLaunchingWithOptions:
 applicationDidBecomeActive:
 
 2. 按下 Home 鍵返回桌面時
 applicationWillResignActive:
 applicationDidEnterBackgroud:
 
 3. 再由桌面按 icon 返回 app
 applicationWillEnterForegroud:
 applicationDidBecomeActive:
 //*/



- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL

{
    
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    
    
    NSError *error = nil;
    
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                    
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    
    if(!success){
        
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        
    }
    
    return success;
}




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //[self _startMigrationDemo];
    // Override point for customization after application launch.
    NSLog(@"GY-didFinishLaunchingWithOptions");
    
//    [YISplashScreen show];
//    [YISplashScreen hide];
    
    
    NSString *docsDir;
    NSArray *dirPaths;
    NSURL * finalURL;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    
    finalURL = [NSURL fileURLWithPath:docsDir];
    
    
    [self addSkipBackupAttributeToItemAtURL:finalURL];
    
 
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    
    NSError *error;
    BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&error];
    if (!success) {
        //Handle error
        NSLog(@"%@", [error localizedDescription]);
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warring"
//                                                        message:@"\nDo you want to turn off background music? \n"
//                                                       delegate:self
//                                              cancelButtonTitle:@"Yes"
//                                              otherButtonTitles:@"No", nil];
//        [alert show];
    } else {
        // Yay! It worked!
    }
    
    g_mrAppDelegate = self;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
   
    
    
    self.mrViewController = [[MRViewController alloc] initWithNibName:nil bundle: nil];
    
    self.window.rootViewController = self.mrViewController;

    
    [self.window makeKeyAndVisible];
    
    

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    NSLog(@"GY-applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    
    
    NSLog(@"GY-applicationDidEnterBackground");

    
    
//    [MRPlist writePlist:@"AudioInput" content:@"No"];
    
    UIApplication *app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
}



- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
//    NSLog(@"GY-applicationWillEnterForeground");
//    BOOL isOtherAudioPlaying = [[AVAudioSession sharedInstance] isOtherAudioPlaying];
//    NSLog(@"isOtherAudioPlaying:%d",isOtherAudioPlaying);
//    
//    if(isOtherAudioPlaying)
//    {
////        if([[MRPlist readPlist:@"Setting" forkey:@"AudioInput"] isEqualToString:@"Yes"])
////        {
//////            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warring"
//////                                                            message:@"\nDo you want to turn off background music? \n"
//////                                                           delegate:self
//////                                                  cancelButtonTitle:@"Yes"
//////                                                  otherButtonTitles:@"No", nil];
//////            [alert show];
////        }
////        [g_mrCameraView AudioInput:NO];
//        [MRPlist writePlist:@"AudioInput" content:@"No"];
//    }
//    else
//    {
////        [g_mrCameraView AudioInput:YES];
//        [MRPlist writePlist:@"AudioInput" content:@"Yes"];
//    }
//    
    
//    NSError *error;
//    BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&error];
//    if (!success) {
//        //Handle error
//        NSLog(@"%@", [error localizedDescription]);
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warring"
//                                                        message:@"\nDo you want to turn off background music? \n"
//                                                       delegate:self
//                                              cancelButtonTitle:@"Yes"
//                                              otherButtonTitles:@"No", nil];
//        [alert show];
//    } else {
//        // Yay! It worked!
//    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    NSLog(@"GY-applicationDidBecomeActive");

//    NSError *error;
//    BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&error];
//    if (!success) {
//        //Handle error
//        NSLog(@"%@", [error localizedDescription]);
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warring"
//                                                        message:@"\nDo you want to turn off background music? \n"
//                                                       delegate:self
//                                              cancelButtonTitle:@"Yes"
//                                              otherButtonTitles:@"No", nil];
//        [alert show];
//    } else {
//        // Yay! It worked!
//    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"GY-applicationWillTerminate");
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:(id)self];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"performFetchWithCompletionHandler");
    
    
}

#pragma mark
#pragma mark - Alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            NSLog(@"Yes button clicked");
            break;
        case 1:
            NSLog(@"No button clicked");
            break;
            
        default:
            break;
    }
}

/*
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    if ([MKDirectionsRequest isDirectionsRequestURL:url]) {
        MKDirectionsRequest* directionsInfo = [[MKDirectionsRequest alloc] initWithContentsOfURL:url];
        // TO DO: Plot and display the route using the
        //   source and destination properties of directionsInfo.
        return YES;
    }
    else {
        // Handle other URL types...
    }
    return NO;
}
//*/


//
//- (void)_startMigrationDemo
//{
//    void (^migrationBlock)(void);
//    
//#if SHOWS_MIGRATION_ALERT
//    migrationBlock = ^{
//        sleep(1);   // NOTE: add CoreData migration logic here
//    };
//#endif
//    
//    [YISplashScreen showAndWaitForMigration:migrationBlock completion:^{
//        
//        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
//        
//#if HIDE_ANIMATION_TYPE == 1
//        
//        //--------------------------------------------------
//        // fade out
//        //--------------------------------------------------
//        //        [YISplashScreen hide];    // fadeOutAnimation
//        [YISplashScreen hideWithAnimation:[YISplashScreenAnimation fadeOutAnimation]];
//        
//#elif HIDE_ANIMATION_TYPE == 2
//        
//        //--------------------------------------------------
//        // page curl
//        //--------------------------------------------------
//        [YISplashScreen hideWithAnimation:[YISplashScreenAnimation pageCurlAnimation]];
//        
//#elif HIDE_ANIMATION_TYPE == 3
//        
//        //--------------------------------------------------
//        // cube
//        //--------------------------------------------------
//        [YISplashScreen hideWithAnimation:[YISplashScreenAnimation cubeAnimation]];
//        
//#elif HIDE_ANIMATION_TYPE == 4
//        
//        //--------------------------------------------------
//        // circle wipe
//        //--------------------------------------------------
//        [YISplashScreen hideWithAnimation:[YISplashScreenAnimation circleOpeningAnimation]];
//        //        [YISplashScreen hideWithAnimation:[YISplashScreenAnimation circleClosingAnimation]];
//        
//        // WARNING: blurred-circle-wipe uses kCAGradientLayerRadial (private API)
//        //        [YISplashScreen hideWithAnimation:[YISplashScreenAnimation _blurredCircleOpeningAnimation]];
//        //        [YISplashScreen hideWithAnimation:[YISplashScreenAnimation _blurredCircleClosingAnimation]];
//        
//#else
//        
//        //--------------------------------------------------
//        // manual implementation
//        //--------------------------------------------------
//        [YISplashScreen hideWithAnimationBlock:^(CALayer* splashLayer, CALayer* rootLayer) {
//            
//            [CATransaction begin];
//            [CATransaction setAnimationDuration:0.7];
//            [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
//            
//            splashLayer.position = CGPointMake(splashLayer.position.x, splashLayer.position.y-splashLayer.bounds.size.height);
//            
//            [CATransaction commit];
//        }];
//        
//#endif
//        
//    }];
//}

@end
