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
@property (strong, nonatomic) UICountingLabel *noDeliveries;
@property (strong, nonatomic) UICountingLabel *salePerDelivery;
@property (strong, nonatomic) UICountingLabel *costPerDelivery;
@property (strong, nonatomic) UICountingLabel *noDeliveriesPerHour;
@property (strong, nonatomic) UICountingLabel *orderReceivedToCust;
@property (strong, nonatomic) UICountingLabel *orderReceivedToUber;
@property (strong, nonatomic) UICountingLabel *uberToCust;
@property (strong, nonatomic) UICountingLabel *grossSales;
@end

@implementation AnalyticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:225.0/255.0 green:225.0/255.0 blue:225.0/255.0 alpha:1.0]];
    
    [self _setupLineGraph];
    
    [self _setupBarGraph];
    
    [self setupTickingNums];
    
    [self addPulsingHalosToMap];
    
}

#pragma mark - Cashwin methods
- (void)setupTickingNums {
    
    //Gross Sales
    self.grossSales = [[UICountingLabel alloc]initWithFrame:CGRectMake(770, 125, 150, 50)];
    self.grossSales.textAlignment = NSTextAlignmentCenter;
    self.grossSales.format = @"$%d";
    self.grossSales.method = UILabelCountingMethodLinear;
    self.grossSales.textColor = [AppConstants specialBlack];
    self.grossSales.font = [UIFont fontWithName:@"OpenSans" size:60];
    [self.view addSubview:self.grossSales];
    
    //Number of Deliveries
    self.noDeliveries = [[UICountingLabel alloc]initWithFrame:CGRectMake(770, 240, 150, 50)];
    self.noDeliveries.textAlignment = NSTextAlignmentCenter;
    self.noDeliveries.format = @"%d";
    self.noDeliveries.method = UILabelCountingMethodLinear;
    self.noDeliveries.textColor = [AppConstants specialBlack];
    self.noDeliveries.font = [UIFont fontWithName:@"OpenSans" size:60];
    [self.view addSubview:self.noDeliveries];
    
    //Sale per Delivery
    self.salePerDelivery = [[UICountingLabel alloc]initWithFrame:CGRectMake(100, 450, 150, 50)];
    self.salePerDelivery.textAlignment = NSTextAlignmentCenter;
    self.salePerDelivery.format = @"$%d";
    self.salePerDelivery.method = UILabelCountingMethodLinear;
    self.salePerDelivery.textColor = [AppConstants specialBlack];
    self.salePerDelivery.font = [UIFont fontWithName:@"OpenSans" size:35];
    [self.view addSubview:self.salePerDelivery];
    
    //Cost per Delivery
    self.costPerDelivery = [[UICountingLabel alloc]initWithFrame:CGRectMake(100, 535, 150, 50)];
    self.costPerDelivery.textAlignment = NSTextAlignmentCenter;
    self.costPerDelivery.format = @"$%d";
    self.costPerDelivery.method = UILabelCountingMethodLinear;
    self.costPerDelivery.textColor = [AppConstants specialBlack];
    self.costPerDelivery.font = [UIFont fontWithName:@"OpenSans" size:35];
    [self.view addSubview:self.costPerDelivery];
    
    //Number of Deliveries per Hour
    self.noDeliveriesPerHour = [[UICountingLabel alloc]initWithFrame:CGRectMake(100, 610, 150, 50)];
    self.noDeliveriesPerHour.textAlignment = NSTextAlignmentCenter;
    self.noDeliveriesPerHour.format = @"%d";
    self.noDeliveriesPerHour.method = UILabelCountingMethodLinear;
    self.noDeliveriesPerHour.textColor = [AppConstants specialBlack];
    self.noDeliveriesPerHour.font = [UIFont fontWithName:@"OpenSans" size:35];
    [self.view addSubview:self.noDeliveriesPerHour];
    
    //Order Received to Customer
    self.orderReceivedToCust = [[UICountingLabel alloc]initWithFrame:CGRectMake(770, 450, 150, 50)];
    self.orderReceivedToCust.textAlignment = NSTextAlignmentCenter;
    self.orderReceivedToCust.format = @"%d min.";
    self.orderReceivedToCust.method = UILabelCountingMethodLinear;
    self.orderReceivedToCust.textColor = [AppConstants specialBlack];
    self.orderReceivedToCust.font = [UIFont fontWithName:@"OpenSans" size:35];
    [self.view addSubview:self.orderReceivedToCust];
    
    //Order Received to Uber
    self.orderReceivedToUber = [[UICountingLabel alloc]initWithFrame:CGRectMake(770, 535, 150, 50)];
    self.orderReceivedToUber.textAlignment = NSTextAlignmentCenter;
    self.orderReceivedToUber.format = @"%d min.";
    self.orderReceivedToUber.method = UILabelCountingMethodLinear;
    self.orderReceivedToUber.textColor = [AppConstants specialBlack];
    self.orderReceivedToUber.font = [UIFont fontWithName:@"OpenSans" size:35];
    [self.view addSubview:self.orderReceivedToUber];
    
    //Uber to Customer
    self.uberToCust = [[UICountingLabel alloc]initWithFrame:CGRectMake(770, 610, 150, 50)];
    self.uberToCust.textAlignment = NSTextAlignmentCenter;
    self.uberToCust.format = @"%d min.";
    self.uberToCust.method = UILabelCountingMethodLinear;
    self.uberToCust.textColor = [AppConstants specialBlack];
    self.uberToCust.font = [UIFont fontWithName:@"OpenSans" size:35];
    [self.view addSubview:self.uberToCust];
    
    [self runAnalyticsNums];
}

- (void)runAnalyticsNums {
    [self.grossSales countFrom:0 to:542 withDuration:1.5f];
    [self.noDeliveries countFrom:0 to:8 withDuration:3.0f];
    [self.salePerDelivery countFrom:0 to:68 withDuration:2.0f];
    [self.costPerDelivery countFrom:0 to:14 withDuration:2.0f];
    [self.noDeliveriesPerHour countFrom:0 to:2 withDuration:1.0f];
    [self.orderReceivedToCust countFrom:0 to:57 withDuration:2.0f];
    [self.orderReceivedToUber countFrom:0 to:13 withDuration:2.0f];
    [self.uberToCust countFrom:0 to:44 withDuration:2.0f];
}

- (void)addPulsingHalosToMap {
    for (int i = 0; i < 5; i++)
    {
        UIView *pulsingHaloView;
        PulsingHaloLayer *halo = [PulsingHaloLayer layer];
        switch (i) {
            case 0:
            {
                pulsingHaloView = [[UIView alloc]initWithFrame:CGRectMake(110, 220, 400, 400)];
                halo.radius = 25;
                break;
            }
            case 1:
            {
                pulsingHaloView = [[UIView alloc]initWithFrame:CGRectMake(180, 200, 400, 400)];
                halo.radius = 20;
                break;
            }
            case 2:
            {
                pulsingHaloView = [[UIView alloc]initWithFrame:CGRectMake(190, 135, 400, 400)];
                halo.radius = 40;
                break;
            }
            case 3:
            {
                pulsingHaloView = [[UIView alloc]initWithFrame:CGRectMake(125, 170, 400, 400)];
                halo.radius = 50;
                break;
            }
            case 4:
            {
                pulsingHaloView = [[UIView alloc]initWithFrame:CGRectMake(175, 140, 400, 400)];
                halo.radius = 15;
                break;
            }
            default:
                break;
        }
        halo.animationDuration = 1;
        halo.position = pulsingHaloView.center;
        halo.backgroundColor = [UIColor colorWithRed:86.0/255.0 green:127.0/255.0 blue:184.0/255.0 alpha:1.0f].CGColor; //darkest version of complementaryBlue
        [pulsingHaloView.layer addSublayer:halo];
        [self.view addSubview:pulsingHaloView];
    }
}

#pragma mark - Graphs
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
    return [[@[@4.5, @11.0, @11.0, @11.0] objectAtIndex:index] doubleValue];
}

- (NSString *)titleForLineAtIndex:(NSInteger)index {
    return [self.lineLabels objectAtIndex:index];
}

#pragma mark - GKBarGraphDataSource
- (void)_setupBarGraph {
    self.barData = @[@30, @40, @20, @80, @70, @100];
    self.barLabels = @[@" ", @" ", @" ", @" ", @" ", @" "];
    
    //    self.graphView.barWidth = 22;
    //self.barGraph.barHeight = 190;
    self.barGraph.marginBar = 70;
    self.barGraph.animationDuration = 5;
    
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
