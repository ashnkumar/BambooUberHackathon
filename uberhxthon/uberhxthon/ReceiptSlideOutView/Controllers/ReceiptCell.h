//
//  ReceiptCell.h
//  uberhxthon
//
//  Created by Ashwin Kumar on 5/3/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AKReceiptStatus) {
    AKReceiptStatusRequestUber,
    AKReceiptStatusUberRequested,
    AKReceiptStatusOutForDelivery,
    AKReceiptStatusDeliveryComplete
};

@protocol ReceiptCellDelegate <NSObject>

- (void)receiptWantsToExpand:(NSString *)orderNumber;

@end

@interface ReceiptCell : UICollectionViewCell

@property (assign, nonatomic) id<ReceiptCellDelegate> delegate;

@property (assign, nonatomic) AKReceiptStatus receiptStatus;
@property (weak, nonatomic) IBOutlet UILabel *orderNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderDayDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderTimeLabel;

@end
