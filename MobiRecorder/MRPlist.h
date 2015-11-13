//
//  MRPlist.h
//  MobRecorder
//
//  Created by GarY on 2014/8/20.
//  Copyright (c) 2014年 GarY WanG. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MRPlist : NSObject
{
    NSMutableDictionary *plistDictionary;
    NSString * g_key;
    NSString * g_content;
}


@property (nonatomic,strong) NSMutableDictionary * plistDictionary;
@property (nonatomic,strong) NSString * g_key;
@property (nonatomic,strong) NSString * g_content;

+ (MRPlist *) sharedInstance;
+ (void) writePlist:(NSString*)key content:(NSString*) content;
+ (NSString*) readPlist:(NSString*)key;
@end
