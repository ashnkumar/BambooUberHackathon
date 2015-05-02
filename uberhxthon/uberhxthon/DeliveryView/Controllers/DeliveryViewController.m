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
#import "ReceiptSlideOutViewController.h"
#import "AppConstants.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define METERS_PER_MILE 1609.344
#define CORNER_RADIUS 4
#define SLIDE_TIMING .25

@interface DeliveryViewController () <ReceiptPanelViewControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) ReceiptSlideOutViewController *receiptPanelViewController;
@property (nonatomic, assign) BOOL showingReceiptPanel;
@property (nonatomic, assign) BOOL showPanel;
//@property (nonatomic, assign) CGPoint preVelocity;

@property (strong, nonatomic) UIVisualEffectView *blurEffectView;
@property (strong, nonatomic) RTSpinKitView *loadingSpinner;
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
    zoomLocation.latitude = 37.7316915;
    zoomLocation.longitude = -122.4409091;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 7.5*METERS_PER_MILE, 7.5*METERS_PER_MILE);
    
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
                           color:[AppConstants mainAppThemeColor]];
    
    // @TODO: Figure out how to get spinner in the right place autolayout
    CGRect newFrame = CGRectMake(500, 300, 20, 20);
    self.loadingSpinner.frame = newFrame;
}

- (void)setupReceiptPanelView
{
    self.receiptPanelViewController = [[ReceiptSlideOutViewController alloc] initWithNibName:@"ReceiptSlideOutView" bundle:nil];
    self.receiptPanelViewController.delegate = self;
    self.receiptPanelViewController.view.frame = CGRectMake(0, 650, self.receiptPanelViewController.view.frame.size.width, self.receiptPanelViewController.view.frame.size.height);
    
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
        self.receiptPanelViewController.view.frame = CGRectMake(0, 650, self.receiptPanelViewController.view.frame.size.width, self.receiptPanelViewController.view.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            self.receiptPanelViewController.panelUpButton.tag = 1;
            self.showingReceiptPanel = NO;
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

@end





