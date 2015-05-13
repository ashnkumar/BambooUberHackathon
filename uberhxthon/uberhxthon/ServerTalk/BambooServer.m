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
static NSString * const UbersPath = @"fake-get-all-ubers";
static NSString * const RequestUberPath = @"fake-request-uber";
static NSString * const GetSingleUberPath = @"get-single-uber";

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

- (void)retrieveUbersWithCompletion:(void (^)(NSDictionary *ubersDictionary))completion
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@", BaseURLString, UbersPath];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *results = (NSDictionary *)responseObject;
        
        completion(results);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error retrieving ubers"
                                  message:[error localizedDescription]
                                  delegate:nil
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
    [operation start];
}

- (void)retrieveSingleUberStatusWithOrderNumber:(int)orderNumber
                                     completion:(void (^)(NSString *uberStatus))completion
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@", BaseURLString, GetSingleUberPath];
//    NSURL *url = [NSURL URLWithString:urlString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSDictionary *params = @{@"orderNumber":[@(orderNumber) stringValue]};

    
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *uberStatus = responseObject[@"uberStatus"];
        completion(uberStatus);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }];
    
    
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
//                                         initWithRequest:request];
//    
//    operation.responseSerializer = [AFJSONResponseSerializer serializer];
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        NSDictionary *results = (NSDictionary *)responseObject;
//        
//        completion(results);
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        UIAlertView *alertView = [[UIAlertView alloc]
//                                  initWithTitle:@"Error retrieving ubers"
//                                  message:[error localizedDescription]
//                                  delegate:nil
//                                  cancelButtonTitle:@"Ok"
//                                  otherButtonTitles:nil];
//        [alertView show];
//    }];
//    
//    [operation start];
    
}


- (void)requestUberWithStartingLatitude:(NSNumber *)startingLatitude
                      startingLongitude:(NSNumber *)startingLongitude
                         endingLatitude:(NSNumber *)endingLatitude
                        endingLongitude:(NSNumber *)endingLongitude
                            orderNumber:(int)orderNumber
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"startingLatitude": startingLatitude,
                             @"startingLongitude": startingLongitude,
                             @"endingLatitude": endingLatitude,
                             @"endingLongitude": endingLongitude,
                             @"orderNumber": @(orderNumber)};
    
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
