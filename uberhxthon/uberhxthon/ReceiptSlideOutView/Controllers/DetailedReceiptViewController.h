//
//  DetailedReceiptViewController.h
//  uberhxthon
//
//  Created by Catherine Jue on 5/12/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailedReceiptViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *details;
@property (strong, nonatomic) IBOutlet UILabel *orderNumber;
@property (strong, nonatomic) IBOutlet UILabel *orderDate;
@property (strong, nonatomic) IBOutlet UILabel *orderTime;
@property (strong, nonatomic) IBOutlet UILabel *destinationName;
@property (strong, nonatomic) IBOutlet UILabel *destinationPhoneNum;
@property (strong, nonatomic) IBOutlet UILabel *destinationAddressLine1;
@property (strong, nonatomic) IBOutlet UILabel *destinationAddressLine2;
@property (strong, nonatomic) IBOutlet UITableView *orderDetails;
@property (strong, nonatomic) IBOutlet UILabel *paymentType;
@property (strong, nonatomic) IBOutlet UILabel *paymentLastFourDigits;

- (void) layoutDetails:(NSMutableArray *)details;
@end
