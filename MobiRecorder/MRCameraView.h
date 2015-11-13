//
//  MRCameraView.h
//  MobRecorder
//
//  Created by GarY on 2014/8/22.
//  Copyright (c) 2014年 GarY WanG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVFoundation/AVFoundation.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVCaptureSession.h>
#import <AVFoundation/AVCaptureOutput.h>
#import <AVFoundation/AVCaptureInput.h>
#import <AVFoundation/AVMediaFormat.h>
#import "MRViewController.h"

#import "ALDisk.h"
#import "MRPlist.h"

//<<Can delete if not storing videos to the photo library.  Delete the assetslibrary framework too requires this)
#import <AssetsLibrary/AssetsLibrary.h>

@interface MRCameraView : UIView <AVCaptureFileOutputRecordingDelegate>
{
   
    BOOL UpdateRecordingProcess;
    BOOL WeAreRecording;
    bool continueRecording;
    bool recordingError;
    CGFloat storageSizeLimit;
    CGFloat dirTotalSizeInBytes;
    AVCaptureSession *CaptureSession;
    AVCaptureMovieFileOutput *MovieFileOutput;
}

@property (retain) AVCaptureSession *CaptureSession;
@property (nonatomic,retain) AVCaptureMovieFileOutput *MovieFileOutput;

@property BOOL UpdateRecordingProcess;
@property (retain) AVCaptureVideoPreviewLayer *PreviewLayer;
@property BOOL WeAreRecording;
@property bool continueRecording;
@property bool contentCreated;
@property bool recordingError;

+ (MRCameraView *)sharedInstance;

- (void) CameraSetOutputProperties;
- (void) StartRecordingProcess;
- (void) StopRecordingProcess;
- (void) updateStorageSizeLimit;
- (void) updateVideoQuality;

- (AVCaptureDevice *) CameraWithPosition:(AVCaptureDevicePosition) Position;

- (void) StartStopButtonPressed;

- (void) RunCamera;
- (void) StopCamera;

- (void) StopRecording;
- (void) StartRecording;

- (void) updateRecordingTimeLabelFrame;
- (void) updateRecordingLEDFrame;

- (void) updateAll;
- (void) hidden:(UIView*)view;
- (void) show:(UIView*)view;

- (void) AudioInput:(BOOL)On;
- (void) CameraFocus :(NSInteger)focusMode;

- (void) updateCameraFrame;
@end
