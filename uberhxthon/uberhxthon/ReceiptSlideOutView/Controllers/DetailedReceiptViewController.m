//
//  DetailedReceiptViewController.m
//  uberhxthon
//
//  Created by Catherine Jue on 5/12/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import "DetailedReceiptViewController.h"

@interface DetailedReceiptViewController ()
@property (strong, nonatomic) NSDictionary *orderDetailsDict;
@end

@implementation DetailedReceiptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)layoutDetails:(NSMutableArray *)details
{
    //Details array contains: order number, date ordered, time ordered, orderer's name, orderer's address line 1, orderer's address line 2, orderer's phonenumber, order details, paymentType, paymentLastFourDigits
    if ([details count] == 10)
    {
        self.orderNumber.text = details[0];
        self.orderDate.text = details[1];
        self.orderTime.text = details[2];
        self.destinationName.text = details[3];
        self.destinationAddressLine1.text = details[4];
        self.destinationAddressLine2.text = details[5];
        self.destinationPhoneNum.text = details[6];
        //TODO: layout order details, paymentType, paymentLastFourDigits
        self.orderDetailsDict = details[7];
        self.paymentType.text = details[8];
        self.paymentLastFourDigits.text = details[9];
    }
    else
    {
        NSLog(@"order details array doesn't have expected number of parameters inside detailedreceiptviewcontroller's layoutDetails");
    }
}

#pragma mark - TableView
-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.orderDetailsDict count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Todo
    UITableViewCell *test = nil;
    return test;
}

@end
