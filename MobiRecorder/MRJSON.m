//
//  MRJSON.m
//  MobiRecorder
//
//  Created by GarY on 2014/10/24.
//  Copyright (c) 2014年 gyhouse. All rights reserved.
//

#import "MRJSON.h"

@implementation MRJSON

+ (NSArray *)getJSONData:(NSString*)name categoryName:(NSString *)_categoryName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    
    NSError *aError = nil;
    NSMutableDictionary *resData = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers
                                                                     error:&aError];
    if (aError) {
        NSLog(@"JSON parse errror : %@", [aError localizedDescription]);
        return nil;
    }
    
    NSMutableArray *menuData = [resData objectForKey:_categoryName];
    return menuData;
}

@end
