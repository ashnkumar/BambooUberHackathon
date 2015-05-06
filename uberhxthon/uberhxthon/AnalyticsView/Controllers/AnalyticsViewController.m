//
//  AnalyticsViewController.m
//  uberhxthon
//
//  Created by Catherine Jue on 4/26/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import "AnalyticsViewController.h"

@interface AnalyticsViewController ()

@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) NSArray *labels;


@end

@implementation AnalyticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:225.0/255.0 green:225.0/255.0 blue:225.0/255.0 alpha:1.0]];
    
    [self _setupExampleGraph];
    
}
    
- (void)_setupExampleGraph {
    
    self.data = @[
                  @[@20, @40, @20, @60, @40, @140, @80],
                  @[@40, @20, @60, @100, @60, @20, @60],
                  @[@80, @60, @40, @160, @100, @40, @110],
                  @[@120, @150, @80, @120, @140, @100, @0],
                  //                  @[@620, @650, @580, @620, @540, @400, @0]
                  ];
    
    self.labels = @[@"Nov", @"Dec", @"Jan", @"Feb", @"Mar", @"Apr", @"May"];
    
    //self.graph = [[GKLineGraph alloc]initWithFrame:CGRectMake(0, 0, 800, 600)];
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
    return [self.data count];
}

- (UIColor *)colorForLineAtIndex:(NSInteger)index {
    id colors = @[[UIColor gk_turquoiseColor],
                  [UIColor gk_peterRiverColor],
                  [UIColor gk_alizarinColor],
                  [UIColor gk_sunflowerColor]
                  ];
    return [colors objectAtIndex:index];
}

- (NSArray *)valuesForLineAtIndex:(NSInteger)index {
    return [self.data objectAtIndex:index];
}

- (CFTimeInterval)animationDurationForLineAtIndex:(NSInteger)index {
    return [[@[@7.3, @7.5, @10.1, @11.0] objectAtIndex:index] doubleValue];
}

- (NSString *)titleForLineAtIndex:(NSInteger)index {
    return [self.labels objectAtIndex:index];
}

@end
