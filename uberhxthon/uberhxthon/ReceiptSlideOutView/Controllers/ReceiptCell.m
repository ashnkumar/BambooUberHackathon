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

- (void)requestUberClicked:(id)sender
{
    // @TODO: Change this to actual order number selected
    [self.delegate requestUberForOrderNum:1];
}

- (void)updateCellHeading
{
    if (self.receiptStatus == AKReceiptStatusRequestUber) {
        self.requestUberButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 8, 150, 48)];
        [self.requestUberButton setImage:[UIImage imageNamed:@"RequestUberButton"] forState:UIControlStateNormal];
        
        [self.requestUberButton addTarget:self
                                   action:@selector(requestUberClicked:)
                         forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:self.requestUberButton];
    }
    
    else {
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
        
        [self.contentView addSubview:cellBanner];
        [self.contentView addSubview:cellBannerText];
    }
    
    
    
    
    
}


@end
