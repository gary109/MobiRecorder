//
//  MRAbout.m
//  MobiRecorder
//
//  Created by GarY on 2014/9/5.
//  Copyright (c) 2014年 gyhouse. All rights reserved.
//

#import "MRAbout.h"
#import "MRViewController.h"


MRAbout *g_mrAbout;
extern MRViewController *g_viewController;

@implementation MRAbout

+ (MRAbout *)sharedInstance
{
    static MRAbout *singleton = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        CGRect frame = [[g_viewController.view layer] bounds];
        frame.origin.x = CGRectGetMidX(frame)-200;
        frame.origin.y = CGRectGetMidY(frame)-125;
        frame.size.height = 250;
        frame.size.width = 400;
        singleton = [[MRAbout alloc] initWithFrame:frame];
        g_mrAbout = singleton;
    });
    return singleton;
}
- (void) handleBtnClicked:(id)sender
{
    [self hidden:g_viewController.view];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
  
            //---------------------------------------------------------------------------
            // Background View
            //---------------------------------------------------------------------------
            UIImageView * backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG"]];
            CGRect backgroundFrame = [[self layer] bounds];
            backgroundImageView.frame = backgroundFrame;
            backgroundImageView.alpha = 1.0;
            [self addSubview:backgroundImageView];
            
            self.backgroundColor = [UIColor colorWithRed:.12 green:.2 blue:.82 alpha:1.0];
            
            CGRect appNameFrame = self.bounds;
            appNameFrame.origin.x = CGRectGetMidX(appNameFrame);
            appNameFrame.origin.y = CGRectGetMinY(appNameFrame);
            appNameFrame.size.height = 64;
            //appNameFrame.size.width = 200;
            
            UILabel * appNameLabel=[[UILabel alloc] initWithFrame:appNameFrame];
            appNameLabel.textColor=[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
            [appNameLabel setFont:[UIFont fontWithName:@"Arial" size:25]];
            appNameLabel.text=[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];;
            appNameLabel.backgroundColor=[UIColor clearColor];
            [self addSubview:appNameLabel];
            
            
            CGRect btnOKFrame = self.bounds;
            btnOKFrame.origin.x = CGRectGetMidX(btnOKFrame);
            btnOKFrame.origin.y = CGRectGetMaxY(btnOKFrame)-30;
            btnOKFrame.size.height = 30;
            btnOKFrame.size.width = 70;
            
            UIButton * btnOK = [[UIButton alloc] initWithFrame: btnOKFrame];
            // 設定按鍵的觸發動作
            [btnOK addTarget:self action:@selector(handleBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btnOK];
    }
    return self;
}

- (void) hidden:(UIView*)view {
    [UIView transitionWithView:view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCurlUp
                    animations:^{[self setHidden:YES];}
                    completion:NULL];
}

- (void) show:(UIView*)view {
    [UIView transitionWithView:view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCurlDown
                    animations:^{ [self setHidden:NO];}
                    completion:NULL];
}

- (void) updateAll {
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
