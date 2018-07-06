//
//  ScannerViewController.m
//  Checkin
//
//  Created by Borislav Jagodic on 1/13/15.
//  Copyright (c) 2015 Krooya. All rights reserved.
//

#import "ScannerViewController.h"
#import "TicketViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "AFHTTPSessionManager+RetryPolicy.h"
#import "yoyoAFHTTPSessionManager.h"
#import "myDataManager.h"
#import "myConstant.h"

@interface ScannerViewController ()
    @property (nonatomic, strong) AVCaptureSession *captureSession;
    @property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
    @property (nonatomic, strong) AVAudioPlayer *audioPlayer;

-(void)stopScanning;
-(void)loadBeepSound;
@end

@implementation ScannerViewController {
    NSArray *supportedMetaTypes;
    NSMutableDictionary *checkinData;
    NSUserDefaults *defaults;
    BOOL checkinStatus;
    __weak IBOutlet UINavigationItem *navItem;
}
@synthesize captureSession, videoPreviewLayer, viewPreview, audioPlayer, btnFlash, btnCancel, imgStatusIcon, lblStatusTitle, lblStatusText, buyerEmail, ticketID, ticketIdLabel, ticketDesc, confirmCheckinBtn, cancelCheckinBtn, confirmBtn;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(!defaults) {
        defaults = [NSUserDefaults standardUserDefaults];
    }
    
    //navItem.title = [defaults objectForKey:@"APP_TITLE"];
    [btnCancel setTitle:@"返回"/*[defaults objectForKey:@"CANCEL"]*/ forState:UIControlStateNormal];
    
    supportedMetaTypes = @[
                   AVMetadataObjectTypeQRCode,
                   AVMetadataObjectTypeEAN8Code,
                   AVMetadataObjectTypeEAN13Code,
                   AVMetadataObjectTypeCode93Code,
                   AVMetadataObjectTypeCode39Code,
                   AVMetadataObjectTypeCode39Mod43Code,
                   AVMetadataObjectTypeCode128Code,
                ];
    
    btnCancel.layer.cornerRadius = 4;
    [self loadBeepSound];
    [self startScanning];
}

-(void)viewDidAppear:(BOOL)animated {
    [self continueScanning];
    
    //[self checkTicketTimeWithCode:@"SHK000385"];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    viewPreview.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if(metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        if([supportedMetaTypes containsObject:[metadataObject type]]) {
//            NSLog(@"READ VALUE: %@", [metadataObject stringValue]);
            [self performSelectorOnMainThread:@selector(stopScanning) withObject:nil waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(checkTicketTimeWithCode:/*checkinWithCode:*/) withObject:[metadataObject stringValue] waitUntilDone:NO];
        }
        
        if(audioPlayer) {
            [audioPlayer play];
        }
    }
}
- (IBAction)flashLightToggle:(id)sender {
//    NSLog(@"FLASH LIGHT");
    AVCaptureDevice *flashLight = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([flashLight isTorchAvailable] && [flashLight isTorchModeSupported:AVCaptureTorchModeOn])
    {
        BOOL success = [flashLight lockForConfiguration:nil];
        if (success)
        {
            if ([flashLight isTorchActive])
            {
                [btnFlash setImage:[UIImage imageNamed:@"icon_flashlight_on"] forState:UIControlStateNormal];
                [flashLight setTorchMode:AVCaptureTorchModeOff];
            }
            else
            {
                [btnFlash setImage:[UIImage imageNamed:@"icon_flashlight_off"] forState:UIControlStateNormal];
                [flashLight setTorchMode:AVCaptureTorchModeOn];
            }
            [flashLight unlockForConfiguration];
        }
    }
}

#pragma mark - Scanning

-(BOOL)startScanning {
    btnFlash.enabled = YES;

    NSError *error;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if(!deviceInput) {
        return NO;
    }
    
    captureSession = [[AVCaptureSession alloc] init];
    [captureSession addInput:deviceInput];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:supportedMetaTypes];
    
    videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    [videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    videoPreviewLayer.bounds = self.view.bounds;
    videoPreviewLayer.position = CGPointMake(CGRectGetMinX(self.view.bounds), CGRectGetMinY(self.view.bounds));
    
    videoPreviewLayer.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
//    videoPreviewLayer.frame = viewPreview.layer.bounds;
    [viewPreview.layer addSublayer:videoPreviewLayer];
    
    [captureSession startRunning];
    
        
    return YES;
}

-(void)stopScanning {
    [captureSession stopRunning];
    btnFlash.enabled = NO;
    
//    [videoPreviewLayer removeFromSuperlayer];
}

-(void)continueScanning {
    [captureSession startRunning];
    btnFlash.enabled = YES;
}

-(void)loadBeepSound {
    NSString *beepPath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"];
    NSURL *beepURL = [NSURL URLWithString:beepPath];
    NSError *error;
    
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:beepURL error:&error];
    if(error) {
//        NSLog(@"Could not load Beep file");
//        NSLog(@"%@", [error localizedDescription]);
    } else {
        [audioPlayer prepareToPlay];
    }
}

//- (void)showOverlayWithStatus:(BOOL)status
- (void)showOverlayWithStatus:(NSString*)status
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    //checkinStatus = status;
    //if(status == YES) {
    if([status isEqualToString:@"1"]) {
        imgStatusIcon.image = [UIImage imageNamed:@"ic_popup_success"];
        lblStatusTitle.text = @"門票掃描成功";//[defaults objectForKey:@"SUCCESS"];
        lblStatusText.text = [defaults objectForKey: @"SUCCESS_MESSAGE"];
        checkinStatus = YES;
        
    } else if([status isEqualToString:@"2"]) {
        imgStatusIcon.image = [UIImage imageNamed:@"ic_popup_scanned"];
        lblStatusTitle.text = @"門票已使用";//[defaults objectForKey: @"ERROR"];
        lblStatusText.text = [defaults objectForKey:@"ERROR_MESSAGE"];
        checkinStatus = NO;
        
    } else if([status isEqualToString:@"3"]) {
        imgStatusIcon.image = [UIImage imageNamed:@"ic_popup_due"];
        lblStatusTitle.text = @"門票不属于當前時段,是否仍然使用？";//[defaults objectForKey: @"ERROR"];
        lblStatusText.text = [defaults objectForKey:@"ERROR_MESSAGE"];
        checkinStatus = NO;
        
    } else if([status isEqualToString:@"4"]) {
        imgStatusIcon.image = [UIImage imageNamed:@"ic_popup_scanned"];
        lblStatusTitle.text = @"門票時段格式不正確！請使用新門票！";//[defaults objectForKey: @"ERROR"];
        lblStatusText.text = [defaults objectForKey:@"ERROR_MESSAGE"];
        checkinStatus = NO;
        
    } else if([status isEqualToString:@"5"]) {
        imgStatusIcon.image = [UIImage imageNamed:@"ic_popup_overtime"];
        lblStatusTitle.text = @"門票已過期！";//[defaults objectForKey: @"ERROR"];
        lblStatusText.text = [defaults objectForKey:@"ERROR_MESSAGE"];
        checkinStatus = NO;
        
    } else if([status isEqualToString:@"6"]) {
        imgStatusIcon.image = [UIImage imageNamed:@"ic_popup_due"];
        lblStatusTitle.text = @"門票不属于當前時段！";//[defaults objectForKey: @"ERROR"];
        lblStatusText.text = [defaults objectForKey:@"ERROR_MESSAGE"];
        checkinStatus = NO;
        
    } else {
        imgStatusIcon.image = [UIImage imageNamed:@"ic_popup_scanned"];
        lblStatusTitle.text = [NSString stringWithFormat:@"%@", @"門票信息無效"];//[defaults objectForKey: @"ERROR"];
        self.buyerEmail.text = [NSString stringWithFormat:@"%@%@", @"當前工作區", [defaults objectForKey:@"eventName"]];
        lblStatusText.text = [defaults objectForKey:@"ERROR_MESSAGE"];
        checkinStatus = NO;
        self.ticketID.hidden = YES;
        self.ticketIdLabel.hidden = YES;
    }
    
    [self.viewOverlayWrapper setHidden:NO];
}

-(void)checkTicketTimeWithCode:(NSString*)checksum
{
    if([checksum containsString:@"|"]) {
        NSArray *ticketArray = [checksum componentsSeparatedByString:@"|"];
        checksum = [ticketArray objectAtIndex:[ticketArray count]-1];
    }

    NSString *requestedUrl = [NSString stringWithFormat:@"%@/check_in/%@&?ct_json", [defaults stringForKey:@"baseUrl"], checksum];
    
    if([NSURL URLWithString:requestedUrl] == nil) {
        [self showOverlayWithStatus:@"0"];
        return;
    }
    
    [defaults setValue:checksum forKey:@"ticketCode"];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFHTTPSessionManager *manager = [yoyoAFHTTPSessionManager sharedManager];
    
    [manager GET:API_SERVERTIME parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseServerTimeObject) {
        
        if(responseServerTimeObject[@"server_datetime"] != nil){
            [manager GET:requestedUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                if (![responseObject isKindOfClass:[NSNull class]] && ![responseObject[@"ticketTime"] isEqualToString:@""]) {
                    NSString *dateFromAPI = [responseObject[@"ticketTime"] stringByReplacingOccurrencesOfString:@"(" withString:@""];
                    dateFromAPI = [dateFromAPI stringByReplacingOccurrencesOfString:@")" withString:@""];
                    
                    NSArray *dateItems = [[dateFromAPI stringByReplacingOccurrencesOfString:@" - " withString:@" "] componentsSeparatedByString:@" "];
                    NSString *date = [NSString stringWithFormat:@"%@", [dateItems[1] stringByReplacingOccurrencesOfString:@"-" withString:@"/"]];
                    NSString *time = [NSString stringWithFormat:@"%@", dateItems[2]];
                    
                    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
                    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
                    NSDateFormatter * timeFormatter = [[NSDateFormatter alloc]init];
                    [timeFormatter setDateFormat:@"HH:mm"];
                    
                    if([dateFormatter dateFromString:date] && [timeFormatter dateFromString:time]){
                        NSString *ticketTime = [myDataManager getCurrentSessionPeriod:[NSString stringWithFormat:@"%@ %@", date, time]];
                        NSString *currentTime = [myDataManager getCurrentSessionPeriod:responseServerTimeObject[@"server_datetime"]];
                        NSLog(@"ticket time: %@", ticketTime);
                        NSLog(@"current server time: %@", currentTime);
                        [defaults setValue:[NSString stringWithFormat:@"%@", [ticketTime stringByReplacingOccurrencesOfString:@"%" withString:@" "]] forKey:@"ticketTime"];
                        
                        if ([ticketTime isEqualToString:currentTime]) {
                            [self checkinWithCode:checksum];
                            
                        }else{
                            //need Staff to confirm if let enter, only in the same day can let in
                            self.ticketID.text = @"";
                            self.buyerEmail.text = @"門票適用時段:";
                            self.ticketIdLabel.text = [NSString stringWithFormat:@"%@", [ticketTime stringByReplacingOccurrencesOfString:@"%" withString:@" "]];
                            
                            NSLog(@"ticket Date(d): %@", [dateFormatter dateFromString:date]);
                            NSLog(@"ticket Date(d): %@", [dateFormatter dateFromString:[responseServerTimeObject[@"server_datetime"] componentsSeparatedByString:@" "][0]]);
                            
                            NSLog(@"ticket Date(s): %@", date);
                            NSLog(@"current Date(s): %@", [responseServerTimeObject[@"server_datetime"] componentsSeparatedByString:@" "][0]);
                            NSLog(@"current Date(c): %d", [[[dateFormatter dateFromString:date] earlierDate:[dateFormatter dateFromString:[responseServerTimeObject[@"server_datetime"] componentsSeparatedByString:@" "][0]]] isEqualToDate:[dateFormatter dateFromString:date]]);
                            
                            if([[dateFormatter dateFromString:date] isEqualToDate:[dateFormatter dateFromString:[responseServerTimeObject[@"server_datetime"] componentsSeparatedByString:@" "][0]]]) {
                                self.confirmCheckinBtn.hidden = NO;
                                self.cancelCheckinBtn.hidden = NO;
                                self.confirmBtn.hidden = YES;
                                
                                [self showOverlayWithStatus:@"3"];
                                
                            }else if([[[dateFormatter dateFromString:date] earlierDate:[dateFormatter dateFromString:[responseServerTimeObject[@"server_datetime"] componentsSeparatedByString:@" "][0]]] isEqualToDate:[dateFormatter dateFromString:date]]){
                                [self showOverlayWithStatus:@"5"];
                            
                            }else if([[[dateFormatter dateFromString:date] laterDate:[dateFormatter dateFromString:[responseServerTimeObject[@"server_datetime"] componentsSeparatedByString:@" "][0]]] isEqualToDate:[dateFormatter dateFromString:date]]){
                                [self showOverlayWithStatus:@"6"];
                            
                            }/*else{
                                self.confirmCheckinBtn.hidden = NO;
                                self.cancelCheckinBtn.hidden = NO;
                                self.confirmBtn.hidden = YES;
                                
                                [self showOverlayWithStatus:@"3"];
                            }*/
                        }
                    }else{
                        //need Staff to confirm if let enter
                        self.ticketID.text = @"";
                        self.buyerEmail.text = @"新門票樣式：";
                        self.ticketIdLabel.text = @"考古巢穴 2018-07-03 (16:30 - 16:40)";
                        
                        [self showOverlayWithStatus:@"4"];
                        
                    }
                }
            
            } failure:^(NSURLSessionTask *task, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self showOverlayWithStatus:@"0"];
            }];
        }else{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        
    } failure:^(NSURLSessionTask *task, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self showOverlayWithStatus:@"0"];
    }];
}

-(void)checkinWithCode:(NSString*)checksum
{
    if([checksum containsString:@"|"]) {
        NSArray *ticketArray = [checksum componentsSeparatedByString:@"|"];
        checksum = [ticketArray objectAtIndex:[ticketArray count]-1];
    }
    
    NSString *requestedUrl = [NSString stringWithFormat:@"%@/check_in/%@?ct_json", [defaults stringForKey:@"baseUrl"], checksum];
    NSLog(@"Scan URL: %@", requestedUrl);
    
    if([NSURL URLWithString:requestedUrl] == nil) {
        [self showOverlayWithStatus:@"0"];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFHTTPSessionManager *manager = [yoyoAFHTTPSessionManager sharedManager];//[AFHTTPSessionManager manager];
    
    [manager GET:API_SERVERTIME parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseServerTimeObject) {
        
        if(responseServerTimeObject[@"server_datetime"] != nil){
            [manager GET:requestedUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSLog(@"%@", responseObject);
                self.ticketID.text = checksum;
                checkinData = [responseObject mutableCopy];
                
                if (![responseObject isKindOfClass:[NSNull class]] && [responseObject count] > 0) {
                    NSArray *tempObj = [responseObject[@"custom_fields"] mutableCopy];
                    self.buyerEmail.text = [tempObj objectAtIndex:tempObj.count-1][1];
                    [checkinData setValue:[tempObj objectAtIndex:tempObj.count-1][1] forKey:@"buyerEmail"];
                    
                }
                
                if([responseObject[@"status"] boolValue]) {
                    
                    NSDateFormatter *printFormatter = [[NSDateFormatter alloc] init];
                    [printFormatter setDateFormat:@"dd.MM.yyyy"];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_GB"]];
                    [dateFormatter setDateFormat:@"MMMM dd, yyyy hh:mm a"];
                    NSDate *dateObj = [dateFormatter dateFromString:responseObject[@"payment_date"]];
                    [checkinData setValue:[printFormatter stringFromDate:dateObj] forKey:@"date"];
                    [checkinData setValue:checksum forKey:@"checksum"];
                    
                    [defaults setValue:[checkinData objectForKey:@"checksum"] forKey:@"ticketNo"];
                    [defaults setValue:[checkinData objectForKey:@"buyerEmail"] forKey:@"buyerEmail"];
                    [defaults setValue:responseObject[@"payment_date"] forKey:@"ticketDate"];
                    NSLog(@"%@", defaults);
                    
                    if(![defaults objectForKey:[myDataManager getCurrentSessionPeriod:responseServerTimeObject[@"server_datetime"]]]){
                        [defaults setInteger:1 forKey:[myDataManager getCurrentSessionPeriod:responseServerTimeObject[@"server_datetime"]]];
                        
                    }else{
                        NSInteger TicketsCheckIn = [[defaults objectForKey:[myDataManager getCurrentSessionPeriod:responseServerTimeObject[@"server_datetime"]]] integerValue];
                        TicketsCheckIn += 1;
                        [defaults setInteger:TicketsCheckIn forKey:[myDataManager getCurrentSessionPeriod:responseServerTimeObject[@"server_datetime"]]];
                        
                    }
                    
                    [self showOverlayWithStatus:@"1"];
                    
                } else {
                    
                    [manager GET:[NSString stringWithFormat:@"%@/ticket_checkins/%@?ct_json", [defaults stringForKey:@"baseUrl"], checksum] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                        
                        NSArray *checkinsArray = [[NSArray alloc] initWithArray:responseObject];
                        
                        for(int i=0;i<checkinsArray.count;i++){
                            if([checkinsArray[i][@"data"][@"status"] isEqualToString:@"Pass"]) {
                                self.ticketDesc.text = [NSString stringWithFormat:@"使用時間:%@", checkinsArray[0][@"data"][@"date_checked"]];
                                self.ticketDesc.hidden = NO;
                            }
                        }
                    
                        [checkinData setValue:checksum forKey:@"checksum"];
                        [self showOverlayWithStatus:@"2"];
                        
                    } failure:^(NSURLSessionTask *task, NSError *error) {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[defaults objectForKey:@"ERROR"] message:[defaults objectForKey:@"ERROR_LOADING_DATA"] preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *okAction = [UIAlertAction actionWithTitle:[defaults objectForKey:@"OK"] style:UIAlertActionStyleDefault handler:nil];
                        [alert addAction:okAction];
                        [self presentViewController:alert animated:YES completion:nil];
                    } retryCount:5 retryInterval:1.0 progressive:false fatalStatusCodes:@[@401, @403]];
                    
                }
                
            } failure:^(NSURLSessionTask *task, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self showOverlayWithStatus:@"0"];
            }];
        }else{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        
    } failure:^(NSURLSessionTask *task, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self showOverlayWithStatus:@"0"];
    }];
}

- (IBAction)confirmCheckinOnClick:(UIButton *)sender {
    self.confirmCheckinBtn.hidden = YES;
    self.cancelCheckinBtn.hidden = YES;
    self.confirmBtn.hidden = NO;
    [self.viewOverlayWrapper setHidden:YES];
    self.ticketID.hidden = NO;
    self.ticketIdLabel.hidden = NO;
    self.ticketIdLabel.text = @"門票號碼:";
    
    [self checkinWithCode:[NSString stringWithFormat:@"%@", [defaults objectForKey:@"ticketCode"]]];
}

- (IBAction)cancelCheckinOnClick:(UIButton *)sender {
    self.confirmCheckinBtn.hidden = YES;
    self.cancelCheckinBtn.hidden = YES;
    self.confirmBtn.hidden = NO;
    self.ticketID.hidden = NO;
    self.ticketIdLabel.hidden = NO;
    self.ticketIdLabel.text = @"門票號碼:";
    
    [self.viewOverlayWrapper setHidden:YES];
    [self continueScanning];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showDetails"]) {
        TicketViewController *ticketVC = [segue destinationViewController];
        ticketVC.ticketData = checkinData;
    }

}
- (IBAction)dismissModal:(id)sender {
    [self.viewOverlayWrapper setHidden:YES];
    if (checkinStatus == YES) {
        [self performSegueWithIdentifier:@"showDetails" sender:self];
    } else {
        self.ticketID.hidden = NO;
        self.ticketIdLabel.hidden = NO;
        self.lblStatusText.hidden = YES;
        [self continueScanning];
    }
}

- (IBAction)back:(id)sender {
    [self stopScanning];
    captureSession = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
