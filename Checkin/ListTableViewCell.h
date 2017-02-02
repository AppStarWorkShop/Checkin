//
//  ListTableViewCell.h
//  Checkin
//
//  Created by Borislav Jagodic on 6/22/15.
//  Copyright (c) 2015 Krooya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblId;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;

@property (weak, nonatomic) IBOutlet UILabel *lblStaticId;
@property (weak, nonatomic) IBOutlet UILabel *lblStaticPurchased;
@property (weak, nonatomic) IBOutlet UIImageView *imgDetails;
@end
