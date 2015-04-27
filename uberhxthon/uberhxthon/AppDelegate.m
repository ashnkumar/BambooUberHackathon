//
//  AppDelegate.m
//  uberhxthon
//
//  Created by Catherine Jue on 4/26/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import "AppDelegate.h"
#import "DeliveryViewController.h"
#import "AnalyticsViewController.h"
#import "SettingsViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    DeliveryViewController *deliveryVC = [[DeliveryViewController alloc]init];
    AnalyticsViewController *analyticsVC = [[AnalyticsViewController alloc]init];
    SettingsViewController *settingsVC = [[SettingsViewController alloc]init];
    
    deliveryVC.title = @"DELIVERY";
    analyticsVC.title = @"ANALYTICS";
    settingsVC.title = @"SETTINGS";
    
    /* TODO */
    /*
    deliveryVC.tabBarItem.image = [UIImage imageNamed:@"deliveryIcon"];
    analyticsVC.tabBarItem.image = [UIImage imageNamed:@"analyticsIcon"];
    settingsVC.tabBarItem.image = [UIImage imageNamed:@"settingsIcon"];
    */
    
    
    NSArray *viewControllers = @[deliveryVC, analyticsVC, settingsVC];
    MHTabBarController *tabBarController = [[MHTabBarController alloc]init];
    
    tabBarController.delegate = self;
    tabBarController.viewControllers = viewControllers;
    
    /* Uncomment this to select Tab 2 */
    //tabBarController.selectedIndex = 1;
    
    /* Uncomment this to select Tab 3 */
    //tabBarController.selectedIndex = 2;
    
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

-(BOOL)mh_tabBarController:(MHTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index
{
    NSLog(@"mh_tabBarController %@ shouldSelectViewController %@ at index %lu", tabBarController, viewController, index);
    
    // Uncomment this to prevent "Tab 3" from being selected.
    //return (index != 2);
    
    return YES;
}

-(void)mh_tabBarController:(MHTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index
{
    NSLog(@"mh_tabBarController %@ didSelectViewController %@ at index %lu", tabBarController, viewController, index);
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
}

@end
