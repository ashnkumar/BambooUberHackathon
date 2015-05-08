//
//  ReceiptCellRequestUber.m
//  uberhxthon
//
//  Created by Ashwin Kumar on 5/8/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import "ReceiptCellRequestUber.h"
#import "AppConstants.h"

@implementation ReceiptCellRequestUber

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Possible animation of border:
    //    http://stackoverflow.com/questions/28113844/how-can-i-animate-border-width-color-of-uicollectionviewcells-during-layout-tr
    
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 3.0f;
    self.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    self.layer.shadowOpacity = 0.5f;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateCellHeading];
}

- (void)requestUberClicked:(id)sender
{
    // @TODO: Change this to actual order number selected
    [self.delegate requestUberForOrderNum:1];
}

- (void)updateCellHeading
{
    self.requestUberButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 8, 150, 48)];
    [self.requestUberButton setImage:[UIImage imageNamed:@"RequestUberButton"] forState:UIControlStateNormal];
    
    [self.requestUberButton addTarget:self
                               action:@selector(requestUberClicked:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.requestUberButton];
}


@end