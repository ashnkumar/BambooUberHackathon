//
//  ReceiptObject.m
//  uberhxthon
//
//  Created by Ashwin Kumar on 5/7/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import "ReceiptObject.h"

@implementation ReceiptObject

- (id)initWithOrderNumber:(NSString *)orderNumber
               orderDayDate:(NSString *)orderDayDate
                  orderTime:(NSString *)orderTime
                orderStatus:(NSString *)orderStatus
{
    if (self = [super init]) {
        self.orderNumber = orderNumber;
        self.orderDayDate = orderDayDate;
        self.orderTime = orderTime;
        self.orderStatus = orderStatus;
    }
    
    return self;
}


@end
