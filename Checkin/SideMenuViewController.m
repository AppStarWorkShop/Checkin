//
//  SideMenuViewController.m
//  Checkin
//
//  Created by Borislav Jagodic on 1/10/15.
//  Copyright (c) 2015 Krooya. All rights reserved.
//

#import "SideMenuViewController.h"
#import "SWRevealViewController.h"

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
        
    } else if( sender.tag == 2 ){
        [defaults setInteger:2 forKey:@"workShopNumber"];
        
    }else{
        [defaults setInteger:3 forKey:@"workShopNumber"];
        
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
