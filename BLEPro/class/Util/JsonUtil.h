//
//  JsonUtil.h
//  BLEPro
//
//  Created by zzt on 15/1/26.
//  Copyright (c) 2015年 卢一. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON.h"
@interface JsonUtil : NSObject

+(NSData*)getDataWithDic:(NSDictionary *)dic;

+(NSDictionary *)getDicWithData:(NSData*)data;

+(NSString *)replaceJsonString:(NSString *)jsonString;

+(NSString *)replaceDoubleSymbleToSignle:(NSString *)str;
@end
