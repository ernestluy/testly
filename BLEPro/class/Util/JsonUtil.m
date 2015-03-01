//
//  JsonUtil.m
//  BLEPro
//
//  Created by zzt on 15/1/26.
//  Copyright (c) 2015年 卢一. All rights reserved.
//

#import "JsonUtil.h"

@implementation JsonUtil
+(NSData*)getDataWithDic:(NSDictionary *)dic{
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&err];
    return data;
    
//    NSString *tmpStr = [dic JSONRepresentation];
//    char *tmpChar = (char*)[tmpStr cStringUsingEncoding:NSUTF8StringEncoding];
//    NSData *sData = [NSData dataWithBytes:(const void*)tmpStr length:strlen(tmpChar)+1];
//    return sData;
}

//132
+(NSDictionary *)getDicWithData:(NSData*)data{
    if (!data) {
        return nil;
    }
    unsigned char *buffer = (unsigned char *)[data bytes];
    NSString *tmpStr = [NSString stringWithUTF8String:(const char *)buffer];
    NSLog(@"recvice :%@",tmpStr);
    
    NSError *err;
    NSDictionary *tDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&err];
    return tDic;
    
    
//    NSString *tttStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    char *buffer = (char *)[data bytes];
//    NSString *tmpStr = [NSString stringWithCString:(const char*)buffer encoding:NSUTF8StringEncoding];
//    tmpStr = [JsonUtil replaceJsonString:tmpStr];
//    return [tmpStr JSONValue];
}

+ (NSString *)replaceJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return @"";
    }
    
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\\\" withString:@""];
    
    
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\\"{" withString:@"{"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"}\\\"" withString:@"}"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\"{" withString:@"{"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"}\"" withString:@"}"];
    
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"{\\\"" withString:@"{\""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\\"}" withString:@"\"}"];
    
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"[\\\"" withString:@"[\""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\\"]" withString:@"\"]"];
    
    
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\\",\\\"" withString:@"\",\""];
    
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\\":" withString:@"\":"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@":\\\"" withString:@":\""];
    
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"{\\\"" withString:@"{\""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\\":" withString:@"\":"];
    
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@",\\\"" withString:@",\""];
    
    return jsonString;
}
+(NSString *)replaceDoubleSymbleToSignle:(NSString *)str{
    if (str && str.length >30) {
        NSRange range = NSMakeRange(0, 30);
        str = [str substringWithRange:range];
    }
    str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
    str = [str stringByReplacingOccurrencesOfString:@"“" withString:@"'"];
    str = [str stringByReplacingOccurrencesOfString:@"”" withString:@"'"];
    return str;
}
@end
