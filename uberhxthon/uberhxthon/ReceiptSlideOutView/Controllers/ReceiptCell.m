//
//  ReceiptCell.m
//  uberhxthon
//
//  Created by Ashwin Kumar on 5/3/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import "ReceiptCell.h"

@implementation ReceiptCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.requestUberButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 8, 150, 48)];
    [self.requestUberButton setImage:[UIImage imageNamed:@"RequestUberButton"] forState:UIControlStateNormal];
    
    [self.requestUberButton addTarget:self
                               action:@selector(requestUberClicked:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.requestUberButton];
    
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 3.0f;
    self.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    self.layer.shadowOpacity = 0.5f;
    
    // Possible animation of border:
    //    http://stackoverflow.com/questions/28113844/how-can-i-animate-border-width-color-of-uicollectionviewcells-during-layout-tr
}

- (void)requestUberClicked:(id)sender
{
    // @TODO: Change this to actual order number selected
    [self.delegate requestUberForOrderNum:1];
}


@end
