//
//  MRFileManagement.h
//  MobiRecorder
//
//  Created by GarY on 2015/4/29.
//  Copyright (c) 2015年 gyhouse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface MRFileManagement : NSObject


+ (NSString *) saveVideoFile:(NSString *)fileName;
+ (NSString *) createDir:(NSString *)dirName;
+ (NSString *)findEarlierCreationDateAtFolder:(NSString *)dirName;
+ (NSDate *)getFileCreationDate:(NSString *)fileName;
+ (void) clearDirContentAll:(NSString*)dirName;
+ (void) createFile:(NSString*)newFileName;
+ (void) moveDirContentToLibrary:(NSString*)dirName;
+ (void) fileEnumerator:(NSString*)dirName;

@end
