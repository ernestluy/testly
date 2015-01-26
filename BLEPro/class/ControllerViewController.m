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
@interface ControllerViewController (){
    
}
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *ac;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UIButton *btnShoot;
@end

@implementation ControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.ac startAnimating];
    self.ac.hidden = NO;
    
    
    self.textView.editable = NO;
//    self.textView.backgroundColor = [UIColor lightGrayColor];
    self.textView.layer.borderWidth = 1;
    self.textView.layer.borderColor = _rgb2uic(0xd7d7d7, 1).CGColor;
    self.textView.layer.cornerRadius = 4;
    self.textView.delegate = self;
//    [self.textView scrollsToTop
    
//    [self.btnShoot setTitleColor:_rgb2uic(0x555555, 1) forState:UIControlStateNormal];
//    [self.btnShoot setBackgroundColor:[UIColor whiteColor]];
//    self.btnShoot.layer.borderWidth = 1;
//    self.btnShoot.layer.borderColor = _rgb2uic(0xd7d7d7, 1).CGColor;
//    self.btnShoot.layer.cornerRadius = 4;
    
    [self.btnShoot setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnShoot setBackgroundColor:_rgb2uic(0x1bbbfe, 1)];
    self.btnShoot.layer.cornerRadius = 4;
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
    [self updateTextViewOffset:@"\n哈哈"];
//    [BLECentralManager sharedInstance].isActive = NO;
//    [[BLECentralManager sharedInstance] disConnect];
}
-(IBAction)shootAction:(id)sender{
    NSLog(@"shootAction");
    [[BLECentralManager sharedInstance] sendData:@{@"code":CNUMBER(Cus_Ctl_Shoot)}];
}


-(void)updateTextViewOffset:(NSString *)str{
    self.textView.text = [self.textView.text stringByAppendingString:str];
    int diff = self.textView.contentSize.height - self.textView.frame.size.height;
    if (self.textView.contentSize.height >self.textView.frame.size.height) {
        CGPoint p = CGPointMake(0, -diff);
        [self.textView setContentOffset:p animated:NO];
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
     NSLog(@"textViewShouldBeginEditing");
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSLog(@"shouldChangeTextInRange");
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView{
    NSLog(@"textViewDidChange");
    int diff = textView.contentSize.height - textView.frame.size.height;
    if (textView.contentSize.height >textView.frame.size.height) {
        [textView setContentOffset:CGPointMake(0, diff) animated:YES];
    }
}

#pragma mark - BLECentralManagerDeleate
-(void)connectSuccess:(BLECentralManager*)bm{
    [self.ac stopAnimating];
    self.ac.hidden = YES;
}
@end
