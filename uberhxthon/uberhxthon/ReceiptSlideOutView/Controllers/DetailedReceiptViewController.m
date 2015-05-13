//
//  DetailedReceiptViewController.m
//  uberhxthon
//
//  Created by Catherine Jue on 5/12/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import "DetailedReceiptViewController.h"

@interface DetailedReceiptViewController ()

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
    //Details array contains: order number, date ordered, time ordered, orderer's name, orderer's address, orderer's phonenumber, order details
    if ([details count] == 7)
    {
        self.orderNumber.text = details[0];
        self.orderDate.text = details[1];
        self.orderTime.text = details[2];
        self.destinationName.text = details[3];
        //TODO display destination address
        self.destinationPhoneNum.text = details[5];
        //TODO: layout order details, paymentType, paymentLastFourDigits

    }
    else
    {
        NSLog(@"order details array doesn't have correct parameters inside layoutDetails");
    }
}

@end
