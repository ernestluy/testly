//
//  BLECentralManager.h
//  BLEPro
//
//  Created by 卢一 on 14-8-27.
//  Copyright (c) 2014年 卢一. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@class BLECentralManager;
@protocol BLECentralManagerDeleate <NSObject>
-(void)connectSuccess:(BLECentralManager*)bm;
@end



@interface BLECentralManager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    CBCentralManager *manager;
    NSMutableArray *_dicoveredPeripherals;
    NSMutableDictionary *_dicPeripherals;
    
    CBPeripheral *_testPeripheral;
    
    CBService        *_service;
    CBCharacteristic *_readCharacteristic;
    CBCharacteristic *_writeCharacteristic;
    NSTimer *connectTimer;
    
    NSMutableData *_recvData;
    
    __weak id<BLECentralManagerDeleate> delegate;
    
    BOOL isConnect;
    BOOL isActive;
    NSString *token;
}

@property (nonatomic,weak)id<BLECentralManagerDeleate> delegate;
@property (nonatomic)BOOL isActive;
+(BLECentralManager*)sharedInstance;
-(void)setSelectedIndex:(int)index;
-(void)beginScan;
-(void)connectTimeout:(id)info;

-(void)writeChar:(NSData *)data;
-(void)sendData:(NSDictionary *)dic;
-(void)disConnect;
@end
