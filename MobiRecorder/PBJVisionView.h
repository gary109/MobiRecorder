//
//  PBJVisionView.h
//  MobiRecorder
//
//  Created by GarY on 2015/4/30.
//  Copyright (c) 2015年 gyhouse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PBJVisionView : UIView
+ (PBJVisionView *)sharedInstance;

@property (nonatomic,strong) UIView *_previewView;

- (void) hidden:(UIView*)view;
- (void) show:(UIView*)view;
- (void) updateCameraFrame;
- (void) updateAll;
- (void) _endCapture;
- (void) _resumeCapture;
- (void) _startCapture;
- (void) recordProcessing;
- (void) stopRecording;
- (void) startRecording;
@end