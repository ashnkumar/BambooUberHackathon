//
//  ReceiptObject.h
//  uberhxthon
//
//  Created by Ashwin Kumar on 5/7/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mapkit/Mapkit.h>


@interface ReceiptObject : NSObject

@property (nonatomic, strong) NSString *orderNumber;
@property (nonatomic, strong) NSString *orderDayDate;
@property (nonatomic, strong) NSString *orderTime;
@property (nonatomic, strong) NSString *orderStatus;
@property (nonatomic, strong) NSString *destinationName;
@property (nonatomic, strong) NSString *destinationAddressLine1;
@property (nonatomic, strong) NSString *destinationAddressLine2;
@property (nonatomic, strong) NSString *destinationPhoneNumber;
@property (nonatomic, strong) NSMutableDictionary *orderDetails;
@property (nonatomic, strong) NSString *paymentType;
@property (nonatomic, strong) NSString *paymentLastFourDigits;

- (id)initWithOrderNumber:(NSString *)orderNumber
             orderDayDate:(NSString *)orderDayDate
                orderTime:(NSString *)orderTime
              orderStatus:(NSString *)orderStatus
          destinationName:(NSString *)destinationName
            destinationAddressLine1:(NSString *)destAddrLine1
            destinationAddressLine2:(NSString *)destAddrLine2
         destinationPhone:(NSString *)destinationPhone
             orderDetails:(NSDictionary *)details
              paymentType:(NSString *)paymentType
        paymentLastDigits:(NSString *)paymentFourDigits;
- (void)setDestination:(CLLocationCoordinate2D)dest;
- (CLLocationCoordinate2D)getDestination;
@end
