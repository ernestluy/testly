//
//  BLEViewController.h
//  BLEPro
//
//  Created by 卢一 on 14-8-27.
//  Copyright (c) 2014年 卢一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLECentralManager.h"

@interface BLEViewController : UIViewController<BLECentralManagerDeleate,UITableViewDataSource,UIPickerViewDelegate,UITableViewDelegate>
{
    IBOutlet UITableView *tTableView;
    
    NSMutableArray *aData;
}

-(IBAction)sendMsgAction;
-(IBAction)startAction;
-(IBAction)disconnect;

-(IBAction)toService:(id)sender;
@end
