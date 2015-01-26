//
//  ControllerViewController.h
//  BLEPro
//
//  Created by zzt on 15/1/23.
//  Copyright (c) 2015年 卢一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLECentralManager.h"
#import "PublicDefine.h"
@interface ControllerViewController : UIViewController<BLECentralManagerDeleate>
{
    
}

-(IBAction)back:(id)sender;
-(IBAction)startAction:(id)sender;
-(IBAction)disconnect:(id)sender;
-(IBAction)shootAction:(id)sender;

@end
