//
//  MRJSON.h
//  MobiRecorder
//
//  Created by GarY on 2014/10/24.
//  Copyright (c) 2014年 gyhouse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MRJSON : NSObject

+ (NSArray *)getJSONData:(NSString*)name categoryName:(NSString *)_categoryName;

@end
