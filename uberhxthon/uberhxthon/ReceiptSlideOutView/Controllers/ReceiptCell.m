//
//  ReceiptCell.m
//  uberhxthon
//
//  Created by Ashwin Kumar on 5/3/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import "ReceiptCell.h"
#import "AppConstants.h"

@implementation ReceiptCell

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

- (void)updateCellHeading
{
    UIView *cellBanner = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 170, 50)];
    UILabel *cellBannerText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 170, 50)];
    cellBannerText.textColor = [UIColor whiteColor];
    cellBannerText.textAlignment = NSTextAlignmentCenter;
    cellBannerText.font = [UIFont fontWithName:@"OpenSans" size:18.0];

    if (self.receiptStatus == AKReceiptStatusUberRequested) {
    cellBanner.backgroundColor = [AppConstants receiptPink];
    cellBannerText.text = @"Uber Requested";
    }

    else if (self.receiptStatus == AKReceiptStatusOutForDelivery) {
    cellBanner.backgroundColor = [AppConstants receiptBlue];
    cellBannerText.text = @"Out for Delivery";
    }

    else if (self.receiptStatus == AKReceiptStatusDeliveryComplete) {
    cellBanner.backgroundColor = [AppConstants receiptGreen];
    cellBannerText.text = @"Delivery Complete";
    }
    
    else
    {
        NSLog(@"receipt cell didn't have a status upon initialization");
    }

    [self.contentView addSubview:cellBanner];
    [self.contentView addSubview:cellBannerText];
    
    
    UIButton *magicbutton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    
    [magicbutton addTarget:self action:@selector(magicButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:magicbutton];
}

- (void)magicButtonPressed:(id)sender
{
    if ([self.orderNumberLabel.text length] > 1)
    {
        NSString *orderNumberStripped = [self.orderNumberLabel.text substringFromIndex:1];
        [self.delegate receiptWantsToExpand:orderNumberStripped];
    }
    else
    {
        NSLog(@"error in order number label inside magic button pressed");
    }
}


@end
