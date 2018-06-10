//
//  ListViewController.h
//  Checkin
//
//  Created by Borislav Jagodic on 1/11/15.
//  Copyright (c) 2015 Krooya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblTickets;
//@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnBurger;

//@property (weak, nonatomic) NSInteger currentPage;
//@property (weak, nonatomic) BOOL showInfinite;
@end
