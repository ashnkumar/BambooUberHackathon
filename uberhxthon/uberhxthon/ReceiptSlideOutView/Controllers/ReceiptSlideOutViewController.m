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

@interface ReceiptSlideOutViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dummyReceiptData;

@end

@implementation ReceiptSlideOutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [AppConstants mainAppThemeColor];
    self.dummyReceiptData = @[@"one", @"two", @"three", @"four", @"five"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"ReceiptCell" bundle:nil] forCellWithReuseIdentifier:@"SampleCell"];
    self.view.backgroundColor = [UIColor clearColor];
    
     
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
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dummyReceiptData count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (ReceiptCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ReceiptCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SampleCell"
                                                                       forIndexPath:indexPath];
    
    
    return cell;
}


#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize retVal = CGSizeMake(170, 210);
    return retVal;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 20, 50, 20);
    
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
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
            [cells addObject:[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]];
        }
    }
    return cells;
}


























@end
