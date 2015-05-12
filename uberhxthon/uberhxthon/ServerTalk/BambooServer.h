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
// (includes the current status of each receipt)
- (void)retrieveReceiptsWithCompletion:(void (^)(NSDictionary *receiptsDictionary))completion;


// Request an UberX in SF (only supported product) with given coordinates
- (void)requestUberWithStartingLatitude:(NSNumber *)startingLatitude
                      startingLongitude:(NSNumber *)startingLongitude
                         endingLatitude:(NSNumber *)endingLatitude
                        endingLongitude:(NSNumber *)endingLongitude;


@end
