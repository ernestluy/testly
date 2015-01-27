//
//  Single.m
//  BLEPro
//
//  Created by 卢一 on 14-8-27.
//  Copyright (c) 2014年 卢一. All rights reserved.
//

#import "Single.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
static Single *singleInstance = nil;

@interface Single()

@property(nonatomic,strong)AVAudioPlayer *player;

@end
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
        NSString * musicFilePath = [[NSBundle mainBundle] pathForResource:@"shootVoice" ofType:@"mp3"];      //创建音乐文件路径
        NSURL * musicURL= [[NSURL alloc] initFileURLWithPath:musicFilePath];
        
        AVAudioPlayer * thePlayer  = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
        //创建播放器
        self.player = thePlayer;    //赋值给自己定义的类变量
        
        [self.player setVolume:1];   //设置音量大小0-1之间
//        self.player.numberOfLoops = -1;//设置音乐播放次数  -1为一直循环
    }
    return self;
}


-(void)playShootVoice{
    [self.player play];   //播放
    AudioSessionSetActive (true);
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
