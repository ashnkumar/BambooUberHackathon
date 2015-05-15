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
#import "LeftmostViewController.h"
#import "BambooServer.h"
#import "JCNotificationCenter.h"
#import "JCNotificationBannerPresenterSmokeStyle.h"
#import "JCNotificationBannerPresenterIOSStyle.h"
#import "JCNotificationBannerPresenterIOS7Style.h"




@interface AppDelegate ()
@property (strong, nonatomic) DeliveryViewController *deliveryVC;
@property (strong, nonatomic) AnalyticsViewController *analyticsVC;
@property (strong, nonatomic) SettingsViewController *settingsVC;
@property (strong, nonatomic) LeftmostViewController *leftVC;
@property (strong, nonatomic) MHTabBarController *tabBarController;


@end

@implementation AppDelegate
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject:nil forKey:@"myUberAccessToken"];


    // CHANGE THIS FOR PRODUCTION /////////
    self.RUN_IN_PRODUCTION = YES;
    // CHANGE THIS FOR PRODUCTION /////////
    
    
    
    // Override point for customization after application launch.
    self.deliveryVC = [[DeliveryViewController alloc]init];
    self.analyticsVC = [[AnalyticsViewController alloc]init];
    self.settingsVC = [[SettingsViewController alloc]init];
    self.leftVC = [[LeftmostViewController alloc]init];
    
    self.leftVC.tabBarItem.image = [UIImage imageNamed:@"Merchant_Icon.png"];
    self.deliveryVC.tabBarItem.image = [UIImage imageNamed:@"Car_Icon.png"];
    self.analyticsVC.tabBarItem.image = [UIImage imageNamed:@"Metrics_Icon.png"];
    self.settingsVC.tabBarItem.image = [UIImage imageNamed:@"Receipt_Icon.png"];
    
    
    NSArray *viewControllers = @[self.leftVC, self.deliveryVC, self.analyticsVC, self.settingsVC];
    self.tabBarController = [[MHTabBarController alloc]init];
    
    self.tabBarController.delegate = self;
    self.tabBarController.viewControllers = viewControllers;
    
    self.tabBarController.selectedIndex = 1;
    
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    [JCNotificationCenter sharedCenter].presenter = [JCNotificationBannerPresenterSmokeStyle new];

    NSString* alert = @"Check the receipt panel for your latest outstanding orders.";
    [JCNotificationCenter
     enqueueNotificationWithTitle:nil
     message:alert
     tapHandler:^{
         NSLog(@"Received tap on notification banner!");
     }];
    
    //Start pinging for receipt updates
    [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(pingForReceiptUpdates) userInfo:nil repeats:YES];
     
    //Start pinging for car location updates
   [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(pingForCarLocations) userInfo:nil repeats:YES];
    
    // To test that BambooServer methods work:
//    [self fakeReceiptsRetrieval];
//    [self fakeUbersRetrieval];
//    [self fakeUberRequest];
//    [self getSingleUber];
//    [self resetAllReceipts];
//    [self clearAllUbers];
//    [self uberRequest];
//    [self getReceiptUpdates];

    return YES;
}

- (void)showInAppBannerWithMessage:(NSString *)message
{
    NSString* alert = message;
    [JCNotificationCenter
     enqueueNotificationWithTitle:nil
     message:alert
     tapHandler:nil];
}

- (void)pingForReceiptUpdates
{
//    NSLog(@"inside pingForReceiptUpdates");
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [[BambooServer sharedInstance]retrieveReceiptUpdatesWithCompletion:^(NSDictionary *receiptUpdatesDic) {
            if (receiptUpdatesDic != nil)
            {
//                NSLog(@"receiptUpdatesDic is not nil");
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [self.deliveryVC receivedReceiptUpdate:receiptUpdatesDic];
                    if (self.tabBarController.selectedIndex == 0 || self.tabBarController.selectedIndex == 2 || self.tabBarController.selectedIndex == 3)
                    {
                        //Display a special notice that something has changed in the delivery view
                        UILocalNotification *notify = [[UILocalNotification alloc]init];
                        notify.fireDate = nil;
                        notify.timeZone = [NSTimeZone defaultTimeZone];
                        notify.repeatInterval = 0;
                        notify.soundName = @"";
                        notify.alertBody = [NSString stringWithFormat:@"%i receipts have updated statuses. Check the delivery view for details.", [receiptUpdatesDic count]];
                        UIApplication *app = [UIApplication sharedApplication];
                        [app scheduleLocalNotification:notify];
                    }
                });
            }
        }];
    });
    
}

- (void)pingForCarLocations
{
//    NSLog(@"inside pingForCarLocations");
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [[BambooServer sharedInstance]retrieveUbersWithCompletion:^(NSDictionary *ubersDictionary) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [self.deliveryVC receivedCarLocationsUpdate:ubersDictionary];
                });
        }];
    });
}

/*- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //if ([application applicationState] == UIApplicationStateActive)
    //{
        // Initialize the alert view.
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:notification.alertBody
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
   // }
}*/

- (void)getReceiptUpdates
{
    [[BambooServer sharedInstance] retrieveReceiptUpdatesWithCompletion:^(NSDictionary *receiptUpdatesDic) {
        NSLog(@"Updates are: %@", receiptUpdatesDic);
    }];
}

- (void)fakeReceiptsRetrieval
{
    [[BambooServer sharedInstance]
        retrieveReceiptsWithCompletion:^(NSDictionary *receiptsDictionary) {
        NSLog(@"Receipts are: %@", receiptsDictionary);
    }];
}

- (void)fakeUbersRetrieval
{
    [[BambooServer sharedInstance]
     retrieveUbersWithCompletion:^(NSDictionary *ubersDictionary) {
         NSLog(@"Ubers are: %@", ubersDictionary);
     }];
}

- (void)fakeUberRequest
{
    [[BambooServer sharedInstance] requestUberWithStartingLatitude:@(37.775871)
                                                 startingLongitude:@(-122.417961)
                                                    endingLatitude:@(37.7860229)
                                                   endingLongitude:@(-122.4413374)
                                                       orderNumber:49
                                                        completion:^(BOOL requestSuccess) {
                                                            if (requestSuccess) {
                                                                NSLog(@"SUCCESSFULLY REQUESTED UBER");
                                                            }
                                                            else {
                                                                NSLog(@"DID NOT SUCCESSFULLY REQUEST UBER");
                                                            }


                                                       }];
}

- (void)uberRequest
{
    [[BambooServer sharedInstance] requestUberWithStartingLatitude:@(37.775871)
                                                 startingLongitude:@(-122.417961)
                                                    endingLatitude:@(37.7860229)
                                                   endingLongitude:@(-122.4413374)
                                                       orderNumber:53
                                                        completion:^(BOOL requestSuccess) {
                                                            NSLog(@"Completed");
                                                        }];
}

- (void)getSingleUber
{
    [[BambooServer sharedInstance] retrieveSingleUberStatusWithOrderNumber:48 completion:^(NSString *uberStatus) {
        NSLog(@"Uber status is %@", uberStatus);
    }];
}

- (void)resetAllReceipts
{
    [[BambooServer sharedInstance] resetAllReceipts];
}

- (void)clearAllUbers
{
    [[BambooServer sharedInstance] clearAllUbers];
}

-(BOOL)mh_tabBarController:(MHTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index
{
//    NSLog(@"mh_tabBarController %@ shouldSelectViewController %@ at index %lu", tabBarController, viewController, index);
    
    // Uncomment this to prevent "Tab 3" from being selected.
    //return (index != 2);
    
    return YES;
}

-(void)mh_tabBarController:(MHTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index
{
//    NSLog(@"mh_tabBarController %@ didSelectViewController %@ at index %lu", tabBarController, viewController, index);
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
    /*UIApplication  *app = [UIApplication sharedApplication];
    NSArray *oldNotifications = [app scheduledLocalNotifications];
    if ([oldNotifications count] > 0)
    {
        [app cancelAllLocalNotifications];
    }*/
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
