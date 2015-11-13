//
//  LBScreenLockView.m
//  LightingBomb
//
//  Created by GarY on 2014/10/18.
//  Copyright (c) 2014年 gyhouse. All rights reserved.
//

#import "LBScreenLockView.h"
#import "MRViewController.h"
#import "MRAbout.h"


LBScreenLockView *g_lbScreenLockView;
extern MRViewController *g_viewController;
extern MRAbout *g_mrAbout;

static const CGFloat kLabelFontSize = 25.f;

@interface LBScreenLockView()

- (UIColor *) randomColor;
@property (nonatomic) BOOL isLock;

@end

@implementation LBScreenLockView
@synthesize isLock;

+ (LBScreenLockView *) sharedInstance {
    static LBScreenLockView *singleton = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        CGRect frame = [[g_viewController.view layer] bounds];
        frame.origin.y = CGRectGetMinY(frame);
        singleton = [[LBScreenLockView alloc] initWithFrame:frame];
        g_lbScreenLockView = singleton;
    });
    return singleton;
}

#pragma mark
#pragma mark - Random Color
// Random Color
- (UIColor *) randomColor {
    CGFloat r = arc4random()%255;
    CGFloat g = arc4random()%255;
    CGFloat b = arc4random()%255;
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
}



#pragma mark
#pragma mark - Slide lock
// MBSliderViewDelegate
- (void) sliderDidSlide:(MBSliderView *)slideView {
    // Customization example
    //    [slideView setThumbColor:[self randomColor]];
    //    [slideView setLabelColor:[self randomColor]];
    if(isLock) {
        slideView.text = @"";
        isLock = NO;
        [self hidden:g_viewController.view];
    }
    else {
        slideView.text = @"";
    }
}

- (void) handleBtnClicked:(id)sender
{
    if(_TAG_SETTING_BACK_BTN_ == ((UIButton *)sender).tag) {
        [self hidden:g_viewController.view];
    }else if(_TAG_SETTING_ABOUT_BTN_ == ((UIButton *)sender).tag) {
        [g_mrAbout show:g_viewController.view];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

            isLock = NO;
            
//            int contentStart_Y      = 10;
//            int titleView_H         = 60;
//            int contentInterval_H   = 30;
//            int contentStart_X      = (self.frame.size.width/2)-60;
//            int contentLabelStart_X = 5;
//            
            
            //---------------------------------------------------------------------------
            // Background View
            //---------------------------------------------------------------------------
            UIImageView * backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG"]];
            CGRect backgroundFrame = [[self layer] bounds];
            backgroundImageView.frame = backgroundFrame;
            backgroundImageView.alpha = 1.0;
            [self addSubview:backgroundImageView];
            
            
            
            UIImageView * lockImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Lock"]];
            CGRect lockImageViewFrame = [[self layer] bounds];
            lockImageViewFrame.size.width = 100;
            lockImageViewFrame.size.height = 100;
            lockImageViewFrame.origin.x = CGRectGetMidX(self.frame)-lockImageViewFrame.size.width/2;
            lockImageViewFrame.origin.y = CGRectGetMidY(self.frame)-lockImageViewFrame.size.height/2;
            
            [lockImageView setFrame:lockImageViewFrame];
            [self addSubview:lockImageView];
            
            [self createSliderSwitchView];
        
            [self updateAll];
            
            
            [self setHidden:YES];
        
    }
    return self;
}

- (void) createSliderSwitchView {
    
    CGRect screenFrame2 = [[self layer] bounds];
    screenFrame2.origin.x = 20;
    screenFrame2.origin.y = CGRectGetMaxY(screenFrame2)-80;
    
    MBSliderView *s1 = [[MBSliderView alloc] initWithFrame:CGRectMake(20.0,
                                                                      screenFrame2.origin.y,
                                                                      self.frame.size.width-44,
                                                                      44)];
    [s1 setText:@""]; // set the label text
    [s1 setDelegate:self]; // set the MBSliderView delegate
    [self addSubview:s1];
    
    
    
    UILabel * label=[[UILabel alloc] init];
    
    label.textColor=[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.5];
    [label setFont:[UIFont fontWithName:@"Arial" size:kLabelFontSize]];
    label.text=@"Silder to unlock";
    label.backgroundColor=[UIColor clearColor];
    
    CGSize labelSize = [label.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kLabelFontSize]}];
    
    [label setFrame:CGRectMake(CGRectGetMidX(self.frame) - labelSize.width/2,
                               screenFrame2.origin.y,
                               self.frame.size.width-44,
                               44)];
    [self addSubview:label];
}

- (void) hidden:(UIView*)view
{
    [UIView transitionWithView:self
                      duration:1.0
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{[self setHidden:YES];}
                    completion:NULL];
}

- (void) show:(UIView*)view
{
    isLock = YES;
    [self updateAll];
    [UIView transitionWithView:self
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{ [self setHidden:NO];}
                    completion:NULL];
    
    //            [NSTimer scheduledTimerWithTimeInterval:0.05
    //                                                           target:self
    //                                                         selector:@selector(updateView:)
    //                                                         userInfo:nil
    //                                                          repeats:YES];
    //
    //            //[updateTimer invalidate];
    //            //[updateTimer fire];
}



- (void) updateAll {
    
}

- (BOOL) isScreenLock {
    return  self.isLock;
}
- (void) setScreenLock:(BOOL)sw {
    self.isLock = sw;
}

@end
