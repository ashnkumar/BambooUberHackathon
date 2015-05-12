//
//  BambooServer.m
//  uberhxthon
//
//  Created by Ashwin Kumar on 5/11/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import "BambooServer.h"

#import "AFNetworking.h"
#import "ReceiptObject.h"


static NSString * const BaseURLString = @"https://bamboo-app.herokuapp.com/";
static NSString * const ReceiptsPath = @"fake-get-all-receipts";
static NSString * const RequestUberPath = @"fake-request-uber";

@implementation BambooServer

+ (id)sharedInstance {
    static BambooServer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)retrieveReceiptsWithCompletion:(void (^)(NSDictionary *receiptsDictionary))completion
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@", BaseURLString, ReceiptsPath];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSDictionary *results = (NSDictionary *)responseObject;
        
        // Code for making receipt objects
        
//        for (NSString *receiptStatus in [results allKeys]) {
//            NSArray *receiptsForStatus = (NSArray *)results[receiptStatus];
//            for (NSDictionary *receiptDictionary in receiptsForStatus) {
//                ReceiptObject *receiptObj = [[ReceiptObject alloc] initWithOrderNumber:receiptDictionary[@"orderNumber"]
//                                                                          orderDayDate:receiptDictionary[@"orderDayDate"]
//                                                                             orderTime:receiptDictionary[@"orderTime"]
//                                                                           orderStatus:receiptDictionary[@"orderStatus"]];
//            }
//        }
        
        completion(results);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error retrieving receipts"
                                  message:[error localizedDescription]
                                  delegate:nil
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
    [operation start];
}


- (void)requestUberWithStartingLatitude:(NSNumber *)startingLatitude
                      startingLongitude:(NSNumber *)startingLongitude
                         endingLatitude:(NSNumber *)endingLatitude
                        endingLongitude:(NSNumber *)endingLongitude
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"startingLat": startingLatitude,
                             @"startingLon": startingLongitude,
                             @"endingLat": endingLatitude,
                             @"endingLon": endingLongitude};
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", BaseURLString, RequestUberPath];
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"This is what I got: %@", responseObject);
    }
     
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error Requesting Uber"
                                  message:[error localizedDescription]
                                  delegate:nil
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
    
}

@end
