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
@synthesize captureSession, videoPreviewLayer, viewPreview, audioPlayer, btnFlash, btnCancel, imgStatusIcon, lblStatusTitle, lblStatusText;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(!defaults) {
        defaults = [NSUserDefaults standardUserDefaults];
    }
    
    navItem.title = [defaults objectForKey:@"APP_TITLE"];
    [btnCancel setTitle:[defaults objectForKey:@"CANCEL"] forState:UIControlStateNormal];
    
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
            [self performSelectorOnMainThread:@selector(checkinWithCode:) withObject:[metadataObject stringValue] waitUntilDone:NO];
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

- (void)showOverlayWithStatus:(BOOL)status
{
    checkinStatus = status;
    if(status == YES) {
        imgStatusIcon.image = [UIImage imageNamed:@"success"];
        lblStatusTitle.text = [defaults objectForKey:@"SUCCESS"];
        lblStatusText.text = [defaults objectForKey: @"SUCCESS_MESSAGE"];
        
    } else {
        imgStatusIcon.image = [UIImage imageNamed:@"error"];
        lblStatusTitle.text = [defaults objectForKey: @"ERROR"];
        lblStatusText.text = [defaults objectForKey:@"ERROR_MESSAGE"];
    }
    [self.viewOverlayWrapper setHidden:NO];
}

-(void)checkinWithCode:(NSString*)checksum
{
    if([checksum containsString:@"|"]) {
        NSArray *ticketArray = [checksum componentsSeparatedByString:@"|"];
        checksum = [ticketArray objectAtIndex:[ticketArray count]-1];
    }

    NSString *requestedUrl = [NSString stringWithFormat:@"%@/check_in/%@?ct_json", [defaults stringForKey:@"baseUrl"], checksum];
    if([NSURL URLWithString:requestedUrl] == nil) {
        [self showOverlayWithStatus:NO];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:requestedUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
//        NSLog(@"%@", responseObject);
        if([responseObject[@"status"] boolValue]) {
            NSDateFormatter *printFormatter = [[NSDateFormatter alloc] init];
            [printFormatter setDateFormat:@"dd.MM.yyyy"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_GB"]];
            [dateFormatter setDateFormat:@"MMMM dd, yyyy hh:mm a"];
            NSDate *dateObj = [dateFormatter dateFromString:responseObject[@"payment_date"]];
            
            checkinData = [responseObject mutableCopy];
            [checkinData setValue:[printFormatter stringFromDate:dateObj] forKey:@"date"];
            [self showOverlayWithStatus:YES];
        } else {
            [self showOverlayWithStatus:NO];
        }
        
    } failure:^(NSURLSessionTask *task, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self showOverlayWithStatus:NO];
    }];
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
        [self continueScanning];
    }
}

- (IBAction)back:(id)sender {
    [self stopScanning];
    captureSession = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
