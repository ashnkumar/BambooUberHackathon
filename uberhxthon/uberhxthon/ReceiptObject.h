//
//  ReceiptObject.h
//  uberhxthon
//
//  Created by Ashwin Kumar on 5/7/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReceiptObject : NSObject

@property (nonatomic, strong) NSString *orderNumber;
@property (nonatomic, strong) NSString *orderDayDate;
@property (nonatomic, strong) NSString *orderTime;
@property (nonatomic, strong) NSString *orderStatus;

- (id)initWithOrderNumber:(NSString *)orderNumber
               orderDayDate:(NSString *)orderDayDate
                  orderTime:(NSString *)orderTime
                orderStatus:(NSString *)orderStatus;

@end
