//
//  routeGenerator.m
//  uberhxthon
//
//  Created by Catherine Jue on 5/6/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import "routeGenerator.h"

@implementation routeGenerator


- (id)init {
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

+ (NSMutableArray *)getRouteAtIndex:(int)index { //Objects of type CLLocation
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    NSString* path;
    
    switch (index) {
        case 1:
        {
            path = [[NSBundle mainBundle] pathForResource:@"route1"
                                                             ofType:@"txt"];
            break;
        }
        case 2:
        {
            path = [[NSBundle mainBundle] pathForResource:@"route2"
                                                   ofType:@"txt"];
            break;
        }
        case 3:
        {
            path = [[NSBundle mainBundle] pathForResource:@"route3"
                                                   ofType:@"txt"];
            break;
        }
        case 4:
        {
            path = [[NSBundle mainBundle] pathForResource:@"route4"
                                                   ofType:@"txt"];
            break;
        }
        default:
            break;
    }
    
    
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    NSArray *lines = [content componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        NSArray *values = [line componentsSeparatedByString:@","];
        double latitude = [[values objectAtIndex:0] doubleValue];
        double longitude = [[values objectAtIndex:1] doubleValue];
        CLLocation *loc = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
        [arr addObject:loc];
    }
    return arr;
}
@end
