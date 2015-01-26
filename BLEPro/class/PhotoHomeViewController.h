//
//  PhotoHomeViewController.h
//  BLEPro
//
//  Created by zzt on 15/1/23.
//  Copyright (c) 2015年 卢一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVCaptureManager.h"
#import "BLEPeripheralManager.h"
@interface PhotoHomeViewController : UIViewController<AVCaptureManagerDelegate,UIActionSheetDelegate,BLEPeripheralManagerDeleate>


-(IBAction)imageCapture:(id)sender;
-(IBAction)homeSetting:(id)sender;
@end
