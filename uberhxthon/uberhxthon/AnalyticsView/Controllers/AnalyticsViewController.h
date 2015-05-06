//
//  AnalyticsViewController.h
//  uberhxthon
//
//  Created by Catherine Jue on 4/26/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GraphKit/GraphKit.h>

@interface AnalyticsViewController : UIViewController <GKLineGraphDataSource>
@property (strong, nonatomic) IBOutlet GKLineGraph *graph;

@end
