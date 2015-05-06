//
//  RequestUberPopupViewController.m
//  uberhxthon
//
//  Created by Ashwin Kumar on 5/5/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import "RequestUberPopupViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "AppConstants.h"
#import "UIColor+CustomColors.h"
#import <SpinKit/RTSpinKitView.h>

@interface RequestUberPopupViewController ()
@property (strong, nonatomic) RTSpinKitView *requestingSpinner;
@property (strong, nonatomic) UIView *checkView;
@end

@implementation RequestUberPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"ViewDidLoad frame is: %@", NSStringFromCGRect(self.view.frame));
    NSLog(@"ViewDidLoad view: %@", self.view);
    
    self.view.layer.cornerRadius = 5;
    self.view.layer.masksToBounds = YES;
    
    
    self.requestingSpinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArc
                                                            color:[AppConstants cashwinGreen]];
    self.requestingSpinner.frame = CGRectMake(10, 10, 20, 20);
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    NSLog(@"ViewWillLayoutSubviews frame is: %@", NSStringFromCGRect(self.view.frame));    
    self.view.frame = CGRectMake(380, 0, 250, 60);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    NSLog(@"ViewWillAppear frame is: %@", NSStringFromCGRect(self.view.frame));
    [self.view addSubview:self.requestingSpinner];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self performSelector:@selector(uberRequestComplete) withObject:self afterDelay:3.0];
}

- (void)uberRequestComplete
{
//    
//    self.checkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"myCheckBox"]];
//    self.checkView.frame = CGRectMake(10, 10, 40, 40);
//    
//    [self.requestingSpinner removeFromSuperview];
//    self.requestStatusLabel.text = @"Uber Requested!";
//    [self.view addSubview:self.checkView];
    
    UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    newView.backgroundColor = [UIColor redColor];
//    [self.view removeFromSuperview];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
