//
//  ReceiptObject.m
//  uberhxthon
//
//  Created by Ashwin Kumar on 5/7/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import "ReceiptObject.h"

@implementation ReceiptObject
{
    CLLocationCoordinate2D destination;
}

- (id)initWithOrderNumber:(NSString *)orderNumber
               orderDayDate:(NSString *)orderDayDate
                  orderTime:(NSString *)orderTime
                orderStatus:(NSString *)orderStatus
          destinationName:(NSString *)destinationName
            destinationAddressLine1:(NSString *)destAddrLine1
        destinationAddressLine2:(NSString *)destAddrLine2
         destinationPhone:(NSString *)destinationPhone
             orderDetails:(NSMutableDictionary *)details
              paymentType:(NSString *)paymentType
        paymentLastDigits:(NSString *)paymentFourDigits
{
    if (self = [super init]) {
        self.orderNumber = orderNumber;
        self.orderDayDate = orderDayDate;
        self.orderTime = orderTime;
        self.orderStatus = orderStatus;
        self.destinationName = destinationName;
        self.destinationAddressLine1 = destAddrLine1;
        self.destinationAddressLine2 = destAddrLine2;
        self.destinationPhoneNumber = destinationPhone;
        self.orderDetails = details;
        self.paymentType = paymentType;
        self.paymentLastFourDigits = paymentFourDigits;
    }
    
    return self;
}

- (void)setDestination:(CLLocationCoordinate2D)dest
{
    destination = dest;
}

-(CLLocationCoordinate2D)getDestination
{
    return destination;
}

@end
