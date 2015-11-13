//
//  PBJVisionView.m
//  MobiRecorder
//
//  Created by GarY on 2015/4/30.
//  Copyright (c) 2015年 gyhouse. All rights reserved.
//
#import "MRViewController.h"
#import "PBJVisionView.h"
#import "PBJStrobeView.h"
#import "PBJFocusView.h"
#import "MRPlist.h"
#import "PBJVision.h"
#import "PBJVisionUtilities.h"
#import "NSTimer+Blocks.h"
#import "MRTableView.h"
#import "FBSquareFontView.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <GLKit/GLKit.h>


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMedia/CoreMedia.h>
#import <Accelerate/Accelerate.h>

#import "MRFileManagement.h"


PBJVisionView* g_mrPBJVisionView;
extern MRViewController *g_viewController;
extern MRTableView *g_mrTableView;


@interface ExtendedHitButton : UIButton

+ (instancetype)extendedHitButton;

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;

@end

@implementation ExtendedHitButton

+ (instancetype)extendedHitButton
{
    return (ExtendedHitButton *)[ExtendedHitButton buttonWithType:UIButtonTypeCustom];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect relativeFrame = self.bounds;
    UIEdgeInsets hitTestEdgeInsets = UIEdgeInsetsMake(-35, -35, -35, -35);
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets);
    return CGRectContainsPoint(hitFrame, point);
}

@end

@interface PBJVisionView () <UIGestureRecognizerDelegate, PBJVisionDelegate, UIAlertViewDelegate>
{
    int stage;
    
    CGFloat storageSizeStart;
    CGFloat storageSizeLimit;
    CGFloat dirTotalSizeInBytes;
    CGFloat dirTempTotalSizeInBytes;
    
    PBJStrobeView *_strobeView;
//    UIButton *_doneButton;
    
    UIButton *_flipButton;
    UIButton *_focusButton;
//    UIButton *_frameRateButton;
//    UIButton *_onionButton;
    UIButton *_recordButton;
    //FBSquareFontView *_recordText;
    
    UIView *_previewView;
    AVCaptureVideoPreviewLayer *_previewLayer;
    PBJFocusView *_focusView;
    GLKViewController *_effectsViewController;
    
    //UILabel *_rectimeLabel;
    UIView *_gestureView;
    UILongPressGestureRecognizer *_longPressGestureRecognizer;
    UITapGestureRecognizer *_focusTapGestureRecognizer;
    UITapGestureRecognizer *_photoTapGestureRecognizer;
    
    BOOL _recording;
    BOOL _continue;
    BOOL _pasueTimer;
    BOOL _saveReady;
    
    ALAssetsLibrary *_assetLibrary;
    __block NSDictionary *_currentVideo;
    __block NSDictionary *_currentPhoto;
    
}
@property (nonatomic) Float64 tatalCapturedVideoSeconds;
@property (nonatomic,retain) NSDate     * tmpStartData;
@property (nonatomic,strong) NSTimer    * updateRecProcessTimer;
@end

@implementation PBJVisionView
@synthesize _previewView;
@synthesize updateRecProcessTimer;
@synthesize tmpStartData;
@synthesize tatalCapturedVideoSeconds;

#pragma mark
#pragma mark Timer callback func - updateRecProcess
- (void) stopRecProcessTimer
{
    if (updateRecProcessTimer) {
        [updateRecProcessTimer invalidate];
        updateRecProcessTimer = nil;
    }
    
}



- (void) updateRecProcess {
    PBJVision * vision = [PBJVision sharedInstance];
    
    [self stopRecProcessTimer];
    
    updateRecProcessTimer = [NSTimer scheduledTimerWithTimeInterval:.3 block:^ {
        
//        double deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
//        
//        if(vision.capturedVideoSeconds > 0)
//            double sss = vision.capturedVideoSeconds + deltaTime;
//        
//        
//        if(![[MRPlist readPlist:@"WeAreRecording"] boolValue])
//            tmpStartData = [NSDate date];
//        else
//        {
//            double deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
//            
//   
//            _strobeView._rectimeLabel.text = [NSString stringWithFormat:@"%.2llu:%.2llu:%.2llu", totalSecondsToHr(deltaTime),
//                                                                                             totalSecondsToMin(deltaTime),
//                                                                                             totalSecondsToSec(deltaTime)];
//  
//        }
        
//        _strobeView._rectimeLabel.text = [NSString stringWithFormat:@"%.2llu:%.2llu:%.2llu",
//                                          totalSecondsToHr(vision.capturedVideoSeconds),
//                                          totalSecondsToMin(vision.capturedVideoSeconds),
//                                          totalSecondsToSec(vision.capturedVideoSeconds)];
//        NSLog(@"%f s, %f mb",vision.capturedVideoSeconds, dirTotalSizeInBytes/1024/1024);
//        
   
        dirTotalSizeInBytes = [ALDisk totalDirSpaceInBytes];
        _strobeView._rectimeLabel.text = [NSString stringWithFormat:@"%.2llu:%.2llu:%.2llu",
                                          totalSecondsToHr(vision.capturedVideoSeconds),
                                          totalSecondsToMin(vision.capturedVideoSeconds),
                                          totalSecondsToSec(vision.capturedVideoSeconds)];
        
        
//        double deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
//
//        
//        _strobeView._rectimeLabel.text = [NSString stringWithFormat:@"%.2llu:%.2llu:%.2llu",
//                                          totalSecondsToHr(deltaTime),
//                                          totalSecondsToMin(deltaTime),
//                                          totalSecondsToSec(deltaTime)];
        
        
        NSLog(@"%f s, %f mb",vision.capturedVideoSeconds, dirTotalSizeInBytes/1024/1024);
        
        
        
        if([g_mrTableView.moviesArray count]!=0)
            NSLog(@"file size:%f", [ALDisk getFileSize:[[[g_mrTableView.moviesArray objectAtIndex:0] objectForKey:PBJVisionVideoPathKey] lastPathComponent]]/1024/1024);
        
        if(_continue)
        {
            if(_saveReady)
            {
                _continue = NO;
                if(dirTotalSizeInBytes >= storageSizeLimit)
                {
                    void (^reservedDirSpace)(void) = ^(void) {
                        NSLog(@"目錄Size(%f)大於設定值(%f)",dirTotalSizeInBytes,storageSizeLimit);
                        do{
                            NSString * filepath = [MRFileManagement findEarlierCreationDateAtFolder:@"MobRecord"];
                            NSString * filename = [filepath lastPathComponent];
                            NSLog(@"開始清除最舊的影片 path:%@",filepath);
                            NSLog(@"開始清除最舊的影片 name:%@",filename);
                            [[NSFileManager defaultManager] removeItemAtPath:filepath error:NULL];
                            
                            [g_mrTableView.moviesArray removeObject:filename];
                            dirTotalSizeInBytes = [ALDisk totalDirSpaceInBytes];
                        }while (dirTotalSizeInBytes > (storageSizeLimit*0.5)); //刪除檔案後的大小，必須預留50%的空間
                    };
                    reservedDirSpace();
                }
                
                [self recordProcessing];
                
                _saveReady = NO;
            }
        }
        else
        {
        
                
            if((dirTotalSizeInBytes >= storageSizeLimit))
            {
                _saveReady = NO;
                [self stopRecording];
                
                _continue = YES;
            }
            else if((vision.capturedVideoSeconds) >= _CAPTURE_MAX_SEC_ )
            {
                _saveReady = NO;
                [self stopRecording];
                _continue = YES;
            }
        }
        
        
        
    } repeats:YES];
}

+ (PBJVisionView *) sharedInstance
{
    static PBJVisionView *singleton = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        singleton = [[PBJVisionView alloc] initWithFrame:[[g_viewController.view layer] bounds]];
        g_mrPBJVisionView = singleton;
    });
    return singleton;
}

- (void) stopRecording
{
tmpStartData = [NSDate date];
    
    [self _endCapture];
    

    [_recordButton setImage:[UIImage imageNamed:@"Record_Start"] forState:UIControlStateNormal];
    
    
    [UIButton beginAnimations:nil context:nil];
    [UIButton setAnimationDuration:0.5];
    [UIButton setAnimationBeginsFromCurrentState:YES];
    [UIButton setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                             forView:_recordButton cache:YES];
    [UIButton commitAnimations];
    
    _recordButton.selected = NO;

    [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(hiddenRecStartStopButton:)
                                   userInfo:nil
                                    repeats:NO];


}

- (void) startRecording
{
//    tmpStartData = [NSDate date];
    
    [_recordButton setImage:[UIImage imageNamed:@"Record_Stop"] forState:UIControlStateNormal];
    
    [UIButton beginAnimations:nil context:nil];
    [UIButton setAnimationDuration:0.5];
    [UIButton setAnimationBeginsFromCurrentState:YES];
    [UIButton setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                             forView:_recordButton cache:YES];
    [UIButton commitAnimations];
    
    _continue = NO;
    
    _recordButton.selected = YES;
    [self _startCapture];
    [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(hiddenRecStartStopButton:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void) recordProcessing
{
//    tmpStartData = [NSDate date];
    
    if([[MRPlist readPlist:@"WeAreRecording"] boolValue])
        [self startRecording];
    else
        [self stopRecording];
    
}

#pragma mark - KVO frame, video quality, audio input
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"PBJVision >>>>>>> keyPath:%@", keyPath);
    
     if([keyPath isEqualToString:@"frame"])
     {
         NSLog(@">>>>>>> frame:%@", [change objectForKey:@"new"]);

         // preview layer
         [_previewView setFrame:self.bounds];
         [_gestureView setFrame:self.bounds];
         _previewLayer = [[PBJVision sharedInstance] previewLayer];
         [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
         [_previewLayer setBounds:self.bounds];
         [_previewLayer setPosition:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))];
         
         // focus button
         CGRect focusFrame = _focusButton.frame;
         focusFrame.origin = CGPointMake((CGRectGetWidth(self.bounds) * 0.5f) - (focusFrame.size.width * 0.5f),
                                         (CGRectGetHeight(self.bounds) * 0.5f) - (focusFrame.size.height * 0.5f));
         _focusButton.frame = focusFrame;
         _focusButton.hidden = YES;
         
         // record button
         CGRect recordFrame = _recordButton.frame;
         recordFrame.origin = CGPointMake((CGRectGetWidth(self.bounds) * 0.5f) - (recordFrame.size.width * 0.5f),
                                         (CGRectGetHeight(self.bounds) * 0.5f) - (recordFrame.size.height * 0.5f));
         _recordButton.frame = recordFrame;
         
         CGRect strobeFrame = _strobeView.frame;
         strobeFrame.origin = CGPointMake((CGRectGetWidth(self.bounds) * 0.5f) - (strobeFrame.size.width * 0.75f), 0);
         _strobeView.frame = strobeFrame;
     }
     else if([keyPath isEqualToString:@"g_AdmobShowing"])
     {
         NSLog(@">>>>>>> g_AdmobShowing:%@", [change objectForKey:@"new"]);
         
         CGRect frame = [[g_viewController.view layer] bounds];
         
         if([[change objectForKey:@"new"] boolValue])
         {
             frame.origin = CGPointMake(0.0f, CGSizeFromGADAdSize(kGADAdSizeSmartBannerLandscape).height);
             if([[MRPlist readPlist:@"MainScreen"] isEqualToString:@"Hybrid"])
             {
                 frame.size = CGSizeMake(150, 150);
             }
             else
             {
                 frame.size.height = frame.size.height - CGSizeFromGADAdSize(kGADAdSizeSmartBannerLandscape).height;
             }
         }
         else
         {
             frame.origin = CGPointMake(0.0f, 0.0f);
             if([[MRPlist readPlist:@"MainScreen"] isEqualToString:@"Hybrid"])
             {
                 frame.size = CGSizeMake(150, 150);
             }
         }
         [self setFrame:frame];
     }
     else if([keyPath isEqualToString:@"g_key"])
     {
         if([[change objectForKey:@"new"] isEqualToString:@"VideoQuality"])
         {
             PBJVision *vision = [PBJVision sharedInstance];
             
             [self stopRecording];
    
             
             if([[MRPlist readPlist:@"VideoQuality"] isEqualToString:@"Normal"])
                 [vision setOutputFormat:PBJOutputFormatStandard];
             else if([[MRPlist readPlist:@"VideoQuality"] isEqualToString:@"High"])
                 [vision setOutputFormat:PBJOutputFormatWidescreen];
             else
                 [vision setOutputFormat:PBJOutputFormatSquare];
         }
         
         else if([[change objectForKey:@"new"] isEqualToString:@"StorageSize"])
         {
             storageSizeLimit = [[[MRPlist readPlist:@"StorageSize"] stringByReplacingOccurrencesOfString:@"" withString:@"G"] doubleValue];
             storageSizeLimit *= (1024*1024*1024);
         }
         
//         else if([[change objectForKey:@"new"] isEqualToString:@"AudioInput"])
//         {
//             PBJVision *vision = [PBJVision sharedInstance];
//             [vision audioInput:[[MRPlist readPlist:@"AudioInput"] boolValue]];
//         }
     }
//     else if([keyPath isEqualToString:@"_recording"])
//     {
//         if([[change objectForKey:@"new"] boolValue])
//         {
//             [_recordButton setImage:[UIImage imageNamed:@"Record_Stop"] forState:UIControlStateNormal];
//             _recordButton.selected = YES;
//         }
//         else
//         {
//             [_recordButton setImage:[UIImage imageNamed:@"Record_Start"] forState:UIControlStateNormal];
//             _recordButton.selected = NO;
//         }
//     }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
//        [self addObserver:self
//               forKeyPath:@"_recording"
//                  options:NSKeyValueObservingOptionNew
//                  context:nil];
        
        [self addObserver:self
               forKeyPath:@"frame"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
        
        [g_viewController addObserver:self
                           forKeyPath:@"g_AdmobShowing"
                              options:NSKeyValueObservingOptionNew
                              context:nil];
        
        [[MRPlist sharedInstance] addObserver:self
                                   forKeyPath:@"g_key"
                                      options:NSKeyValueObservingOptionNew
                                      context:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
  
        
        NSLog(@"Setting LimitStorageSize");
        storageSizeLimit = [[[MRPlist readPlist:@"StorageSize"] stringByReplacingOccurrencesOfString:@"" withString:@"G"] doubleValue];
        storageSizeLimit *= (1024*1024*1024);
        //storageSizeLimit = 10*1024*1024;
        NSLog(@"setStorageSize:%f",storageSizeLimit);

        _continue = NO;
        
        tatalCapturedVideoSeconds = 0;
        
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
        
        
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _assetLibrary = [[ALAssetsLibrary alloc] init];
        
        
        
        // preview and AV layer
        _previewView = [[UIView alloc] initWithFrame:CGRectZero];
        _previewView.backgroundColor = [UIColor blackColor];
        CGRect previewFrame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetWidth(self.frame));
        _previewView.frame = previewFrame;
        _previewLayer = [[PBJVision sharedInstance] previewLayer];
        _previewLayer.frame = _previewView.bounds;
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [_previewView.layer addSublayer:_previewLayer];
        [PBJVision sharedInstance].captureDirectory = [MRFileManagement createDir:@"MobRecord"];
        
        // onion skin
        _effectsViewController = [[GLKViewController alloc] init];
        _effectsViewController.preferredFramesPerSecond = 60;
        
//        UIImageView * recordingLedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"capture_flip"]];
//        
//        [_effectsViewController.view addSubview:recordingLedImageView];
        
        NSLog(@"%@", [NSString PBJformattedTimestampStringFromDate:[NSDate date]]);
        
        
        
        GLKView *view = (GLKView *)_effectsViewController.view;
        CGRect viewFrame = _previewView.bounds;
        view.frame = viewFrame;
        view.context = [[PBJVision sharedInstance] context];
        view.contentScaleFactor = [[UIScreen mainScreen] scale];
        view.alpha = 0.5f;
        view.hidden = YES;
        [[PBJVision sharedInstance] setPresentationFrame:_previewView.frame];
        [_previewView addSubview:_effectsViewController.view];
        
        
        
        // focus view
        _focusView = [[PBJFocusView alloc] initWithFrame:CGRectZero];
        
        
        
        
      
        // touch to record
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongPressGestureRecognizer:)];
        _longPressGestureRecognizer.delegate = self;
        _longPressGestureRecognizer.minimumPressDuration = 0;//0.05f;
        _longPressGestureRecognizer.allowableMovement = 10.0f;
        
        // tap to focus
        _focusTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleFocusTapGesterRecognizer:)];
        _focusTapGestureRecognizer.delegate = self;
        _focusTapGestureRecognizer.numberOfTapsRequired = 1;
        _focusTapGestureRecognizer.enabled = NO;
        [_previewView addGestureRecognizer:_focusTapGestureRecognizer];
        
        // gesture view to record
        _gestureView = [[UIView alloc] initWithFrame:CGRectZero];
        _gestureView.frame = [[self layer] bounds];
        [_previewView addSubview:_gestureView];
        
        [_gestureView addGestureRecognizer:_longPressGestureRecognizer];
        
//        // bottom dock
//        _captureDock = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 60.0f, CGRectGetWidth(self.bounds), 60.0f)];
//        _captureDock.backgroundColor = [UIColor clearColor];
//        _captureDock.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
//        [self addSubview:_captureDock];
        
        // flip button
        _flipButton = [ExtendedHitButton extendedHitButton];
        UIImage *flipImage = [UIImage imageNamed:@"capture_flip"];
        [_flipButton setImage:flipImage forState:UIControlStateNormal];
        CGRect flipFrame = _flipButton.frame;
        flipFrame.origin = CGPointMake(20.0f, 16.0f);
        flipFrame.size = flipImage.size;
        _flipButton.frame = flipFrame;
        [_flipButton addTarget:self action:@selector(_handleFlipButton:) forControlEvents:UIControlEventTouchUpInside];
//        [_captureDock addSubview:_flipButton];
        
        // focus mode button
        _focusButton = [ExtendedHitButton extendedHitButton];
        UIImage *focusImage = [UIImage imageNamed:@"capture_focus_button"];
        [_focusButton setImage:focusImage forState:UIControlStateNormal];
        [_focusButton setImage:[UIImage imageNamed:@"capture_focus_button_active"] forState:UIControlStateSelected];
        CGRect focusFrame = _focusButton.frame;
        focusFrame.origin = CGPointMake((CGRectGetWidth(self.bounds) * 0.5f) - (focusImage.size.width * 0.5f),
                                        (CGRectGetHeight(self.bounds) * 0.5f) - (focusImage.size.height * 0.5f));
        focusFrame.size = focusImage.size;
        _focusButton.frame = focusFrame;
        [_focusButton addTarget:self action:@selector(_handleFocusButton:) forControlEvents:UIControlEventTouchUpInside];
        [_previewView addSubview:_focusButton];
        
        
        // record button
        _recordButton = [ExtendedHitButton extendedHitButton];
        UIImage *recordImage = [UIImage imageNamed:@"Record_Start"];
        [_recordButton setImage:recordImage forState:UIControlStateNormal];
        [_recordButton setImage:[UIImage imageNamed:@"Record_Stop"] forState:UIControlStateSelected];
        //[_recordButton setBackgroundImage:[UIImage imageNamed:@"settings-icon"] forState:UIControlStateSelected];
        CGRect recordFrame = _recordButton.frame;
        recordFrame.origin = CGPointMake((CGRectGetWidth(self.bounds) * 0.5f) - (recordImage.size.width * 0.5f),
                                        (CGRectGetHeight(self.bounds) * 0.5f) - (recordImage.size.height * 0.5f));
        
        recordFrame.size.width = recordImage.size.width *0.9;
        recordFrame.size.height = recordImage.size.height *0.9;
        _recordButton.frame = recordFrame;
        [_recordButton addTarget:self action:@selector(_handleRecordButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_recordButton addTarget:self action:@selector(_handleRecordButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_recordButton addTarget:self action:@selector(_handleRecordButtonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        [_previewView addSubview:_recordButton];
        
        
        if ([[PBJVision sharedInstance] supportsVideoFrameRate:120]) {
            // set faster frame rate
        }
        
//        // onion button
//        _onionButton = [ExtendedHitButton extendedHitButton];
//        UIImage *onionImage = [UIImage imageNamed:@"capture_onion"];
//        [_onionButton setImage:onionImage forState:UIControlStateNormal];
//        [_onionButton setImage:[UIImage imageNamed:@"capture_onion_selected"] forState:UIControlStateSelected];
//        CGRect onionFrame = _onionButton.frame;
//        onionFrame.origin = CGPointMake(CGRectGetWidth(self.bounds) - onionImage.size.width - 20.0f, 50.0f);
//        onionFrame.size = onionImage.size;
//        _onionButton.frame = onionFrame;
//        _onionButton.imageView.frame = _onionButton.bounds;
//        [_onionButton addTarget:self action:@selector(_handleOnionSkinningButton:) forControlEvents:UIControlEventTouchUpInside];
//        [_previewView addSubview:_onionButton];
        
        
        // elapsed time and red dot
        _strobeView = [[PBJStrobeView alloc] initWithFrame:CGRectZero];
        CGRect strobeFrame = _strobeView.frame;
        strobeFrame.origin = CGPointMake((CGRectGetWidth(self.bounds) * 0.5f) - (strobeFrame.size.width * 0.75f), 0);
        _strobeView.frame = strobeFrame;
        [_previewView addSubview:_strobeView];
        
//        // done button
//        CGFloat viewWidth = CGRectGetWidth(self.frame);
//        _doneButton = [ExtendedHitButton extendedHitButton];
//        _doneButton.frame = CGRectMake(viewWidth - 25.0f - 15.0f, 18.0f, 25.0f, 25.0f);
//        UIImage *buttonImage = [UIImage imageNamed:@"capture_done"];
//        [_doneButton setImage:buttonImage forState:UIControlStateNormal];
//        [_doneButton addTarget:self action:@selector(_handleDoneButton:) forControlEvents:UIControlEventTouchUpInside];
//        [_previewView addSubview:_doneButton];
        
        
        
        [self addSubview:_previewView];
        [self bringSubviewToFront:_gestureView];
        
        
        
//        CGRect frame = CGRectMake(10, 150, 300, 50);
//        frame.origin = CGPointMake((CGRectGetWidth(self.bounds) * 0.5f) - (recordImage.size.width * 0.5f),
//                                   (CGRectGetHeight(self.bounds) * 0.5f) - (recordImage.size.height * 0.5f));
//        _recordText = [[FBSquareFontView alloc] initWithFrame:frame];
//        
//        _recordText.text = @"START";
//        _recordText.lineWidth = 5;//3.0;
//        _recordText.lineCap = kCGLineCapRound;
//        _recordText.lineJoin = kCGLineJoinRound;
//        _recordText.margin = 6;//12.0;
//        _recordText.backgroundColor = [UIColor clearColor];
//        _recordText.horizontalPadding = 15;//30;
//        _recordText.verticalPadding = 7;//14;
//        _recordText.glowSize = 5;//10.0;
//        _recordText.glowColor = UIColorFromRGB(0x00ffff);//0x00ffff
//        _recordText.innerGlowColor = UIColorFromRGB(0x00ffff); //0x00ffff
//        _recordText.lineColor = UIColorFromRGB(0xffffff); // 0xffdd66 ,0xffffff
//        _recordText.innerGlowSize = 2.0;
//        _recordText.verticalEdgeLength = 10;//12;
//        _recordText.horizontalEdgeLength = 12;//14;
//        
//        
//        _recordText.tag = 9999;
//        
//        [self addSubview:_recordText];
//        [_recordText resetSize];
        
        
        // iOS 6 support
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        
        [self _resetCapture];
        [[PBJVision sharedInstance] startPreview];
        
        [self performSelectorOnMainThread:@selector(updateRecProcess) withObject:nil waitUntilDone:NO];
    }
    return self;
}
//
//#pragma mark - touch
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"Touches Began");
//    //[self logTouches: event];
//    UITouch *touch = [touches anyObject];
//    if(touch.view.tag == 9999)
//    {
//
//        _recordText.glowColor = UIColorFromRGB(0xffffff);//0x00ffff
//        _recordText.innerGlowColor = UIColorFromRGB(0xff8080); //0x00ffff
//        _recordText.lineColor = UIColorFromRGB(0xff0000); // 0xffdd66 ,0xffffff
// 
//    }
//    
//    
//
//    [super touchesEnded: touches withEvent: event];
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"Touches Moved");
//    //[self logTouches: event];
//
//    [super touchesEnded: touches withEvent: event];
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"Touches Ended");
//    //[self logTouches: event];
//    UITouch *touch = [touches anyObject];
//    if(touch.view.tag == 9999)
//    {
//        _recordText.glowColor = UIColorFromRGB(0xff8080);//0x00ffff
//        _recordText.innerGlowColor = UIColorFromRGB(0xff8080); //0x00ffff
//        _recordText.lineColor = UIColorFromRGB(0xff0000); // 0xffdd66 ,0xffffff
//        _recordText.text = @"STOP";
//        [_recordText resetSize];
//    }
//    
//    [super touchesEnded: touches withEvent: event];
//}
//
//-(void)logTouchesFor: (UIEvent*)event
//{
////    int count = 1;
////
////    for (UITouch* touch in event.allTouches)
////    {
////        CGPoint location = [touch locationInView: self.view];
////
////        NSLog(@"%d: (%.0f, %.0f)", count, location.x, location.y);
////        count++;
////    }
//}
#pragma mark - private start/stop helper methods

- (void)_startCapture
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
//    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        //_rectimeLabel.alpha = 0;
//        _rectimeLabel.text = [NSString stringWithFormat:@"%.2llu:%.2llu:%.2llu", totalSecondsToHr(0),
//                                                                                 totalSecondsToMin(0),
//                                                                                 totalSecondsToSec(0)];
//        _rectimeLabel.textColor = [UIColor redColor];
//        _rectimeLabel.transform = CGAffineTransformMakeScale(2.0f, 2.0f);
//    } completion:^(BOOL finished) {
//    }];
    [[PBJVision sharedInstance] startVideoCapture];
    
}

- (void)_pauseCapture
{
//    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        //_rectimeLabel.alpha = 1;
//        _rectimeLabel.textColor = [UIColor grayColor];
//        _rectimeLabel.transform = CGAffineTransformMakeScale(2.0f, 2.0f);
//    } completion:^(BOOL finished) {
//    }];
    
    [[PBJVision sharedInstance] pauseVideoCapture];
//    _effectsViewController.view.hidden = !_onionButton.selected;
}

- (void)_resumeCapture
{
//    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        //_rectimeLabel.alpha = 0;
//        _rectimeLabel.textColor = [UIColor redColor];
//        _rectimeLabel.transform = CGAffineTransformMakeScale(2.0f, 2.0f);
//    } completion:^(BOOL finished) {
//    }];
    
    [[PBJVision sharedInstance] resumeVideoCapture];
//    _effectsViewController.view.hidden = YES;
}

- (void)_endCapture
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[PBJVision sharedInstance] endVideoCapture];
//    _effectsViewController.view.hidden = YES;
}

- (void)_resetCapture
{
    [_strobeView stop];
    _longPressGestureRecognizer.enabled = YES;
    
    PBJVision *vision = [PBJVision sharedInstance];
    vision.delegate = self;
    
    if ([vision isCameraDeviceAvailable:PBJCameraDeviceBack]) {
        vision.cameraDevice = PBJCameraDeviceBack;
        _flipButton.hidden = NO;
    } else {
        vision.cameraDevice = PBJCameraDeviceFront;
        _flipButton.hidden = YES;
    }
    
    vision.cameraMode = PBJCameraModeVideo;
    //vision.cameraMode = PBJCameraModePhoto; // PHOTO: uncomment to test photo capture
    vision.cameraOrientation = [self videoOrientationFromDeviceOrientation];
    
    [vision setExposureMode:PBJExposureModeContinuousAutoExposure];
    
//    vision.audioCaptureEnabled = [[MRPlist readPlist:@"AudioInput"] boolValue];//![[AVAudioSession sharedInstance] isOtherAudioPlaying];//[[MRPlist readPlist:@"AudioInput"] boolValue];
    
    vision.autoUpdatePreviewOrientation = YES;
    vision.focusMode = PBJFocusModeContinuousAutoFocus;
    
    if([[MRPlist readPlist:@"VideoQuality"] isEqualToString:@"Normal"])
        vision.outputFormat = PBJOutputFormatStandard;
    else if([[MRPlist readPlist:@"VideoQuality"] isEqualToString:@"High"])
        vision.outputFormat = PBJOutputFormatWidescreen;
    else
        vision.outputFormat = PBJOutputFormatSquare;
    vision.videoRenderingEnabled = YES;
    vision.additionalCompressionProperties = @{AVVideoProfileLevelKey :
                                                   AVVideoProfileLevelH264Baseline30}; // AVVideoProfileLevelKey requires specific captureSessionPreset
    
    
    
    //vision.previewOrientation =PBJCameraOrientationLandscapeLeft;
    // specify a maximum duration with the following property
    // vision.maximumCaptureDuration = CMTimeMakeWithSeconds(5, 600); // ~ 5 seconds
    
    NSLog(@"GGYY-_resetCapture");
}

#pragma mark - UIButton
- (void)_handleRecordButtonTouchUpInside:(UIButton *)button
{
    NSLog(@"_handleRecordButtonTouchUpInside:%hhd", button.selected);
    
    if([[MRPlist readPlist:@"WeAreRecording"]boolValue])
    {
        [MRPlist writePlist:@"WeAreRecording" content:@"NO"];
        [self stopRecording];
    }
    else
    {
        
        [MRPlist writePlist:@"WeAreRecording" content:@"YES"];
        [self startRecording];
        tmpStartData = [NSDate date];
    }
    
}
- (void)_handleRecordButtonTouchDown:(UIButton *)button
{
    NSLog(@"_handleRecordButtonTouchDown:%hhd", button.selected);
}
- (void)_handleRecordButtonTouchUpOutside:(UIButton *)button
{
    NSLog(@"_handleRecordButtonTouchUpOutside:%hhd", button.selected);
}

- (void)_handleFlipButton:(UIButton *)button
{
    PBJVision *vision = [PBJVision sharedInstance];
    vision.cameraDevice = vision.cameraDevice == PBJCameraDeviceBack ? PBJCameraDeviceFront : PBJCameraDeviceBack;
}

- (void)_handleFocusButton:(UIButton *)button
{
    _focusButton.selected = !_focusButton.selected;
    
    [UIButton beginAnimations:nil context:nil];
    [UIButton setAnimationDuration:0.5];
    [UIButton setAnimationBeginsFromCurrentState:YES];
    [UIButton setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                             forView:_focusButton cache:YES];
    
    [UIButton commitAnimations];
    
//    if (_focusButton.selected) {
//        _focusTapGestureRecognizer.enabled = YES;
//        _gestureView.hidden = YES;
//        
//    } else {
//        if (_focusView && [_focusView superview]) {
//            [_focusView stopAnimation];
//        }
//        _focusTapGestureRecognizer.enabled = NO;
//        _gestureView.hidden = NO;
//    }
    
//    [UIView animateWithDuration:0.15f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        _instructionLabel.alpha = 0;
//    } completion:^(BOOL finished) {
//        _instructionLabel.text = _focusButton.selected ? NSLocalizedString(@"Touch to focus", @"Touch to focus") :
//        NSLocalizedString(@"Touch and hold to record", @"Touch and hold to record");
//        [UIView animateWithDuration:0.15f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            _instructionLabel.alpha = 1;
//        } completion:^(BOOL finished1) {
//        }];
//    }];
}

- (void)_handleFrameRateChangeButton:(UIButton *)button
{
}

//- (void)_handleOnionSkinningButton:(UIButton *)button
//{
//    _onionButton.selected = !_onionButton.selected;
//    
//    if (_recording) {
//        _effectsViewController.view.hidden = !_onionButton.selected;
//    }
//}

- (void)_handleDoneButton:(UIButton *)button
{
    // resets long press
    _longPressGestureRecognizer.enabled = NO;
    _longPressGestureRecognizer.enabled = YES;
    
    [self _endCapture];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self _resetCapture];
}

#pragma mark - UIGestureRecognizer

- (void)_handleLongPressGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    // PHOTO: uncomment to test photo capture
    //    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    //        [[PBJVision sharedInstance] capturePhoto];
    //        return;
    //    }
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
//            if (!_recording)
//                [self _startCapture];
//            else
//                [self _resumeCapture];
            NSLog(@"UIGestureRecognizerStateBegan");
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            NSLog(@"UIGestureRecognizerStateEnded");
            if(_recordButton.hidden)
            {
                [self recButtonHidden:NO];
                
                if(_recording)
                {
                    [NSTimer scheduledTimerWithTimeInterval:10.0
                                                     target:self
                                                   selector:@selector(hiddenRecStartStopButton:)
                                                   userInfo:nil
                                                    repeats:NO];
                }
            }
            else
            {
                [self recButtonHidden:YES];
            }

            break;
        }
        default:
            break;
    }
}

- (void)_handleFocusTapGesterRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint tapPoint = [gestureRecognizer locationInView:_previewView];
    
    // auto focus is occuring, display focus view
    CGPoint point = tapPoint;
    
    CGRect focusFrame = _focusView.frame;
#if defined(__LP64__) && __LP64__
    focusFrame.origin.x = rint(point.x - (focusFrame.size.width * 0.5));
    focusFrame.origin.y = rint(point.y - (focusFrame.size.height * 0.5));
#else
    focusFrame.origin.x = rintf(point.x - (focusFrame.size.width * 0.5f));
    focusFrame.origin.y = rintf(point.y - (focusFrame.size.height * 0.5f));
#endif
    [_focusView setFrame:focusFrame];
    
    [_previewView addSubview:_focusView];
    [_focusView startAnimation];
    
    CGPoint adjustPoint = [PBJVisionUtilities convertToPointOfInterestFromViewCoordinates:tapPoint inFrame:_previewView.frame];
    [[PBJVision sharedInstance] focusExposeAndAdjustWhiteBalanceAtAdjustedPoint:adjustPoint];
    
    
}

#pragma mark - PBJVisionDelegate

// session

- (void)visionSessionWillStart:(PBJVision *)vision
{
    NSLog(@"visionSessionWillStart");
}

- (void)visionSessionDidStart:(PBJVision *)vision
{
    NSLog(@"visionSessionDidStart");
    
//    if (![_previewView superview]) {
//        [self addSubview:_previewView];
//        [self bringSubviewToFront:_gestureView];
//    }

    
    if([[MRPlist readPlist:@"WeAreRecording"] boolValue])
    {
        [self startRecording];
    }
    else
    {
        [self stopRecording];
    }
    [self performSelectorOnMainThread:@selector(updateRecProcess) withObject:nil waitUntilDone:NO];
}

- (void)visionSessionDidStop:(PBJVision *)vision
{
    NSLog(@"visionSessionDidStop");
    
//    [_previewView removeFromSuperview];
    
    
    [self stopRecProcessTimer];
}

// preview

- (void)visionSessionDidStartPreview:(PBJVision *)vision
{
    NSLog(@"Camera preview did start");
}

- (void)visionSessionDidStopPreview:(PBJVision *)vision
{
    NSLog(@"Camera preview did stop");

}

// device

- (void)visionCameraDeviceWillChange:(PBJVision *)vision
{
    NSLog(@"Camera device will change");
}

- (void)visionCameraDeviceDidChange:(PBJVision *)vision
{
    NSLog(@"Camera device did change");
}

// mode

- (void)visionCameraModeWillChange:(PBJVision *)vision
{
    NSLog(@"Camera mode will change");
}

- (void)visionCameraModeDidChange:(PBJVision *)vision
{
    NSLog(@"Camera mode did change");
}

// format

- (void)visionOutputFormatWillChange:(PBJVision *)vision
{
    NSLog(@"Output format will change");
    
}

- (void)visionOutputFormatDidChange:(PBJVision *)vision
{
    NSLog(@"Output format did change");
}

- (void)vision:(PBJVision *)vision didChangeCleanAperture:(CGRect)cleanAperture
{
}

// focus / exposure

- (void)visionWillStartFocus:(PBJVision *)vision
{
}

- (void)visionDidStopFocus:(PBJVision *)vision
{
    if (_focusView && [_focusView superview]) {
        [_focusView stopAnimation];
    }
}

- (void)visionWillChangeExposure:(PBJVision *)vision
{
}

- (void)visionDidChangeExposure:(PBJVision *)vision
{
    if (_focusView && [_focusView superview]) {
        [_focusView stopAnimation];
    }
}

// flash

- (void)visionDidChangeFlashMode:(PBJVision *)vision
{
    NSLog(@"Flash mode did change");
}

// photo

- (void)visionWillCapturePhoto:(PBJVision *)vision
{
}

- (void)visionDidCapturePhoto:(PBJVision *)vision
{
}

- (void)vision:(PBJVision *)vision capturedPhoto:(NSDictionary *)photoDict error:(NSError *)error
{
    if (error) {
        // handle error properly
        return;
    }
    _currentPhoto = photoDict;
    
    // save to library
    NSData *photoData = _currentPhoto[PBJVisionPhotoJPEGKey];
    NSDictionary *metadata = _currentPhoto[PBJVisionPhotoMetadataKey];
    [_assetLibrary writeImageDataToSavedPhotosAlbum:photoData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error1) {
        if (error1 || !assetURL) {
            // handle error properly
            return;
        }
        
        NSString *albumName = @"PBJVision";
        __block BOOL albumFound = NO;
        [_assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if ([albumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
                albumFound = YES;
                [_assetLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                    [group addAsset:asset];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Photo Saved!" message: @"Saved to the camera roll."
                                                                   delegate:nil
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"OK", nil];
                    [alert show];
                } failureBlock:nil];
            }
            if (!group && !albumFound) {
                __weak ALAssetsLibrary *blockSafeLibrary = _assetLibrary;
                [_assetLibrary addAssetsGroupAlbumWithName:albumName resultBlock:^(ALAssetsGroup *group1) {
                    [blockSafeLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                        [group1 addAsset:asset];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Photo Saved!" message: @"Saved to the camera roll."
                                                                       delegate:nil
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"OK", nil];
                        [alert show];
                    } failureBlock:nil];
                } failureBlock:nil];
            }
        } failureBlock:nil];
    }];
    
    _currentPhoto = nil;
}

// video capture

- (void)visionDidStartVideoCapture:(PBJVision *)vision
{
    [_strobeView start];
    _recording = YES;
    
   
}

- (void)visionDidPauseVideoCapture:(PBJVision *)vision
{
    [_strobeView stop];
    
}

- (void)visionDidResumeVideoCapture:(PBJVision *)vision
{
    [_strobeView start];
   
}

- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error
{
    _saveReady = NO;
    _recording = NO;
    [_strobeView stop];
    
    
//    NSString * const PBJVisionVideoPathKey = @"PBJVisionVideoPathKey";
//    NSString * const PBJVisionVideoThumbnailKey = @"PBJVisionVideoThumbnailKey";
//    NSString * const PBJVisionVideoThumbnailArrayKey = @"PBJVisionVideoThumbnailArrayKey";
//    NSString * const PBJVisionVideoCapturedDurationKey = @"PBJVisionVideoCapturedDurationKey";
//    
//    
    
    
    
    
//    [g_mrTableView.tableViewMovies reloadData];
 
    if (error && [error.domain isEqual:PBJVisionErrorDomain] && error.code == PBJVisionErrorCancelled) {
        NSLog(@"recording session cancelled");
        _saveReady = YES;
        return;
    } else if (error) {
        NSLog(@"encounted an error in video capture (%@)", error);
        _saveReady = YES;
        return;
    }
    
    _currentVideo = videoDict;
    
    
    [g_mrTableView addTableViewItem:videoDict];// 加入新的Cell
    
    _saveReady = YES;
//    _currentVideo = videoDict;
//    
//    NSString *videoPath = [_currentVideo  objectForKey:PBJVisionVideoPathKey];
//    [_assetLibrary writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:videoPath] completionBlock:^(NSURL *assetURL, NSError *error1) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Video Saved!" message: @"Saved to the camera roll."
//                                                       delegate:self
//                                              cancelButtonTitle:nil
//                                              otherButtonTitles:@"OK", nil];
//        [alert show];
//    }];
}

// progress

- (void)vision:(PBJVision *)vision didCaptureVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    //NSLog(@"captured video (%f) seconds", vision.capturedVideoSeconds);
    
 
    
//    //if((totalSecondsToSec(vision.capturedVideoSeconds) % 2) == 0)
//    {
//        
//        NSLog(@"totalDirSpaceInBytes=%f",[ALDisk totalDirSpaceInBytes]/1024/1024);
//        NSLog(@"availableDiskSpaceInBytes=%llu",[PBJVisionUtilities availableDiskSpaceInBytes]/1024/1024);
//        
//    }
    
//    if([[MRPlist readPlist:@"WeAreRecording"] boolValue])
//    {
//        if(_continueRecording == NO)
//        {
//            dirTotalSizeInBytes = [ALDisk totalDirSpaceInBytes];
//            //if(dirTotalSizeInBytes <= storageSizeLimit)
//            if(dirTotalSizeInBytes <= 1024*1024*1)
//            {
//                
//                //Start recording
//                NSLog(@"Start recording...");
//                
//                [self _pauseCapture];
//                [self _endCapture];
//                [self _startCapture];
//                _continueRecording = YES;
//            }
//            else{
//                NSLog(@"目錄Size(%f)大於設定值(%f)",dirTotalSizeInBytes,storageSizeLimit);
//                do{
//                    NSLog(@"開始清除最舊的影片 path:%@",[MRFileManagement findEarlierCreationDateAtFolder:@"MobRecord"]);
//                    [[NSFileManager defaultManager] removeItemAtPath:[MRFileManagement findEarlierCreationDateAtFolder:@"MobRecord"] error:NULL];
//                    dirTotalSizeInBytes = [ALDisk totalDirSpaceInBytes];
//                }while (dirTotalSizeInBytes > (storageSizeLimit*0.6)); //刪除檔案後的大小，必須預留50%的空間
//            }
//        }
//    }
}

//- (void)maxFromImage:(const vImage_Buffer)src toImage:(const vImage_Buffer)dst
//{
//    unsigned long kernelSize = 7;
//    vImageMin_Planar8(&src, &dst, NULL, 0, 0, kernelSize, kernelSize, kvImageDoNotTile);
//}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

- (void)vision:(PBJVision *)vision didCaptureAudioSample:(CMSampleBufferRef)sampleBuffer
{
        //NSLog(@"captured Audio (%f) seconds", vision.capturedAudioSeconds);
}


//#pragma mark - Protocol CvVideoCameraDelegate
//
//#ifdef __cplusplus
//- (void)processImage:(Mat&)image;
//{
//    // Do some OpenCV stuff with the image
//    // Do some OpenCV stuff with the image
//    Mat image_copy;
//    cvtColor(image, image_copy, CV_BGRA2BGR);
//    
//    // invert image
//    bitwise_not(image_copy, image_copy);
//    cvtColor(image_copy, image, CV_BGR2BGRA);
//}
//#endif

#pragma mark
#pragma mark - 更新預覽視圖

- (void) updateCameraFrame {
//    CGRect cameraViewFrame = self.frame;
//    if(g_viewController.g_AdmobShowing)
//    {
//        if(cameraViewFrame.size.width == 150)
//            cameraViewFrame.origin.y = CGSizeFromGADAdSize(kGADAdSizeSmartBannerLandscape).height;
//        else
//            cameraViewFrame.origin.y = CGSizeFromGADAdSize(kGADAdSizeSmartBannerLandscape).height;
//    }
//    else
//    {
//        cameraViewFrame.origin.y = 0;
//    }
//    [self setFrame:cameraViewFrame];
//    [_previewView setFrame:self.frame];
//    [_gestureView setFrame:self.frame];
    
    
    [self updateAll];
}

- (void) updatePreviewLayerFrame {
    
}

- (void) updateAll{
    
    
}

- (void) hidden:(UIView*)view
{
    [UIButton beginAnimations:nil context:nil];
    [UIButton setAnimationDuration:0.5];
    [UIButton setAnimationBeginsFromCurrentState:YES];
    [UIButton setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                             forView:self cache:YES];
    self.hidden = YES;
    [UIButton commitAnimations];

}
- (void) show:(UIView*)view
{
    [UIButton beginAnimations:nil context:nil];
    [UIButton setAnimationDuration:0.5];
    [UIButton setAnimationBeginsFromCurrentState:YES];
    [UIButton setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                             forView:self cache:YES];
    self.hidden = NO;
    [UIButton commitAnimations];
}


#pragma mark
#pragma mark - 設定攝影機的轉向
- (PBJCameraOrientation)videoOrientationFromDeviceOrientation {
    
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)[UIDevice currentDevice].orientation;
    switch (result)
    {
        case UIDeviceOrientationLandscapeLeft:
            return PBJCameraOrientationLandscapeRight;
        case UIDeviceOrientationLandscapeRight:
            return PBJCameraOrientationLandscapeLeft;
        case UIDeviceOrientationPortraitUpsideDown:
            return PBJCameraOrientationPortraitUpsideDown;
        case UIDeviceOrientationPortrait:
            return PBJCameraOrientationPortrait;
        default:break;
    }
    return (PBJCameraOrientation)result;
}
- (void) orientationChanged:(NSNotification *)notification {
    [self rotateLayer];
}

- (void) rotateLayer {
    if(([self videoOrientationFromDeviceOrientation] == AVCaptureVideoOrientationLandscapeLeft)  ||
       ([self videoOrientationFromDeviceOrientation] == AVCaptureVideoOrientationLandscapeRight) )
    {
        [PBJVision sharedInstance].cameraOrientation = [self videoOrientationFromDeviceOrientation];
    }else{}
}

#pragma mark
#pragma mark Timer callback func - hiddenRecStartStopButton
- (void) hiddenRecStartStopButton:(NSTimer *)theTimer {
    if([[MRPlist readPlist:@"WeAreRecording"] boolValue])
    {
        [UIButton beginAnimations:nil context:nil];
        [UIButton setAnimationDuration:0.5];
        [UIButton setAnimationBeginsFromCurrentState:YES];
        [UIButton setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                                 forView:_recordButton cache:YES];
        _recordButton.hidden = YES;
        [UIButton commitAnimations];
    }
}
#pragma mark
#pragma make - REC按鍵的顯示與隱藏
- (void) recButtonHidden : (BOOL)hidden {
    if(hidden)
    {
        [UIButton beginAnimations:nil context:nil];
        [UIButton setAnimationDuration:0.5];
        [UIButton setAnimationBeginsFromCurrentState:YES];
        [UIButton setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                                 forView:_recordButton cache:YES];
       _recordButton.hidden = YES;
        
        [UIButton commitAnimations];
    }
    else
    {
        [UIButton beginAnimations:nil context:nil];
        [UIButton setAnimationDuration:0.5];
        [UIButton setAnimationBeginsFromCurrentState:YES];
        [UIButton setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                                 forView:_recordButton cache:YES];
        _recordButton.hidden = NO;
        [UIButton commitAnimations];
    }
}
@end
