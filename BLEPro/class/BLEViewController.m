//
//  BLEViewController.m
//  BLEPro
//
//  Created by 卢一 on 14-8-27.
//  Copyright (c) 2014年 卢一. All rights reserved.
//

#import "BLEViewController.h"
#import "ServiceViewController.h"
@interface BLEViewController ()

@end

@implementation BLEViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)init{
    self = [super init];
    if (self) {
        NSLog(@"BLEViewController init");
        [BLECentralManager sharedInstance].delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    tTableView.delegate = self;
    tTableView.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -
#pragma mark Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [aData count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    CBPeripheral *p = [aData objectAtIndex:indexPath.row];
	cell.textLabel.text = [NSString stringWithFormat:@"index%d_%@",indexPath.row,p.name];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[BLECentralManager sharedInstance] setSelectedIndex:indexPath.row];
}

-(IBAction)sendMsgAction{
    char *ddd = "I am luyi.";
    int len = strlen(ddd)+1;
    NSData *td = [NSData dataWithBytes:ddd length:len];
    [[BLECentralManager sharedInstance] writeChar:td];
}
-(IBAction)startAction{
    [BLECentralManager sharedInstance].delegate = self;
    [[BLECentralManager sharedInstance] beginScan];
}
-(IBAction)disconnect{
    [[BLECentralManager sharedInstance] disConnect];
}

-(IBAction)toService:(id)sender{
    [self.navigationController pushViewController:[[ServiceViewController alloc]init] animated:YES];
}

#pragma mark - BLEViewDeleate

-(void)updateDataArray:(NSArray *)array{
    NSLog(@"count:%d",array.count);
    dispatch_async(dispatch_get_main_queue(), ^{
        aData = [NSMutableArray arrayWithArray:array];
        [tTableView reloadData];
    });
    
}

@end
