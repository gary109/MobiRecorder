//
//  PBJStrobeView.m
//  PBJVision
//
//  Created by Patrick Piemonte on 7/23/13.
//  Copyright (c) 2013-present, Patrick Piemonte, http://patrickpiemonte.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "PBJStrobeView.h"

#import <QuartzCore/QuartzCore.h>

@interface PBJStrobeView ()
{
    UIImageView *_strobeView;
    UIImageView *_strobeViewRecord;
    UIImageView *_strobeViewRecordIdle;
}
@end

@implementation PBJStrobeView
@synthesize _rectimeLabel;

- (UIImageView *)_strobeView
{
    UIImage *strobeDisc = [UIImage imageNamed:@"capture_rec_base"];
    UIImageView *strobeView = [[UIImageView alloc] initWithImage:strobeDisc];
    return strobeView;
}

- (UIImageView *)_strobeViewRecord
{
    UIImage *strobeDisc = [UIImage imageNamed:@"Record-Led-On"];
    UIImageView *strobeView = [[UIImageView alloc] initWithImage:strobeDisc];
    return strobeView;
}

- (UIImageView *)_strobeViewRecordIdle
{
    UIImage *strobeDisc = [UIImage imageNamed:@"Record-Led-Off"];
    UIImageView *strobeView = [[UIImageView alloc] initWithImage:strobeDisc];
    return strobeView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat padding = 4.0f;
    
        self.backgroundColor = [UIColor clearColor];
        CGRect viewFrame = CGRectZero;
        viewFrame.size = CGSizeMake(100.0f, 30.0f);
        self.frame = viewFrame;
                
        _strobeView = [self _strobeView];
        CGRect strobeFrame = _strobeView.frame;
        strobeFrame.origin = CGPointMake(padding, self.frame.size.height - _strobeView.frame.size.height - padding);
        _strobeView.frame = strobeFrame;
        [self addSubview:_strobeView];
        
        _strobeViewRecord = [self _strobeViewRecord];
        _strobeViewRecord.frame = strobeFrame;
        _strobeViewRecord.transform = CGAffineTransformMakeScale(2.0f, 2.0f);
        _strobeViewRecord.alpha = 0;
        [self addSubview:_strobeViewRecord];

        _strobeViewRecordIdle = [self _strobeViewRecordIdle];
        _strobeViewRecordIdle.frame = strobeFrame;
        _strobeViewRecordIdle.transform = CGAffineTransformMakeScale(2.0f, 2.0f);
        [self addSubview:_strobeViewRecordIdle];
        
//        CGRect rectimeLabelFrame = strobeFrame;
//        rectimeLabelFrame.origin = CGPointMake(80, self.frame.size.height - _strobeView.frame.size.height - padding*2);
//    
//        _rectimeLabel = [[UILabel alloc] initWithFrame:rectimeLabelFrame];
//        _rectimeLabel.textAlignment = NSTextAlignmentCenter;
//        _rectimeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
//        _rectimeLabel.textColor = [UIColor grayColor];
//        _rectimeLabel.backgroundColor = [UIColor clearColor];
//        _rectimeLabel.transform = CGAffineTransformMakeScale(2.0f, 2.0f);
//        _rectimeLabel.text = [NSString stringWithFormat:@"%.2llu:%.2llu:%.2llu", totalSecondsToHr(0),
//                                                                                 totalSecondsToMin(0),
//                                                                                 totalSecondsToSec(0)];
//        [_rectimeLabel sizeToFit];
//        
//        [self addSubview:_rectimeLabel];
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//        CGRect rectimeLabelFrame = strobeFrame;
//        rectimeLabelFrame.origin = CGPointMake(_strobeViewRecordIdle.frame.size.width/2+padding*2, 0);
//        CGRect frame = rectimeLabelFrame;
//        _rectimeLabel = [[FBGlowLabel alloc] initWithFrame:frame];
//        _rectimeLabel.text = @"00:00:00";
//        _rectimeLabel.textAlignment = NSTextAlignmentCenter;
//        _rectimeLabel.clipsToBounds = YES;
//        _rectimeLabel.backgroundColor = [UIColor clearColor];
//        _rectimeLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:30];
//        _rectimeLabel.alpha = 1.0;
//        _rectimeLabel.glowSize = 20;//20;
//        _rectimeLabel.innerGlowSize = 4;//4;
//        _rectimeLabel.textColor = UIColorFromRGB(0xffffff);
//        _rectimeLabel.glowColor = UIColor.grayColor;//UIColorFromRGB(0x00ffff);
//        _rectimeLabel.innerGlowColor = UIColor.grayColor;//UIColorFromRGB(0x00ffff);
//        
//        [self addSubview:_rectimeLabel];
//        [_rectimeLabel sizeToFit];
        
        
        
//        CGRect rectimeLabelFrame = CGRectMake(10, 150, 300, 50);
//        rectimeLabelFrame.origin = CGPointMake(_strobeViewRecordIdle.frame.size.width/2+padding*2, padding);
//        CGRect frame = rectimeLabelFrame;
//        _rectimeLabel = [[FBSquareFontView alloc] initWithFrame:frame];
//        _rectimeLabel.text = @"00 00 00";
//        _rectimeLabel.lineWidth = 3.0;
//        _rectimeLabel.margin = 5;//12.0;
//        _rectimeLabel.lineCap = kCGLineCapSquare;
//        _rectimeLabel.lineJoin = kCGLineJoinMiter;
//        
//        _rectimeLabel.lineCap = kCGLineCapRound;
//        _rectimeLabel.lineJoin = kCGLineJoinRound;
//        
//        _rectimeLabel.backgroundColor = [UIColor clearColor];
//        _rectimeLabel.horizontalPadding = 1;//10;
//        _rectimeLabel.verticalPadding = 1;//10;;
//        _rectimeLabel.glowSize = 4;//10.0;
//        _rectimeLabel.glowColor = UIColorFromRGB(0x00ffff);
//        _rectimeLabel.innerGlowColor = UIColorFromRGB(0x00ffff);
//        _rectimeLabel.lineColor = UIColorFromRGB(0xffffff);
//        _rectimeLabel.innerGlowSize = 4.0;
//        _rectimeLabel.horizontalEdgeLength = 5;//6.0;
//        _rectimeLabel.verticalEdgeLength = 10;//12;
//        [self addSubview:_rectimeLabel];
//        [_rectimeLabel resetSize];
        
//        CGRect rectimeLabelFrame = CGRectMake(10, 150, 300, 50);
//        rectimeLabelFrame.origin = CGPointMake(_strobeViewRecordIdle.frame.size.width/2+padding*2, padding);
//        CGRect frame = rectimeLabelFrame;
//        _rectimeLabel = [[FBSquareFontView alloc] initWithFrame:frame];
//        _rectimeLabel.text = @"00 00 00";
//        _rectimeLabel.lineWidth = 3.0;
//        _rectimeLabel.lineCap = kCGLineCapRound;
//        _rectimeLabel.lineJoin = kCGLineJoinRound;
//        _rectimeLabel.margin = 5;//12.0;
//        _rectimeLabel.backgroundColor = [UIColor clearColor];
//        _rectimeLabel.horizontalPadding = 7.5;//15;//30;
//        _rectimeLabel.verticalPadding = 3.5;//7;//14;
//        _rectimeLabel.glowSize = 3;//5;//10.0;
//        _rectimeLabel.glowColor = UIColorFromRGB(0xffffff);//0x00ffff
//        _rectimeLabel.innerGlowColor = UIColorFromRGB(0xffffff); //0x00ffff
//        _rectimeLabel.lineColor = UIColorFromRGB(0xffffff); // 0xffdd66 ,0xffffff
//        _rectimeLabel.innerGlowSize = 1.0;//2.0;
//        _rectimeLabel.verticalEdgeLength = 10;//10;//12;
//        _rectimeLabel.horizontalEdgeLength = 4.5;//12;//14;
//        [self addSubview:_rectimeLabel];
//        [_rectimeLabel resetSize];
        
        
        CGRect rectimeLabelFrame = CGRectMake(10, 150, 300, 50);
        rectimeLabelFrame.origin = CGPointMake(_strobeViewRecordIdle.frame.size.width/2+padding*2, padding);
        CGRect frame = rectimeLabelFrame;
        _rectimeLabel = [[FBLCDFontView alloc] initWithFrame:frame];
       // [v setTag:_TAG_DASHBOARD_ALTITUDE_LABEL_];
        _rectimeLabel.text = @"00:00:00";
        _rectimeLabel.lineWidth = 3.0;
        _rectimeLabel.drawOffLine = NO;
        _rectimeLabel.edgeLength = 11;
        _rectimeLabel.margin = 2.0;
        _rectimeLabel.backgroundColor = [UIColor clearColor];
        _rectimeLabel.horizontalPadding = 5;
        _rectimeLabel.verticalPadding = 1;
        _rectimeLabel.glowSize = 2;
        _rectimeLabel.glowColor = UIColorFromRGB(0x00ffff);
        _rectimeLabel.innerGlowColor = UIColorFromRGB(0x00ffff);
        _rectimeLabel.innerGlowSize = 1.0;
        _rectimeLabel.offColor = UIColorFromRGB(0xd0d0d0);
        _rectimeLabel.lineColor = [UIColor whiteColor];
        [self addSubview:_rectimeLabel];
        [_rectimeLabel resetSize];
    }
    return self;
}

- (void)start
{
    _strobeViewRecord.alpha = 1;
    [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        
//        _rectimeLabel.textColor = [UIColor redColor];
        _rectimeLabel.lineColor = UIColorFromRGB(0xff0000);
        _rectimeLabel.glowColor = UIColorFromRGB(0xffe0e0);
        _rectimeLabel.innerGlowColor = UIColorFromRGB(0xffe0e0);
        _strobeViewRecordIdle.transform = CGAffineTransformMakeScale(0, 0);
    } completion:^(BOOL finished) {
    }];
}

- (void)stop
{
    _rectimeLabel.text = @"00:00:00";
    
    [_strobeViewRecord.layer removeAllAnimations];
    
    _strobeViewRecord.alpha = 0;
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        _rectimeLabel.textColor = [UIColor grayColor];
       _rectimeLabel.lineColor = [UIColor whiteColor];
        _rectimeLabel.glowColor = UIColorFromRGB(0x00ffff);
        _rectimeLabel.innerGlowColor = UIColorFromRGB(0x00ffff);
        _strobeViewRecordIdle.transform = CGAffineTransformMakeScale(2.0f, 2.0f);
    } completion:^(BOOL finished) {
    }];
}

@end
