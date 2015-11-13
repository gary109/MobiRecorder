//
//  MRFileManagement.m
//  MobiRecorder
//
//  Created by GarY on 2015/4/29.
//  Copyright (c) 2015年 gyhouse. All rights reserved.
//

#import "MRFileManagement.h"

@implementation MRFileManagement

+ (NSString *) saveVideoFile:(NSString *)fileName {
    NSString *DestFilename = fileName;
    
    //Set the file save to URL
    NSString *DestPath;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    DestPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"MobRecord"];
    
    
    NSLog(@"目前目錄路徑為 : %@", DestPath);
    
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:DestPath])    //Does directory already exist?
    {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:DestPath
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                             error:&error])
        {
            NSLog(@"Create directory error: %@", error);
            return nil;
        }
        else
        {
            NSLog(@"Create directory pass: %@", DestPath);
        }
    }
    else
    {
        NSLog(@"目前系統的暫存目錄已存在: %@", DestPath);
    }
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:@"yyyy_MM_dd_HH_mm_ss"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    
    
    NSString *outputPath = [NSString stringWithFormat:@"%@/%@%@", DestPath, strDate,DestFilename];
    NSLog(@"saveVideoFiletPath: %@", outputPath);
    return outputPath;
}
+ (NSString *) createDir:(NSString *)dirName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString * DestPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:dirName];
    
    NSLog(@"目前目錄路徑為 : %@", DestPath);
    
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:DestPath])    //Does directory already exist?
    {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:DestPath
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                             error:&error])
        {
            NSLog(@"Create directory error: %@", error);
            return nil;
        }
        else
        {
            NSLog(@"Create directory pass: %@", dirName);
        }
    }
    else
    {
        NSLog(@"目前系統的暫存目錄已存在: %@", dirName);
    }
    return DestPath;
}



+ (NSString *)findEarlierCreationDateAtFolder:(NSString *)dirName {
    double dateTime,dateTimeTmp;
    NSString* path;
    NSString *DestPath;
    NSString *DestPathTmp;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    DestPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:dirName];
    NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager] enumeratorAtPath: DestPath];
    NSString *filename;
    dateTime = [NSDate timeIntervalSinceReferenceDate];
    while ((filename = [direnum nextObject]))
    {
        dateTimeTmp = [[self getFileCreationDate:[DestPath stringByAppendingPathComponent:path]] timeIntervalSinceReferenceDate];
        // 找到建立時間的檔案有早於date1則替換
        if(dateTime > dateTimeTmp)
        {
            dateTime = dateTimeTmp;
            DestPathTmp = [DestPath stringByAppendingPathComponent:filename];
        }
    }
    NSLog(@"最舊的檔案：%@", DestPathTmp);
    return DestPathTmp;
}
+ (NSDate *)getFileCreationDate:(NSString *)fileName {
    NSDictionary* attr;
    NSError * error;
    
    
    if ((attr = [[NSFileManager defaultManager] attributesOfItemAtPath:fileName error:&error]) == nil)
    {
        NSLog (@"Couldn't get file attributes!");
    }
    
    return [attr fileCreationDate];
}



+ (void) clearDirContentAll:(NSString*)dirName {
    NSString *DestPathTmp;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString * DestPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:dirName];
    
    NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager] enumeratorAtPath: DestPath];
    NSString *filename;
    while ((filename = [direnum nextObject]))
    {
        DestPathTmp = [DestPath stringByAppendingPathComponent:filename];
        // 移除檔案
        NSLog(@"移除檔案:%@",DestPathTmp);
        [[NSFileManager defaultManager] removeItemAtPath:DestPathTmp error:NULL];
    }
}

+ (void) createFile:(NSString*)newFileName {
    //    NSString * tempDirPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"MobRecord"];
    //    NSLog(@"目前系統的暫存目錄路徑為 : %@", tempDirPath);
    
    //    // 在暫存目錄路徑後面附加將要新建的檔案名稱
    //    NSString* newFile = [tempDirPath stringByAppendingPathComponent: newFileName];
    //    NSLog(@"新建檔案的路徑與檔名 : %@", newFile);
    
    // 依照盪案路徑與名稱實際建立檔案
    if ([[NSFileManager defaultManager] fileExistsAtPath:newFileName] == YES) {
        NSLog(@"檔案已存在");
    }else {
        [[NSFileManager defaultManager] createFileAtPath: newFileName contents:nil attributes: nil];
    }
}
+ (void) moveDirContentToLibrary:(NSString*)dirName {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    NSString *DestPath;
    NSString *DestPathTmp;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    DestPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:dirName];
    NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager] enumeratorAtPath: DestPath];
    NSString *filename;
    while ((filename = [direnum nextObject]))
    {
        DestPathTmp = [DestPath stringByAppendingPathComponent:filename];
        NSLog(@"moveDirContentToLibrary FileName: %@", filename);
        [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:DestPathTmp]
                                    completionBlock:^(NSURL *assetURL, NSError *error)
         {
             if (error)
             {
                 NSLog(@"writeVideoAtPathToSavedPhotosAlbum error: %@", error);
             }
             else
             {
                 NSLog(@"writeVideoAtPathToSavedPhotosAlbum sccess");
                 
                 // 移除檔案
                 NSLog(@"移除檔案:%@",DestPathTmp);
                 [[NSFileManager defaultManager] removeItemAtPath:DestPathTmp error:NULL];
             }
         }];
        
        sleep (10);
    }
    
    
    
    UIAlertView * myAlertView = [[UIAlertView alloc] initWithTitle:@"Video"
                                                           message:@"All movies had to save to photo album!"
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles: nil];
    
    [myAlertView show];
    
    [myAlertView dismissWithClickedButtonIndex:0 animated:YES];
}
+ (void) fileEnumerator:(NSString*)dirName {
    // 取得路徑中所有目錄與檔案
    NSString *DestPath;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    DestPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:dirName];
    
    NSLog(@"DestPath: %@", DestPath);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *direnum = [fileManager enumeratorAtPath: DestPath];
    NSString *filename;
    while ((filename = [direnum nextObject]))
    {
        NSLog(@"檔案名稱為%@",filename);
        
    }
    
}
@end
