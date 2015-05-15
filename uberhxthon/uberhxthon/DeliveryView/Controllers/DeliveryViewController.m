//
//  DeliveryViewController.m
//  uberhxthon
//
//  Created by Catherine Jue on 4/26/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import "DeliveryViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "RTSpinKitView.h"
#import <POP/POP.h>

#import "AppConstants.h"
#import "ReceiptSlideOutViewController.h"
#import "RequestUberPopupViewController.h"
#import "PresentingAnimator.h"
#import "DismissingAnimator.h"
#import "DetailedReceiptViewController.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define METERS_PER_MILE 1609.344
#define CORNER_RADIUS 4
#define SLIDE_TIMING .25
#define PANELCLOSED 1
#define PANELOPEN 0

@interface DeliveryViewController () <ReceiptPanelViewControllerDelegate, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate, RequestPopupViewControllerDelegate>
{
    int intIndex_route1;
    int intIndex_route2;
    int intIndex_route3;
    int intIndex_route4;
    CGRect screenRect;
    CGFloat screenWidth;
    CGFloat screenHeight;
    
}

@property (nonatomic, strong) ReceiptSlideOutViewController *receiptPanelViewController;

// Receipt panel view
@property (nonatomic, assign) BOOL showingReceiptPanel;
@property (nonatomic, assign) BOOL showPanel;
@property (nonatomic, strong) UITapGestureRecognizer *mapTapRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *exitDetailedReceiptTapRecognizer;
@property (nonatomic, strong) UIView *dimView;
@property (nonatomic, strong) DetailedReceiptViewController *detailedReceipt;
@property (nonatomic, assign) BOOL showingDetailedReceipt;
@property (nonatomic, strong) RequestUberPopupViewController *requestUberPopupVC;
@property (nonatomic, strong) NSMutableDictionary *ubersCars;

// Loading view / spinner
@property (strong, nonatomic) UIVisualEffectView *blurEffectView;
@property (strong, nonatomic) RTSpinKitView *loadingSpinner;


// Animating cars
@property(strong, nonatomic) MKPointAnnotation* annotation1;
@property(strong, nonatomic) MKPointAnnotation* annotation2;
@property(strong, nonatomic) MKPointAnnotation* annotation3;
@property(strong, nonatomic) MKPointAnnotation* annotation4;
@property (strong,nonatomic) routeGenerator *routeGenerator;
@end

@implementation DeliveryViewController

#pragma mark - View Controller Lifecycle
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupVariables];
    [self addLoadingView];
    [self setupMapView];
    [self setupReceiptPanelView];
    [self setupGestures];
    [self setupDetailedReceipt];
    [self createNotification]; //TODO: post after logging in
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.mapView.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated
{
    CLLocationCoordinate2D zoomLocation;
    
    //zoomLocation.latitude = self.locationManager.location.coordinate.latitude;
    //zoomLocation.longitude= self.locationManager.location.coordinate.longitude;
    
    zoomLocation.latitude = 37.775871;
    zoomLocation.longitude = -122.417961;

    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 7.5*METERS_PER_MILE, 7.5*METERS_PER_MILE);
    //MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 1100, 1100);
    [self.mapView setRegion:viewRegion animated:YES];
}


#pragma mark - Helpers
- (void) createNotification
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = @"You have new deliveries to fill! Check your receipt panel for details.";
    localNotification.fireDate = nil;
    localNotification.soundName = @"";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}
- (void)setupVariables
{
    screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    self.loadingSpinner = [[RTSpinKitView alloc]
                           initWithStyle:RTSpinKitViewStyleBounce
                           color:[AppConstants cashwinGreen]];
    
    float spinnerx = screenWidth / 2 - 10;
    float spinnery = screenHeight / 2 - 10;
    CGRect newFrame = CGRectMake(spinnerx, spinnery, 20, 20);
    self.loadingSpinner.frame = newFrame;
}


// Adds a blur loading view to the screen while map is getting ready
- (void)addLoadingView
{
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        self.blurEffectView.frame = self.view.bounds;
        [self.view addSubview:self.blurEffectView];
        
        [self.blurEffectView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        NSLayoutConstraint *constraint1 = [NSLayoutConstraint
                                           constraintWithItem:self.blurEffectView
                                           attribute:NSLayoutAttributeTop
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:self.view
                                           attribute:NSLayoutAttributeTop
                                           multiplier:1
                                           constant:0];
        
        NSLayoutConstraint *constraint2 = [NSLayoutConstraint
                                           constraintWithItem:self.blurEffectView
                                           attribute:NSLayoutAttributeBottom
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:self.view
                                           attribute:NSLayoutAttributeBottom
                                           multiplier:1
                                           constant:0];
        
        NSLayoutConstraint *constraint3 = [NSLayoutConstraint
                                           constraintWithItem:self.blurEffectView
                                           attribute:NSLayoutAttributeLeading
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:self.view
                                           attribute:NSLayoutAttributeLeading
                                           multiplier:1
                                           constant:0];
        
        NSLayoutConstraint *constraint4 = [NSLayoutConstraint
                                           constraintWithItem:self.blurEffectView
                                           attribute:NSLayoutAttributeTrailing
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:self.view
                                           attribute:NSLayoutAttributeTrailing
                                           multiplier:1
                                           constant:0];
        
        [self.view addConstraint:constraint1];
        [self.view addConstraint:constraint2];
        [self.view addConstraint:constraint3];
        [self.view addConstraint:constraint4];
        
    } else {
        self.view.backgroundColor = [UIColor blackColor];
    }
    
    // Add the spinner
    [self.view addSubview:self.loadingSpinner];
}

- (void)setupMapView
{
    self.mapView.delegate = self;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if (IS_OS_8_OR_LATER) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    // Don't do anything yet when user location updates
    //    [self.locationManager startUpdatingLocation];
    //    [self.mapView setShowsUserLocation:YES];
    [self.mapView setMapType:MKMapTypeStandard];
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
    
    // Add gesture recognizer to map so when user taps it, it closes
    // the receipt panel view if it is open
    self.mapTapRecognizer = [[UITapGestureRecognizer alloc]
                             initWithTarget:self
                             action:@selector(closePanelDueToMapTouch:)];
    
    [self.mapView addGestureRecognizer:self.mapTapRecognizer];
    
    self.ubersCars = [[NSMutableDictionary alloc]init];
    
}

- (void)setupReceiptPanelView
{
    self.receiptPanelViewController = [[ReceiptSlideOutViewController alloc]
                                       initWithNibName:@"ReceiptSlideOutView"
                                       bundle:nil];
    
    self.receiptPanelViewController.delegate = self;
    
    //view.frame = (0, screenHeight - HEIGHTOFPULL-YTHING)
    self.receiptPanelViewController.view.frame = CGRectMake(0, screenHeight-140, self.receiptPanelViewController.view.frame.size.width, self.receiptPanelViewController.view.frame.size.height);
    self.receiptPanelViewController.view.alpha = 0.0f;
    [self.view addSubview:self.receiptPanelViewController.view];
}

- (void)setupGestures
{
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
    panRecognizer.delegate = self;
    [self.receiptPanelViewController.view addGestureRecognizer:panRecognizer];
}

- (void)setupDetailedReceipt
{
    self.dimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    self.dimView.backgroundColor = [UIColor colorWithRed:84/255.0 green:82/255.0 blue:82/255.0 alpha:1.0];
    self.dimView.layer.opacity = 0.0;
    [self.view addSubview:self.dimView];
    
    float detailedReceiptWidth = screenWidth * 0.65;
    float detailedReceiptHeight = screenHeight * 0.75;
    float detailedReceiptX = screenWidth / 2 - (detailedReceiptWidth / 2);
    
    self.detailedReceipt = [[DetailedReceiptViewController alloc]init];
    self.detailedReceipt.view.frame = CGRectMake(detailedReceiptX, screenHeight * 2 * -1, detailedReceiptWidth, detailedReceiptHeight);
    self.detailedReceipt.view.layer.opacity = 0;
    self.showingDetailedReceipt = NO;
    self.detailedReceipt.view.layer.cornerRadius = 8;
    self.detailedReceipt.view.layer.masksToBounds = YES;
    self.detailedReceipt.view.clipsToBounds = YES;

    [self.view addSubview:self.detailedReceipt.view];
}

#pragma mark - Tap Recognizers
- (void)closePanelDueToMapTouch:(UITapGestureRecognizer *)recognizer
{
    [self closePanel];
}

- (void)exitDetailedReceipt:(UITapGestureRecognizer *)recognizer
{
    if (self.showingDetailedReceipt)
    {
        [self.dimView removeGestureRecognizer:recognizer];
        float detailedReceiptWidth = screenWidth * 0.65;
        float detailedReceiptHeight = screenHeight * 0.75;
        float detailedReceiptX = screenWidth / 2 - (detailedReceiptWidth / 2);
    
        [UIView animateWithDuration:.3 delay:.1 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            //TODO: check if set detailedReceiptViewFrame correctly
            self.detailedReceipt.view.frame = CGRectMake(detailedReceiptX, screenHeight * 2 * -1, detailedReceiptWidth, detailedReceiptHeight);
            self.dimView.layer.opacity = 0;
            
        } completion:^(BOOL finished) {
            NSLog(@"exited detailed receipt view");
            //TODO: create a gesture recognizer for on top of the dimming view to close the detailed receipt view
            self.detailedReceipt.view.layer.opacity = 0;
            self.showingDetailedReceipt = NO;
        }];
    }
    else
    {
        NSLog(@"showingDetailedReceipt not set");
    }

}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    return [PresentingAnimator new];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [DismissingAnimator new];
}

#pragma mark - LocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* loc = [locations lastObject]; // locations is guaranteed to have at least one object
    float latitude = loc.coordinate.latitude;
    float longitude = loc.coordinate.longitude;
    NSLog(@"Lat: %.8f | Lon: %.8f",latitude, longitude);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    //    NSLog(@"%d", status);
}

#pragma mark - MapKit Delegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // Don't do anything yet when user location updates
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView
                       fullyRendered:(BOOL)fullyRendered
{
    [self.blurEffectView removeFromSuperview];
    [self.loadingSpinner removeFromSuperview];
    self.receiptPanelViewController.view.alpha = 1.0f;
    
    MKPointAnnotation *testCar = [[MKPointAnnotation alloc]init];
    [testCar setCoordinate:CLLocationCoordinate2DMake(37.7833, -122.4167)];
    [testCar setTitle:@"47"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView addAnnotation:testCar];
    });

}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer *renderer =
    [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 3.0;
    return renderer;
}


#pragma mark - Receipt Panel View
- (void)closePanel
{
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.receiptPanelViewController.view.frame = CGRectMake(0, screenHeight-140, self.receiptPanelViewController.view.frame.size.width, self.receiptPanelViewController.view.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            self.receiptPanelViewController.panelUpButton.tag = PANELCLOSED;
            self.showingReceiptPanel = NO;
            [self.receiptPanelViewController removeAllCellBorders];
        }
    }];
}

//Move panel up all four rows
//Used for receiptVC's manual call
- (void)movePanelAllUp
{
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                        //receipt panel view controller frame: (0, screenHeight-SIZEOFRECEIPTVIEW)
                         self.receiptPanelViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                         
                     } completion:^(BOOL finished) {
                         self.receiptPanelViewController.panelUpButton.tag = PANELOPEN;
                         self.showingReceiptPanel = YES;
                     }];
    
}

//Move panel one row
//Used for receiptVC's manual call
- (void)movePanelOneRow
{
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                        //receipt panel view controller frame: (0, screenHeight-SIZEOFONEROW), frameHeight = screenHeight-ONEROW
                         self.receiptPanelViewController.view.frame = CGRectMake(0, screenHeight-140-300, self.receiptPanelViewController.view.frame.size.width, self.view.frame.size.height);// self.receiptPanelViewController.view.frame.size.height-325);
                     } completion:^(BOOL finished) {
                         self.receiptPanelViewController.panelUpButton.tag = PANELOPEN;
                         self.showingReceiptPanel = YES;
                         //[self.receiptPanelViewController scrollToRow:2];
                     }];
}

//Move panel up two rows
//Used for receiptVC's manual call
- (void)movePanelTwoRows
{
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                        //receipt panel view controller frame: (0, screenHeight-SIZEOFTWOROWS), frameHeight = screenHeight-TWOROWS
        self.receiptPanelViewController.view.frame = CGRectMake(0, screenHeight-725, self.view.frame.size.width, self.view.frame.size.height);// self.view.frame.size.height-40);
                     } completion:^(BOOL finished) {
                         self.receiptPanelViewController.panelUpButton.tag = PANELOPEN;
                         self.showingReceiptPanel = YES;
                     }];
    
}

- (void)expandReceipt:(NSMutableArray *)details
{
    //Details array contains: order number, date ordered, time ordered, orderer's name, orderer's address, orderer's phonenumber, order details
    if ([details count] == 11 && !self.showingDetailedReceipt)
    {
        //Reset all the necessary views just to make sure
        self.dimView.frame = CGRectMake(0, 0, screenWidth, screenHeight);

        //Display the xib template with the specified information
        //TODO: Check if set detailed receipt view correctly
        float detailedReceiptWidth = screenWidth * 0.65;
        float detailedReceiptHeight = screenHeight * 0.75;
        float detailedReceiptX = screenWidth / 2 - (detailedReceiptWidth / 2);
        float detailedReceiptY = screenHeight / 2 - (detailedReceiptHeight / 1.8); //TODO: why is this 1.8 and not 2??
        
        self.detailedReceipt.view.frame = CGRectMake(detailedReceiptX, screenHeight * 2 * -1, detailedReceiptWidth, detailedReceiptHeight);
        self.detailedReceipt.view.layer.opacity = 1;
        
        //Set the details of the receipt detail
        [self.detailedReceipt layoutDetails:details];
        
        [UIView animateWithDuration:.3 delay:.1 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.dimView.layer.opacity = 0.5;
            //TODO: check if set detailedReceiptViewFrame correctly
            self.detailedReceipt.view.frame = CGRectMake(detailedReceiptX, detailedReceiptY, detailedReceiptWidth, detailedReceiptHeight);
        } completion:^(BOOL finished) {
            NSLog(@"displayed detailed receipt view");
            NSLog(@"screen width: %f, screen height: %f", screenWidth, screenHeight);
            NSLog(@"detailedReceiptY: %f", detailedReceiptY);

            //TODO: create a gesture recognizer for on top of the dimming view to close the detailed receipt view
            self.exitDetailedReceiptTapRecognizer = [[UITapGestureRecognizer alloc]
                                     initWithTarget:self
                                     action:@selector(exitDetailedReceipt:)];
            
            [self.dimView addGestureRecognizer:self.exitDetailedReceiptTapRecognizer];
            
            self.showingDetailedReceipt = YES;
        }];
        
    }
    else {
        NSLog(@"details array doesn't have correct parameters in expandReceipt or detailedReceiptShowing flag already true");
    }
}

-(BOOL)isReceiptPanelShowing
{
    return self.showingReceiptPanel;
}

//Move panel up or down by selected amount
-(void)movePanel:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.view];

    //End at max y translation if recognizer goes past map view's bounds or below bottom of screen
    float scrollUpY = self.receiptPanelViewController.view.frame.origin.y + translation.y;
    float scrollDownY = scrollUpY + 140;

    //If it doesn't go above the top menu or below the bottom of the screen + height of the pull-y thing
    if ((scrollUpY >= 0) && (scrollDownY <= screenHeight))
    {
        recognizer.view.center = CGPointMake(self.view.center.x, recognizer.view.center.y + translation.y);
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
        if (self.receiptPanelViewController.view.frame.origin.y >= screenHeight - 428) //Set showing as NO until shows at least one row
        {
            self.showingReceiptPanel = NO;
        }
        else
        {
            self.showingReceiptPanel = YES;
        }
    }
}

- (void)highlightReceiptAtIndex:(int)receiptIndex
{
    //@TODO: find section to highlight
    int section = 1;
    
    NSIndexPath *indexPathToSelect = [NSIndexPath indexPathForRow:0
                                                        inSection:section];
    [self.receiptPanelViewController highlightReceiptAtIndexPath:indexPathToSelect];
}

//Present the Uber-requesting popup until that receipt's status changes on the server
- (void)requestedUber
{
    //Display the dimming view
    [UIView animateWithDuration:.2 delay:.1 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.dimView.layer.opacity = 0.5;
    } completion:^(BOOL finished) {
        NSLog(@"displaying the requestuberpopup");
        //Now display the popup
        self.requestUberPopupVC = [[RequestUberPopupViewController alloc]init];
        self.requestUberPopupVC.delegate = self;
        self.requestUberPopupVC.transitioningDelegate = self;
        self.requestUberPopupVC.modalPresentationStyle = UIModalPresentationCustom;
        
        [self presentViewController:self.requestUberPopupVC animated:YES completion:nil];
    }];
}

- (void)removeRequestingReceiptStatusVC
{
    [self.requestUberPopupVC uberRequestComplete];
}

//Remove the Uber-requesting popup
- (void)dismissedRequestUberPopup
{
    [UIView animateWithDuration:.2 delay:.1 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.dimView.layer.opacity = 0;
    } completion:^(BOOL finished) {
        NSLog(@"removing the requestuberpopup");
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - pings
- (void)receivedReceiptUpdate:(NSDictionary *)receiptsDictionary
{
    NSLog(@"inside receivedReceiptUpdate for Delivery View Controller");
    [self.receiptPanelViewController receivedReceiptUpdate:receiptsDictionary];
}

- (void)receivedCarLocationsUpdate:(NSDictionary *)ubersDictionary
{
    NSLog(@"inside receivedCarLocationsUpdate for Delivery View Controller");
    [self.receiptPanelViewController receivedCarLocationsUpdate:ubersDictionary];
}


#pragma mark - MapKit Annotations/Move Users
- (float)getUsersLocationLatitude
{
    //TODO
    return 37.775871;
}

- (float)getUsersLocationLongitude
{
    //TODO
    return -122.417961;
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *AnnotationViewID = @"annotationViewID";
    
    MKAnnotationView *annotationView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    if (annotationView == nil)
    {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    }
    annotationView.image = [UIImage imageNamed:@"uber_route1.png"]; //TODO: set with correct bearing
    
    annotationView.annotation = annotation;
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    MKPointAnnotation *car = view.annotation;
    int orderNum = [car.title intValue];
    [self.receiptPanelViewController scrollToOrderNum:orderNum andHighlight:YES];
}

//@Todo - test - simplify it by simply setting mapview addAnnotations to entire ubersdictoinaries (can remove all self.uberscars)
- (void) updateCarLocations:(NSDictionary *)ubersDictionary
{
    if ([ubersDictionary count] > 0)
    {
        NSMutableArray *cars = [[NSMutableArray alloc]init];
        for (NSString *orderNum in [ubersDictionary allKeys])
        {
            MKPointAnnotation *car = [[MKPointAnnotation alloc]init];
            car.title = orderNum;
            NSString *uberLatitude = ubersDictionary[@"uberLatitude"];
            NSString *uberLongitude = ubersDictionary[@"uberLatitude"];
            
            [car setCoordinate:CLLocationCoordinate2DMake([uberLatitude floatValue], [uberLongitude floatValue])];
            //todo - Set the bearing
            [cars addObject:car];
        }
        [self.mapView addAnnotations:cars];
    }
    
    /*
        If app's uber dictionary is empty, just push them all
        Else if not empty, search for the order number and if found, update the location
            Else if not found, push a new object with its location
     */
    /*if ([self.ubersCars count] == 0)
    {
        for (NSString *orderNum in [ubersDictionary allKeys])
        {
            //Add the objects
            MKPointAnnotation *car = [[MKPointAnnotation alloc]init];
            [car setCoordinate:CLLocationCoordinate2DMake(0, 0)];//Set based on how Ashwin returns the coordinates
            //TODO: set the bearing
            [car setTitle:[NSString stringWithFormat:@"%@", orderNum]];
            [self.ubersCars setObject:car forKey:orderNum];
        }
        [self.mapView addAnnotations:[self.ubersCars allValues]];
    }
    else
    {
        for (NSString *orderNum in [ubersDictionary allKeys])
        {
            if ([self.ubersCars objectForKey:orderNum] != nil)
            {
                //Update the location
                MKPointAnnotation *car = [self.ubersCars objectForKey:orderNum];
                [car setCoordinate:CLLocationCoordinate2DMake(0, 0)]; //Set based on how Ashwin returns the coordinates
                //TODO: set the bearing
            }
            else
            {
                //Instantiate a new mkpointannotation for that car
                MKPointAnnotation *car = [[MKPointAnnotation alloc]init];
                [car setCoordinate:CLLocationCoordinate2DMake(0, 0)];//Set based on how Ashwin returns the coordinates
                //TODO: set the bearing
                [car setTitle:[NSString stringWithFormat:@"%@", orderNum]];
                
                [self.mapView addAnnotation:car];
            }
        }
    }*/
}

/*- (void) prepareRoutes
{
    for (int i = 0; i < 4; i++)
    {
        //Get the route
        self.routeGenerator = [[routeGenerator alloc]init];
        NSMutableArray *routeMut = [routeGenerator getRouteAtIndex:(i+1)];
        //Show the route
        [self showRoute:routeMut withIndex:(i+1)];
    }
}

- (void)showRoute:(NSMutableArray *)routeMut withIndex:(int)intIndex {
    if (intIndex == 1)
    {
        intIndex_route1 = 0;
        [self manageUserMove1:routeMut];
    }
    else if (intIndex == 2)
    {
        intIndex_route2 = 0;
        [self manageUserMove2:routeMut];
    }
    else if (intIndex == 3)
    {
        intIndex_route3 = 0;
        [self manageUserMove3:routeMut];
    }
    else if (intIndex == 4)
    {
        intIndex_route4 = 0;
        [self manageUserMove4:routeMut];
    }
    else
    {
        NSLog(@"error inside showRoute");
    }
}

// Route 1 Methods
- (void)moveUser1:(CLLocation*)newLoc
{
    CLLocationCoordinate2D coords;
    coords.latitude = newLoc.coordinate.latitude;
    coords.longitude = newLoc.coordinate.longitude;
    
    [self.annotation1 setCoordinate:coords];
}

-(void)manageUserMove1:(NSMutableArray *)routeMut

{
    CLLocation *newLoc = [routeMut objectAtIndex:intIndex_route1];
    if (intIndex_route1 == 0) {
        self.annotation1 = [[MKPointAnnotation alloc] init];
        [self.annotation1 setTitle:@"1"];
    }
    [self moveUser1:newLoc];
    
    if(intIndex_route1 == 0){
        [self.mapView addAnnotation:self.annotation1];
    }
    
    if (intIndex_route1 < (routeMut.count-1))
    {
        intIndex_route1++;
        [self performSelector:@selector(manageUserMove1:) withObject:routeMut afterDelay:0.6];
    }
}*/
@end



