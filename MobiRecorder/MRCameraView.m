//
//  MRCameraView.m
//  MobRecorder
//
//  Created by GarY on 2014/8/22.
//  Copyright (c) 2014年 GarY WanG. All rights reserved.
//

#import "MRCameraView.h"
#import "MRTableView.h"
#import "MRFileManagement.h"
#import "NSTimer+Blocks.h"

MRCameraView *g_mrCameraView;
extern MRViewController *g_viewController;
extern MRTableView *g_mrTableView;

@interface MRCameraView ()
@property (nonatomic,strong) NSTimer    * updateViewTimer;
@property (nonatomic,retain) NSTimer    * updateStartStopBtnMotion;
@property (nonatomic,retain) NSDate     * tmpStartData;
@property (nonatomic,retain) NSDate     * currentStartData;
@property (retain) AVCaptureDeviceInput * myDeviceInput;
@end

@implementation MRCameraView
@synthesize updateViewTimer;
@synthesize updateStartStopBtnMotion;
@synthesize CaptureSession = _CaptureSession;
@synthesize MovieFileOutput = _MovieFileOutput;
@synthesize tmpStartData,currentStartData;
@synthesize myDeviceInput,PreviewLayer;
@synthesize recordingError;
@synthesize contentCreated,continueRecording;
@synthesize WeAreRecording;
@synthesize UpdateRecordingProcess;


+ (MRCameraView *)sharedInstance
{
    static MRCameraView *singleton = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        CGRect frame = [[g_viewController.view layer] bounds];
        frame.origin.y = CGRectGetMinY(frame);
        singleton = [[MRCameraView alloc] initWithFrame:frame];
        g_mrCameraView = singleton;
    });
    return singleton;
}

#pragma mark
#pragma mark Timer callback func - hiddenRecStartStopButton
- (void) hiddenRecStartStopButton:(NSTimer *)theTimer {
    //[updateStartStopBtnMotion setFireDate:[NSDate distantFuture]];
    if(WeAreRecording)
    {
        [UIButton beginAnimations:nil context:nil];
        [UIButton setAnimationDuration:0.5];
        [UIButton setAnimationBeginsFromCurrentState:YES];
        [UIButton setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                                 forView:(UIView*)[self viewWithTag:_TAG_CAMERA_REC_STARTSTOP_BTN_] cache:YES];
        ((UIView*)[self viewWithTag:_TAG_CAMERA_REC_STARTSTOP_BTN_]).hidden = YES;
        [UIButton commitAnimations];
    }
}

#pragma mark
#pragma mark Timer callback func - updateView
- (void) updateView {
    //NSLog(@"updateView");
    [self stopTimer];
    updateViewTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 block:^ {
        if(UpdateRecordingProcess)
        {
            if(WeAreRecording)
            {
                double deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
            
                UILabel * recordingTimeLabel = (UILabel *)[self viewWithTag:_TAG_CAMERA_RECORDING_TIME_LABEL_];
                recordingTimeLabel.text = [NSString stringWithFormat:@"%.2llu:%.2llu:%.2llu", totalSecondsToHr(deltaTime),
                                                                                              totalSecondsToMin(deltaTime),
                                                                                              totalSecondsToSec(deltaTime)];
            }else{
                tmpStartData = [NSDate date];
            }
        
            [self RecordingProcess];
        }else{
            tmpStartData = [NSDate date];
        }
    } repeats:YES];
}
- (void) stopTimer
{
    if (updateViewTimer) {
        [updateViewTimer invalidate];
        updateViewTimer = nil;
    }
    
}
#pragma mark
#pragma mark 視圖初始化
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSLog(@"initWithFrame - Enter");
        g_mrCameraView = self;
        contentCreated = NO;
        WeAreRecording = [[MRPlist readPlist:@"WeAreRecording"] boolValue];
        continueRecording = NO;
        recordingError = NO;
        UpdateRecordingProcess = YES;
        
       
            self.layer.borderWidth = 1;
            self.layer.borderColor = [[UIColor colorWithRed:.5 green:.5 blue:.5 alpha:0.4] CGColor];
            
            NSLog(@"didMoveToView - Enter");
            
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"HH:mm:ss"];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(orientationChanged:)
                                                         name:UIDeviceOrientationDidChangeNotification
                                                       object:nil];
            
            NSLog(@"x: %f", [[self layer] bounds].origin.x);
            NSLog(@"y: %f", [[self layer] bounds].origin.y);
            NSLog(@"w: %f", [[self layer] bounds].size.width);
            NSLog(@"h: %f", [[self layer] bounds].size.height);
            
            self.backgroundColor = [UIColor darkGrayColor];
            
            
            // 偵測是否有 Camera
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIAlertView * myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                       message:@"Device has no camera"
                                                                      delegate:nil
                                                             cancelButtonTitle:@"OK"
                                                             otherButtonTitles: nil];
                
                [myAlertView show];
            }
            else {
                [self CameraInit];
                
                [self createRecStartStopButton];
                
                [self createRecordingTimeLabel];
                [self updateRecordingTimeLabel];
                
                [self createRecordingLED];
                [self updateRecordingLED];
                
                currentStartData = [NSDate date];
                
//                [NSTimer scheduledTimerWithTimeInterval:0.05
//                                                 target:self
//                                               selector:@selector(updateView:)
//                                               userInfo:nil
//                                                repeats:YES];
                
                [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:NO];
                
                
//                updateStartStopBtnMotion = [NSTimer scheduledTimerWithTimeInterval:5.0
//                                                                            target:self
//                                                                          selector:@selector(hiddenRecStartStopButton:)
//                                                                          userInfo:nil
//                                                                           repeats:YES];
//                [updateStartStopBtnMotion setFireDate:[NSDate distantFuture]];
            }
           
    }
    return self;
}
#pragma mark
#pragma mark - 場景旋轉相關

#pragma mark
#pragma mark - 音訊切換
- (void) AudioInput:(BOOL)On
{
    if(On)
    {
        // beginConfiguration ensures that pending changes are not applied immediately
        [CaptureSession beginConfiguration];
        AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        NSError *error = nil;
        AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
        if ([CaptureSession canAddInput:audioInput])
        {
            [CaptureSession addInput:audioInput];
            [CaptureSession setUsesApplicationAudioSession:YES];
        }
        else
            NSLog(@"加入音訊設定---失敗");
        
        // Changes take effect once the outermost commitConfiguration is invoked.
        [CaptureSession commitConfiguration];
    }
    else
    {
        // beginConfiguration ensures that pending changes are not applied immediately
        [CaptureSession beginConfiguration];
        AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        NSError *error = nil;
        AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
        [CaptureSession removeInput:audioInput];
        
        // Changes take effect once the outermost commitConfiguration is invoked.
        [CaptureSession commitConfiguration];
    }
}

#pragma mark
#pragma mark - 鏡頭切換
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}
- (void) swapFrontAndBackCameras {
    // Assume the session is already running
    
    NSArray *inputs = CaptureSession.inputs;
    for ( AVCaptureDeviceInput *input in inputs ) {
        AVCaptureDevice *device = input.device;
        if ( [device hasMediaType:AVMediaTypeVideo] ) {
            AVCaptureDevicePosition position = device.position;
            AVCaptureDevice *newCamera = nil;
            AVCaptureDeviceInput *newInput = nil;
            
            if (position == AVCaptureDevicePositionFront)
            {
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            }
            else
            {
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            }
            
            
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            
            // beginConfiguration ensures that pending changes are not applied immediately
            [CaptureSession beginConfiguration];
            
            [CaptureSession removeInput:input];
            [CaptureSession addInput:newInput];
            
            //Set the connection properties again
            [self CameraSetOutputProperties];
            
            
            // Changes take effect once the outermost commitConfiguration is invoked.
            [CaptureSession commitConfiguration];
            break;
        }
    }
}
//********** GET CAMERA IN SPECIFIED POSITION IF IT EXISTS **********
- (AVCaptureDevice *) CameraWithPosition:(AVCaptureDevicePosition) Position {
    NSArray *Devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *Device in Devices)
    {
        if ([Device position] == Position)
        {
            return Device;
        }
    }
    return nil;
}
//********** DID FINISH RECORDING TO OUTPUT FILE AT URL **********
- (void) captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections
                error:(NSError *)error {
    
    NSLog(@"didFinishRecordingToOutputFileAtURL - enter");
    
    BOOL RecordedSuccessfully = YES;
    if ([error code] != noErr)
    {
        // A problem occurred: Find out if the recording was successful.
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value)
        {
            RecordedSuccessfully = [value boolValue];
        }
    }
    else
    {
        
        
    }
    
    
    if (RecordedSuccessfully)
    {
        //----- RECORDED SUCESSFULLY -----
        NSLog(@"didFinishRecordingToOutputFileAtURL - success");
        NSLog(@"outputFileURL: %@ size:%@", outputFileURL,[ALDisk totalDirSpace]);
        dirTotalSizeInBytes = [ALDisk totalDirSpaceInBytes];
        continueRecording = NO;
        NSLog(@"outputFileURL lastPathComponent: %@", [outputFileURL lastPathComponent]);
        //[g_mrTableView addTableViewItem:[outputFileURL lastPathComponent]];// 加入新的Cell
    }
    else
    {
        NSLog(@"didFinishRecordingToOutputFileAtURL - error:%@",error);
        dirTotalSizeInBytes = [ALDisk totalDirSpaceInBytes];
        NSLog(@"outputFileURL: %@ size:%@", outputFileURL,[ALDisk totalDirSpace]);
        recordingError = YES;
    }
    
}
- (void) CameraFocus :(NSInteger)focusMode{
    NSArray *devices = [AVCaptureDevice devices];
    NSError *error;
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionBack) {
            [device lockForConfiguration:&error];
            if ([device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                
                
                device.focusMode = focusMode;//AVCaptureFocusModeAutoFocus;//AVCaptureFocusModeLocked;//;
                CGPoint convertedPoint = [PreviewLayer captureDevicePointOfInterestForPoint:self.center];
                [device setFocusPointOfInterest:convertedPoint];
            }
            
            [device unlockForConfiguration];
        }
    }
}
- (void) tapToFocus:(UITapGestureRecognizer *)singleTap {
    NSLog(@"tapToFocus - Enter");
    
    
    CGPoint touchPoint = [singleTap locationInView:self];
    NSLog(@"tapToFocus - touchPoint: x=%f y=%f",touchPoint.x,touchPoint.y);
    
    CGPoint convertedPoint = [PreviewLayer captureDevicePointOfInterestForPoint:touchPoint];
    
    AVCaptureDevice *currentDevice = myDeviceInput.device;
    
    
    if([currentDevice isFocusPointOfInterestSupported] && [currentDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus])
    {
        NSError *error = nil;
        [currentDevice lockForConfiguration:&error];
        if(!error)
        {
            [currentDevice setFocusPointOfInterest:convertedPoint];
            [currentDevice setFocusMode:AVCaptureFocusModeAutoFocus];
            [currentDevice unlockForConfiguration];
        }
    }
    NSLog(@"tapToFocus - End");
}
#pragma mark
#pragma mark - 螢幕觸控
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touches Began - MRCameraview");
    UIButton * RecStartStopBtn = (UIButton *)[self viewWithTag:_TAG_CAMERA_REC_STARTSTOP_BTN_];
    if(RecStartStopBtn.hidden)
    {
        [self recButtonHidden:NO];
        
        if(WeAreRecording)
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
}
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touches Moved - MRCameraview");
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touches Ended - MRCameraview");
}
#pragma mark
#pragma mark - 攝影機初始化
- (void) CameraInit {
    //建立 AVCaptureSession
    CaptureSession = [[AVCaptureSession alloc] init];
    

    
    [CaptureSession setSessionPreset:AVCaptureSessionPresetPhoto];
    
    //建立 AVCaptureDeviceInput
    NSArray *myDevices = [AVCaptureDevice devices];
    
    for (AVCaptureDevice *device in myDevices) {
        if ([device position] == AVCaptureDevicePositionBack) {
            NSLog(@"後攝影機硬體名稱: %@", [device localizedName]);
        }
        
        if ([device position] == AVCaptureDevicePositionFront) {
            NSLog(@"前攝影機硬體名稱: %@", [device localizedName]);
        }
        
        if ([device hasMediaType:AVMediaTypeAudio]) {
            NSLog(@"麥克風硬體名稱: %@", [device localizedName]);
        }
    }
    
    //使用後置鏡頭當做輸入
    NSError *error = nil;
    for (AVCaptureDevice *device in myDevices) {
        if ([device position] == AVCaptureDevicePositionBack) {
            
            myDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
            
            if (error) {
                //裝置取得失敗時的處理常式
                NSLog(@"後攝影機硬體取得失敗");
            } else {
                //                    [myCaptureSessionCameraBack addInput:myDeviceInput];
                if([CaptureSession canAddInput:myDeviceInput])
                    [CaptureSession addInput:myDeviceInput];
                else
                    NSLog(@"後攝影機硬體輸入設定失敗");
            }
        }
//        else if([device position] == AVCaptureDevicePositionFront)
//        {
//            myDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
//            
//            if (error) {
//                //裝置取得失敗時的處理常式
//                NSLog(@"前攝影機硬體取得失敗");
//            } else {
//                if([CaptureSession canAddInput:myDeviceInput])
//                    [CaptureSession addInput:myDeviceInput];
//                else
//                    NSLog(@"前攝影機硬體輸入設定失敗");
//            }
//        }
    }
    //
    
    //ADD AUDIO INPUT
    NSLog(@"Adding audio input");
    
    
    
//
////    BOOL success = [session setCategory:AVAudioSessionCategoryPlayAndRecord
////                       withOptions:kAudioSessionOverrideAudioRoute_Speaker//AVAudioSessionCategoryOptionMixWithOthers
////                             error:nil];
//    
//    //    success = [session setCategory:AVAudioSessionCategoryPlayback
//    //                       withOptions:kAudioSessionOverrideAudioRoute_Speaker
//    //                             error:&error];
//    
//
//    //    if (![session setCategory:AVAudioSessionCategoryPlayback
//    //                  withOptions:kAudioSessionOverrideAudioRoute_Speaker
//    //                        error:&setCategoryError]) {
//    //
//    
//    //if(!isOtherAudioPlaying)
//    {
//        AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
//        //AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeMuxed];
//        error = nil;
//        AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
//        if (audioInput)
//        {
//            [CaptureSession addInput:audioInput];
//      
//            [CaptureSession setUsesApplicationAudioSession:YES];
//        }
//        else
//            NSLog(@"音訊設定失敗");
//    }
//    
////            BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
////                               withOptions:AVAudioSessionCategoryOptionMixWithOthers//kAudioSessionOverrideAudioRoute_Speaker
////                                     error:&error];
////    
//
    
    [self updateAudioSetting];
    
    
    [self createPreviewLayer];
    
    
#ifdef __tapToFocus__
    // 設定手指觸控對焦
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToFocus:)];
    [tapGR setNumberOfTapsRequired:1];
    [tapGR setNumberOfTouchesRequired:1];
    [self addGestureRecognizer:tapGR];
#endif
    
    [self updateCameraFocus];
    
    
    //ADD MOVIE FILE OUTPUT
    NSLog(@"Adding movie file output");
    if(nil == MovieFileOutput){
        
        NSLog(@"MovieFileOutput = nil");
        MovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
       
    }
    
    [self updateVideoQuality];
    [self updateStorageSizeLimit];
    [self CameraSetOutputProperties];
    
    NSLog(@"Adding movie file output");
    if ([CaptureSession canAddOutput:MovieFileOutput])
        [CaptureSession addOutput:MovieFileOutput];
    else
        NSLog(@"can't adding movie file output");
    
    //啟用攝影機
    [CaptureSession startRunning];
    
    currentStartData = [NSDate date];
}
#pragma mark
#pragma mark - 更新預覽視圖
- (void) updatePreviewLayerFrame {
    [PreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    PreviewLayer.connection.videoOrientation = [self videoOrientationFromDeviceOrientation];
    //[PreviewLayer setFrame:[self.layer bounds]];
    
    CGRect layerRect = [[self layer] bounds];
    [PreviewLayer setBounds:layerRect];
    [PreviewLayer setPosition:CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect))];
}
#pragma mark
#pragma mark - 建立預覽視圖
- (void) createPreviewLayer {
    // Set preview layer
    PreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:CaptureSession];
    [PreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    PreviewLayer.connection.videoOrientation = [self videoOrientationFromDeviceOrientation];
    //[PreviewLayer setFrame:[self.layer bounds]];
    
    CGRect layerRect = [[self layer] bounds];
    [PreviewLayer setBounds:layerRect];
    [PreviewLayer setPosition:CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect))];
    [self.layer addSublayer:PreviewLayer];
}
#pragma mark
#pragma mark - 更新影像品質設定
- (void) updateVideoQuality {
    // Set videoQuality
    NSLog(@"Setting image quality");
    NSString * videoQuality = [NSString stringWithFormat:@"%@",[MRPlist readPlist:@"VideoQuality"]];
    
  
    if([videoQuality isEqualToString:@"Normal"])
    {
        [CaptureSession setSessionPreset:AVCaptureSessionPresetMedium];
        Float64 TotalSeconds = 60*60;			//Total seconds
        int32_t preferredTimeScale = 1;	//Frames per second
        CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);	//<<SET MAX DURATION
        MovieFileOutput.maxRecordedDuration = maxDuration;
    }
    else if([videoQuality isEqualToString:@"High"])
    {
        [CaptureSession setSessionPreset:AVCaptureSessionPresetHigh];
        Float64 TotalSeconds = 60*5;			//Total seconds
        int32_t preferredTimeScale = 1;	//Frames per second
        CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);	//<<SET MAX DURATION
        MovieFileOutput.maxRecordedDuration = maxDuration;
    }
    else
    {
        [CaptureSession setSessionPreset:AVCaptureSessionPresetLow];
        Float64 TotalSeconds = 60*60;			//Total seconds
        int32_t preferredTimeScale = 1;	//Frames per second
        CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);	//<<SET MAX DURATION
        MovieFileOutput.maxRecordedDuration = maxDuration;
    }
    MovieFileOutput.minFreeDiskSpaceLimit = 1024 * 1024;		//<<SET MIN FREE SPACE IN BYTES FOR RECORDING TO CONTINUE ON A VOLUME
}
#pragma mark
#pragma mark - 更新鏡頭對焦設定
- (void) updateCameraFocus {
    if([[MRPlist readPlist:@"AutoFocus"] isEqualToString:@"No"])
        [self CameraFocus:AVCaptureFocusModeLocked];
    else
        [self CameraFocus:AVCaptureFocusModeContinuousAutoFocus];
}
#pragma mark
#pragma mark - 更新Audio設定
- (void) updateAudioSetting {
    if([[MRPlist readPlist:@"AudioInput"] isEqualToString:@"Yes"])
        [self AudioInput:YES];
    else
        [self AudioInput:NO];
}
#pragma mark
#pragma mark - 更新儲存空間的限制
- (void) updateStorageSizeLimit {
    // Set Storage Size
    NSLog(@"Setting LimitStorageSize");
    NSString * storageSize = [NSString stringWithFormat:@"%@",[MRPlist readPlist:@"StorageSize"]];
    storageSizeLimit = [[storageSize stringByReplacingOccurrencesOfString:@"" withString:@"G"] doubleValue];
    storageSizeLimit *= (1024*1024*1024);
    NSLog(@"setStorageSize:%f",storageSizeLimit);
}
#pragma mark
#pragma mark - 設定攝影機的轉向
- (AVCaptureVideoOrientation)videoOrientationFromDeviceOrientation {
    
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)[UIDevice currentDevice].orientation;
    switch (result)
    {
            /*
             BOOL CameraPosition;
             
             AVCaptureDevicePosition position = device.position;
             AVCaptureDevice *newCamera = nil;
             AVCaptureDeviceInput *newInput = nil;
             
             if (position == AVCaptureDevicePositionFront)
             //*/
        case UIDeviceOrientationLandscapeLeft:
            //result = AVCaptureVideoOrientationLandscapeLeft;
            result = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            //result = AVCaptureVideoOrientationLandscapeRight;
            result = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            //result = AVCaptureVideoOrientationPortrait;
            result = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationPortrait:
            //result = AVCaptureVideoOrientationPortraitUpsideDown;
            result = AVCaptureVideoOrientationPortrait;
            break;
        default:
//            result = AVCaptureVideoOrientationLandscapeLeft;
            break;
    }
    return result;
}
- (void) CameraSetOutputProperties {
    AVCaptureConnection *CaptureConnection = [MovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    //Set landscape (if required)
    if ([CaptureConnection isVideoOrientationSupported])
    {
        AVCaptureVideoOrientation orientation = [self videoOrientationFromDeviceOrientation];
        if(AVCaptureVideoOrientationLandscapeLeft == orientation  ||
           AVCaptureVideoOrientationLandscapeRight == orientation ||
           AVCaptureVideoOrientationPortrait == orientation)
            [CaptureConnection setVideoOrientation:orientation];
        else{}
    }
}

- (BOOL) supportsVideoOrientation {
    return YES;
}

- (void) orientationChanged:(NSNotification *)notification {
    [self rotateLayer];
}
- (void) rotateLayer {
    if(([self videoOrientationFromDeviceOrientation] == AVCaptureVideoOrientationLandscapeLeft)  ||
       ([self videoOrientationFromDeviceOrientation] == AVCaptureVideoOrientationLandscapeRight) ||
       ([self videoOrientationFromDeviceOrientation] == AVCaptureVideoOrientationPortrait))
    {
        PreviewLayer.connection.videoOrientation = [self videoOrientationFromDeviceOrientation];
        [self CameraSetOutputProperties];
    }else{}
}
#pragma mark
#pragma mark - 按鍵事件處理
- (void) handleSwapCameraButtonClicked:(id)sender {
    NSLog(@"swapFrontAndBackCameras button have been clicked.");
    [self swapFrontAndBackCameras];
}
- (void) handleRecStartStopButtonClicked:(id)sender {
    NSLog(@"handleRecStartStopButtonClicked button have been clicked.");
    
    
    if(storageSizeLimit <= ([ALDisk freeDiskSpaceInBytes]+[ALDisk totalDirSpaceInBytes]))
    {
        [self StartStopButtonPressed];
    }
    else
    {
        UIAlertView * myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                 message:@"disk space not enough!"
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles: nil];
        [myAlertView show];
    }
}
- (void) StartStopButtonPressed {
    if (!WeAreRecording)
    {
        //----- START RECORDING -----
        NSLog(@"START RECORDING");
        WeAreRecording = YES;
        [MRPlist writePlist:@"WeAreRecording" content:[NSString stringWithFormat:@"%d",WeAreRecording]];
        [self StartRecording];
        UpdateRecordingProcess = YES;
    }
    else
    {
        //----- STOP RECORDING -----
        NSLog(@"Stop recording...");
        WeAreRecording = NO;
        [MRPlist writePlist:@"WeAreRecording" content:[NSString stringWithFormat:@"%d",WeAreRecording]];
        [self StopRecording];
        UpdateRecordingProcess = NO;
        [updateStartStopBtnMotion setFireDate:[NSDate distantFuture]];
    }
    
    dirTotalSizeInBytes = [ALDisk totalDirSpaceInBytes];
    NSLog(@"Mobile Dir Size:%@",[ALDisk totalDirSpace]);
    
    UIButton * RecStartStopBtn = (UIButton *)[self viewWithTag:_TAG_CAMERA_REC_STARTSTOP_BTN_];
    if(WeAreRecording)
        [RecStartStopBtn setImage:[UIImage imageNamed:@"Record_Stop"] forState:UIControlStateNormal];
    else
        [RecStartStopBtn setImage:[UIImage imageNamed:@"Record_Start"] forState:UIControlStateNormal];
}
#pragma mark
#pragma mark - 按鍵、燈號、標籤初始化
- (void) createSwitchButton {
    /*
     UIImage *btnImage = [UIImage imageNamed:@"Photo-Video-switch-camera-icon"];
     CGRect swbuttonFrame = CGRectMake(CGRectGetMaxX(self.frame)-64,
     CGRectGetMinY(view.frame),
     64,
     64);
     UIButton *swBtn = [[UIButton alloc] initWithFrame: swbuttonFrame];
     [swBtn setImage:btnImage forState:UIControlStateNormal];
     
     // 設定按鍵陰影
     swBtn.layer.borderWidth=1.0f;
     swBtn.layer.borderColor=[[UIColor blackColor] CGColor];
     swBtn.layer.cornerRadius = 10;
     swBtn.layer.shadowOpacity = 0.5;
     swBtn.layer.shadowColor = [[UIColor blackColor] CGColor];
     swBtn.layer.shadowOffset = CGSizeMake(3.0, 3.0);
     swBtn.layer.shadowRadius = 5;
     
     
     
     // 設定按鍵的觸發動作
     [swBtn addTarget:self
     action:@selector(handleSwapCameraButtonClicked:)
     forControlEvents:UIControlEventTouchUpInside];
     
     [self addSubview:swBtn];
     //*/
    
}
- (void) createRecStartStopButton {
    NSLog(@"---------createRecStartStopButton-----------");
    NSLog(@"x: %f", [[self layer] bounds].origin.x);
    NSLog(@"y: %f", [[self layer] bounds].origin.y);
    NSLog(@"w: %f", [[self layer] bounds].size.width);
    NSLog(@"h: %f", [[self layer] bounds].size.height);
    
    CGRect RecStartStopbuttonFrame = [self.layer bounds];
    RecStartStopbuttonFrame.origin.x = CGRectGetMidX(RecStartStopbuttonFrame)-64;
    RecStartStopbuttonFrame.origin.y = CGRectGetMidY(RecStartStopbuttonFrame)-64;
    RecStartStopbuttonFrame.size.height = 128;
    RecStartStopbuttonFrame.size.width = 128;
    
    UIButton * RecStartStopBtn = [[UIButton alloc] initWithFrame:RecStartStopbuttonFrame];
    [RecStartStopBtn setTag:_TAG_CAMERA_REC_STARTSTOP_BTN_];
    
    if(WeAreRecording)
        [RecStartStopBtn setImage:[UIImage imageNamed:@"Record_Stop"] forState:UIControlStateNormal];
    else
        [RecStartStopBtn setImage:[UIImage imageNamed:@"Record_Start"] forState:UIControlStateNormal];
    
    // 設定按鍵的觸發動作
    [RecStartStopBtn addTarget:self action:@selector(handleRecStartStopButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    RecStartStopBtn.alpha = 0.8f;
    
    [self addSubview:RecStartStopBtn];
}
- (void) createRecordingLED {
    CGRect screenFrame3 = [self.layer bounds];
    screenFrame3.origin.x = CGRectGetMidX(screenFrame3)-20;
    screenFrame3.origin.y = CGRectGetMinY(screenFrame3);
    screenFrame3.size.height = 20;
    screenFrame3.size.width = 20;
    UIImageView * recordingLedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Record-Led-Off"]];
    [recordingLedImageView setTag:_TAG_CAMERA_RECORDING_LED_IMAGE_];
    recordingLedImageView.frame =  screenFrame3;
    recordingLedImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:recordingLedImageView];
}
- (void) createRecordingTimeLabel {
    CGRect recordingTimeLabelFrame = [self.layer bounds];
    recordingTimeLabelFrame.origin.x = CGRectGetMidX(recordingTimeLabelFrame);
    recordingTimeLabelFrame.origin.y = CGRectGetMinY(recordingTimeLabelFrame);
    recordingTimeLabelFrame.size.height = 20;
    recordingTimeLabelFrame.size.width = 200;
    
    UILabel * recordingTimeLabel=[[UILabel alloc] initWithFrame:recordingTimeLabelFrame];
    [recordingTimeLabel setTag:_TAG_CAMERA_RECORDING_TIME_LABEL_];
    recordingTimeLabel.textColor=[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    [recordingTimeLabel setFont:[UIFont fontWithName:@"Arial" size:18]];
    recordingTimeLabel.text=@"00:00:00";
    recordingTimeLabel.backgroundColor=[UIColor clearColor];
    [self addSubview:recordingTimeLabel];
}
#pragma mark
#pragma mark - 更新按鍵、燈號、標籤佈局
- (void) updateRecStartStopButtonFrame {
    UIButton * RecStartStopBtn = (UIButton *)[self viewWithTag:_TAG_CAMERA_REC_STARTSTOP_BTN_];
    [RecStartStopBtn setFrame:CGRectMake(CGRectGetMidX([self.layer bounds])-64,
                                         CGRectGetMidY([self.layer bounds])-64,
                                         128,
                                         128)];
}
- (void) updateRecordingTimeLabelFrame {
    CGRect recordingTimeLabelFrame = [self.layer bounds];
    recordingTimeLabelFrame.origin.x = CGRectGetMidX(recordingTimeLabelFrame);
    recordingTimeLabelFrame.origin.y = CGRectGetMinY(recordingTimeLabelFrame);
    recordingTimeLabelFrame.size.height = 20;
    recordingTimeLabelFrame.size.width = 200;
    UILabel * recordingTimeLabel = (UILabel *)[self viewWithTag:_TAG_CAMERA_RECORDING_TIME_LABEL_];
    [recordingTimeLabel setFrame:recordingTimeLabelFrame];
}
- (void) updateRecordingTimeLabel {
    UILabel * recordingTimeLabel = (UILabel *)[self viewWithTag:_TAG_CAMERA_RECORDING_TIME_LABEL_];
    if(WeAreRecording)
        recordingTimeLabel.textColor=[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    else
    {
        recordingTimeLabel.textColor=[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
        recordingTimeLabel.text = @"00:00:00";
    }
}
- (void) updateRecordingLEDFrame{
    CGRect screenFrame3 = [self.layer bounds];
    screenFrame3.origin.x = CGRectGetMidX(screenFrame3)-20;
    screenFrame3.origin.y = CGRectGetMinY(screenFrame3);
    screenFrame3.size.height = 20;
    screenFrame3.size.width = 20;
    UIImageView * recordingLedImageView = (UIImageView *)[self viewWithTag:_TAG_CAMERA_RECORDING_LED_IMAGE_];
    [recordingLedImageView setFrame:screenFrame3];
}
- (void) updateRecordingLED {
    UIImageView * recordingLedImageView = (UIImageView *)[self viewWithTag:_TAG_CAMERA_RECORDING_LED_IMAGE_];
    if(WeAreRecording)
        [recordingLedImageView setImage:[UIImage imageNamed:@"Record-Led-On"]];
    else
        [recordingLedImageView setImage:[UIImage imageNamed:@"Record-Led-Off"]];
}
- (void) updateAll {
    NSLog(@"------------MRCamera -> updateAll - Enter---------------");
    [self updatePreviewLayerFrame];
    [self CameraSetOutputProperties];
    [self updateRecordingTimeLabelFrame];
    [self updateRecStartStopButtonFrame];
    [self updateRecordingLEDFrame];
    [self updateCameraFocus];
    [self updateAudioSetting];
    NSLog(@"------------MRCamera -> updateAll - End---------------");
}
#pragma mark
#pragma mark - 攝影機的啟動與關閉
- (void) RunCamera {
    [CaptureSession startRunning];
}
- (void) StopCamera {
    [CaptureSession stopRunning];
}
- (void) StartRecording {
    [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:NO];
    
    WeAreRecording = [[MRPlist readPlist:@"WeAreRecording"] boolValue];
    
    if(WeAreRecording)
    {
        //Create temporary URL to record to
        if(continueRecording == NO)
        {
            //Start recording
            NSLog(@"Start recording...");
            [MovieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:
                                                            [MRFileManagement saveVideoFile:@".MOV"]] recordingDelegate:self];
            continueRecording = YES;
            
            [NSTimer scheduledTimerWithTimeInterval:5.0
                                             target:self
                                           selector:@selector(hiddenRecStartStopButton:)
                                           userInfo:nil
                                            repeats:NO];
        }
        tmpStartData = [NSDate date];
    }
    
    UIButton * RecStartStopBtn = (UIButton *)[self viewWithTag:_TAG_CAMERA_REC_STARTSTOP_BTN_];
    if(WeAreRecording)
        [RecStartStopBtn setImage:[UIImage imageNamed:@"Record_Stop"] forState:UIControlStateNormal];
    else
        [RecStartStopBtn setImage:[UIImage imageNamed:@"Record_Start"] forState:UIControlStateNormal];
    
    
    [self updateRecordingLED];
    [self updateRecordingTimeLabel];
    
//    [RecStartStopBtn setHidden:NO];
//    if(WeAreRecording)
//        [NSTimer scheduledTimerWithTimeInterval:15.0
//                                         target:self
//                                       selector:@selector(hiddenRecStartStopButton:)
//                                       userInfo:nil
//                                        repeats:NO];
}
- (void) StopRecording {
    WeAreRecording = [[MRPlist readPlist:@"WeAreRecording"] boolValue];
    
    [MovieFileOutput stopRecording];
    continueRecording = NO;
    
    UIButton * RecStartStopBtn = (UIButton *)[self viewWithTag:_TAG_CAMERA_REC_STARTSTOP_BTN_];
    if(WeAreRecording)
        [RecStartStopBtn setImage:[UIImage imageNamed:@"Record_Stop"] forState:UIControlStateNormal];
    else
        [RecStartStopBtn setImage:[UIImage imageNamed:@"Record_Start"] forState:UIControlStateNormal];
  
    
    [self updateRecordingLED];
    [self updateRecordingTimeLabel];
   
    [self stopTimer];
    
    [self recButtonHidden:NO];
}
- (void) RecordingProcess {
    if(recordingError)
    {
        [self StopRecording];
        recordingError = NO;
    }
    
    if(WeAreRecording)
    {
        //Create temporary URL to record to
        if(continueRecording == NO)
        {
            dirTotalSizeInBytes = [ALDisk totalDirSpaceInBytes];
            if(dirTotalSizeInBytes <= storageSizeLimit)
            {
                
                //Start recording
                NSLog(@"Start recording...");
                [MovieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:
                                                                [MRFileManagement saveVideoFile:@".MOV"]
                                                                ] recordingDelegate:self];
                
                continueRecording = YES;
            }
            else{
                NSLog(@"目錄Size(%f)大於設定值(%f)",dirTotalSizeInBytes,storageSizeLimit);
                do{
                    NSLog(@"開始清除最舊的影片 path:%@",[MRFileManagement findEarlierCreationDateAtFolder:@"MobRecord"]);
                    [[NSFileManager defaultManager] removeItemAtPath:[MRFileManagement findEarlierCreationDateAtFolder:@"MobRecord"] error:NULL];
                    dirTotalSizeInBytes = [ALDisk totalDirSpaceInBytes];
                }while (dirTotalSizeInBytes > (storageSizeLimit*0.6)); //刪除檔案後的大小，必須預留50%的空間
            }
            
        }
    }
    
    //    // 目錄Size大於1G
    //    if(dirTotalSizeInBytes > storageSizeLimit)
    //    {
    //        NSLog(@"目錄Size(%f)大於設定值(%f)",dirTotalSizeInBytes,storageSizeLimit);
    //        do{
    //            NSLog(@"開始清除最舊的影片 path:%@",[self.gydelegate findEarlierCreationDateAtFolder:@"MobRecord"]);
    //            [[NSFileManager defaultManager] removeItemAtPath:[self.gydelegate findEarlierCreationDateAtFolder:@"MobRecord"] error:NULL];
    //            dirTotalSizeInBytes = [ALDisk totalDirSpaceInBytes];
    //        }while (dirTotalSizeInBytes > (storageSizeLimit*0.6)); //刪除檔案後的大小，必須預留50%的空間
    //    }
}
#pragma mark
#pragma mark - 視圖顯示與隱藏
- (void) hidden:(UIView*)view {
    [UIView transitionWithView:view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCurlDown
                    animations:^{[self setHidden:YES];}
                    completion:NULL];
}
- (void) show:(UIView*)view {
    [self updateAll];
    [UIView transitionWithView:view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCurlDown
                    animations:^{ [self setHidden:NO];}
                    completion:NULL];
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
                                 forView:(UIView*)[self viewWithTag:_TAG_CAMERA_REC_STARTSTOP_BTN_] cache:YES];
        ((UIView*)[self viewWithTag:_TAG_CAMERA_REC_STARTSTOP_BTN_]).hidden = YES;
        
        [UIButton commitAnimations];
    }
    else
    {
        [UIButton beginAnimations:nil context:nil];
        [UIButton setAnimationDuration:0.5];
        [UIButton setAnimationBeginsFromCurrentState:YES];
        [UIButton setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                                 forView:(UIView*)[self viewWithTag:_TAG_CAMERA_REC_STARTSTOP_BTN_] cache:YES];
        ((UIView*)[self viewWithTag:_TAG_CAMERA_REC_STARTSTOP_BTN_]).hidden = NO;
        [UIButton commitAnimations];
    }
}



- (void) updateCameraFrame {
    CGRect cameraViewFrame = self.frame;
    if(g_viewController.g_AdmobShowing)
    {
        if(cameraViewFrame.size.width == 150)
            cameraViewFrame.origin.y = CGSizeFromGADAdSize(kGADAdSizeSmartBannerLandscape).height;
        else
            cameraViewFrame.origin.y = CGSizeFromGADAdSize(kGADAdSizeSmartBannerLandscape).height;
    }
    else
    {
        cameraViewFrame.origin.y = 0;
    }
    [self setFrame:cameraViewFrame];
    [self updateAll];
}

- (void) StopRecordingProcess {
    NSLog(@"StopRecordingProcess - Enter");
    self.UpdateRecordingProcess = NO;
    [self StopRecording];
}
- (void) StartRecordingProcess {
    NSLog(@"StartRecordingProcess - Enter");
    self.UpdateRecordingProcess = YES;
    [self StartRecording];
}
@end
