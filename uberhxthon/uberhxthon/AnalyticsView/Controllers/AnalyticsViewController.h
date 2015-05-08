//
//  AnalyticsViewController.h
//  uberhxthon
//
//  Created by Catherine Jue on 4/26/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphKit.h"
#include "AppConstants.h"
#import "UICountingLabel.h"
#import "PulsingHaloLayer.h"

@interface AnalyticsViewController : UIViewController <GKLineGraphDataSource, GKBarGraphDataSource>
@property (strong, nonatomic) IBOutlet GKLineGraph *graph;
@property (strong, nonatomic) IBOutlet GKBarGraph *barGraph;

@end
