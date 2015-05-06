//
//  AnalyticsViewController.m
//  uberhxthon
//
//  Created by Catherine Jue on 4/26/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import "AnalyticsViewController.h"

@interface AnalyticsViewController ()

@property (strong, nonatomic) NSArray *lineData;
@property (strong, nonatomic) NSArray *lineLabels;

@property (strong, nonatomic) NSArray *barData;
@property (strong, nonatomic) NSArray *barLabels;


@end

@implementation AnalyticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:225.0/255.0 green:225.0/255.0 blue:225.0/255.0 alpha:1.0]];
    
    [self _setupLineGraph];
    
    [self _setupBarGraph];
    
}
    
- (void)_setupLineGraph {
    
    self.lineData = @[
                  @[@2000, @2000, @3500, @2300, @5500, @5500, @7500],
                  
                  ];
    
    self.lineLabels = @[@" ", @" ", @" ", @" ", @" ", @"", @" "];
    
    self.graph.dataSource = self;
    self.graph.lineWidth = 3.0;
    
    self.graph.valueLabelCount = 6;
    
    [self.graph draw];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - GKLineGraphDataSource

- (NSInteger)numberOfLines {
    return [self.lineData count];
}

- (UIColor *)colorForLineAtIndex:(NSInteger)index {
    id colors = @[[AppConstants complementaryBlue],
                  [AppConstants complementaryBlue],
                  [AppConstants complementaryBlue],
                  [AppConstants complementaryBlue]
                  ];
    return [colors objectAtIndex:index];
}

- (NSArray *)valuesForLineAtIndex:(NSInteger)index {
    return [self.lineData objectAtIndex:index];
}

- (CFTimeInterval)animationDurationForLineAtIndex:(NSInteger)index {
    return [[@[@11.0, @11.0, @11.0, @11.0] objectAtIndex:index] doubleValue];
}

- (NSString *)titleForLineAtIndex:(NSInteger)index {
    return [self.lineLabels objectAtIndex:index];
}

#pragma mark - GKBarGraphDataSource
- (void)_setupBarGraph {
    self.barData = @[@35, @70, @45, @100, @90, @155];
    self.barLabels = @[@" ", @" ", @" ", @" ", @" ", @" "];
    
    //    self.graphView.barWidth = 22;
    //self.barGraph.barHeight = 190;
    self.barGraph.marginBar = 70;
    self.barGraph.animationDuration = 10.0;
    
    self.barGraph.dataSource = self;
    [self.barGraph draw];
        
}

- (NSInteger)numberOfBars {
    return [self.barData count];
}

- (NSNumber *)valueForBarAtIndex:(NSInteger)index {
    return [self.barData objectAtIndex:index];
}

- (CFTimeInterval)animationDurationForBarAtIndex:(NSInteger)index {
    CGFloat percentage = [[self valueForBarAtIndex:index] doubleValue];
    percentage = (percentage / 100);
    return (self.barGraph.animationDuration * percentage);
}

- (UIColor *)colorForBarAtIndex:(NSInteger)index {
    return [AppConstants cashwinGreen];
}
- (UIColor *)colorForBarBackgroundAtIndex:(NSInteger)index {
    return [UIColor clearColor];
    
}

@end
