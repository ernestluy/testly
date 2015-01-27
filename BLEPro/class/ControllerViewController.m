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
@property (nonatomic, weak) IBOutlet UIButton *btnBack;
@end

@implementation ControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.ac startAnimating];
    self.ac.hidden = NO;
    
    

    
    [self.btnBack setTitleColor:_rgb2uic(0x555555, 1) forState:UIControlStateNormal];
    [self.btnBack setBackgroundColor:[UIColor whiteColor]];
    self.btnBack.layer.borderWidth = 1;
    self.btnBack.layer.borderColor = _rgb2uic(0xd7d7d7, 1).CGColor;
    self.btnBack.layer.cornerRadius = 4;
    
    [self.btnShoot setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnShoot setBackgroundColor:_rgb2uic(0x1bbbfe, 1)];
    self.btnShoot.layer.cornerRadius = 4;
    
    NSString *reqSysVer = @"7.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    if (osVersionSupported) {
        NSTextStorage* textStorage = [[NSTextStorage alloc] init];
        NSLayoutManager* layoutManager = [NSLayoutManager new];
        [textStorage addLayoutManager:layoutManager];
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.view.bounds.size];
        [layoutManager addTextContainer:textContainer];
//        self.textView.textContainer = textContainer;
        self.textView.hidden = YES;
        [self.textView removeFromSuperview];
        
        UITextView *tv = [[UITextView alloc] initWithFrame:self.textView.frame
                                            textContainer:textContainer];
        self.textView = tv;
//        self.textView.hidden = YES;
        [self.view addSubview:self.textView];
        // if using ARC, remove these 3 lines
        //        [textContainer release];
        //        [layoutManager release];
        //        [textStorage release];
    }

    self.textView.text = @"正在搜索可受控制的拍照设备";
    self.textView.editable = NO;
    //    self.textView.backgroundColor = [UIColor lightGrayColor];
    self.textView.layer.borderWidth = 1;
    self.textView.layer.borderColor = _rgb2uic(0xd7d7d7, 1).CGColor;
    self.textView.layer.cornerRadius = 4;
    self.textView.delegate = self;
    
    self.btnShoot.enabled = NO;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setOffset];
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
    [self btnDisconnect:nil];
    [Single sharedInstance].deviceType = DeviceNormal;
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(IBAction)startAction:(id)sender{
    [BLECentralManager sharedInstance].isActive = YES;
    [BLECentralManager sharedInstance].delegate = self;
    [[BLECentralManager sharedInstance] beginScan];
}
-(IBAction)btnDisconnect:(id)sender{
//    [self updateTextViewOffset:@"哈哈"];
    [BLECentralManager sharedInstance].isActive = NO;
    [[BLECentralManager sharedInstance] disConnect];
}
-(IBAction)shootAction:(id)sender{
    NSLog(@"shootAction");
    [[BLECentralManager sharedInstance] sendData:@{@"code":CNUMBER(Cus_Ctl_Shoot)}];
    [self updateTextViewOffset:@"  拍照成功"];
    [[Single sharedInstance] playShootVoice];
}


-(void)updateTextViewOffset:(NSString *)str{
    NSLog(@"updateTextViewOffset");
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"\nyyyy-MM-dd HH:mm:ss-"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSString *tmpStr =  self.textView.text;
    tmpStr = [tmpStr stringByAppendingString:currentDateStr];//
    self.textView.text = [tmpStr stringByAppendingString:str];
//    int diff = self.textView.contentSize.height - self.textView.frame.size.height;
//    if (self.textView.contentSize.height >self.textView.frame.size.height) {
//        CGPoint p = CGPointMake(0, -diff);
//        [self.textView setContentOffset:p animated:NO];
//    }
//    [self setOffset];
    self.textView .contentOffset = CGPointMake(0, MAX(self.textView .contentSize.height - self.textView .frame.size.height,0)+10);
//    [self scrollOutputToBottom];
    NSLog(@"end");
}
-(void)setOffset{
    NSLog(@"setOffset");
    self.textView .contentOffset = CGPointMake(0, MAX(self.textView .contentSize.height - self.textView .frame.size.height,0));
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
#pragma mark - UITextViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSLog(@"offset:%d",(int)scrollView.contentOffset.y);
}

#pragma mark - BLECentralManagerDeleate
-(void)connectSuccess:(BLECentralManager*)bm{
    [self updateTextViewOffset:@"已经成功连接到可拍照设备，可以开始拍照"];
    [self.ac stopAnimating];
    self.ac.hidden = YES;
    self.btnShoot.enabled = YES;
}
-(void)disconnect:(BLECentralManager*)bm{
    [self updateTextViewOffset:@"和拍照设备连接断开，失去控制"];
    [self updateTextViewOffset:@"重新搜索拍照设备"];
    [self.ac startAnimating];
    self.ac.hidden = NO;
    self.btnShoot.enabled = NO;
}
-(void)updataCentrelStatus:(NSString *)str{
    if (!str) {
        return;
    }
    [self updateTextViewOffset:str];
}
-(void)updataStatusWithDic:(NSDictionary *)tDic{
    if (tDic&& [tDic objectForKey:@"msg"]) {
        [self updateTextViewOffset:[tDic objectForKey:@"msg"]];
    }
}
@end
