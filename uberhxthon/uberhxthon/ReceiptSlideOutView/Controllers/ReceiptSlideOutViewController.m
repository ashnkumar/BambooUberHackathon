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

#define kUberStatusProcessing @"processing"
#define kUberStatusAccepted @"accepted"
#define kUberStatusArriving @"arriving"
#define kUberStatusInProgress @"in_progress"
#define kUberStatusDriverCanceled @"driver_canceled"
#define kUberStatusCompleted @"completed"


#define PANELCLOSED 1
#define PANELOPEN 0

@interface ReceiptSlideOutViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ReceiptCellRequestUberDelegate, ReceiptCellDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *receiptData;
@property (nonatomic, assign) BOOL pingingForAllReceiptUpdatesOn;
@property (nonatomic, assign) BOOL pingingForAllCarLocationsOn;

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
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"EmptySectionPlaceholderCell" bundle:nil] forCellWithReuseIdentifier:@"SampleCell3"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"ReceiptSectionHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SectionHeaderView"];
    
    self.pingingForAllReceiptUpdatesOn = NO;
    self.pingingForAllCarLocationsOn = NO;
    
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
    
    /*if (![[BambooServer sharedInstance]succededInConnectingToServer])
    {
        //Temporary, read from a static file
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"receiptData" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSDictionary *receiptsDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
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

    }*/
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
    //if ([self.receiptData[section] count] > 0)
    //{
        return [self.receiptData[section] count];
    /*}
    else
    {
        //Return 1, so can display placeholder cell
        return 1;
    }*/
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
         cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    if ([self.receiptData[indexPath.section] count] > 0)
    {
        ReceiptObject *receiptObject = self.receiptData[indexPath.section][indexPath.row];
        NSString *orderStatus = receiptObject.orderStatus;
        
        if ([orderStatus isEqualToString:kStatusRequestUber])
        {
            ReceiptCellRequestUber *rucell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SampleCell2" forIndexPath:indexPath];
            
            rucell.orderNumberLabel.text = [NSString stringWithFormat:@"#%@", receiptObject.orderNumber];
            rucell.orderDayDateLabel.text = receiptObject.orderDayDate;
            rucell.orderTimeLabel.text = receiptObject.orderTime;
            rucell.delegate = self;
            cell = rucell;
            
        }
        else
        {
            ReceiptCell *rucell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SampleCell" forIndexPath:indexPath];
            if ([orderStatus isEqualToString:kStatusUberRequested]) {
                rucell.receiptStatus = AKReceiptStatusUberRequested;
            } else if ([orderStatus isEqualToString:kStatusOutForDelivery]) {
                rucell.receiptStatus = AKReceiptStatusOutForDelivery;
            } else if ([orderStatus isEqualToString:kStatusOrderComplete]) {
                rucell.receiptStatus = AKReceiptStatusDeliveryComplete;
            }
            else
            {
                NSLog(@"error with the cell's status inside uicollectionview cellforitem");
            }
            
            rucell.orderNumberLabel.text = [NSString stringWithFormat:@"#%@", receiptObject.orderNumber];
            rucell.orderDayDateLabel.text = receiptObject.orderDayDate;
            rucell.orderTimeLabel.text = receiptObject.orderTime;
            
            rucell.delegate = self;
            cell = rucell;
        }

    }
    else
    {
        //Display the placeholder cell
        EmptySectionPlaceholderCell *rucell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SampleCell3" forIndexPath:indexPath];
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
- (NSMutableArray *)findReceiptWithOrderNum:(int)orderNum inSection:(int)requestSection
{
    NSMutableArray *receiptAndIndex = [[NSMutableArray alloc]init];
    ReceiptObject *receiptFound = nil;
    NSIndexPath *indexFound = nil;
    
    int sectionCount = 0;
    int rowCount = 0;
    //TODO: fix with requestSection so don't have to iterate through entire data structure holding receipts
    for (NSMutableArray *arr in self.receiptData)
    {
        for (ReceiptObject *receipt in arr)
        {
            int receiptOrderNum = [receipt.orderNumber intValue];
            if (receiptOrderNum == orderNum)
            {
                receiptFound = receipt;
                [receiptAndIndex addObject:receiptFound];
                indexFound = [NSIndexPath indexPathForRow:rowCount inSection:sectionCount];
                [receiptAndIndex addObject:indexFound];
                
                return receiptAndIndex;
            }
            rowCount ++;
        }
        rowCount = 0;
        sectionCount ++;
    }
    return receiptAndIndex;
}

- (void)requestUberWithReceipt:(NSString *)receiptNumber
{
    //Find the receipt with correct order num
    int orderNum = [receiptNumber intValue];
    
    NSIndexPath *requestedReceiptIndexPath = [[self findReceiptWithOrderNum:orderNum inSection:0] lastObject];//TODO fix section
    
    if (requestedReceiptIndexPath != nil)
    {
        //Get the receipt
        ReceiptObject *requestedReceipt = self.receiptData[requestedReceiptIndexPath.section][requestedReceiptIndexPath.row];
        if (requestedReceipt != nil)
        {
            //Send a request for an Uber through Bamboo's server, specifying:
            /*
             product requested
             start latitude, longitude
             final destination latitude, longitude
             */
            float usersLat = [self.delegate getUsersLocationLatitude];
            float usersLon = [self.delegate getUsersLocationLongitude];
            float requestedLat = [requestedReceipt getDestination].latitude;
            float requestedLon = [requestedReceipt getDestination].longitude;
            
            [[BambooServer sharedInstance]requestUberWithStartingLatitude:[NSNumber numberWithFloat:usersLat] startingLongitude:[NSNumber numberWithFloat:usersLon] endingLatitude:[NSNumber numberWithFloat:requestedLat] endingLongitude:[NSNumber numberWithFloat:requestedLon] orderNumber:orderNum completion:^(BOOL requestSuccess) {
                
                //Update the Delivery View UI that a request is in process
                [self.delegate requestedUber];
                
                [self pingForUpdate:requestedReceiptIndexPath];
                NSLog(@"requested an uber successfuly retrieved in receiptslideoutviewcontroller");
            }];
            
        }
        else
        {
            NSLog(@"error grabbing requested receipt from nsindexpath inside requestuberwithrecept");
        }
    }
    else
    {
        NSLog(@"couldn't find uber with specified receipt number in ReceiptSlideOutViewController's requestUberWithReceipt");
    }
}


#pragma mark - Car and Server dictionaries
- (void)scrollToOrderNum:(int)orderNum andHighlight:(BOOL)shouldhighlight
{
    
    //Find the receipt's index path and scroll to it
    NSMutableArray *receiptAndIndex = [self findReceiptWithOrderNum:orderNum inSection:0];
    if ([receiptAndIndex count] == 2)
    {
        NSIndexPath *foundIndex = [receiptAndIndex lastObject];
        [self scrollToRow:foundIndex.section];
        if (shouldhighlight)
        {
            [self highlightReceiptAtIndexPath:foundIndex];
        }
    }
    else
    {
        NSLog(@"receiptandindex count error");
    }
}

- (void)updateCarLocations:(NSDictionary *)ubersDictionary
{
    if (ubersDictionary != nil)
    {
        //Update the annotations
        [self.delegate updateCarLocations:ubersDictionary];
    }
}

- (void)compareServerDictionary:(NSDictionary *)receiptsDictionary
{
    //Receive notifications for uberstatusdrivercancelled and uberstatusarriving here
    for (NSString *orderNumber in [receiptsDictionary allKeys])
    {
        NSString *newStatus = [receiptsDictionary objectForKey:orderNumber];
        if ([newStatus isEqualToString:kUberStatusArriving])
        {
            [self createNotificationWithMessage:[NSString stringWithFormat:@"Your Uber for order number %@ is arriving.", orderNumber]];
        }
        else if ([newStatus isEqualToString:kUberStatusDriverCanceled])
        {
            [self createNotificationWithMessage:[NSString stringWithFormat:@"Your Uber driver for order number %@ cancelled - please re-request pick-up for that order.", orderNumber]];
            [self uberCancelled:orderNumber];
        }
        else
        {
            NSMutableArray *receiptAndIndex = [self findReceiptWithOrderNum:[orderNumber intValue] inSection:0];
            if ([receiptAndIndex count] == 2)
            {
                ReceiptObject *foundReceipt = [receiptAndIndex  firstObject];
                if (![foundReceipt.orderStatus isEqualToString:newStatus])
                {
                    //Move the receipt and update the UI
                    foundReceipt.orderStatus = newStatus;
                    NSIndexPath *requestedReceiptIndexPath = [receiptAndIndex lastObject];//TODO fix section
                    [self moveReceipt:requestedReceiptIndexPath];
                }
                else
                {
                    NSLog(@"new order status is the same as previously");
                }
            }
        }
    }
    [self.collectionView reloadData];
}

- (void)createNotificationWithMessage:(NSString *)message
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = message;
    localNotification.fireDate = [NSDate date];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void)uberCancelled:(NSString *)orderNumber
{
    //Update the data structure and UI -- TEST!
    NSMutableArray *foundArr = [self findReceiptWithOrderNum:[orderNumber intValue] inSection:0];
    if ([foundArr count] == 2)
    {
        ReceiptObject *foundReceipt = [foundArr firstObject];
        NSIndexPath *foundIndexpath = [foundArr lastObject];
        
        foundReceipt.orderStatus = kStatusRequestUber;
        [self.receiptData[foundIndexpath.section] removeObjectAtIndex:foundIndexpath.row];
        [self.receiptData[0] insertObject:foundReceipt atIndex:0];
        [self.collectionView reloadData];
    }
    else
    {
        NSLog(@"error in uber cancelled");
    }
    
}

- (void)pingRegularlyForReceiptUpdates
{
    [[BambooServer sharedInstance]retrieveReceiptUpdatesWithCompletion:^(NSDictionary *receiptsDictionary) {
       if (receiptsDictionary != nil)
       {
           //Compare receiptsDictionary to own to determine updates
           [self compareServerDictionary:receiptsDictionary];
       }
    }];
}

- (void)pingRegularlyForCarlocations
{
    [[BambooServer sharedInstance]retrieveUbersWithCompletion:^(NSDictionary *ubersDictionary) {
        if (ubersDictionary != nil)
        {
            //Compare receiptsDictionary to own to determine updates
            [self updateCarLocations:ubersDictionary];
        }
    }];
}

- (void)pingForUpdate:(NSIndexPath *)requestedReceiptIndexPath
{
    ReceiptObject *requestedReceipt = self.receiptData[requestedReceiptIndexPath.section][requestedReceiptIndexPath.row];
    int orderNum = [requestedReceipt.orderNumber intValue];
    NSString *originalStatus = requestedReceipt.orderStatus;
    //Ping for an update for the receipt
    
    [[BambooServer sharedInstance]retrieveSingleUberStatusWithOrderNumber:orderNum completion:^(NSString *uberStatus) {
        if ([uberStatus isEqualToString:kUberStatusAccepted] && [originalStatus isEqualToString:kStatusRequestUber])
        {
            NSLog(@"receipts status was updated to uberrequested");
            [self.delegate removeRequestingReceiptStatusVC];
            
            requestedReceipt.orderStatus = kStatusUberRequested;
            //Now update arrays & move animation
            [self moveReceipt:requestedReceiptIndexPath];
            
            //start pinging regularly if the app isn't currently
            if (!self.pingingForAllReceiptUpdatesOn)
            {
                [self pingRegularlyForReceiptUpdates]; //TODO: do it regularly
                self.pingingForAllReceiptUpdatesOn = YES;
            }
            if (!self.pingingForAllCarLocationsOn)
            {
                [self pingRegularlyForCarlocations]; //TODO: do it regularly
                self.pingingForAllCarLocationsOn = YES;
            }
        }
        else if ([uberStatus isEqualToString:kUberStatusAccepted] && [originalStatus isEqualToString:kStatusUberRequested])
        {
            //TODO: display that the uber is arriving
        }
        else if ([uberStatus isEqualToString:kUberStatusInProgress] && [originalStatus isEqualToString:kStatusUberRequested])
        {
            NSLog(@"receipts status was updated to outfordelivery");
            //requestedReceipt.orderStatus = kStatusOutForDelivery;
            //[self moveReceipt:requestedReceiptIndexPath];
            //[self.collectionView reloadData];
            //[self performSelector:@selector(performMoveReceiptAnimation:) withObject:requestedReceiptIndexPath afterDelay:0.4];
        }
        else if ([uberStatus isEqualToString:kUberStatusCompleted] && [originalStatus isEqualToString:kStatusOutForDelivery])
        {
            NSLog(@"receipts status was updated to ordercomplete");
            //requestedReceipt.orderStatus = kStatusOrderComplete;
            //[self moveReceipt:requestedReceiptIndexPath];
            //[self.collectionView reloadData];
            //[self performSelector:@selector(performMoveReceiptAnimation:) withObject:requestedReceiptIndexPath afterDelay:0.4];
        }
        else if ([uberStatus isEqualToString:kUberStatusDriverCanceled])
        {
            //TODO: display that the driver canceled
        }
        else
        {
            NSLog(@"still processing, pinging again");
            [self performSelector:@selector(pingForUpdate:) withObject:requestedReceiptIndexPath afterDelay:3];
        }
    }];
}

- (void)highlightReceiptAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"collectionview in section 0: %i section 1: %i, section 2: %i, section 3:%i", [self.collectionView numberOfItemsInSection:0], [self.collectionView numberOfItemsInSection:1], [self.collectionView numberOfItemsInSection:2], [self.collectionView numberOfItemsInSection:3]);
    NSLog(@"indexpath section: %i, row: %i", indexPath.section, indexPath.row);
    
    NSLog(@"%@", [self allCellsInCollectionView]);
    
    if (indexPath.section == 0)
    {
        ReceiptCellRequestUber *cell = (ReceiptCellRequestUber *)[self.collectionView cellForItemAtIndexPath:indexPath];
        cell.layer.borderWidth = 5;
        cell.layer.borderColor = [AppConstants cashwinGreen].CGColor;
    }
    else
    {
        ReceiptCell *cell = (ReceiptCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        NSLog(@"Highlighting cell: ordernum: %@", cell.orderNumberLabel.text);
        
        cell.layer.borderWidth = 5;
        cell.layer.borderColor = [AppConstants cashwinGreen].CGColor;
    }
}

- (void)removeAllCellBorders
{
    NSMutableArray *allCells = [self allCellsInCollectionView];
    
    for (ReceiptCell *cell in allCells) {
        cell.layer.borderColor = nil;
        cell.layer.borderWidth = 0;
    }
    NSLog(@"removed all cell borders");
}

- (NSMutableArray *)allCellsInCollectionView {
    NSMutableArray *cells = [[NSMutableArray alloc] init];
    for (NSInteger j = 0; j < [self.collectionView numberOfSections]; j++) {
        NSLog(@"%i", [self.collectionView numberOfItemsInSection:j]);
        for (NSInteger i = 0; i < [self.collectionView numberOfItemsInSection:j]; i++) {
            ReceiptCell *cell = (ReceiptCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
            
            NSLog(@"hi");
            if (cell) {
                [cells addObject:cell];
            }
        }
    }
    NSLog(@"number of sections %i", [self.collectionView numberOfSections]);
    return cells;
}

#pragma mark - Object insert/remove
//Move a receipt when a receipt's status changes
- (void)moveReceipt:(NSIndexPath *)indexPath
{
    ReceiptObject *receiptObject = self.receiptData[indexPath.section][indexPath.row];
    if (receiptObject != nil)
    {
        NSLog(@"receipt object's status is: %@", receiptObject.orderStatus); //Test to see if its status was updated
        
        //receiptObject's orderStatus should already be moved by this point
        [self.collectionView reloadData];
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
     
     if ([receiptsInSection count] > 0)
     {
         //Todo: test if grabs the correct receiptObject
         ReceiptObject *receiptToMove = receiptsInSection[indexPath.row];
     
         if (receiptToMove != nil)
         {
             [receiptsInSection removeObjectAtIndex:indexPath.row];
     
             NSMutableArray *receiptsInSecondSection = self.receiptData[indexPath.section + 1];
             [receiptsInSecondSection insertObject:receiptToMove atIndex:0];
             //Reload the collection view again to now display the updated receipt in its correct row
             [self.collectionView reloadData];
     
             //[self.collectionView moveItemAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForItem:0 inSection:indexPath.section + 1]];
     
             //Scroll to correct row (+1 because scrollToRow uses intuitive definition of which row to scroll to)
            //[self scrollToRow:indexPath.section + 1];
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
    /*ReceiptObject *receiptObject = self.receiptData[indexPath.section][indexPath.row];

    if (indexPath != nil)
    {
        NSLog(@"indexpath section: %i, row:%i", indexPath.section, indexPath.row);
        //Update app's internal data structure
        NSMutableArray *receiptsInSection = self.receiptData[indexPath.section];
        [receiptsInSection removeObjectAtIndex:indexPath.row];
        NSMutableArray *receiptsInSecondSection = self.receiptData[indexPath.section + 1];
        [receiptsInSecondSection insertObject:receiptObject atIndex:0];
        
        [self.collectionView moveItemAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForItem:0 inSection:indexPath.section + 1]];
        
        //Scroll to correct row (+1 because scrollToRow uses intuitive definition of which row to scroll to)
        [self scrollToRow:indexPath.section + 1];
    }*/
}

- (void)scrollToRow:(int)row
{
    //Note that row is the CS definition of which row to move to
    if (![self.delegate isReceiptPanelShowing])
    {
        [self.delegate movePanelOneRow];
    }
   
    //TODO: Test that this works if more than one panel is showing
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:row] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

#pragma mark - ReceiptDelegate
- (void)receiptWantsToExpand:(NSString *)orderNumber
{
    NSMutableArray *receiptDetails = [[NSMutableArray alloc]init];
    //Get the correct receipt
    ReceiptObject *specifiedReceipt = [[self findReceiptWithOrderNum:[orderNumber intValue] inSection:0] firstObject];//TODO fix so doesn't iterate through entire data struct
    
    if (specifiedReceipt != nil)
    {
        //Push the info into receiptDetails in the following index order:
        //order number, date ordered, time ordered, orderer's name, orderer's address line 1, orderer's address line 2, orderer's phonenumber, order details, payment type, payment last four digits, order status
        
        //CLLocation *destAddress = [[CLLocation alloc]initWithLatitude:[specifiedReceipt getDestination].latitude longitude:[specifiedReceipt getDestination].longitude];
        
        [receiptDetails addObject:specifiedReceipt.orderNumber];
        [receiptDetails addObject:specifiedReceipt.orderDayDate];
        [receiptDetails addObject:specifiedReceipt.orderTime];
        [receiptDetails addObject:specifiedReceipt.destinationName];
        [receiptDetails addObject:specifiedReceipt.destinationAddressLine1];
        [receiptDetails addObject:specifiedReceipt.destinationAddressLine2];
        [receiptDetails addObject:specifiedReceipt.destinationPhoneNumber];
        [receiptDetails addObject:specifiedReceipt.orderDetails];
        [receiptDetails addObject:specifiedReceipt.paymentType];
        [receiptDetails addObject:specifiedReceipt.paymentLastFourDigits];
        [receiptDetails addObject:specifiedReceipt.orderStatus];
        
        if ([receiptDetails count] == 11)
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
