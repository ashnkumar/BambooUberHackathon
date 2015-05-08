//
//  ReceiptSectionHeaderView.h
//  uberhxthon
//
//  Created by Ashwin Kumar on 5/7/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReceiptSectionHeaderView : UICollectionReusableView

@property (strong, nonatomic) IBOutlet UILabel *sectionHeaderLabel;

- (void)setSectionHeaderTitle:(NSString *)sectionHeaderTitle;

@end
