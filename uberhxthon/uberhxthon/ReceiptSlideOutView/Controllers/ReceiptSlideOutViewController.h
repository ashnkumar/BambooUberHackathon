//
//  ReceiptSlideOutViewController.h
//  uberhxthon
//
//  Created by Ashwin Kumar on 5/1/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReceiptPanelViewControllerDelegate <NSObject>

- (void)closePanel;
- (void)movePanelUp;
- (void)showRequestUberPopup;
- (void)movePanelOneRow;
- (void)movePanelTwoRows;

// Delegate methods for receipt selection here
@optional
- (void)receiptSelected;
@end

@interface ReceiptSlideOutViewController : UIViewController

@property (nonatomic, assign) id<ReceiptPanelViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *panelUpButton;

- (void)highlightReceiptAtIndexPath:(NSIndexPath *)indexPath;
- (void)removeAllCellBorders;
- (void)fakeReceiptMove:(NSUInteger)section;
- (void)scrollToSecondRow;

@end
