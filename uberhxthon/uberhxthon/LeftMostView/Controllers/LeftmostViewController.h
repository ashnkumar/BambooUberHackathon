//
//  LeftmostViewController.h
//  uberhxthon
//
//  Created by Catherine Jue on 4/26/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftmostViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *merchantHome;
- (IBAction)uberLoginButton:(id)sender;
- (IBAction)squareLoginButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *uberButton;
@property (strong, nonatomic) IBOutlet UIButton *squareButton;

@end
