//
//  TicketViewController.h
//  Checkin
//
//  Created by Borislav Jagodic on 1/12/15.
//  Copyright (c) 2015 Krooya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TicketViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tblCheckins;
@property (weak, nonatomic) IBOutlet UITableView *tblCustomFields;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckin;
@property (strong, nonatomic) NSDictionary *ticketData;
@property (weak, nonatomic) IBOutlet UIView *viewOverlay;
@property (weak, nonatomic) IBOutlet UIView *viewOverlayWrapper;

@property (weak, nonatomic) IBOutlet UILabel *lblID;
@property (weak, nonatomic) IBOutlet UILabel *lblHolderName;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UIImageView *imgStatusIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblStatusTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblStatusText;


@property (weak, nonatomic) IBOutlet UILabel *ticketNo;
@property (weak, nonatomic) IBOutlet UILabel *buyerEmail;
@property (weak, nonatomic) IBOutlet UILabel *ticketDate;

@property (weak, nonatomic) IBOutlet UILabel *workShopVenue;
@property (weak, nonatomic) IBOutlet UILabel *workShopName;
@property (weak, nonatomic) IBOutlet UILabel *workShopDate;
@property (weak, nonatomic) IBOutlet UILabel *workShopHour;
@property (weak, nonatomic) IBOutlet UILabel *buyerNumber;
@property (weak, nonatomic) IBOutlet UILabel *ticketStatus;

@end
