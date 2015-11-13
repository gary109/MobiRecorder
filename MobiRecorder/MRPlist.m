//
//  MRPlist.m
//  MobRecorder
//
//  Created by GarY on 2014/8/20.
//  Copyright (c) 2014年 GarY WanG. All rights reserved.
//

#import "MRPlist.h"

MRPlist *g_mrPlist;

@interface MRPlist ()
{
    NSString *rootPath;
    NSString *plistPath;
    NSString *saveRootPath;
    NSString *savePath;
    
    
    
}

@property (nonatomic,strong) NSString * rootPath;
@property (nonatomic,strong) NSString * plistPath;
@property (nonatomic,strong) NSString * saveRootPath;
@property (nonatomic,strong) NSString * savePath;



@end

@implementation MRPlist
@synthesize plistDictionary;
@synthesize rootPath;
@synthesize plistPath;
@synthesize saveRootPath;
@synthesize savePath;
@synthesize g_key;
@synthesize g_content;


#pragma mark
#pragma mark 初始化物件
+ (MRPlist *)sharedInstance
{
    static MRPlist *singleton = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        singleton = [[MRPlist alloc] init];
        g_mrPlist = singleton;
    });
    return singleton;
}

- (id) init
{
    self = [super init];
    if(self){
        //初始化路徑
        rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
        //取得儲存路徑
        saveRootPath = [NSSearchPathForDirectoriesInDomains
                                  (NSDocumentDirectory,NSUserDomainMask, YES)
                                  objectAtIndex:0];
        //取得 plist 檔路徑
        plistPath = [rootPath stringByAppendingPathComponent:@"Setting.plist"];
        
        savePath = [saveRootPath stringByAppendingPathComponent:@"Setting.plist"];
        
        //如果 Documents 文件夾中沒有 test.plist 的話，則從 project 目錄中载入 test.plist
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath])
        {
            plistPath = [[NSBundle mainBundle] pathForResource:@"Setting" ofType:@"plist"];
        }
        //將取得的 plist 內容載入至剛才建立的 Dictionary 中
        plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        
        //利用 NSLog 來查看剛才取得的 plist 檔的內容
        NSLog(@"plist:%@",g_mrPlist.plistDictionary);
    }
    
    return self;
}

//+ (NSString*) readPlist:(NSString*)fileName forkey:(NSString*)key {
//    //建立一個 Dictionary
//    NSMutableDictionary *plistDictionary;
//    
//    //初始化路徑
//    NSString *rootPath = [NSSearchPathForDirectoriesInDomains
//                          (NSDocumentDirectory,NSUserDomainMask, YES)
//                          objectAtIndex:0];
//    
//    //rootPath = [rootPath stringByAppendingPathComponent:@"MobRecord/"];
//    
//    //取得 plist 檔路徑
//    NSString *plistName = [fileName stringByAppendingString:@".plist"];
//    NSString *plistPath = [rootPath stringByAppendingPathComponent:plistName];
//    NSLog(@"%@ plist path:%@",fileName,plistPath);
//    
//    //[[NSFileManager defaultManager] removeItemAtPath:plistPath error:NULL];
//    
//    //如果 Documents 文件夾中沒有 test.plist 的話，則從 project 目錄中载入 test.plist
//    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath])
//    {
//        plistPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
//    }
//    //將取得的 plist 內容載入至剛才建立的 Dictionary 中
//    plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
//    
//    //利用 NSLog 來查看剛才取得的 plist 檔的內容
//    NSLog(@"%@ plist:%@",fileName,plistDictionary);
//    
//    if([plistDictionary objectForKey:key] == nil)
//    {
//        plistPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
//    }
//    //將取得的 plist 內容載入至剛才建立的 Dictionary 中
//    plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
//    
//    //利用 NSLog 來查看剛才取得的 plist 檔的內容
//    NSLog(@"%@ plist:%@",fileName,plistDictionary);
//    
//    return [plistDictionary objectForKey:key];
//}


+ (void) writePlist:(NSString*)key content:(NSString*) content {
    
    //接荖我們來試著修改其內容
    [g_mrPlist.plistDictionary setObject:content forKey:key];

    //將 Dictionary 儲存至指定的檔案
    [g_mrPlist.plistDictionary writeToFile:g_mrPlist.savePath atomically:YES];
    
    g_mrPlist.g_content = [g_mrPlist.plistDictionary objectForKey:key];
    g_mrPlist.g_key = key;
}

+ (NSString*) readPlist:(NSString*)key {
    return [g_mrPlist.plistDictionary objectForKey:key];
}

@end
