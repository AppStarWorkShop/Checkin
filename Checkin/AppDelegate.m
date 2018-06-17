//
//  AppDelegate.m
//  Checkin
//
//  Created by Borislav Jagodic on 1/10/15.
//  Copyright (c) 2015 Krooya. All rights reserved.
//

#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar_bg.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:58/255 green:58/255 blue:58/255 alpha:1]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor whiteColor], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"Montserrat-Bold" size:12.0], NSFontAttributeName, nil]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"logged"];
    
    if(![defaults boolForKey:@"custom_translations"]) {
        [defaults setValue:@"WORDPRESS INSTALLATION URL" forKey:@"WORDPRESS_INSTALLATION_URL"];
        [defaults setValue:@"API KEY" forKey:@"API_KEY"];
        [defaults setValue:@"AUTO LOGIN" forKey:@"AUTO_LOGIN"];
        [defaults setValue:@"SIGN IN" forKey:@"SIGN_IN"];
        [defaults setValue:@"SOLD TICKETS" forKey:@"SOLD_TICKETS"];
        [defaults setValue:@"CHECK-IN TICKETS" forKey:@"CHECKED_IN_TICKETS"];
        [defaults setValue:@"HOME_STATS" forKey:@"Home - Stats"];
        [defaults setValue:@"LIST" forKey:@"LIST"];
        [defaults setValue:@"SIGN OUT" forKey:@"SIGN_OUT"];
        [defaults setValue:@"CANCEL" forKey:@"CANCEL"];
        [defaults setValue:@"SEARCH" forKey:@"SEARCH"];
        [defaults setValue:@"ID" forKey:@"ID"];
        [defaults setValue:@"PURCHASED" forKey:@"PURCHASED"];
        [defaults setValue:@"CHECK-INS" forKey:@"CHECKINS"];
        [defaults setValue:@"CHECK IN" forKey:@"CHECK_IN"];
        [defaults setValue:@"SUCCESS" forKey:@"SUCCESS"];
        [defaults setValue:@"Ticket has been check-in" forKey:@"SUCCESS_MESSAGE"];
        [defaults setValue:@"OK" forKey:@"OK"];
        [defaults setValue:@"ERROR" forKey:@"ERROR"];
        [defaults setValue:@"Wrong ticket code" forKey:@"ERROR_MESSAGE"];
        [defaults setValue:@"Pass" forKey:@"PASS"];
        [defaults setValue:@"Fail" forKey:@"FAIL"];
        [defaults setValue:@"Error loading data. Please check the URL and API KEY provided" forKey:@"ERROR_LOADING_DATA"];
        [defaults setValue:@"Error. Please check the URL and API KEY provided" forKey:@"API_KEY_LOGIN_ERROR"];
        [defaults setValue:@"Ticket Check-in" forKey:@"APP_TITLE"];
        [defaults setValue:@"License key is not valid. Please contact your administrator." forKey:@"ERROR_LICENSE_KEY"];
        [defaults setBool:NO forKey:@"custom_translations"];
        [defaults synchronize];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //if(![defaults boolForKey:@"autoLogin"]) {
        [defaults setBool:NO forKey:@"logged"];
    //}
}

@end
