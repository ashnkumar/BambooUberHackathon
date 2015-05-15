//
//  SettingsViewController.h
//  uberhxthon
//
//  Created by Catherine Jue on 4/26/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"

//This is actually the receipt table view (rightmost tab)

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *receiptTableView;

@end
