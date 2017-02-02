//
//  CustomListCell.m
//  Checkin
//
//  Created by Borislav Jagodic on 1/11/15.
//  Copyright (c) 2015 Krooya. All rights reserved.
//

#import "CustomListCell.h"

@implementation CustomListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {		// Initialization code
        
        // we need a view to place our labels on.
        UIView *myContentView = self.contentView;
        myContentView.backgroundColor = [UIColor whiteColor];
        
        // name label
        self.lblName = [[UILabel alloc] initWithFrame:CGRectMake(8, 6, 200, 20)];
        self.lblName.textColor = [UIColor blackColor];
        self.lblName.font = [UIFont fontWithName:@"Montserrat-Bold" size:16.0f];
        [myContentView addSubview:self.lblName];
        
        // static id label
        self.lblStaticID = [[UILabel alloc] initWithFrame:CGRectMake(8, 28, 16, 15)];
        self.lblStaticID.textColor = [UIColor colorWithRed:188.0/255.0 green:188.0/255.0 blue:188.0/255.0 alpha:1.0];
        self.lblStaticID.font = [UIFont fontWithName:@"Montserrat-Bold" size:12.0f];
        self.lblStaticID.text = [defaults objectForKey:@"ID"];
        [myContentView addSubview:self.lblStaticID];

        // id label
        self.lblID = [[UILabel alloc] initWithFrame:CGRectMake(28, 28, 95, 15)];
        self.lblID.textColor = [UIColor colorWithRed:255.0/255.0 green:84.0/255.0 blue:66.0/255.0 alpha:1.0];
        self.lblID.font = [UIFont fontWithName:@"Montserrat-Bold" size:12.0f];
        [myContentView addSubview:self.lblID];

        // static purchased label
        self.lblStaticPurchased = [[UILabel alloc] initWithFrame:CGRectMake(140, 28, 90, 15)];
        self.lblStaticPurchased.textColor = [UIColor colorWithRed:188.0/255.0 green:188.0/255.0 blue:188.0/255.0 alpha:1.0];
        self.lblStaticPurchased.font = [UIFont fontWithName:@"Montserrat-Bold" size:12.0f];
        self.lblStaticPurchased.text =  [defaults objectForKey:@"Purchased:"];
        [myContentView addSubview:self.lblStaticPurchased];

        // static purchased label
        self.lblDate = [[UILabel alloc] initWithFrame:CGRectMake(220, 28, 70, 15)];
        self.lblDate.textColor = [UIColor colorWithRed:255.0/255.0 green:84.0/255.0 blue:66.0/255.0 alpha:1.0];
        self.lblDate.font = [UIFont fontWithName:@"Montserrat-Bold" size:12.0f];
        [myContentView addSubview:self.lblDate];

        self.imgDetails = [[UIImageView alloc] initWithFrame:CGRectMake(myContentView.layer.frame.size.width-24, 18, 16, 16)];
        self.imgDetails.image = [UIImage imageNamed:@"table_details"];
        [myContentView addSubview:self.imgDetails];
    }
    
    return self;
}

@end
