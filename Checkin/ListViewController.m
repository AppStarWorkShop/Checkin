//
//  ListViewController.m
//  Checkin
//
//  Created by Borislav Jagodic on 1/11/15.
//  Copyright (c) 2015 Krooya. All rights reserved.
//

#import "ListViewController.h"
#import "SWRevealViewController.h"
#import "CustomListCell.h"
#import "ListTableViewCell.h"
#import "TicketViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <AFNetworking/AFNetworking.h>
#import "UIScrollView+InfiniteScroll.h"
#import "AFHTTPSessionManager+RetryPolicy.h"
#import "yoyoAFHTTPSessionManager.h"

@interface ListViewController ()
@end

@implementation ListViewController {
    NSMutableArray *listItems;
    NSArray *searchResults;
    NSUserDefaults *defaults;
}
@synthesize /*btnBurger,*/ tblTickets, closeBtn, searchIcon, pageTitle, headerView, pageBg;

- (void)viewDidLoad {
    [super viewDidLoad];

    if(!defaults) {
        defaults = [NSUserDefaults standardUserDefaults];
    }
    
    self.navigationItem.title = [defaults objectForKey:@"APP_TITLE"];
    /*
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [btnBurger setTarget: self.revealViewController];
        [btnBurger setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    */
    searchResults = [NSArray array];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [tblTickets registerNib:[UINib nibWithNibName:@"ListTableViewCell" bundle:nil] forCellReuseIdentifier:@"cellIdentifier"];
    
    listItems = [NSMutableArray array];
    /*
    self.currentPage = 1;
    self.showInfinite = YES;
    */
    [defaults setInteger:1 forKey:@"currentPage"];
    [defaults setBool:YES forKey:@"showInfinite"];
    
    __weak typeof(self) weakSelf = self;

    // Set custom indicator margin
    self.tblTickets.infiniteScrollIndicatorMargin = 40;
    // Set custom trigger offset
    self.tblTickets.infiniteScrollTriggerOffset = 200;
    
    [self.tblTickets addInfiniteScrollWithHandler:^(UITableView *tableView) {
        [weakSelf fetchTickets:^{
            [tableView finishInfiniteScroll];
        }];
    }];

    [self.tblTickets setShouldShowInfiniteScrollHandler:^BOOL(UIScrollView * _Nonnull scrollView) {
        // Only show up to 5 pages then prevent the infinite scroll
        return [[defaults objectForKey:@"showInfinite"] boolValue];//self.showInfinite;
    }];
    
//    [self loadTicketsList];
 
    [self.tblTickets beginInfiniteScroll:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchTickets:(void(^)(void))completion {
    NSInteger itemsPerPage = 50;
    NSInteger currentPage = [[defaults objectForKey:@"currentPage"] integerValue];
    NSString *requestedUrl = [NSString stringWithFormat:@"%@/tickets_info/%ld/%ld/?ct_json", [defaults stringForKey:@"baseUrl"], itemsPerPage, currentPage];
    NSLog(@"Fetch Tickets URL: %@", requestedUrl);
    
    AFHTTPSessionManager *manager = [yoyoAFHTTPSessionManager sharedManager];//[AFHTTPSessionManager manager];
    [manager GET:requestedUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        unsigned int i;
        
        if ([responseObject count] > 0) {
            NSMutableArray *dataObject = [responseObject mutableCopy];
            [dataObject removeObjectAtIndex:[responseObject count]-1];
            if([dataObject count] == itemsPerPage) {
                NSInteger currentPage = [[defaults objectForKey:@"currentPage"] integerValue];
                currentPage += 1;
                [defaults setInteger:currentPage forKey:@"currentPage"];
                [defaults setBool:YES forKey:@"showInfinite"];
                
            } else {
                [defaults setBool:NO forKey:@"showInfinite"];

            }
            
            for (i=0; i < [dataObject count]-1; i++) {
                NSMutableDictionary *tempData = [dataObject objectAtIndex:i];
                NSMutableDictionary *tempObj = [tempData[@"data"] mutableCopy];
                
                [tempObj setValue:[NSString stringWithFormat:@"%@ %@", tempObj[@"buyer_first"], tempObj[@"buyer_last"]] forKey:@"name"];
                [listItems addObject:tempObj];
                    
            }
        }
        [tblTickets reloadData];
        if(completion) {
            completion();
        }
    } failure:^(NSURLSessionTask *task, NSError *error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[defaults objectForKey:@"ERROR"] message:[defaults objectForKey:@"ERROR_LOADING_DATA"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:[defaults objectForKey:@"OK"] style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
        } retryCount:5 retryInterval:1.0 progressive:false fatalStatusCodes:@[@401, @403]];
//            [[UIApplication sharedApplication] stopNetworkActivity];
}

#pragma mark - Table methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
    } else {
        return [listItems count];
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"cellIdentifier";
    ListTableViewCell *cell = (ListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ListTableViewCell" owner:self options:nil];
//        cell = [[ListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MyCustomCellNib" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    
    NSDictionary *ticketDict;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        ticketDict = [searchResults objectAtIndex:indexPath.row];
    } else {
        ticketDict = [listItems objectAtIndex:indexPath.row];
    }
        
    cell.lblName.text = [NSString stringWithFormat:@"%@", ticketDict[@"name"]];
    cell.lblId.text = ticketDict[@"transaction_id"];
    cell.lblDate.text = ticketDict[@"payment_date"];
    
    cell.lblStaticId.text = [defaults objectForKey:@"ID"];
    cell.lblStaticPurchased.text = [defaults objectForKey:@"PURCHASED"];
    
    cell.backgroundColor = UIColor.clearColor;
    /*
    if(indexPath.row % 2 == 1) {
        //cell.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:239.0/255.0 blue:242.0/255.0 alpha:1.0];
        
    } else {
        //cell.backgroundColor = [UIColor whiteColor];
    }*/
    
    cell.selectionStyle = UITableViewCellStyleDefault;
    
    
    if ([tableView respondsToSelector:@selector(layoutMargins)]) {
        tableView.layoutMargins = UIEdgeInsetsZero;
    }
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self performSegueWithIdentifier:@"showDetails" sender:nil];
//    }
}

#pragma mark - Search
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    searchResults = [listItems filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if([segue.identifier isEqualToString:@"showDetails"]) {
        NSIndexPath *indexPath = nil;
        NSDictionary *ticketDict = nil;
        if (self.searchDisplayController.active) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            ticketDict = [searchResults objectAtIndex:indexPath.row];
        } else {
            indexPath = [tblTickets indexPathForSelectedRow];
            ticketDict = [listItems objectAtIndex:indexPath.row];
        }
        
        TicketViewController *ticketVC = [segue destinationViewController];
        ticketVC.ticketData = ticketDict;
    }
}
/*
- (IBAction)closeBtnOnClick:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController popViewControllerAnimated:YES];
    
}*/
- (IBAction)close:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
