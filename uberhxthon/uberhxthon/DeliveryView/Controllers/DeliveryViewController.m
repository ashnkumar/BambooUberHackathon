//
//  DeliveryViewController.m
//  uberhxthon
//
//  Created by Catherine Jue on 4/26/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import "DeliveryViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <SpinKit/RTSpinKitView.h>
#import <POP/POP.h>

#import "AppConstants.h"
#import "ReceiptSlideOutViewController.h"
#import "RequestUberPopupViewController.h"
#import "PresentingAnimator.h"
#import "DismissingAnimator.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define METERS_PER_MILE 1609.344
#define CORNER_RADIUS 4
#define SLIDE_TIMING .25

@interface DeliveryViewController () <ReceiptPanelViewControllerDelegate, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate>
{
    int intIndex_route1;
    int intIndex_route2;
    int intIndex_route3;
    int intIndex_route4;

}

@property (nonatomic, strong) ReceiptSlideOutViewController *receiptPanelViewController;

// Receipt panel view
@property (nonatomic, assign) BOOL showingReceiptPanel;
@property (nonatomic, assign) BOOL showPanel;
@property (nonatomic, strong) UITapGestureRecognizer *mapTapRecognizer;
//@property (nonatomic, assign) CGPoint preVelocity;


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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupVariables];
    [self addLoadingView];
    [self setupMapView];
    [self setupReceiptPanelView];
    [self setupGestures];
    [self prepareRoutes];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.mapView.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated
{
    CLLocationCoordinate2D zoomLocation;
    
//    zoomLocation.latitude = self.locationManager.location.coordinate.latitude;
//    zoomLocation.longitude= self.locationManager.location.coordinate.longitude;
    
    // FAKE LOCATION for now in center of SF.
    //zoomLocation.latitude = 37.7316915;
    //zoomLocation.longitude = -122.4409091;
    
    zoomLocation.latitude =37.800980;
    zoomLocation.longitude=-122.412766;

    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 7.5*METERS_PER_MILE, 7.5*METERS_PER_MILE);
    //MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 1200, 1200);
    [self.mapView setRegion:viewRegion animated:YES];
}


- (void)setupGestures
{
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
    panRecognizer.minimumNumberOfTouches = 1;
    panRecognizer.maximumNumberOfTouches = 1;
    panRecognizer.delegate = self;
    
    [self.receiptPanelViewController.view addGestureRecognizer:panRecognizer];
}

- (void)setupVariables
{
    self.loadingSpinner = [[RTSpinKitView alloc]
                           initWithStyle:RTSpinKitViewStyleBounce
                           color:[AppConstants cashwinGreen]];
    
    // @TODO: Figure out how to get spinner in the right place autolayout
    CGRect newFrame = CGRectMake(500, 300, 20, 20);
    self.loadingSpinner.frame = newFrame;
}

- (void)setupReceiptPanelView
{
    self.receiptPanelViewController = [[ReceiptSlideOutViewController alloc]
                                       initWithNibName:@"ReceiptSlideOutView"
                                       bundle:nil];
    
    self.receiptPanelViewController.delegate = self;
    self.receiptPanelViewController.view.frame = CGRectMake(0, 630, self.receiptPanelViewController.view.frame.size.width, self.receiptPanelViewController.view.frame.size.height);
    
    [self.view addSubview:self.receiptPanelViewController.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Receipt Panel View

- (void)movePanelToOriginalPosition
{
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.receiptPanelViewController.view.frame = CGRectMake(0, 630, self.receiptPanelViewController.view.frame.size.width, self.receiptPanelViewController.view.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            self.receiptPanelViewController.panelUpButton.tag = 1;
            self.showingReceiptPanel = NO;
            [self.receiptPanelViewController removeAllCellBorders];
        }
    }];
}

- (void)movePanelUp
{
    [UIView animateWithDuration:SLIDE_TIMING
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
     
                     animations:^{
                         self.receiptPanelViewController.view.frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height);
                         
                     } completion:^(BOOL finished) {
                         self.receiptPanelViewController.panelUpButton.tag = 0;
                         self.showingReceiptPanel = YES;
                     }];
    
}

// @TODO: HACK -> this moves the panel up just one row, for the video to highlight receipt
// @TODO: If panel is already open, don't re-open it
- (void)movePanelUpOneRow
{
    [UIView animateWithDuration:SLIDE_TIMING
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
     
                     animations:^{
                         self.receiptPanelViewController.view.frame = CGRectMake(0, 373, self.view.frame.size.width, self.view.frame.size.height);
                         
                     } completion:^(BOOL finished) {
                         self.receiptPanelViewController.panelUpButton.tag = 0;
                         self.showingReceiptPanel = YES;
                     }];
}

- (void)highlightReceiptAtIndex:(int)receiptIndex
{
    NSIndexPath *indexPathToSelect = [NSIndexPath indexPathForRow:receiptIndex
                                                        inSection:0];
    [self.receiptPanelViewController highlightReceiptAtIndexPath:indexPathToSelect];
}

-(void)movePanel:(id)sender
{
    [[[(UITapGestureRecognizer *)sender view] layer] removeAllAnimations];
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer *)sender translationInView:self.view];
    CGPoint velocity = [(UIPanGestureRecognizer *)sender velocityInView:[sender view]];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        //        UIView *childView = nil;
        //
        //        if (velocity.x > 0){
        //            if (!_showingRightPanel) {
        //                childView = [self getLeftView];
        //            }
        //        } else {
        //            if (!_showingLeftPanel) {
        //                childView = [self getRightView];
        //            }
        //        }
        //
        //        [self.view sendSubviewToBack:childView];
        //        [[sender view] bringSubviewToFront:[(UIPanGestureRecognizer *)sender view]];
    }
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
        if (!_showPanel) {
            [self movePanelToOriginalPosition];
        } else {
            [self movePanelUp];
        }
    }
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
        if(velocity.y < 0) {
            _showPanel = [sender view].center.y < 970;
        } else {
            _showPanel = NO;
        }
        
        // @TODO: Depending on where they gesture to, change where menu lands
        //        _showPanel = abs([sender view].center.y - self.view.frame.size.height/2) > self.view.frame.size.height/2
        
        [sender view].center = CGPointMake([sender view].center.x, [sender view].center.y + translatedPoint.y);
        [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0,0) inView:self.view];
        
        //        // If you needed to check for a change in direction, you could use this code to do so.
        //        if(velocity.x*_preVelocity.x + velocity.y*_preVelocity.y > 0) {
        //            // NSLog(@"same direction");
        //        } else {
        //            // NSLog(@"opposite direction");
        //        }
        //        
        //        _preVelocity = velocity;
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



- (void)showRequestUberPopup {
    RequestUberPopupViewController *modalViewController = [RequestUberPopupViewController new];
    
    modalViewController.transitioningDelegate = self;
    modalViewController.modalPresentationStyle = UIModalPresentationCustom;
    
    [self presentViewController:modalViewController
                       animated:YES
                     completion:^{
                         NSLog(@"Completed presenting view controller");
                     }];
}


#pragma mark - Helpers

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
}

- (void)closePanelDueToMapTouch:(UITapGestureRecognizer *)recognizer
{
    [self movePanelToOriginalPosition];
}


// Adds a blur loading view to the screen while map is getting ready
// @TODO: Change this to whatever we want, blur looks a bit funky
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
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *AnnotationViewID = @"annotationViewID";
    
    MKAnnotationView *annotationView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    if (annotationView == nil)
    {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    }
    
    if ([annotation.title isEqualToString:@"1"])
    {
        annotationView.image = [UIImage imageNamed:@"uber_route1.png"];

    }
    else if ([annotation.title isEqualToString:@"2"])
    {
        annotationView.image = [UIImage imageNamed:@"uber_route2.png"];
    }
    else if ([annotation.title isEqualToString:@"3"])
    {
        annotationView.image = [UIImage imageNamed:@"uber_route3.png"];
    }
    else if ([annotation.title isEqualToString:@"4"])
    {
        annotationView.image = [UIImage imageNamed:@"uber_route4.png"];
    }
    else if ([annotation.title isEqualToString:@"5"])
    {
        annotationView.image = [UIImage imageNamed:@"map-vehicle-icon-sm.png"];
    }
    else
    {
        NSLog(@"couldn't find annotation title");
    }
    annotationView.annotation = annotation;
    //annotationView.centerOffset = CGPointMake(0, -annotationView.image.size.height / 2);
    
    return annotationView;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer *renderer =
    [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 3.0;
    return renderer;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [self highlightReceiptAtIndex:1];
    [self movePanelUpOneRow];
}

#pragma mark - Car Animations
- (void) prepareRoutes
{
    // Set the routes
    /* Route 1: Aquatic Park to UN Plaza */
    CLLocationCoordinate2D route1src_cl = CLLocationCoordinate2DMake(37.807734, -122.420093);
    CLLocationCoordinate2D route1dest_cl = CLLocationCoordinate2DMake(37.780604, -122.414257);

    /* Route 2: Aquatic Park to Church of Scientology */
    CLLocationCoordinate2D route2src_cl = CLLocationCoordinate2DMake(37.795798, -122.403528);
    CLLocationCoordinate2D route2dest_cl = CLLocationCoordinate2DMake(37.807734, -122.420093);

    
     /* Route 3: USNaval Recruiting Station to St Brigid School */
    CLLocationCoordinate2D route3src_cl = CLLocationCoordinate2DMake(37.795385, -122.424678);
    CLLocationCoordinate2D route3dest_cl = CLLocationCoordinate2DMake(37.798726, -122.398392);

    
     /* Route 4: Academy of Art to Chinese United Method Church */
    CLLocationCoordinate2D route4src_cl = CLLocationCoordinate2DMake(37.795250, -122.408020);
    CLLocationCoordinate2D route4dest_cl = CLLocationCoordinate2DMake(37.807483, -122.410278);
    
        /*for (int i = 0; i < 4; i++)
        {
            MKDirectionsRequest *routereq = [[MKDirectionsRequest alloc]init];
            [routereq setRequestsAlternateRoutes:NO];
            
            switch (i)
            {
                case 0:
                {
                    MKPlacemark *route1src_p = [[MKPlacemark alloc] initWithCoordinate:route1src_cl addressDictionary:nil];
                    MKPlacemark *route1dest_p = [[MKPlacemark alloc] initWithCoordinate:route1dest_cl addressDictionary:nil];
                    MKMapItem *route1src_mki = [[MKMapItem alloc] initWithPlacemark:route1src_p];
                    MKMapItem *route1dest_mki = [[MKMapItem alloc] initWithPlacemark:route1dest_p];
                    [routereq setSource:route1src_mki];
                    [routereq setDestination:route1dest_mki];
                    break;
                }
                case 1:
                {
                    MKPlacemark *route2src_p = [[MKPlacemark alloc] initWithCoordinate:route2src_cl addressDictionary:nil];
                    MKPlacemark *route2dest_p = [[MKPlacemark alloc] initWithCoordinate:route2dest_cl addressDictionary:nil];
                    MKMapItem *route2src_mki = [[MKMapItem alloc] initWithPlacemark:route2src_p];
                    MKMapItem *route2dest_mki = [[MKMapItem alloc] initWithPlacemark:route2dest_p];
                    [routereq setSource:route2src_mki];
                    [routereq setDestination:route2dest_mki];
                    break;
                }
                case 2:
                {
                    MKPlacemark *route3src_p = [[MKPlacemark alloc] initWithCoordinate:route3src_cl addressDictionary:nil];
                    MKPlacemark *route3dest_p = [[MKPlacemark alloc] initWithCoordinate:route3dest_cl addressDictionary:nil];
                    MKMapItem *route3src_mki = [[MKMapItem alloc] initWithPlacemark:route3src_p];
                    MKMapItem *route3dest_mki = [[MKMapItem alloc] initWithPlacemark:route3dest_p];
                    [routereq setSource:route3src_mki];
                    [routereq setDestination:route3dest_mki];
                    break;
                }
                case 3:
                {
                    MKPlacemark *route4src_p = [[MKPlacemark alloc] initWithCoordinate:route4src_cl addressDictionary:nil];
                    MKPlacemark *route4dest_p = [[MKPlacemark alloc] initWithCoordinate:route4dest_cl addressDictionary:nil];
                    MKMapItem *route4src_mki = [[MKMapItem alloc] initWithPlacemark:route4src_p];
                    MKMapItem *route4dest_mki = [[MKMapItem alloc] initWithPlacemark:route4dest_p];
                    [routereq setSource:route4src_mki];
                    [routereq setDestination:route4dest_mki];
                    break;
                }
                default:
                    break;
            }
            MKDirections *routedirections = [[MKDirections alloc]initWithRequest:routereq];
            [routedirections calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                if (error) {
                    NSLog(@"Couldn't calculate route %i directions", i+1);
                }
                else {
                    [self showRoute:response withIndex:(i+1)];
                }
            }];
        }*/
    
    self.routeGenerator = [[routeGenerator alloc]init];
    NSMutableArray *r = [routeGenerator getRouteAtIndex:1];
    for (int i = 0; i < [r count]; i++)
    {
        CLLocation *loc = [r objectAtIndex:i];
        double lat = loc.coordinate.latitude;
        double lon = loc.coordinate.longitude;
        NSLog(@"lat: %f, lon: %f", lat, lon);
    }
    [self showRoute:r withIndex:1];
    /*for (int i = 0; i < 4; i++)
    {
        //Get the route
        NSMutableArray *routeMut = [routeGenerator getRouteAtIndex:(i+1)];
        //Show the route
        [self showRoute:routeMut withIndex:(i+1)];
    }*/
}

- (void)showRoute:(NSMutableArray *)routeMut withIndex:(int)intIndex {
    /*NSAssert([response.routes count] == 1, @"Response.routes didn't return 1");
    
       MKRoute *route = response.routes.firstObject;
    //[self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];

       NSUInteger pointCount = route.polyline.pointCount;
    

        //TODO: double check this allocates enough spots for all the coordinates
        CLLocationCoordinate2D coordArr[pointCount];
        [route.polyline getCoordinates:coordArr range:NSMakeRange(0, pointCount)];
    
    
        NSMutableArray *routeMut = [[NSMutableArray alloc]init];
        
        //NSLog(@"route %i's pointCount = %lu", intIndex, pointCount);
        for (int c=0; c < pointCount; c++)
        {
            NSLog(@"routeCoordinates[%i] = %f, %f", c, coordArr[c].latitude, coordArr[c].longitude);
            if (c > 0)
            {
                CLLocation *nextloc = [[CLLocation alloc] initWithLatitude:coordArr[c].latitude longitude:coordArr[c].longitude];
                [routeMut addObject:nextloc];
            }
            
        }*/
    
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

/* Route 1 Methods */
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
        [self performSelector:@selector(manageUserMove1:) withObject:routeMut afterDelay:0.1];
    }
}


/* Route 2 Methods */
- (void)moveUser2:(CLLocation *)newLoc
{
    CLLocationCoordinate2D coords;
    coords.latitude = newLoc.coordinate.latitude;
    coords.longitude = newLoc.coordinate.longitude;
    
    [self.annotation2 setCoordinate:coords];
}

-(void)manageUserMove2:(NSMutableArray *)routeMut

{
    CLLocation *newLoc = [routeMut objectAtIndex:intIndex_route2];
    if (intIndex_route2 == 0) {
        self.annotation2 = [[MKPointAnnotation alloc] init];
        [self.annotation2 setTitle:@"2"];
    }
    [self moveUser2:newLoc];
    
    if(intIndex_route2 == 0){
        [self.mapView addAnnotation:self.annotation2];
    }
    
    if (intIndex_route2 < (routeMut.count-1))
    {
        intIndex_route2++;
        [self performSelector:@selector(manageUserMove2:) withObject:routeMut afterDelay:3.5];
    }
}

/* Route 3 Methods */
- (void)moveUser3:(CLLocation *)newLoc
{
    CLLocationCoordinate2D coords;
    coords.latitude = newLoc.coordinate.latitude;
    coords.longitude = newLoc.coordinate.longitude;
    
    [self.annotation3 setCoordinate:coords];
}

-(void)manageUserMove3:(NSMutableArray *)routeMut

{
    CLLocation *newLoc = [routeMut objectAtIndex:intIndex_route3];
    if (intIndex_route3 == 0) {
        self.annotation3 = [[MKPointAnnotation alloc] init];
        [self.annotation3 setTitle:@"3"];
    }
    [self moveUser3:newLoc];
    
    if(intIndex_route3 == 0){
        [self.mapView addAnnotation:self.annotation3];
    }
    
    if (intIndex_route3 < (routeMut.count-1))
    {
        intIndex_route3++;
        [self performSelector:@selector(manageUserMove3:) withObject:routeMut afterDelay:3.5];
    }

}

/* Route 4 Methods */
- (void)moveUser4:(CLLocation *)newLoc
{
    CLLocationCoordinate2D coords;
    coords.latitude = newLoc.coordinate.latitude;
    coords.longitude = newLoc.coordinate.longitude;
    
    [self.annotation4 setCoordinate:coords];
}

-(void)manageUserMove4:(NSMutableArray *)routeMut

{
    CLLocation *newLoc = [routeMut objectAtIndex:intIndex_route4];
    if (intIndex_route4 == 0) {
        self.annotation4 = [[MKPointAnnotation alloc] init];
        [self.annotation4 setTitle:@"4"];
    }
    [self moveUser4:newLoc];
    
    if(intIndex_route4 == 0){
        [self.mapView addAnnotation:self.annotation4];
    }
    
    if (intIndex_route4 < (routeMut.count-1))
    {
        intIndex_route4++;
        [self performSelector:@selector(manageUserMove4:) withObject:routeMut afterDelay:4.5];
    }

}

- (IBAction)tappedRequestPickup:(id)sender
{
    //Display a loading swirly icon
    //Display a message that an uber is requested
    //Now create an instantiation of a car for tapping to highlight receipt
    MKPointAnnotation *annotation_static = [[MKPointAnnotation alloc]init];
    CLLocationCoordinate2D static_uber_coord = CLLocationCoordinate2DMake(37.799539, -122.410213);
    [annotation_static setCoordinate:static_uber_coord];
    [annotation_static setTitle:@"5"];
    //Shift the map to where this pin is
    //Make this animated via CurveInEaseOut
    [self.mapView addAnnotation:annotation_static];
    
    //If we have time, start moving the car

}
@end



