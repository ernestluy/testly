//
//  Single.h
//  BLEPro
//
//  Created by 卢一 on 14-8-27.
//  Copyright (c) 2014年 卢一. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PublicDefine.h"
@interface Single : NSObject
{
    NSString *token;
}
@property (nonatomic)DeviceType deviceType;
@property (nonatomic,copy)NSString *token;
+(Single*)sharedInstance;
-(void)playShootVoice;
-(NSString *)generatToken;
@end
