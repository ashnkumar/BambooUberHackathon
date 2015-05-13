//
//  BambooServer.h
//  uberhxthon
//
//  Created by Ashwin Kumar on 5/11/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BambooServer : NSObject

+ (id)sharedInstance;

// Retrieve a list of all receipts from the server as a dictionary
- (void)retrieveReceiptsWithCompletion:(void (^)(NSDictionary *receiptsDictionary))completion;

// Retrieve a list of all ubers from the server as a dictionary
- (void)retrieveUbersWithCompletion:(void (^)(NSDictionary *ubersDictionary))completion;

// Retrieve a status of a single Uber (used when requesting an uber)
- (void)retrieveSingleUberStatusWithOrderNumber:(int)orderNumber
                                     completion:(void (^)(NSString *uberStatus))completion;

// Reset all receipts back to the original JSON dummy data
- (void)resetAllReceipts;

// Clear all ubers
- (void)clearAllUbers;


// Request an UberX in SF (only supported product) with given coordinates
- (void)requestUberWithStartingLatitude:(NSNumber *)startingLatitude
                      startingLongitude:(NSNumber *)startingLongitude
                         endingLatitude:(NSNumber *)endingLatitude
                        endingLongitude:(NSNumber *)endingLongitude
                            orderNumber:(int)orderNumber;


@end
