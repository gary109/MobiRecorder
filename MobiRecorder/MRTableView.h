//
//  MRTableView.h
//  MobRecorder
//
//  Created by GarY on 2014/9/3.
//  Copyright (c) 2014年 GarY WanG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVFoundation/AVFoundation.h"

#import "ALDisk.h"
#import "MRPlist.h"
#import "SWTableViewCell.h"
#import <MediaPlayer/MediaPlayer.h>
//<<Can delete if not storing videos to the photo library.  Delete the assetslibrary framework too requires this)
#import <AssetsLibrary/AssetsLibrary.h>

@interface MRTableView : UIView <UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate,UIAlertViewDelegate>
{
    NSMutableArray *moviesArray;//, *moviesArrayTemp;
    NSDictionary * movieItem;
    UITableView *tableViewMovies;

}

@property (nonatomic,strong) UITableView *tableViewMovies;
@property (nonatomic,retain) NSMutableArray *moviesArray;//, *moviesArrayTemp;
@property (nonatomic,retain) NSDictionary *moviesItem;//, *moviesArrayTemp;
+ (MRTableView *)sharedInstance;

- (void) updateAll;
- (void) hidden:(UIView*)view;
- (void) show:(UIView*)view;

- (void) addTableViewItem:(NSDictionary*) videoDict;
@end
