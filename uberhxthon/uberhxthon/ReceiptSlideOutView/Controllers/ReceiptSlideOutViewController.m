//
//  ReceiptSlideOutViewController.m
//  uberhxthon
//
//  Created by Ashwin Kumar on 5/1/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import "ReceiptSlideOutViewController.h"

#import "AppConstants.h"
#import "ReceiptCell.h"
#import "ReceiptCellRequestUber.h"
#import "ReceiptSectionHeaderView.h"
#import "ReceiptCollectionFlowLayout.h"
#import "ReceiptObject.h"

#define kStatusRequestUber @"requestUber"
#define kStatusUberRequested @"uberRequested"
#define kStatusOutForDelivery @"outForDelivery"
#define kStatusOrderComplete @"deliveryComplete"

@interface ReceiptSlideOutViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ReceiptCellRequestUberDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dummyReceiptData;

- (void)addNewItemInSection:(NSUInteger)section;
- (void)deleteItemAtIndexPath:(NSIndexPath*)indexPath;

- (void)insertSectionAtIndex:(NSUInteger)index;
- (void)deleteSectionAtIndex:(NSUInteger)index;

@end

@implementation ReceiptSlideOutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"ReceiptCell" bundle:nil] forCellWithReuseIdentifier:@"SampleCell"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"ReceiptCellRequestUber" bundle:nil] forCellWithReuseIdentifier:@"SampleCell2"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"ReceiptSectionHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SectionHeaderView"];
    
    
    [self populateDummyReceipts];
    
    
    ReceiptCollectionFlowLayout *layout = [[ReceiptCollectionFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 20.f;
    layout.minimumLineSpacing = 20.f;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(10.f, 20.f, 10.f, 20.f);
    
    layout.itemSize = CGSizeMake(170, 210);
    [layout makeBoring];
    
    self.collectionView.collectionViewLayout = layout;
    
    
}

- (void)populateDummyReceipts
{
    self.dummyReceiptData = [NSMutableArray new];
    //    NSMutableArray *section1Arr = [[NSMutableArray alloc] initWithArray:@[@"58", @"59", @"60"]];
    //    NSMutableArray *section2Arr = [[NSMutableArray alloc] initWithArray:@[@"61", @"62", @"63", @"64"]];
    //    NSMutableArray *section3Arr = [[NSMutableArray alloc] initWithArray:@[@"65", @"66"]];
    //    NSMutableArray *section4Arr = [[NSMutableArray alloc] initWithArray:@[@"65", @"66"]];
    //    [self.dummyReceiptData addObject:section1Arr];
    //    [self.dummyReceiptData addObject:section2Arr];
    //    [self.dummyReceiptData addObject:section3Arr];
    //    [self.dummyReceiptData addObject:section4Arr];
    
    NSMutableArray *requestUberArr = [NSMutableArray new];
    NSMutableArray *uberRequestedArr = [NSMutableArray new];
    NSMutableArray *outForDeliveryArr = [NSMutableArray new];
    NSMutableArray *orderCompleteArr = [NSMutableArray new];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"receiptData" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSArray *receipts = [json objectForKey:@"receipts"];
    
    for (NSDictionary *receiptDic in receipts) {
        NSString *orderNumber  = receiptDic[@"orderNumber"];
        NSString *orderDayDate = receiptDic[@"orderDayDate"];
        NSString *orderTime    = receiptDic[@"orderTime"];
        NSString *orderStatus  = receiptDic[@"orderStatus"];
        
        ReceiptObject *receiptObject = [[ReceiptObject alloc]
                                        initWithOrderNumber:orderNumber
                                        orderDayDate:orderDayDate
                                        orderTime:orderTime
                                        orderStatus:orderStatus];
        
        if ([orderStatus isEqualToString:kStatusRequestUber]) {
            [requestUberArr addObject:receiptObject];
        } else if ([orderStatus isEqualToString:kStatusUberRequested]) {
            [uberRequestedArr addObject:receiptObject];
        } else if ([orderStatus isEqualToString:kStatusOutForDelivery]) {
            [outForDeliveryArr addObject:receiptObject];
        } else if ([orderStatus isEqualToString:kStatusOrderComplete]) {
            [orderCompleteArr addObject:receiptObject];
        }
    }
    
    [self.dummyReceiptData addObject:requestUberArr];
    [self.dummyReceiptData addObject:uberRequestedArr];
    [self.dummyReceiptData addObject:outForDeliveryArr];
    [self.dummyReceiptData addObject:orderCompleteArr];
}

- (IBAction)btnMovePanelUp:(id)sender
{
    UIButton *button = sender;
    switch (button.tag) {
        case 0: {
            [_delegate movePanelToOriginalPosition];
            break;
        }
            
        case 1: {
            [_delegate movePanelUp];
            break;
        }
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView DataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.dummyReceiptData count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSMutableArray *receiptsInSection = self.dummyReceiptData[section];
    return [receiptsInSection count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
         cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    ReceiptObject *receiptObject = self.dummyReceiptData[indexPath.section][indexPath.row];
    NSString *orderStatus = receiptObject.orderStatus;
    
    if ([orderStatus isEqualToString:kStatusRequestUber]) {

        
        ReceiptCellRequestUber *rucell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SampleCell2" forIndexPath:indexPath];
        rucell.orderNumberLabel.text = [NSString stringWithFormat:@"#%@", receiptObject.orderNumber];
        rucell.orderDayDateLabel.text = receiptObject.orderDayDate;
        rucell.orderTimeLabel.text = receiptObject.orderTime;
        rucell.delegate = self;
        cell = rucell;
        
    } else {
        ReceiptCell *rcell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SampleCell" forIndexPath:indexPath];
        
        rcell.orderNumberLabel.text = [NSString stringWithFormat:@"#%@", receiptObject.orderNumber];
        rcell.orderDayDateLabel.text = receiptObject.orderDayDate;
        rcell.orderTimeLabel.text = receiptObject.orderTime;
        
        if ([orderStatus isEqualToString:kStatusUberRequested]) {
            rcell.receiptStatus = AKReceiptStatusUberRequested;
        } else if ([orderStatus isEqualToString:kStatusOutForDelivery]) {
            rcell.receiptStatus = AKReceiptStatusOutForDelivery;
        } else if ([orderStatus isEqualToString:kStatusOrderComplete]) {
            rcell.receiptStatus = AKReceiptStatusDeliveryComplete;
        }
        cell = rcell;
    }

    return cell;
}


#pragma mark - UICollectionViewDelegateFlowLayout
//- (CGSize)collectionView:(UICollectionView *)collectionView
//                  layout:(UICollectionViewLayout *)collectionViewLayout
//  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    CGSize retVal = CGSizeMake(170, 210);
//    return retVal;
//}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 20, 20, 20);
    
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    ReceiptSectionHeaderView *sectionHeaderView = [collectionView
                                                   dequeueReusableSupplementaryViewOfKind:kind
                                                   withReuseIdentifier:@"SectionHeaderView"
                                                   forIndexPath:indexPath];
    switch (indexPath.section) {
        case 0:
            [sectionHeaderView setSectionHeaderTitle:@"Waiting for Pickup"];
            break;
        case 1:
            [sectionHeaderView setSectionHeaderTitle:@"Uber Requested"];
            break;
        case 2:
            [sectionHeaderView setSectionHeaderTitle:@"Out for Delivery"];
            break;
        case 3:
            [sectionHeaderView setSectionHeaderTitle:@"Delivery Complete"];
            break;
            
        default:
            break;
    }
    //    [sectionHeaderView setSectionHeaderTitle:@"Waiting for Pickup"];
    return sectionHeaderView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    // only the height component is used
    return CGSizeMake(50, 50);
}


#pragma mark - Receipt Cell Delegate
- (void)requestUberForOrderNum:(int)orderNum
{
    [self.delegate showRequestUberPopup];
}


#pragma mark - Helpers
- (void)highlightReceiptAtIndexPath:(NSIndexPath *)indexPath
{
    ReceiptCell *cell = (ReceiptCell *)[self.collectionView
                                        cellForItemAtIndexPath:indexPath];
    
    cell.layer.borderWidth = 5;
    cell.layer.borderColor = [AppConstants cashwinGreen].CGColor;
    
}

- (void)removeAllCellBorders
{
    
    NSMutableArray *allCells = [self allCellsInCollectionView];
    
    for (ReceiptCell *cell in allCells) {
        cell.layer.borderColor = nil;
        cell.layer.borderWidth = 0;
    }
}

- (NSMutableArray *)allCellsInCollectionView {
    NSMutableArray *cells = [[NSMutableArray alloc] init];
    for (NSInteger j = 0; j < [self.collectionView numberOfSections]; ++j) {
        for (NSInteger i = 0; i < [self.collectionView numberOfItemsInSection:j]; ++i) {
            ReceiptCell *cell = (ReceiptCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
            
            if (cell) {
                [cells addObject:cell];
            }
            
        }
    }
    return cells;
}

#pragma mark - Object insert/remove

- (void)fakeReceiptMove:(NSUInteger)section
{
    [self.delegate movePanelUpTwoRows];
    ReceiptObject *receiptObject = self.dummyReceiptData[0][0];
    receiptObject.orderStatus = kStatusUberRequested;
    [self.collectionView reloadData];
    [self performSelector:@selector(moveActualReceipt) withObject:self afterDelay:0.4];
}

- (void)moveActualReceipt
{
    NSMutableArray *receiptsInSection = self.dummyReceiptData[0];
    
    if ([receiptsInSection count] > 0) {
        ReceiptObject *receiptToMove = receiptsInSection[0];
        
        if (receiptToMove != nil) {
            [receiptsInSection removeObjectAtIndex:0];
            
            NSMutableArray *receiptsInSecondSection = self.dummyReceiptData[1];
            [receiptsInSecondSection insertObject:receiptToMove atIndex:0];
            
            [self.collectionView moveItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] toIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
        }
    }

}



//- (void)deleteItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSMutableArray *colorNames = self.sectionedColorNames[indexPath.section];
//    [colorNames removeObjectAtIndex:indexPath.item];
//    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
//}
//
//- (void)insertSectionAtIndex:(NSUInteger)index
//{
//    [self.sectionedColorNames insertObject:[NSMutableArray array] atIndex:index];
//
//    // Batch this so the other sections will be updated on completion
//    [self.collectionView performBatchUpdates:^{
//        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:index]];
//    }
//                                  completion:^(BOOL finished) {
//                                      [self.collectionView reloadData];
//                                  }];
//}
//
//- (void)deleteSectionAtIndex:(NSUInteger)index
//{
//    // no checking if section exists - this is somewhat unsafe
//    [self.sectionedColorNames removeObjectAtIndex:index];
//
//    // Batch this so the other sections will be updated on completion
//    [self.collectionView performBatchUpdates:^{
//        [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:index]];
//    }
//                                  completion:^(BOOL finished) {
//                                      [self.collectionView reloadData];
//                                  }];
//    
//}



@end
