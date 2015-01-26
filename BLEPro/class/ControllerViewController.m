//
//  ControllerViewController.m
//  BLEPro
//
//  Created by zzt on 15/1/23.
//  Copyright (c) 2015年 卢一. All rights reserved.
//

#import "ControllerViewController.h"
#import "PublicDefine.h"
#import "Single.h"
@interface ControllerViewController ()

@end

@implementation ControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self startAction:nil]; 
}
-(IBAction)back:(id)sender{
    [self disconnect:nil];
    [Single sharedInstance].deviceType = DeviceNormal;
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(IBAction)startAction:(id)sender{
    [BLECentralManager sharedInstance].isActive = YES;
    [BLECentralManager sharedInstance].delegate = self;
    [[BLECentralManager sharedInstance] beginScan];
}
-(IBAction)disconnect:(id)sender{
    [BLECentralManager sharedInstance].isActive = NO;
    [[BLECentralManager sharedInstance] disConnect];
}
-(IBAction)shootAction:(id)sender{
    NSLog(@"shootAction");
    [[BLECentralManager sharedInstance] sendData:@{@"code":CNUMBER(Cus_Ctl_Shoot)}];
}

#pragma mark - BLECentralManagerDeleate
-(void)connectSuccess:(BLECentralManager*)bm{
    
}
@end
