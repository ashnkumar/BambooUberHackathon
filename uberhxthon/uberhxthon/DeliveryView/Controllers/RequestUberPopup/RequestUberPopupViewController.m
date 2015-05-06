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
@end

@implementation RequestUberPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.layer.cornerRadius = 5;
    self.view.layer.masksToBounds = YES;
    
    self.requestingSpinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArc
                                                            color:[AppConstants cashwinGreen]];
    self.requestingSpinner.frame = CGRectMake(10, 10, 20, 20);
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect newFrame = CGRectMake(380, 0, 250, 60);
    self.view.frame = newFrame;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIImageView *checkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"myCheckBox"]];
    checkView.frame = CGRectMake(10, 10, 40, 40);
    [self.view addSubview:checkView];
    
    [self.view addSubview:self.requestingSpinner];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
