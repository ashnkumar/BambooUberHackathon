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
    [self.delegate requestUberWithReceipt:self.orderNumberLabel.text];
}

- (void)updateCellHeading
{
    //Make the entire receipt touchable
    UIButton *magicbutton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    
    [magicbutton addTarget:self action:@selector(magicButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:magicbutton];
    
    //Add another button on top for requesting an uber - TEST THAT TOUCHES WORK CORRECTLY
    self.requestUberButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 8, 150, 48)];
    [self.requestUberButton setImage:[UIImage imageNamed:@"RequestUberButton"] forState:UIControlStateNormal];
    
    [self.requestUberButton addTarget:self
                               action:@selector(requestUberClicked:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.requestUberButton];

}

- (void)magicButtonPressed:(id)sender
{
    [self.delegate receiptWantsToExpand:self.orderDayDateLabel.text];
}

@end