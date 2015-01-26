//
//  Single.m
//  BLEPro
//
//  Created by 卢一 on 14-8-27.
//  Copyright (c) 2014年 卢一. All rights reserved.
//

#import "Single.h"
static Single *singleInstance = nil;
@implementation Single
@synthesize token;

+(Single*)sharedInstance{
    if (nil == singleInstance) {
        @synchronized([Single class]){
            if (nil == singleInstance) {
                singleInstance = [[Single alloc ]init];
            }
        }
    }
    return singleInstance;
}


-(id)init{
    self = [super init];
    if (self) {
//        [self testAction];
    }
    return self;
}

-(void)testAction{
    for (int i = 0; i<6; i++) {
        NSString *uuId = [[NSUUID UUID] UUIDString];
        NSLog(@"uuid:%@",uuId);
    }
}
-(NSString *)generatToken{
    return [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}
@end
