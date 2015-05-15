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
#import "RTSpinKitView.h"

@interface RequestUberPopupViewController ()
@property (strong, nonatomic) UILabel *requestStatusLabel;
@property (strong, nonatomic) RTSpinKitView *requestingSpinner;
@property (strong, nonatomic) UIImageView *checkView;
@end

@implementation RequestUberPopupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.cornerRadius = 5;
    self.view.layer.masksToBounds = YES;
    
    //TODO: make this dynamic to the frame of iPad
    self.requestStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 7, 200, 40)];
    self.requestStatusLabel.font = [UIFont fontWithName:@"OpenSans" size:20.0];
    self.requestStatusLabel.textAlignment = NSTextAlignmentLeft;
    
    self.requestingSpinner = [[RTSpinKitView alloc]
                           initWithStyle:RTSpinKitViewStyleArc
                           color:[AppConstants cashwinGreen]];
    self.requestingSpinner.frame = CGRectMake(20, 7, 20, 20);
    
    [self.view addSubview:self.requestStatusLabel];
    [self.view addSubview:self.requestingSpinner];
    
   // [self performSelector:@selector(uberRequestComplete) withObject:self afterDelay:3.0];
    
}

- (void)setFirstStatus:(NSString *)firstStatus
{
    self.requestStatusLabel.text = firstStatus;
}

- (void)uberRequestComplete:(NSString *)message
{
    self.checkView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 6.5, 40, 40)];
    self.checkView.image = [UIImage imageNamed:@"myCheckBox"];
    [self.requestingSpinner removeFromSuperview];
    [self.view addSubview:self.checkView];
    self.requestStatusLabel.text = message;
    
    [self performSelector:@selector(dismissMyself) withObject:self afterDelay:1.0];
}

- (void)dismissMyself
{
    [self.delegate dismissedRequestUberPopup];
}

@end
