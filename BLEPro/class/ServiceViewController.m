//
//  ServiceViewController.m
//  BLEPro
//
//  Created by zzt on 15/1/22.
//  Copyright (c) 2015年 卢一. All rights reserved.
//

#import "ServiceViewController.h"
#import "BLEPeripheralManager.h"
#import "BLECentralManager.h"
@interface ServiceViewController ()

@end

@implementation ServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"service";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)startServiceAction{
    [[BLEPeripheralManager sharedInstance] startupServer];
}
-(IBAction)tearDownServiceAction{
    [[BLEPeripheralManager sharedInstance] teardownServer];
}

- (IBAction)serviceSwitchSwitched:(id)sender {
    UISwitch *theSwitch = (UISwitch*)sender;
    if (theSwitch.isOn) {
        [[BLEPeripheralManager sharedInstance] startupServer];
    } else {
        [[BLEPeripheralManager sharedInstance] teardownServer];
    }
}
@end
