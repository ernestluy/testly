//
//  BLECentralManager.m
//  BLEPro
//
//  Created by 卢一 on 14-8-27.
//  Copyright (c) 2014年 卢一. All rights reserved.
//

#import "BLECentralManager.h"
#import "PublicDefine.h"
#import "JsonUtil.h"
static BLECentralManager *bleInstance = nil;
@interface BLECentralManager () {
    
}
-(void)setDisconnect;
-(void)stopTimer;
-(BOOL)judgeConnectIsValid;
@end


@implementation BLECentralManager
@synthesize delegate,isActive;



-(id)init{
    self = [super init];
    if (self) {
        _dicoveredPeripherals = [NSMutableArray array];
        _dicPeripherals = [NSMutableDictionary dictionary];
        _recvData = [NSMutableData data];
        manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        manager.delegate = self;
        isConnect  = NO;
        isActive = NO;
        token = @"";
    }
    return self;
}
+(BLECentralManager*)sharedInstance{
    if (nil == bleInstance) {
        @synchronized([BLECentralManager class]){
            if (nil == bleInstance) {
                bleInstance = [[BLECentralManager alloc ]init];
            }
        }
    }
    return bleInstance;
}

//开始扫描周边设备
-(void)beginScan{
    if (manager) {
        [manager stopScan];
    }
    [_dicoveredPeripherals removeAllObjects];
    [_dicPeripherals removeAllObjects];

    NSLog(@"beginScan");
    //scan外设
    NSDictionary* scanOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:[NSNumber numberWithBool:NO] };
    NSArray	*uuidArray= [NSArray arrayWithObjects:[CBUUID UUIDWithString:UUIDSTR_ISSC_PROPRIETARY_SERVICE], nil];
    [manager scanForPeripheralsWithServices:uuidArray options:scanOptions];
//    [manager scanForPeripheralsWithServices:nil options:nil];
}
-(void)stopScan{
    if (manager) {
        [manager stopScan];
    }
}
#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSLog(@"state:%d",(int)central.state);
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:{
            NSLog(@"设备支持，你可以开启蓝牙搜索");
            
            break;
        }
            
        default:{
            NSLog(@"设备不支持,不开启");
            break;
        }
    }
}

//当扫描到4.0的设备后，系统会通过回调函数告诉我们设备的信息，然后我们就可以连接相应的设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"dicoveredPeripherals");
    NSLog(@"peripheral:%@", peripheral);
//    if(![_dicoveredPeripherals containsObject:peripheral])
//        [_dicoveredPeripherals addObject:peripheral];
    NSString *tUUID = [peripheral.identifier UUIDString];
    if (!peripheral.identifier || !tUUID || tUUID.length == 0) {
        return;
    }
    
    //判断，如果列表中已经存在该周边设备，则不添加到列表中
    NSObject *tob = [_dicPeripherals objectForKey:tUUID];
    if (!tob) {
        [_dicPeripherals setObject:@"YES" forKey:tUUID];
        [_dicoveredPeripherals addObject:peripheral];
        if (!isConnect) {
            [self connect:peripheral];
        }
        
    }

    
}



//连接指定的设备
-(BOOL)connect:(CBPeripheral *)peripheral
{
    NSLog(@"connect start");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    _testPeripheral = peripheral;
    
    [manager connectPeripheral:peripheral
                       options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    
    //开一个定时器监控连接超时的情况
    connectTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(connectTimeout:) userInfo:peripheral repeats:NO];
    
    return (YES);
}

-(void)connectTimeout:(id)info{
    NSLog(@"connectTimeout 链接超时，断开");
    [self setDisconnect];
}

-(void)setDisconnect{
    _testPeripheral = nil;
    _service = nil;
    _readCharacteristic = nil;
    _writeCharacteristic = nil;
    isConnect = NO;
    [self stopTimer];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)stopTimer{
    if (connectTimer) {
        if ([connectTimer isValid]) {
            [connectTimer  invalidate];
        }
        connectTimer = nil;
    }
}

-(BOOL)judgeConnectIsValid{
    if (!_service) {
        return NO;
    }
    if (!_readCharacteristic) {
        return NO;
    }
    if (!_writeCharacteristic) {
        return NO;
    }
    return YES;
}


//当连接成功后，系统会通过回调函数告诉我们，然后我们就在这个回调里去扫描设备下所有的服务和特征
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self stopTimer];//停止时钟
    isConnect = YES;
    NSLog(@"Did connect to peripheral: %@", peripheral);
    _testPeripheral = peripheral;
    
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];//扫描已经连接上得周边设备，获取该设备的服务和特征
    if (self.delegate && [self.delegate respondsToSelector:@selector(connectSuccess:)]) {
        [self.delegate connectSuccess:self];
    }
    
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"didFailToConnectPeripheral: %@", peripheral);
    [self setDisconnect];
    if (isActive) {
        [self beginScan];
    }
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"didDisconnectPeripheral: %@", peripheral);
    [self setDisconnect];
    if (isActive) {
        [self beginScan];
    }
    
}



#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"didDiscoverServices");
    if (error)
    {
        NSLog(@"Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
        return;
    }
    
    
    for (CBService *service in peripheral.services)
    {
        
        if ([service.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_ISSC_PROPRIETARY_SERVICE]])
        {
            //发现需要控制的对象
            _service = service;
            NSLog(@"Service found with UUID: %@", service.UUID);
            [peripheral discoverCharacteristics:nil forService:service];
            return;
        }
//        NSLog(@"everyone Service  UUID: %@", service.UUID);
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    
    if (error)
    {
        NSLog(@"Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        return;
    }

    for (CBCharacteristic *characteristic in service.characteristics)
    {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_ISSC_TRANS_READX]])
        {
            NSLog(@"Discovered read characteristics:%@ for service: %@", characteristic.UUID, service.UUID);
            
            _readCharacteristic = characteristic;//保存读的特征
            [self startSubscribe];
        }
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_ISSC_TRANS_WRITEX]])
        {
            
            NSLog(@"Discovered write characteristics:%@ for service: %@", characteristic.UUID, service.UUID);
            _writeCharacteristic = characteristic;//保存写的特征
            
        }
//        NSLog(@"everyone characteristics:%@ for service: %@", characteristic.UUID, service.UUID);
    }
    [self stopScan];
}

//发送成功调用
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"发送数据回调");
    if (error) {
        NSLog(@"error:%@",error);
        [[[UIAlertView alloc] initWithTitle:nil message:@"发送数据失败" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
//    [[[UIAlertView alloc] initWithTitle:nil message:@"发送数据成功" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

//接收数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"接收数据");
    if (error)
    {
        NSLog(@"Error updating value for characteristic %@ error: %@", characteristic.UUID, [error localizedDescription]);
    
        return;
    }
    if (characteristic.value) {
        NSLog(@"value.len:%d",(int)characteristic.value.length);
    }else{
        NSLog(@"value is nil.");
    }
//    NSError *jsonError;
    NSDictionary *tDic  = [JsonUtil getDicWithData:characteristic.value];
    //NSDictionary *tDic = [NSJSONSerialization JSONObjectWithData:characteristic.value options:NSJSONReadingMutableLeaves error:&jsonError];

    //[[[UIAlertView alloc] initWithTitle:@"接收数据" message:[tDic objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
//    unsigned char *buffer = (unsigned char *)[characteristic.value bytes];
//    NSString *tmpStr = [NSString stringWithUTF8String:(const char *)buffer];
//    NSLog(@"recvice :%@",tmpStr);
//    [[[UIAlertView alloc] initWithTitle:@"接收数据" message:tmpStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
    int tCode = [[tDic objectForKey:@"code"] intValue];
    switch (tCode) {
        case Cus_Success:{
            token = [tDic objectForKey:@"token"];
            [self sendData:@{@"code":CNUMBER(Cus_Normal_Msg),@"token":token,@"msg":[NSString stringWithFormat:@"设备由 %@ 控制",[JsonUtil replaceDoubleSymbleToSignle:[UIDevice currentDevice].name]]}];//[UIDevice currentDevice].name
            break;
        }
        default:
            break;
    }
    
}

//在7.0系统下，先执行该代理方法，然后执行 didDisconnectPeripheral方法
- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral{
    NSLog(@"peripheralDidInvalidateServices :%@",peripheral);
    isConnect = NO;
}
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (!error) {
        NSLog(@"rssi %d", (int)[[peripheral RSSI] integerValue]);
    }
}

#pragma mark - customAction
//写数据
-(void)writeChar:(NSData *)data
{
    NSLog(@"writeChar");//CBCharacteristicWriteWithResponse
    if (!isConnect) {
        NSLog(@"disconnect");
        return;
    }
    if (_writeCharacteristic == nil) {
        NSLog(@"_writeCharacteristic is nil ,return .");
        return;
    }
    [_testPeripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
}
-(void)sendData:(NSDictionary *)dic{
    NSLog(@"sendData");//CBCharacteristicWriteWithResponse
    if (!isConnect) {
        NSLog(@"is disconnect");
        return;
    }
    if (_writeCharacteristic == nil) {
        NSLog(@"_writeCharacteristic is nil ,return .");
        return;
    }
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    [mDic setObject:token forKey:@"token"];

    NSData *sData = [JsonUtil getDataWithDic:mDic];
//    NSData *data = [NSJSONSerialization dataWithJSONObject:mDic options:NSJSONWritingPrettyPrinted error:nil];
    [_testPeripheral writeValue:sData forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
}



//监听设备
-(void)startSubscribe
{
    NSLog(@"startSubscribe");
    [_testPeripheral setNotifyValue:YES forCharacteristic:_readCharacteristic];
}

//主动断开设备
-(void)disConnect
{
    NSLog(@"disConnect");
    if (!manager) {
        return;
    }
    if(!isConnect)
        return;
    if (_testPeripheral != nil)
    {
        NSLog(@"disConnect start");
        [manager cancelPeripheralConnection:_testPeripheral];
        [manager stopScan];
        [self setDisconnect];
    }
    
}

#pragma mark - BLEDataDeleate
-(void)setSelectedIndex:(int)index{
    [self connect:[_dicoveredPeripherals objectAtIndex:index]];
}

@end
