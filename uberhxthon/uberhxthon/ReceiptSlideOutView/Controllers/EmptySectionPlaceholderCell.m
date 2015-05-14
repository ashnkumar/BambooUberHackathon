//
//  EmptySectionPlaceholderCell.m
//  uberhxthon
//
//  Created by Catherine Jue on 5/13/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import "EmptySectionPlaceholderCell.h"

@implementation EmptySectionPlaceholderCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.borderColor = [UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:0.2f].CGColor;
    self.layer.borderWidth = 3.0f;
}

@end
