//
//  ALDisk.h
//  ALSystem
//
//  Created by Andrea Mario Lufino on 19/07/13.
//  Copyright (c) 2013 Andrea Mario Lufino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/*!
 * Check total and free disk space
 */
@interface ALDisk : NSObject

/*!
 The total dir space
 @return String which represents the total disk space
 */
+ (NSString *)totalDirSpace;


/*!
 The total disk space
 @return String which represents the total disk space
 */
+ (NSString *)totalDiskSpace;

/*!
 The free disk space
 @return String which represents the free disk space
 */
+ (NSString *)freeDiskSpace;

/*!
 The used disk space
 @return String which represents the used disk space
 */
+ (NSString *)usedDiskSpace;

/*!
 The total dir space in bytes
 @return CGFloat represents the total disk space in bytes
 */
+ (CGFloat)totalDirSpaceInBytes;
+ (CGFloat)totalDirSpaceInBytes : (NSString*)dirName;
+ (CGFloat)getFileSize:(NSString *)fileName;
+ (NSString*) getFilePath:(NSString*)dirName fileName:(NSString*)fileName;
+ (NSString*)getFileSpace:(NSString *)fileName;
/*!
 The total disk space in bytes
 @return CGFloat represents the total disk space in bytes
 */
+ (CGFloat)totalDiskSpaceInBytes;

/*!
 The free disk space in bytes
 @return CGFloat represents the free disk space in bytes
 */
+ (CGFloat)freeDiskSpaceInBytes;

/*!
 The used disk space in bytes
 @return CGFloat represents the used disk space in bytes
 */
+ (CGFloat)usedDiskSpaceInBytes;

+ (NSString *)memoryFormatter:(long long)diskSpace;

@end
