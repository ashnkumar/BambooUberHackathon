//
//  AppDelegate.h
//  uberhxthon
//
//  Created by Catherine Jue on 4/26/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHTabBarController.h"
#import "UberKit.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, MHTabBarControllerDelegate, UberKitDelegate>

@property (strong, nonatomic) UIWindow *window;

// CHANGE THIS FOR PRODUCTION /////////
@property BOOL RUN_IN_PRODUCTION;
// CHANGE THIS FOR PRODUCTION /////////

- (void)showInAppBannerWithMessage:(NSString *)message;
@end

