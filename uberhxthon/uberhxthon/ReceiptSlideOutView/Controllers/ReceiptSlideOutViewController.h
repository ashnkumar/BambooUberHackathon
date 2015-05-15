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
- (void)movePanelAllUp;
- (void)movePanelOneRow;
- (void)movePanelTwoRows;
- (void)requestedUber;
- (void)expandReceipt:(NSMutableArray *)details;
- (BOOL)isReceiptPanelShowing;
- (void)removeRequestingReceiptStatusVC;
- (float)getUsersLocationLatitude;
- (float)getUsersLocationLongitude;
- (void)updateCarLocations:(NSDictionary *)ubersDictionary;

// Delegate methods for receipt selection here
@optional
- (void)receiptSelected;
@end

@interface ReceiptSlideOutViewController : UIViewController

@property (nonatomic, assign) id<ReceiptPanelViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *panelUpButton;

- (void)highlightReceiptAtIndexPath:(NSIndexPath *)indexPath;
- (void)removeAllCellBorders;
- (void)scrollToOrderNum:(int)orderNum andHighlight:(BOOL)shouldhighlight;
@end
