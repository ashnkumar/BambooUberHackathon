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
@property (nonatomic, strong) RequestUberPopupViewController *loginPopup;
@property (nonatomic, strong) NSMutableDictionary *ubersCars;

// Loading view / spinner
@property (strong, nonatomic) UIVisualEffectView *blurEffectView;
//@property (strong, nonatomic) RTSpinKitView *loadingSpinner;


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

    
    //MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 7.5*METERS_PER_MILE, 7.5*METERS_PER_MILE);
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 1100, 1100);
    [self.mapView setRegion:viewRegion animated:YES];
}


#pragma mark - Helpers
- (void)setupVariables
{
    screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    /*self.loadingSpinner = [[RTSpinKitView alloc]
                           initWithStyle:RTSpinKitViewStyleBounce
                           color:[AppConstants cashwinGreen]];
    
    float spinnerx = screenWidth / 2 - 10;
    float spinnery = screenHeight / 2 - 10;
    CGRect newFrame = CGRectMake(spinnerx, spinnery, 20, 20);
    self.loadingSpinner.frame = newFrame;*/
    
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
    //[self.view addSubview:self.loadingSpinner];
    
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
    self.receiptPanelViewController.view.frame = CGRectMake(0, screenHeight-140, self.receiptPanelViewController.view.frame.size.width, 0); //CJ //self.receiptPanelViewController.view.frame.size.height);
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
            self.detailedReceipt.view.layer.opacity = 0;
            self.showingDetailedReceipt = NO;
        }];
    }
    else
    {
        NSLog(@"error - showingDetailedReceipt not set");
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
    
    //[self.loadingSpinner removeFromSuperview];
    self.receiptPanelViewController.view.alpha = 1.0f;
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
        self.receiptPanelViewController.view.frame = CGRectMake(0, screenHeight-140, self.receiptPanelViewController.view.frame.size.width, 0); //self.receiptPanelViewController.view.frame.size.height);
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
                         self.receiptPanelViewController.view.frame = CGRectMake(0, screenHeight-140-30-20-20-210, self.receiptPanelViewController.view.frame.size.width, 30 + 20 + 20 + 210); //CJ self.view.frame.size.height);// self.receiptPanelViewController.view.frame.size.height-325);
                     } completion:^(BOOL finished) {
                         self.receiptPanelViewController.panelUpButton.tag = PANELOPEN;
                         self.showingReceiptPanel = YES;
                     }];
}

//Move panel up two rows
//Used for receiptVC's manual call
- (void)movePanelTwoRows
{
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                        //receipt panel view controller frame: (0, screenHeight-SIZEOFTWOROWS), frameHeight = screenHeight-TWOROWS
        self.receiptPanelViewController.view.frame = CGRectMake(0, screenHeight-140-20-20-20-20-20-210-210, self.view.frame.size.width, 20 + 20 + 20 + 20 + 20 + 210 + 210); //self.view.frame.size.height);// self.view.frame.size.height-40);
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
        
        //Set the collectionview frame
        //Convert translation to its absolute value to determine collectionview frame height
        float absTranslation = fabsf(translation.y);
        
        //Check if going up or down
        CGPoint velocity = [recognizer velocityInView:self.view];
        
        //If going up
        if(velocity.y < 0)
        {
            //Gesture went down so increase receipt panel by the translation amount
            self.receiptPanelViewController.view.frame = CGRectMake(self.receiptPanelViewController.view.frame.origin.x, self.receiptPanelViewController.view.frame.origin.y, self.receiptPanelViewController.view.frame.size.width, self.receiptPanelViewController.view.frame.size.height + absTranslation);
        }
        //Else, is going down
        else
        {
            //Gesture went up so decrease receipt panel by the translation amount
            self.receiptPanelViewController.view.frame = CGRectMake(self.receiptPanelViewController.view.frame.origin.x, self.receiptPanelViewController.view.frame.origin.y, self.receiptPanelViewController.view.frame.size.width, self.receiptPanelViewController.view.frame.size.height - absTranslation);
        }
    }
}

//Present the Uber-requesting popup until that receipt's status changes on the server
- (void)requestedUber
{
    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.dimView.layer.opacity = 0.5;
    } completion:^(BOOL finished) {
        self.requestUberPopupVC = [[RequestUberPopupViewController alloc]init];
        [self.requestUberPopupVC setFirstStatus:@"Requesting Uber..."];
        self.requestUberPopupVC.delegate = self;
        self.requestUberPopupVC.transitioningDelegate = self;
        self.requestUberPopupVC.modalPresentationStyle = UIModalPresentationCustom;
        
        [self presentViewController:self.requestUberPopupVC animated:YES completion:nil];
    }];
}

- (void)removeRequestingReceiptStatusVC
{
    [self.requestUberPopupVC uberRequestComplete:@"Uber En Route!"];
}

//Remove the Uber-requesting popup
- (void)dismissedRequestUberPopup
{
    [UIView animateWithDuration:.2 delay:.1 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.dimView.layer.opacity = 0;
    } completion:^(BOOL finished) {
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
    [self updateCarLocations:ubersDictionary];
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
    NSString *bearingString = annotation.subtitle;
    float bearing = [bearingString floatValue];
    
    if (bearing == 0)
    {

    }
    else if (bearing > 0 && bearing < 30)
    {
        annotationView.image = [UIImage imageNamed:@"uber12"];
    }
    else if (bearing >= 30 && bearing < 60)
    {
        annotationView.image = [UIImage imageNamed:@"uber1"];
    }
    else if (bearing >= 60 && bearing < 90)
    {
        annotationView.image = [UIImage imageNamed:@"uber2"];
    }
    else if (bearing == 90)
    {
        annotationView.image = [UIImage imageNamed:@"map-vehicle-icon-sm.png"];
    }
    else if (bearing > 90 && bearing < 120)
    {
        annotationView.image = [UIImage imageNamed:@"uber4"];
    }
    else if (bearing >= 120 && bearing < 150)
    {
        annotationView.image = [UIImage imageNamed:@"uber5"];
    }
    else if (bearing >= 150 && bearing < 180)
    {
        annotationView.image = [UIImage imageNamed:@"uber6"];
    }
    else if (bearing < 0 && bearing >= -30)
    {
        //Go counterclockwise backward
        annotationView.image = [UIImage imageNamed:@"uber11"];
    }
    else if (bearing < -30 && bearing >= -60)
    {
        annotationView.image = [UIImage imageNamed:@"uber10"];
    }
    else if (bearing < -60 && bearing >= -90)
    {
        annotationView.image = [UIImage imageNamed:@"uber9"];
    }
    else if (bearing < -90 && bearing >= -120)
    {
        annotationView.image = [UIImage imageNamed:@"uber8"];
    }
    else if (bearing < -120 && bearing >= -150)
    {
        annotationView.image = [UIImage imageNamed:@"uber7"];
    }
    else if (bearing < -150 && bearing >= -180)
    {
        annotationView.image = [UIImage imageNamed:@"uber6"];
    }
    else
    {
        annotationView.image = [UIImage imageNamed:@"map-vehicle-icon-sm.png"];
    }
    
    annotationView.annotation = annotation;
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    MKPointAnnotation *car = view.annotation;
    int orderNum = [car.title intValue];
    [self.receiptPanelViewController scrollToOrderNum:orderNum andHighlight:YES];
}

//Set the car annotations
- (void)updateCarLocations:(NSDictionary *)ubersDictionary
{
    if ([ubersDictionary count] > 0)
    {
        [self.mapView removeAnnotations:self.mapView.annotations];
        NSMutableArray *cars = [[NSMutableArray alloc]init];
        for (NSString *orderNum in [ubersDictionary allKeys])
        {
            MKPointAnnotation *car = [[MKPointAnnotation alloc]init];
            car.title = orderNum;
            NSString* uberLatitude = [[ubersDictionary objectForKey:orderNum] objectForKey:@"uberLatitude"];
            NSString* uberLongitude = [[ubersDictionary objectForKey:orderNum] objectForKey:@"uberLongitude"];
            NSString* bearing = [[ubersDictionary objectForKey:orderNum] objectForKey:@"uberBearing"];
            NSLog(@"NSSTRING UBERLATITUDE: %@, UBERLONGITUDE: %@", uberLatitude, uberLongitude);
            car.subtitle = bearing;
            NSLog(@"bearing: %@", car.subtitle);
            
            [car setCoordinate:CLLocationCoordinate2DMake([uberLatitude floatValue], [uberLongitude floatValue])];
            [cars addObject:car];
        }
        [self.mapView addAnnotations:cars];
    }
    else
    {
        [self.mapView removeAnnotations:self.mapView.annotations];
    }
}

@end



