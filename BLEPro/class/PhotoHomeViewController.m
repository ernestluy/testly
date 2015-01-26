//
//  PhotoHomeViewController.m
//  BLEPro
//
//  Created by zzt on 15/1/23.
//  Copyright (c) 2015年 卢一. All rights reserved.
//

#import "PhotoHomeViewController.h"
#import "PublicDefine.h"
#import "AppDelegate.h"
#import "Single.h"
#import "BLEPeripheralManager.h"
#import "BLECentralManager.h"
#import "ControllerViewController.h"
#define TAG_BE_CONTROL  101
#define TAG_TO_CONTROL  102
#define TAG_FIRST_LEVEL 103
#define TAG_STOP_LEVEL  104
@interface PhotoHomeViewController ()
{
    UIImageView *rbImageView;
    UIImageView *animImageView;
    DeviceType dtype;
    
}
@property (nonatomic, strong) AVCaptureManager *captureManager;
@property (nonatomic, weak) IBOutlet UIView *barView;
@property (nonatomic, weak) IBOutlet UIView *statusView;
@property (nonatomic, weak) IBOutlet UIButton *recBtn;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *ac;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *captureAc;
@property (nonatomic, weak) IBOutlet UIButton *btnStop;
@end

@implementation PhotoHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    animImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    rbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - 70, 50, 50)];
    [self.view addSubview:rbImageView];
    UIView*preView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:preView];
    [self.view sendSubviewToBack:preView];
    self.captureManager = [[AVCaptureManager alloc] initWithPreviewView:preView];
    self.captureManager.delegate = self;
    self.ac.hidden = YES;
    self.captureAc.hidden = YES;
    
    
    self.barView.backgroundColor = _rgb2uic(0x595959, 0.6);
    self.statusView.backgroundColor = _rgb2uic(0x595959, 0.6);
    
    self.statusLabel.textColor = [UIColor whiteColor];
    self.statusLabel.numberOfLines = 2;
    self.statusLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    [self.recBtn setTintColor:[UIColor colorWithRed:245./255.
                                              green:51./255.
                                               blue:51./255.
                                              alpha:1.0]];
    [BLEPeripheralManager sharedInstance].delegate = self;
    
    
    self.btnStop.layer.borderWidth = 1;
    self.btnStop.layer.borderColor = [UIColor whiteColor].CGColor;
    self.btnStop.layer.cornerRadius = 2;
    self.btnStop.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)imageCapture:(id)sender{
    self.captureAc.hidden = NO;
    [self.captureAc startAnimating];
    [self.captureManager Captureimage];
}
-(IBAction)homeSetting:(id)sender{
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"请选择设备模式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"作为控制器",@"作为拍摄设备", nil];
    as.tag = TAG_FIRST_LEVEL;
    UIWindow *w =   ((AppDelegate *)[UIApplication sharedApplication].delegate).window;
    [as showInView:w];
}
-(IBAction)stopPer:(id)sender{
    NSLog(@"stopPer");
    self.btnStop.hidden = YES;
    [[BLEPeripheralManager sharedInstance] teardownServer];
    self.statusLabel.text = @"终止被控制";
    self.ac.hidden = YES;
    [self.ac stopAnimating];
    [Single sharedInstance].deviceType = DeviceNormal;
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"index:%d",(int)buttonIndex);
    if (actionSheet.tag == TAG_FIRST_LEVEL) {
        NSLog(@"TAG_FIRST_LEVEL");
        if (0 == buttonIndex) {
            [Single sharedInstance].deviceType = DeviceConroller;
            [self.navigationController pushViewController:[[ControllerViewController alloc]init] animated:YES];
        }else if (1 == buttonIndex){
            [Single sharedInstance].deviceType = DeviceShootPhoto;
            [[BLEPeripheralManager sharedInstance] startupServer];
            self.statusLabel.text = @"正在搜索控制器";
            
            self.btnStop.hidden = NO;
            self.ac.hidden = NO;
            [self.ac startAnimating];
        }
    }else if(TAG_STOP_LEVEL == actionSheet.tag){
        if (0 == buttonIndex) {
            if ([Single sharedInstance].deviceType == DeviceShootPhoto) {
                [[BLEPeripheralManager sharedInstance] teardownServer];
                self.statusLabel.text = @"终止被控制";
                self.ac.hidden = YES;
                [self.ac stopAnimating];
                [Single sharedInstance].deviceType = DeviceNormal;
            }
        }
    }
}
#pragma mark -  BLEPeripheralManagerDeleate
-(void)connectSuccess:(BLEPeripheralManager*)pm{
    self.ac.hidden = YES;
    [self.ac stopAnimating];
}
-(void)disconnect:(BLEPeripheralManager*)pm{
    self.statusLabel.text = @"断开连接,搜索控制器";
    self.ac.hidden = NO;
    [self.ac startAnimating];
}
-(void)updateStatus:(NSString *)str{
    self.statusLabel.text = str;
}
-(void)receiveData:(NSDictionary *)dic{
    if (dic) {
        int ttag = [[dic objectForKey:@"code"] intValue];
        switch (ttag) {
            case Cus_Ctl_Shoot:{
                [self.captureManager Captureimage];
                break;
            }
            case Cus_Normal_Msg:{
                self.statusLabel.text = [dic objectForKey:@"msg"];
                break;
            }
            default:
                break;
        }
    }
}
#pragma mark -  AVCaptureManagerDelegate
- (void)didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
                                      error:(NSError *)error{
    
}
-(void)captureImageEnd:(UIImage*)timg{
    NSLog(@"captureImageEnd");
    self.captureAc.hidden = YES;
    [self.captureAc stopAnimating];
    
    animImageView.frame = self.view.bounds;
    animImageView.image = timg;
    [self.view addSubview:animImageView];
    [UIView animateWithDuration:0.5 animations:^{
        animImageView.frame = rbImageView.frame;
    }completion:^(BOOL finished){
        rbImageView.image = timg;
        [animImageView removeFromSuperview];
    }];
}

@end
