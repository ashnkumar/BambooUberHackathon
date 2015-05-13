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
#import "EmptySectionPlaceholderCell.h"
#import "ReceiptSectionHeaderView.h"
#import "ReceiptCollectionFlowLayout.h"
#import "ReceiptObject.h"
#import "BambooServer.h"

#define kStatusRequestUber @"requestUber"
#define kStatusUberRequested @"uberRequested"
#define kStatusOutForDelivery @"outForDelivery"
#define kStatusOrderComplete @"deliveryComplete"
#define PANELCLOSED 1
#define PANELOPEN 0

@interface ReceiptSlideOutViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ReceiptCellRequestUberDelegate, ReceiptCellDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *receiptData;

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
    
    //Note: should call populateReceipts when database tells me I have new ones
    [self populateReceipts];
    
    
    ReceiptCollectionFlowLayout *layout = [[ReceiptCollectionFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 20.f;
    layout.minimumLineSpacing = 20.f;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(10.f, 20.f, 10.f, 20.f);
    
    layout.itemSize = CGSizeMake(170, 210); //size of receipt cell
    [layout makeBoring]; //default layout appearance
    
    self.collectionView.collectionViewLayout = layout;
}

//?: use this for updating receipts too, or create a separate method?
- (void)populateReceipts
{
    self.receiptData = [NSMutableArray new];
    
    NSMutableArray *requestUberArr = [NSMutableArray new];
    NSMutableArray *uberRequestedArr = [NSMutableArray new];
    NSMutableArray *outForDeliveryArr = [NSMutableArray new];
    NSMutableArray *orderCompleteArr = [NSMutableArray new];

    //Get data from json file here
    /*NSString *filePath = [[NSBundle mainBundle] pathForResource:@"receiptData" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSArray *receipts = [json objectForKey:@"receipts"];*/
    
    [[BambooServer sharedInstance]retrieveReceiptsWithCompletion:^(NSDictionary *receiptsDictionary) {
        NSLog(@"%@", receiptsDictionary);
        for (NSString *receiptKey in [receiptsDictionary allKeys])
        {
            NSDictionary *receiptDic = [receiptsDictionary valueForKey:receiptKey];
            NSString *orderNumber  = receiptDic[@"orderNumber"];
            NSString *orderDayDate = receiptDic[@"orderDayDate"];
            NSString *orderTime    = receiptDic[@"orderTime"];
            NSString *orderStatus  = receiptDic[@"orderStatus"];
            NSString *destLat = receiptDic[@"destinationLatitude"];
            NSString *destLon = receiptDic[@"destinationLongitude"];
            NSString *destAddrLine1 = receiptDic[@"destinationAddressLine1"];
            NSString *destAddrLine2 = receiptDic[@"destinationAddressLine2"];
            NSString *destName = receiptDic[@"destinationName"];
            NSString *destPhone = receiptDic[@"destinationPhoneNum"];
            NSDictionary *orderDeets = receiptDic[@"orderDetails"];
            NSString *payType = receiptDic[@"paymentType"];
            NSString *payDigits = receiptDic[@"paymentLastFourDigits"];
            
            //Parse destLoc into coordinates
            float destLatitude = [destLat floatValue];
            float destLongitude = [destLon floatValue];
            //Instantiate a destination
            CLLocationCoordinate2D destination = CLLocationCoordinate2DMake(destLatitude, destLongitude);
            
            //Instantiate the receipt object with all its parameters
            ReceiptObject *receiptObject = [[ReceiptObject alloc]
                                            initWithOrderNumber:orderNumber
                                            orderDayDate:orderDayDate
                                            orderTime:orderTime
                                            orderStatus:orderStatus
                                            destinationName:destName
                                            destinationAddressLine1:destAddrLine1
                                            destinationAddressLine2:destAddrLine2
                                            destinationPhone:destPhone
                                            orderDetails:orderDeets
                                            paymentType:payType
                                            paymentLastDigits:payDigits];
            
           [receiptObject setDestination:destination];
            
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
        
        [self.receiptData addObject:requestUberArr];
        [self.receiptData addObject:uberRequestedArr];
        [self.receiptData addObject:outForDeliveryArr];
        [self.receiptData addObject:orderCompleteArr];
        [self.collectionView reloadData];
    }];
}

/*- (IBAction)btnMovePanelUp:(id)sender
{
    UIButton *button = sender;
    switch (button.tag) {
        case 0: {
            [_delegate closePanel];
            break;
        }
            
        case 1: {
            [_delegate movePanelAllUp];
            break;
        }
            
        default:
            break;
    }
}*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView DataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.receiptData count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.receiptData[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
         cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    ReceiptObject *receiptObject = self.receiptData[indexPath.section][indexPath.row]; //self.receiptData[2][0];//self.receiptData[indexPath.section][indexPath.row];
    
    //Test to see if there are any objects to display first
    if (receiptObject != nil)
    {
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
            if ([orderStatus isEqualToString:kStatusUberRequested]) {
                rcell.receiptStatus = AKReceiptStatusUberRequested;
            } else if ([orderStatus isEqualToString:kStatusOutForDelivery]) {
                rcell.receiptStatus = AKReceiptStatusOutForDelivery;
            } else if ([orderStatus isEqualToString:kStatusOrderComplete]) {
                rcell.receiptStatus = AKReceiptStatusDeliveryComplete;
            }
            else
            {
                NSLog(@"error with the cell's status inside uicollectionview cellforitem");
            }
            
            rcell.orderNumberLabel.text = [NSString stringWithFormat:@"#%@", receiptObject.orderNumber];
            rcell.orderDayDateLabel.text = receiptObject.orderDayDate;
            rcell.orderTimeLabel.text = receiptObject.orderTime;
            
            rcell.delegate = self;
            cell = rcell;
        }
    }
    else
    {
        //Display the placeholder cell
        EmptySectionPlaceholderCell *rucell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SampleCell2" forIndexPath:indexPath];
        cell = rucell;
    }

    return cell;
}


#pragma mark - UICollectionViewDelegateFlowLayout
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 20, 20, 20);
    
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //TODO: open detailed receipt view
    //Make sure there are items in that index path first
    
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
            [sectionHeaderView setSectionHeaderTitle:@"OutstandingDeliveriesSectionHeader.png"];
            break;
        case 1:
            [sectionHeaderView setSectionHeaderTitle:@"UberRequestedSectionHeader.png"];
            break;
        case 2:
            [sectionHeaderView setSectionHeaderTitle:@"UberEnRouteSectionHeader.png"];
            break;
        case 3:
            [sectionHeaderView setSectionHeaderTitle:@"CompletedDeliveriesSectionHeader.png"];
            break;
            
        default:
            break;
    }
    return sectionHeaderView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    // only the height component is used
    return CGSizeMake(50, 50);
}


#pragma mark - Receipt Cell Delegate
- (ReceiptObject *)findReceiptWithOrderNum:(int)orderNum inSection:(int)requestSection
{
    ReceiptObject *receiptFound = nil;
    NSLog(@"receipt order nums:");
    //TODO: fix with requestSection so don't have to iterate through entire data structure holding receipts
    for (NSMutableArray *arr in self.receiptData)
    {
        for (ReceiptObject *receipt in arr)
        {
            int receiptOrderNum = [receipt.orderNumber intValue];
            NSLog(@"%i ", receiptOrderNum);
            if (receiptOrderNum == orderNum)
            {
                receiptFound = receipt;
                return receiptFound;
            }
        }
    }
    return receiptFound;
}

- (void)requestUberWithReceipt:(NSString *)receipt
{
    //Find the receipt with correct order num
    int orderNum = [receipt intValue];
    
    ReceiptObject *requestedReceipt = [self findReceiptWithOrderNum:orderNum inSection:0];//TODO fix section
    if (requestedReceipt != nil)
    {
        //Send a request for an Uber through Bamboo's server, specifying:
        /*
         product requested
         start latitude, longitude
         final destination latitude, longitude
         */
        NSLog(@"requested an uber successfuly retrieved in receiptslideoutviewcontroller with order num: %@", requestedReceipt.orderNumber);
        
        //Update the Delivery View UI
        //[self.delegate requestedUber];
    }
    else
    {
        NSLog(@"couldn't find uber with specified receipt number in ReceiptSlideOutViewController's requestUberWithReceipt");
    }
}


#pragma mark - Helpers
- (void)highlightReceiptAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Highlighting cell: %@", indexPath);
    ReceiptCell *cell = (ReceiptCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
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
//TODO: use when a receipt's status changes
- (void)moveReceipt:(NSIndexPath *)indexPath
{
    ReceiptObject *receiptObject = self.receiptData[indexPath.section][indexPath.row];
    if (receiptObject != nil)
    {
        //receiptObject's orderStatus should already be moved by this point
        //Reload with the updated receipt's UI
        [self.collectionView reloadData];
        
        //Now perform the receipt's move animation
        [self performSelector:@selector(performMoveReceiptAnimation:) withObject:indexPath afterDelay:0.4];
    }
    else
    {
        NSLog(@"error getting receiptobject in movereceipt");
    }
}

- (void)performMoveReceiptAnimation:(NSIndexPath *)indexPath
{
    NSMutableArray *receiptsInSection = self.receiptData[indexPath.section];
    
    if ([receiptsInSection count] > 0) {
        //Todo: test if grabs the correct receiptObject
        ReceiptObject *receiptToMove = receiptsInSection[indexPath.row];
        
        if (receiptToMove != nil) {
            [receiptsInSection removeObjectAtIndex:indexPath.row]; //todo: test
            
            NSMutableArray *receiptsInSecondSection = self.receiptData[indexPath.section + 1]; //todo: test
            [receiptsInSecondSection insertObject:receiptToMove atIndex:0];
            
            [self.collectionView moveItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.row inSection:indexPath.section] toIndexPath:[NSIndexPath indexPathForItem:0 inSection:indexPath.section + 1]]; //todo:test
        }
        else
        {
            NSLog(@"error getting receiptobject in  performMoveReceiptAnimation");
        }
    }
    else
    {
        NSLog(@"no receipts in indexpath's section inside performMoveReceiptAnimation");
    }
}

- (void)scrollToRow:(int)row
{
    //Note that row is DECREMENTED to account for the correct index (ie whoever calls this method should choose the intuitive, non-CS idea of which row to scroll to)
    
    if ([self.delegate isReceiptPanelShowing])
    {
        //TODO: Test that this works if more than one panel is showing
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:row] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
    else
    {
        [self.delegate movePanelOneRow];
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:row] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
}

#pragma mark - ReceiptDelegate
- (void)receiptWantsToExpand:(NSString *)orderNumber
{
    NSMutableArray *receiptDetails = [[NSMutableArray alloc]init];
    //Get the correct receipt
    ReceiptObject *specifiedReceipt = [self findReceiptWithOrderNum:[orderNumber intValue] inSection:0];//TODO fix
    
    if (specifiedReceipt != nil)
    {
        //Push the info into receiptDetails in the following index order:
        //order number, date ordered, time ordered, orderer's name, orderer's address line 1, orderer's address line 2, orderer's phonenumber, order details
        
        //CLLocation *destAddress = [[CLLocation alloc]initWithLatitude:[specifiedReceipt getDestination].latitude longitude:[specifiedReceipt getDestination].longitude];
        
        [receiptDetails addObject:specifiedReceipt.orderNumber];
        [receiptDetails addObject:specifiedReceipt.orderDayDate];
        [receiptDetails addObject:specifiedReceipt.orderTime];
        [receiptDetails addObject:specifiedReceipt.destinationName];
        [receiptDetails addObject:specifiedReceipt.destinationAddressLine1];
        [receiptDetails addObject:specifiedReceipt.destinationAddressLine2];
        [receiptDetails addObject:specifiedReceipt.destinationPhoneNumber];
        //Todo: make sure that orderDetails is okay, since it's a mutable dictionary!!
        [receiptDetails addObject:specifiedReceipt.orderDetails];
        [receiptDetails addObject:specifiedReceipt.paymentType];
        [receiptDetails addObject:specifiedReceipt.paymentLastFourDigits];
        
        if ([receiptDetails count] == 10)
        {
            [self.delegate expandReceipt:receiptDetails];
        }
        else
        {
            NSLog(@"receiptDetails was not populated correctly in ReceiptSlideOutViewController receiptWantsToExpand");
        }
    }
}

- (void)deleteItemAtIndexPath:(NSIndexPath *)indexPath
{
   //NOOOOOOOOOO!
}

- (void)deleteSectionAtIndex:(NSUInteger)index
{
    //NOOOOOOOOOO!
}

- (void)addNewItemInSection:(NSUInteger)section
{
    //NOOOOOOOOOO!
}

- (void)insertSectionAtIndex:(NSUInteger)index
{
    //NOOOOOOOOOO!
}
@end
