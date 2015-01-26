//
//  BLEPeripheralManager.m
//  BLEPro
//
//  Created by zzt on 15/1/22.
//  Copyright (c) 2015年 卢一. All rights reserved.
//
/*
 
 */
#import "BLEPeripheralManager.h"
#import "PublicDefine.h"
#import "Single.h"
#import "JsonUtil.h"
@interface BLEPeripheralManager () {
    // iBeacons
    CBPeripheralManager *_peripheralManager;
    
    // CBCentral
    CBCentralManager *_centralManager;
    NSMutableData *_data;
    CBPeripheral *_peripheral;
    CBUUID *_serviceUUID;
    
    CBMutableService *_service;
    CBMutableCharacteristic *_characteristicRead; //读
    CBMutableCharacteristic *_characteristicWrite;//写

    BOOL _didAddService;
    
    
    CBCentral *centralCtl;
}

@end
@implementation BLEPeripheralManager
@synthesize isConnect;

+(BLEPeripheralManager*)sharedInstance{
    static BLEPeripheralManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[BLEPeripheralManager alloc] init];
    });
    
    return _sharedInstance;
}

-(id)init{
    if(self = [super init]){
        _subscribedCentrals = [NSMutableArray array];
        _peripheralManager = nil;
        centralCtl = nil;
    }
    return self;
}

- (void) startupServer {
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    _serviceUUID = [CBUUID UUIDWithString:UUIDSTR_ISSC_PROPRIETARY_SERVICE];
    NSLog(@"_peripheralManager.isAdvertising:%d",_peripheralManager.isAdvertising);
    [_subscribedCentrals removeAllObjects];
    
    
}

- (void) teardownServer {
    if (_peripheralManager) {
        [_peripheralManager stopAdvertising];
    }
    _peripheralManager = nil;
    _peripheral = nil;
    _data = nil;
    _serviceUUID = nil;
    _characteristicRead = nil;
    _characteristicWrite = nil;
    centralCtl = nil;
}

-(void)initService{
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:UUIDSTR_ISSC_TRANS_READX];
    _characteristicRead = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID
                                                         properties:CBCharacteristicPropertyNotify
                                                              value:nil
                                                        permissions:CBAttributePermissionsReadable];
    
    
    CBUUID *characteristicUUIDWrite = [CBUUID UUIDWithString:UUIDSTR_ISSC_TRANS_WRITEX];
    _characteristicWrite = [[CBMutableCharacteristic alloc] initWithType:characteristicUUIDWrite
                                                              properties:CBCharacteristicPropertyWrite
                                                                   value:nil
                                                             permissions:CBAttributePermissionsWriteable];
    
    
    _serviceUUID = [CBUUID UUIDWithString:UUIDSTR_ISSC_PROPRIETARY_SERVICE];
    _service = [[CBMutableService alloc] initWithType:_serviceUUID primary:YES];
    [_service setCharacteristics:@[_characteristicRead,_characteristicWrite]];
    
    [_peripheralManager addService:_service];
}

//开始广播
- (void)setupBeaconRegion {
    NSLog(@"setupBeaconRegion");
    NSDictionary *tmpDic = @{CBAdvertisementDataLocalNameKey : @"ICServer",CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:UUIDSTR_ISSC_PROPRIETARY_SERVICE]]};
    [_peripheralManager startAdvertising:tmpDic];
    [_subscribedCentrals removeAllObjects];
    
    
}

-(void)stopAdvert{
    NSLog(@"stopAdvert");
    [_peripheralManager stopAdvertising];
}

#pragma mark - CBPeripheralManagerDelegate
//告诉app当前设备是可以使用蓝牙设备，可以开始进行业务处理
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            [self initService];
            break;
            
        default:{
            //提示用户设置蓝牙
        }
            break;
    }
}
//报告广播是否成功
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    if (error) {
        NSLog(@"peripheralManagerDidStartAdvertising:%@",error);
    }
    NSLog(@"peripheral:%@",peripheral);
    NSLog(@"_peripheralManager.isAdvertising:%d",_peripheralManager.isAdvertising);
}


//添加service后会调用该代理方法 addservice
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    if (error) {
        NSLog(@"didAddService error");
    }
    NSLog(@"service:%@",service);
    [self setupBeaconRegion];
}

//收到中心设备发送过来的消息，并进行回复
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests{
    NSLog(@"didReceiveWriteRequests");
    if (requests.count >0) {
        for (int i = 0; i<requests.count; i++) {
            
            CBATTRequest *req = (CBATTRequest *)[requests objectAtIndex:i];
            if (!req.value) {
                NSLog(@"req.value is nil,%@",req);
                [peripheral respondToRequest:req withResult:CBATTErrorSuccess];
                continue;
            }
//            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:req.value options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary *dic = [JsonUtil getDicWithData:req.value];
            
            [peripheral respondToRequest:req withResult:CBATTErrorSuccess];
            if ([Single sharedInstance].token && [dic objectForKey:@"token"]) {
                if ([[Single sharedInstance].token isEqualToString:[dic objectForKey:@"token"]]) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(receiveData:)]) {
                        [self.delegate receiveData:dic];
                    }
                }
            }
            
        }
    }
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
    NSLog(@"didReceiveReadRequest");
    char *tmpChar = (char *)[request.value bytes];
    NSString *tmpStr = [NSString stringWithUTF8String:tmpChar];
    NSLog(@"receive:%@",tmpStr);
}

//当有central设备连接进来并订阅相应地特征时，调用该方法
- (void) peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    if (centralCtl) {
        //只能让一个控制器进入控制
        [self adverData:@{@"code":CNUMBER(Cus_Shoot_Device_Be_Ctl),@"msg":@"拍摄设备已经处于控制状态，无法连接"}];
        [_subscribedCentrals addObject:central];
        return;
    }
    
    centralCtl = central;
    [_subscribedCentrals addObject:central];
    isConnect = YES;
    [Single sharedInstance].token = [[Single sharedInstance] generatToken];
    NSLog(@"Publishing Characteristic to Central,size:%d",(int)_subscribedCentrals.count);
    if (self.delegate && [self.delegate respondsToSelector:@selector(connectSuccess:)]) {
        [self.delegate connectSuccess:self];
    }
    //[NSString stringWithFormat:@"您控制的是%@的设备",[JsonUtil replaceDoubleSymbleToSignle:[UIDevice currentDevice].name]]
    NSDictionary *msgDic = @{@"code":CNUMBER(Cus_Success),@"token":[Single sharedInstance].token,@"msg":@"success"};
    [self adverData:msgDic];
    [self performSelector:@selector(sendDetailData) withObject:nil afterDelay:0.2];
    
    [self stopAdvert];
}

-(void)updateViewStr:(NSString *)str{
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateStatus:)]) {
        [self.delegate updateStatus:str];
    }
}

-(void)sendDetailData{
    NSDictionary *msgDic = @{@"code":CNUMBER(Cus_Normal_Msg),@"msg":[NSString stringWithFormat:@"您控制的是%@的设备",[JsonUtil replaceDoubleSymbleToSignle:[UIDevice currentDevice].name]]};
    [self adverData:msgDic];
}

//当有central设备退订相应地特征时，调用该方法 （断开连接也会调用该方法）
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{
    NSLog(@"didUnsubscribeFromCharacteristic");
//    if ([[centralCtl.identifier UUIDString] isEqualToString:[central.identifier UUIDString]]) {
//        centralCtl = nil;
//    }
    if (central == centralCtl) {
        centralCtl = nil;
        if (self.delegate && [self.delegate respondsToSelector:@selector(disconnect:)]) {
            [self.delegate disconnect:self];
        }
    }
    [_subscribedCentrals removeObject:central];
    [self setupBeaconRegion];
}



//周边设备发送广播给中心设备
- (void) updateCharactaristicValueWithDictionary:(NSDictionary*)JSONDictionary {
//    NSData *data = [NSJSONSerialization dataWithJSONObject:JSONDictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSData *data = [JsonUtil getDataWithDic:JSONDictionary];
    
    NSLog(@"蓝牙设备广播 信息");
    if (_peripheralManager) {
        [_peripheralManager updateValue:data
                      forCharacteristic:_characteristicRead
                   onSubscribedCentrals:_subscribedCentrals];
    }
    
}
//周边设备发送广播给中心设备
-(void)adverData:(NSDictionary*)JSONDictionary{
    NSData *data = [JsonUtil getDataWithDic:JSONDictionary];
    NSLog(@"蓝牙设备广播 信息");
    if (_peripheralManager) {
        [_peripheralManager updateValue:data
                      forCharacteristic:_characteristicRead
                   onSubscribedCentrals:@[centralCtl]];
    }
}

-(void)adverAllCentrl:(NSDictionary*)JSONDictionary{
//    NSData *data = [NSJSONSerialization dataWithJSONObject:JSONDictionary  options:NSJSONWritingPrettyPrinted error:nil];
    NSData *data = [JsonUtil getDataWithDic:JSONDictionary];
    NSLog(@"蓝牙设备广播 信息");
    if (_peripheralManager) {
        [_peripheralManager updateValue:data
                      forCharacteristic:_characteristicRead
                   onSubscribedCentrals:_subscribedCentrals];
    }
}
#pragma mark -  end

@end
