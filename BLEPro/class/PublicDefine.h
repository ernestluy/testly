//
//  PublicDefine.c
//  TestApp
//
//  Created by 卢一 on 14-5-29.
//  Copyright (c) 2014年 卢一. All rights reserved.
//

#include <stdio.h>

#define CUSTOM_COLOR(a,b,c,d)   [UIColor colorWithRed:(a)/255.0 green:(b)/255.0 blue:(c)/255.0 alpha:(d)]

//static NSString * const kOWUBeaconRegionID = @"8CE0239D-4D43-48B8-9306-C3934C6EA827";
//static NSString * const kOWUBeaconProximityUUID = @"7C3024A9-CC9D-4E40-B8A3-E58A6D79FBFD";
//static NSString * const kOWUBluetoothServiceUUID = @"06F24877-77F2-44EE-89B8-A83A3D68EE4F";
//static NSString * const kOWUBluetoothCharacteristicUUID = @"83F49B4E-3647-4935-B4B2-D8A7519A7166";
#define _rgb2uic(i,a) [UIColor colorWithRed:(i>>16&0xFF)/255.0 green:(i>>8&0xFF)/255.0 blue:(i&0xFF)/255.0 alpha:a]

#define UUID_SPECIEL_SERVICE                 @"0069-61"
#define UUIDSTR_ISSC_PROPRIETARY_SERVICE     @"06F24877-77F2-44EE-89B8-A83A3D68EE4F"
#define UUIDSTR_ISSC_TRANS_WRITEX            @"7C3024A9-CC9D-4E40-B8A3-E58A6D79FBFD"
#define UUIDSTR_ISSC_TRANS_READX             @"83F49B4E-3647-4935-B4B2-D8A7519A7166"
#define CNUMBER(ti) [NSNumber numberWithInt:(ti)]


typedef enum {
    DeviceShootPhoto,
    DeviceConroller,
    DeviceNormal
}DeviceType;

typedef enum {
    Cus_Success = 200,
    Cus_Apply ,
    Cus_Error = 401,
    Cus_Shoot_Device_Be_Ctl = 402,
    
    Cus_Normal_Msg = 500,
    
    Cus_Ctl_Shoot = 501
}CusCode;
