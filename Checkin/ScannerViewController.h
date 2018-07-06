//
//  ScannerViewController.h
//  Checkin
//
//  Created by Borislav Jagodic on 1/13/15.
//  Copyright (c) 2015 Krooya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ScannerViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewPreview;
@property (weak, nonatomic) IBOutlet UIButton *btnFlash;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

@property (weak, nonatomic) IBOutlet UIView *viewOverlayWrapper;
@property (weak, nonatomic) IBOutlet UIImageView *imgStatusIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblStatusTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblStatusText;

@property (weak, nonatomic) IBOutlet UILabel *buyerEmail;
@property (weak, nonatomic) IBOutlet UILabel *ticketID;
@property (weak, nonatomic) IBOutlet UILabel *ticketIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *ticketDesc;

@property (weak, nonatomic) IBOutlet UIButton *confirmCheckinBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelCheckinBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@end
