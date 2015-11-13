//
//  ALDisk.m
//  ALSystem
//
//  Created by Andrea Mario Lufino on 19/07/13.
//  Copyright (c) 2013 Andrea Mario Lufino. All rights reserved.
//

#import "ALDisk.h"

#define MB (1024*1024)
#define GB (MB*1024)
#define KB (1024)

@implementation ALDisk

#pragma mark - Formatter

+ (NSString *)memoryFormatter:(long long)diskSpace {
    NSString *formatted;
    double bytes = 1.0 * diskSpace;
    double megabytes = bytes / MB;
    double gigabytes = bytes / GB;
    double kbytes = bytes / KB;
    if (gigabytes >= 1.0)
        formatted = [NSString stringWithFormat:@"%.2f GB", gigabytes];
    else if (megabytes >= 1.0)
        formatted = [NSString stringWithFormat:@"%.2f MB", megabytes];
    else if (kbytes >= 1.0)
        formatted = [NSString stringWithFormat:@"%.2f KB", kbytes];
    else
        formatted = [NSString stringWithFormat:@"%.2f bytes", bytes];
    
    return formatted;
}

#pragma mark - Methods

+ (NSString *)totalDirSpace {
//    long long space = 0;
//    NSString *DestPath, *DestPathTmp;
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//                                                         NSUserDomainMask,
//                                                         YES);
//    DestPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"MobRecord"];
//
//    NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager] enumeratorAtPath: DestPath];
//    NSString *filename;
//    while ((filename = [direnum nextObject]))
//    {
//        DestPathTmp = [DestPath stringByAppendingPathComponent:filename];
//        space += [[[[NSFileManager defaultManager] attributesOfItemAtPath:DestPathTmp error:nil] objectForKey: NSFileSize] longLongValue];
//    }
//    return [self memoryFormatter:space];
//    
    
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* DestPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"MobRecord"];
    NSArray *folderContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:DestPath error:nil];
    __block unsigned long long int folderSize = 0;
    
    [folderContents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[DestPath stringByAppendingPathComponent:obj] error:nil];
        folderSize += [[fileAttributes objectForKey:NSFileSize] intValue];
    }];
    return [self memoryFormatter:folderSize];
}

+ (NSString *)totalDiskSpace {
    long long space = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemSize] longLongValue];
    return [self memoryFormatter:space];
}

+ (NSString *)freeDiskSpace {
    long long freeSpace = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemFreeSize] longLongValue];
    
    
    return [self memoryFormatter:freeSpace];
}

+ (NSString *)usedDiskSpace {
    return [self memoryFormatter:[self usedDiskSpaceInBytes]];
}

+ (CGFloat)totalDirSpaceInBytes : (NSString*)dirName {
//    long long space = 0;
//    NSString *DestPath, *DestPathTmp;
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//                                                         NSUserDomainMask,
//                                                         YES);
//    DestPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:dirName];
//    
//    NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager] enumeratorAtPath: DestPath];
//    NSString *filename;
//    while ((filename = [direnum nextObject]))
//    {
//        DestPathTmp = [DestPath stringByAppendingPathComponent:filename];
//        space += [[[[NSFileManager defaultManager] attributesOfItemAtPath:DestPathTmp error:nil] objectForKey: NSFileSize] longLongValue];
//    }
//    return space;
//    
//    
//    
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* DestPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:dirName];
    NSArray *folderContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:DestPath error:nil];
    __block unsigned long long int folderSize = 0;
    
    [folderContents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[DestPath stringByAppendingPathComponent:obj] error:nil];
        folderSize += [[fileAttributes objectForKey:NSFileSize] intValue];
    }];
    return folderSize;
}

+ (NSString*) getFilePath:(NSString*)dirName fileName:(NSString*)fileName {
    NSString *DestPath;
    NSString *DestPathTmp;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    DestPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:dirName];
    DestPathTmp = [DestPath stringByAppendingPathComponent:fileName];
    return DestPathTmp;
}

+ (CGFloat)totalDirSpaceInBytes {
//    long long space = 0;
//    NSString *DestPath, *DestPathTmp;
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//                                                         NSUserDomainMask,
//                                                         YES);
//    DestPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"MobRecord"];
//    
//    NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager] enumeratorAtPath: DestPath];
//    NSString *filename;
//    while ((filename = [direnum nextObject]))
//    {
//        DestPathTmp = [DestPath stringByAppendingPathComponent:filename];
//        space += [[[[NSFileManager defaultManager] attributesOfItemAtPath:DestPathTmp error:nil] objectForKey: NSFileSize] longLongValue];
//    }
//    return space;
//    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* DestPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"MobRecord"];
    NSArray *folderContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:DestPath error:nil];
    __block unsigned long long int folderSize = 0;
    
    [folderContents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[DestPath stringByAppendingPathComponent:obj] error:nil];
        folderSize += [[fileAttributes objectForKey:NSFileSize] intValue];
    }];
    return folderSize;
}

+ (CGFloat)getFileSize:(NSString *)fileName
{
    long long space = 0;
    
    NSString *DestPath, *DestPathTmp;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    DestPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"MobRecord"];
    DestPathTmp = [DestPath stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:DestPathTmp] == YES) {
        space = [[[[NSFileManager defaultManager] attributesOfItemAtPath:DestPathTmp error:nil] objectForKey: NSFileSize] longLongValue];
    }

    return space;
}

+ (NSString*)getFileSpace:(NSString *)fileName
{
    long long space = 0;
    
    NSString *DestPath, *DestPathTmp;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    DestPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"MobRecord"];
    DestPathTmp = [DestPath stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:DestPathTmp] == YES) {
        space = [[[[NSFileManager defaultManager] attributesOfItemAtPath:DestPathTmp error:nil] objectForKey: NSFileSize] longLongValue];
    }
    
    return [self memoryFormatter:space];
}

+ (CGFloat)totalDiskSpaceInBytes {
    long long space = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemSize] longLongValue];
    return space;
}

+ (CGFloat)freeDiskSpaceInBytes {
    long long freeSpace = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemFreeSize] longLongValue];
    return freeSpace;
}

+ (CGFloat)usedDiskSpaceInBytes {
    long long usedSpace = [self totalDiskSpaceInBytes] - [self freeDiskSpaceInBytes];
    return usedSpace;
}

/*! WORK IN PROGRESS */
+ (CGFloat)numberOfNodes {
    long long numberOfNodes = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemNodes] longLongValue];
    return numberOfNodes;
}

@end
