//
//  LeftmostViewController.m
//  uberhxthon
//
//  Created by Catherine Jue on 4/26/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import "LeftmostViewController.h"

@interface LeftmostViewController ()

@end

@implementation LeftmostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.merchantHome setImage:[UIImage imageNamed:@"merchanthome"]];
    self.uberButton.layer.cornerRadius = 5.0f;
    self.uberButton.clipsToBounds = YES;
    self.squareButton.layer.cornerRadius = 5.0f;
    self.squareButton.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)uberLoginButton:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Logging out not yet supported!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

- (IBAction)squareLoginButton:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Logging out not yet supported!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}
@end
