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
#import "yoyoAFHTTPSessionManager.h"

@interface HomeViewController ()

@end

@implementation HomeViewController {
    NSUserDefaults *defaults;
    __weak IBOutlet UILabel *lblSoldTickets;
    __weak IBOutlet UILabel *lblCheckedIn;
}
@synthesize btnBurger, btnSearch;

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
        
       // [btnSearch setTarget: self.revealViewController];
        //[btnSearch setAction: @selector( revealToggle: )];
        
    }
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    lblCheckedIn.text = @"";
    lblSoldTickets.text = @"";
    lblSoldTickets.transform = CGAffineTransformMakeRotation(3.14/2);
    lblCheckedIn.transform = CGAffineTransformMakeRotation(3.14/2);
    
    if( [[defaults objectForKey:@"workShopNumber"] integerValue] == 1 ){
        self.workShopCover.image = [UIImage imageNamed:@"bg_ws01.png"];
        self.workShopTitle.text = @"工作坊 // #1 - 掃化石 + 抱抱恐龍BB";
        
    }else if( [[defaults objectForKey:@"workShopNumber"] integerValue] == 2 ){
        self.workShopCover.image = [UIImage imageNamed:@"bg_ws02.png"];
        self.workShopTitle.text = @"工作坊 // #2 - 化石清修室";
        
    }else{
        self.workShopCover.image = [UIImage imageNamed:@"bg_ws03.png"];
        self.workShopTitle.text = @"工作坊 // #3 - 復活任務";
        
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    lblCheckedIn.text = [defaults objectForKey:@"CHECKED_IN_TICKETS"];
    lblSoldTickets.text = [defaults objectForKey:@"SOLD_TICKETS"];
    //self.navigationItem.title = [defaults objectForKey:@"APP_TITLE"];
    
    UINavigationBar *nav = self.navigationController.navigationBar;
    [nav setBarStyle:UIBarStyleBlack];
    [nav setTintColor:UIColor.yellowColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 124, 28)];
    [imageView setContentMode:UIViewContentModeScaleToFill];
    
    imageView.image = [UIImage imageNamed:@"ic_top_logo.png"];
    
    self.navigationItem.titleView = imageView;
    
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
        [self performSegueWithIdentifier:@"showLanding" sender:self];
    } else {
        //[self eventDetails];
        [self login];
    }
    
    /*
    if(![defaults boolForKey:@"logged"]) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    } else {
        [self eventDetails];
    }*/
    
}

-(void)login
{
    
    NSString *url = [NSString stringWithFormat:@"%@", [defaults objectForKey:@"apiUrl"]];
    NSString *apiKey = [NSString stringWithFormat:@"%@", [defaults objectForKey:@"apiKey"]];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *baseUrl = [NSString stringWithFormat:@"%@/tc-api/%@", url, apiKey];
    NSString *requestedUrl = [NSString stringWithFormat:@"%@/check_credentials?ct_json", baseUrl];
    
    if([NSURL URLWithString:requestedUrl] == nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[defaults objectForKey:@"ERROR"] message:[defaults stringForKey:@"API_KEY_LOGIN_ERROR"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:[defaults objectForKey:@"OK"] style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        
        return;
    }
    NSLog(@"Login URL: %@", requestedUrl);
    
    AFHTTPSessionManager *manager = [yoyoAFHTTPSessionManager sharedManager];//[AFHTTPSessionManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    [manager GET:requestedUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSLog(@"responseObject: %@", responseObject);
        // Store data to user defaults
        if([responseObject[@"pass"] boolValue] == YES) {
            [defaults setObject:url forKey:@"url"];
            [defaults setObject:apiKey forKey:@"apiKey"];
            [defaults setObject:baseUrl forKey:@"baseUrl"];
            [defaults setBool:YES forKey:@"logged"];
            
            NSString *translationURL = [NSString stringWithFormat:@"%@/translation?ct_json", baseUrl];
            [manager GET:translationURL parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                if(responseObject[@"pass"] == nil) {
                    [defaults setObject: responseObject[@"WORDPRESS_INSTALLATION_URL"] forKey:@"WORDPRESS_INSTALLATION_URL"];
                    [defaults setObject: responseObject[@"API_KEY"] forKey:@"API_KEY"];
                    [defaults setObject: responseObject[@"AUTO_LOGIN"] forKey:@"AUTO_LOGIN"];
                    [defaults setObject: responseObject[@"SIGN_IN"] forKey:@"SIGN_IN"];
                    [defaults setObject: responseObject[@"SOLD_TICKETS"] forKey:@"SOLD_TICKETS"];
                    [defaults setObject: responseObject[@"CHECKED_IN_TICKETS"] forKey:@"CHECKED_IN_TICKETS"];
                    [defaults setObject: responseObject[@"HOME_STATS"] forKey:@"HOME_STATS"];
                    [defaults setObject: responseObject[@"LIST"] forKey:@"LIST"];
                    [defaults setObject: responseObject[@"SIGN_OUT"] forKey:@"SIGN_OUT"];
                    [defaults setObject: responseObject[@"CANCEL"] forKey:@"CANCEL"];
                    [defaults setObject: responseObject[@"SEARCH"] forKey:@"SEARCH"];
                    [defaults setObject: responseObject[@"ID"] forKey:@"ID"];
                    [defaults setObject: responseObject[@"PURCHASED"] forKey:@"PURCHASED"];
                    [defaults setObject: responseObject[@"CHECKINS"] forKey:@"CHECKINS"];
                    [defaults setObject: responseObject[@"CHECK_IN"] forKey:@"CHECK_IN"];
                    [defaults setObject: responseObject[@"SUCCESS"] forKey:@"SUCCESS"];
                    [defaults setObject: responseObject[@"SUCCESS_MESSAGE"] forKey:@"SUCCESS_MESSAGE"];
                    [defaults setObject: responseObject[@"OK"] forKey:@"OK"];
                    [defaults setObject: responseObject[@"ERROR"] forKey:@"ERROR"];
                    [defaults setObject: responseObject[@"ERROR_MESSAGE"] forKey:@"ERROR_MESSAGE"];
                    [defaults setObject: responseObject[@"PASS"] forKey:@"PASS"];
                    [defaults setObject: responseObject[@"FAIL"] forKey:@"FAIL"];
                    [defaults setObject: responseObject[@"ERROR_LOADING_DATA"] forKey:@"ERROR_LOADING_DATA"];
                    [defaults setObject: responseObject[@"API_KEY_LOGIN_ERROR"] forKey:@"API_KEY_LOGIN_ERROR"];
                    [defaults setObject: responseObject[@"APP_TITLE"] forKey:@"APP_TITLE"];
                    [defaults setObject: responseObject[@"ERROR_LICENSE_KEY"] forKey:@"ERROR_LICENSE_KEY"];
                    
                    
                    [defaults setBool:YES forKey:@"custom_translations"];
                    [defaults synchronize];
                }
            }failure:^(NSURLSessionTask *task, NSError *error) {} retryCount:5 retryInterval:1.0 progressive:false fatalStatusCodes:@[@401,@403]];
            
            // check for license key
            if([responseObject objectForKey:@"tc_iw_is_pr"] != nil && [responseObject[@"tc_iw_is_pr"] boolValue] == YES) {
                NSString *licenseURL = [NSString stringWithFormat:@"http://update.tickera.com/license/%@/can_access_chrome_app", responseObject[@"license_key"]];
                [manager GET:licenseURL parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                    if([responseObject objectForKey:@"is_valid"] != nil && [responseObject[@"is_valid"] boolValue] == YES) {
                        //[self dismissViewControllerAnimated:YES completion:nil];
                        [self eventDetails];
                    } else {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[defaults objectForKey:@"ERROR"] message:[defaults stringForKey:@"ERROR_LICENSE_KEY"] preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *okAction = [UIAlertAction actionWithTitle:[defaults objectForKey:@"OK"] style:UIAlertActionStyleDefault handler:nil];
                        [alert addAction:okAction];
                        [self presentViewController:alert animated:YES completion:nil];
                        
                        [defaults setBool:NO forKey:@"logged"];
                    }
                }failure:^(NSURLSessionTask *task, NSError *error) {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                    if(httpResponse.statusCode != 403) {
                        //[self dismissViewControllerAnimated:YES completion:nil];
                        
                    } else {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[defaults objectForKey:@"ERROR"] message:[defaults stringForKey:@"ERROR_LICENSE_KEY"] preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *okAction = [UIAlertAction actionWithTitle:[defaults objectForKey:@"OK"] style:UIAlertActionStyleDefault handler:nil];
                        [alert addAction:okAction];
                        [self presentViewController:alert animated:YES completion:nil];
                        
                        [defaults setBool:NO forKey:@"logged"];
                    }
                    
                } retryCount:5 retryInterval:1.0 progressive:false fatalStatusCodes:@[@401,@403]];
            } else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[defaults objectForKey:@"ERROR"] message:[defaults stringForKey:@"API_KEY_LOGIN_ERROR"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:[defaults objectForKey:@"OK"] style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
            
            [defaults setBool:NO forKey:@"logged"];
        }
        [defaults synchronize];
        
    } failure:^(NSURLSessionTask *task, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[defaults objectForKey:@"ERROR"] message:[defaults stringForKey:@"ERROR_LOADING_DATA"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:[defaults objectForKey:@"OK"] style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    } retryCount:5 retryInterval:1.0 progressive:false fatalStatusCodes:@[@401,@403]];
    
}

-(void)eventDetails
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *requestedUrl = [NSString stringWithFormat:@"%@/event_essentials?ct_json", [defaults stringForKey:@"baseUrl"]];
    NSLog(@"Event Detail URL: %@", requestedUrl);
    
    //AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [[yoyoAFHTTPSessionManager sharedManager] GET:requestedUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
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

- (IBAction)btnSearchOnClick:(UIBarButtonItem *)sender {
    __weak HomeViewController *theSelf = self;
    [theSelf performSegueWithIdentifier:@"showTicketList" sender:theSelf];
    
}


@end
