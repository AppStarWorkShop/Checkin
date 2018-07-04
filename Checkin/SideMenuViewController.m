//
//  SideMenuViewController.m
//  Checkin
//
//  Created by Borislav Jagodic on 1/10/15.
//  Copyright (c) 2015 Krooya. All rights reserved.
//

#import "SideMenuViewController.h"
#import "SWRevealViewController.h"
#import "myConstant.h"

@interface SideMenuViewController ()

@end

@implementation SideMenuViewController {
    NSUserDefaults *defaults;
    __weak IBOutlet UILabel *lblHome;
    __weak IBOutlet UILabel *lblList;
    __weak IBOutlet UILabel *lblSignOut;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(!defaults) {
        defaults = [NSUserDefaults standardUserDefaults];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    lblHome.text = [defaults objectForKey:@"HOME_STATS"];
    lblList.text = [defaults objectForKey:@"LIST"];
    lblSignOut.text = [defaults objectForKey:@"SIGN_OUT"];
    self.lblEventTitle.text = [defaults stringForKey:@"eventName"];
    self.lblEventSubtitle.text = [defaults stringForKey:@"eventDateTime"];
    
    /*
    self.workShopTitle1.text = @"掃化石 + 抱抱恐龍BB";
    self.workShopTitle2.text = @"化石清修室";
    self.workShopTitle3.text = @"復活任務";
     */
    self.workShopTitle1.text = @"考古巢穴";
    self.workShopTitle2.text = @"化石清修室";
    self.workShopTitle3.text = @"恐龍解碼任務";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateLabelsWithTitle:(NSString*)title andSubtitle:(NSString*)subtitle
{
}

#pragma mark - Navigation

- (IBAction)workShopMenuOnClick:(UIButton *)sender {

    if( sender.tag == 1 ){
        [defaults setInteger:1 forKey:@"workShopNumber"];
        [defaults setBool:YES forKey:@"logged"];
        //[defaults setValue:@"https://shopsolndemo.com/" forKey:@"apiUrl"];
        //[defaults setValue:@"315D1804" forKey:@"apiKey"];
        [defaults setValue:API_DOMAIN_1 forKey:@"apiUrl"];
        [defaults setValue:@"2A7B217C" forKey:@"apiKey"];
        
        //[self login];
        
    } else if( sender.tag == 2 ){
        [defaults setInteger:2 forKey:@"workShopNumber"];
        [defaults setBool:YES forKey:@"logged"];
        //[defaults setValue:@"https://shopsolndemo.com/" forKey:@"apiUrl"];
        //[defaults setValue:@"315D1804" forKey:@"apiKey"];
        [defaults setValue:API_DOMAIN_1 forKey:@"apiUrl"];
        [defaults setValue:@"935AB3B1" forKey:@"apiKey"];
        
        //[self login];
        
    }else{
        [defaults setInteger:3 forKey:@"workShopNumber"];
        [defaults setBool:YES forKey:@"logged"];
        //[defaults setValue:@"https://shopsolndemo.com/" forKey:@"apiUrl"];
        //[defaults setValue:@"315D1804" forKey:@"apiKey"];
        [defaults setValue:API_DOMAIN_1 forKey:@"apiUrl"];
        [defaults setValue:@"38BD7BA3" forKey:@"apiKey"];
        
        //[self login];
    }
    
    [self performSegueWithIdentifier:@"switchWorkShop" sender:self];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"signOut"]) {
        [defaults setObject:NO forKey:@"autoLogin"];
        [defaults setBool:NO forKey:@"logged"];
        [defaults setObject:@"" forKey:@"apiKey"];
        [defaults synchronize];
    }
}

@end
