//
//  ReceiptCellRequestUber.h
//  uberhxthon
//
//  Created by Ashwin Kumar on 5/8/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReceiptCellRequestUberDelegate <NSObject>

- (void)requestUberForOrderNum:(int)orderNum;

@end

@interface ReceiptCellRequestUber : UICollectionViewCell

@property (assign, nonatomic) id<ReceiptCellRequestUberDelegate> delegate;

@property (strong, nonatomic) UIButton *requestUberButton;
@property (weak, nonatomic) IBOutlet UILabel *orderNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderDayDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderTimeLabel;

@end