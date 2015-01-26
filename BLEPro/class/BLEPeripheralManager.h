//
//  BLEPeripheralManager.h
//  BLEPro
//
//  Created by zzt on 15/1/22.
//  Copyright (c) 2015年 卢一. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@class BLEPeripheralManager;
@protocol BLEPeripheralManagerDeleate <NSObject>
-(void)connectSuccess:(BLEPeripheralManager*)pm;
-(void)disconnect:(BLEPeripheralManager*)pm;
-(void)receiveData:(NSDictionary *)dic;
-(void)updateStatus:(NSString *)str;
@end

@interface BLEPeripheralManager : NSObject<CBPeripheralManagerDelegate>
{
    NSMutableArray *_subscribedCentrals;
    BOOL isConnect;
}
@property (nonatomic,weak)id<BLEPeripheralManagerDeleate> delegate;
@property(nonatomic)BOOL isConnect;
+(BLEPeripheralManager*)sharedInstance;

-(void)adverData:(NSDictionary*)JSONDictionary;
-(void)adverAllCentrl:(NSDictionary*)JSONDictionary;
- (void) startupServer;
- (void)setupBeaconRegion;
- (void) teardownServer;
@end
