//
//  HomeViewController.m
//  Checkin
//
//  Created by Borislav Jagodic on 1/10/15.
//  Copyright (c) 2015 Krooya. All rights reserved.
//

#import "HomeViewController.h"
#import "SWRevealViewController.h"
#import "SideMenuViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "AFHTTPSessionManager+RetryPolicy.h"

@interface HomeViewController ()

@end

@implementation HomeViewController {
    NSUserDefaults *defaults;
    __weak IBOutlet UILabel *lblSoldTickets;
    __weak IBOutlet UILabel *lblCheckedIn;
}
@synthesize btnBurger;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!defaults) {
        defaults = [NSUserDefaults standardUserDefaults];
    }
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [btnBurger setTarget: self.revealViewController];
        [btnBurger setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    lblCheckedIn.text = @"";
    lblSoldTickets.text = @"";
    lblSoldTickets.transform = CGAffineTransformMakeRotation(3.14/2);
    lblCheckedIn.transform = CGAffineTransformMakeRotation(3.14/2);
}

- (void)viewDidAppear:(BOOL)animated
{
    lblCheckedIn.text = [defaults objectForKey:@"CHECKED_IN_TICKETS"];
    lblSoldTickets.text = [defaults objectForKey:@"SOLD_TICKETS"];
    self.navigationItem.title = [defaults objectForKey:@"APP_TITLE"];
    
    [self checkLogin];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

/*
#pragma mark - Navigation
*/
- (void)checkLogin
{
    if(![defaults boolForKey:@"logged"]) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    } else {
        [self eventDetails];
    }
}

-(void)eventDetails
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *requestedUrl = [NSString stringWithFormat:@"%@/event_essentials?ct_json", [defaults stringForKey:@"baseUrl"]];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:requestedUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];

        self.lblSold.text = [NSString stringWithFormat:@"%@", responseObject[@"sold_tickets"]];
        self.lblCheckins.text =  [NSString stringWithFormat:@"%@", responseObject[@"checked_tickets"]];
        
        [defaults setObject:responseObject[@"event_name"] forKey:@"eventName"];
        [defaults setObject:responseObject[@"event_date_time"] forKey:@"eventDateTime"];
        [defaults setObject:responseObject[@"sold_tickets"] forKey:@"soldTickets"];
        [defaults synchronize];
        
    } failure:^(NSURLSessionTask *task, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[defaults objectForKey:@"ERROR"] message:[defaults objectForKey:@"ERROR_LOADING_DATA"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:[defaults objectForKey:@"OK"] style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    } retryCount:5 retryInterval:1.0 progressive:false fatalStatusCodes:@[@401,@403]];
}

@end
