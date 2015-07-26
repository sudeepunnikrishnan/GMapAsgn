//
//  TYUTrackViewController.m
//  TrackYou
//
//  Created by Sudeep Unnikrishnan on 7/23/15.
//  Copyright (c) 2015 Sudeep Unnikrishnan. All rights reserved.
//

#import "TYUTrackViewController.h"
#import <CoreMotion/CoreMotion.h>
#import <GoogleMaps/GoogleMaps.h>
#import "Route.h"
#import "UserLocation.h"
#import "TYUUtility.h"

@interface TYUTrackViewController ()<CLLocationManagerDelegate,UIActionSheetDelegate>
{
    NSString *routeName;
}
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) Route *route;
@property (nonatomic, weak) IBOutlet UILabel *accValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeValueLbl;
@property (nonatomic, weak) IBOutlet UILabel *distanceValueLbl;
@property (nonatomic, weak) IBOutlet UILabel *speedValueLbl;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property int seconds;
@property float distance;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *stopBarbtn;


@end

@implementation TYUTrackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:12.9667 longitude:77.5667 zoom:8.0];
    _mapView.camera = camera;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.accValueLabel.hidden = YES;
    self.timeValueLbl.hidden = YES;
    self.distanceValueLbl.hidden = YES;
    self.speedValueLbl.hidden = YES;
    self.mapView.hidden = YES;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
}

/**
 *  Method fired when user starts location tracking
 *
 *  @param sender <#sender description#>
 */
-(IBAction)startPressed:(id)sender
{
    // hide the start UI
    self.accValueLabel.hidden = NO;
    
    // show the running UI
    self.timeValueLbl.hidden = NO;
    self.distanceValueLbl.hidden = NO;
    self.speedValueLbl.hidden = NO;
    self.mapView.hidden = NO;
    self.seconds = 0;
    self.distanceValueLbl.text = @"";
    self.speedValueLbl.text = @"";
    self.timeValueLbl.text = @"";
    self.accValueLabel.text = @"";
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .2;
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 [self showAccelertionData:accelerometerData.acceleration];
                                                 if(error){
                                                     
                                                     NSLog(@"%@", error);
                                                 }}];
    
    // initialize the timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self selector:@selector(updateEverySecond) userInfo:nil repeats:YES];
    
    self.distance = 0;
    self.locations = [NSMutableArray array];
    [self startLocationUpdates];
}

/**
 *  Method fired when accelerometer data is received
 *
 *  @param acceleration <#acceleration description#>
 */
-(void)showAccelertionData:(CMAcceleration)acceleration
{
    double accel = sqrt(acceleration.x*acceleration.x+acceleration.y*acceleration.y+acceleration.z*acceleration.z);
    NSString *squareSymbol = @"\u00B2";
    dispatch_async(dispatch_get_main_queue(), ^{
    self.accValueLabel.text = [NSString stringWithFormat:@"%.2f m/sec%@ (X:%.2f Y:%.2f Z:%.2f)",accel,squareSymbol,acceleration.x,acceleration.y,acceleration.z];
        [self.view layoutIfNeeded];
    });
}

/**
 *  Method fired for the timer
 */
- (void)updateEverySecond
{
    self.seconds++;
    [self updateLabels];
}

/**
 *  Method called when stop button clicked
 *
 *  @param sender <#sender description#>
 */
- (IBAction)stopPressed:(id)sender
{
    if(!self.mapView.hidden)
    {
    [self.locationManager stopUpdatingLocation];
    _mapView.settings.myLocationButton = NO;
    _mapView.myLocationEnabled = NO;
    [self.timer invalidate];
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Tell what to do?"
                                          message:@"Choose"
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *saveAction = [UIAlertAction
                                   actionWithTitle:@"Save"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [self performSelector:@selector(showAlertForRouteSave) withObject:nil afterDelay:0.7];
                                   }];
    UIAlertAction *discardAction = [UIAlertAction
                               actionWithTitle:@"Discard"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [self.navigationController popToRootViewControllerAnimated:YES];
                               }];
    [alertController addAction:saveAction];
    [alertController addAction:discardAction];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        CGRect rect = CGRectMake(0,0, [[sender view] frame].size.width, [[sender view] frame].size.height);
        popover.sourceView = [sender view];
        popover.sourceRect = rect ;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
    }
}

/**
 *  Method to update UIlabels
 */
- (void)updateLabels
{
    self.timeValueLbl.text = [NSString stringWithFormat:@"%@",  [TYUUtility getStringForSecondCount:self.seconds usingLongFormat:NO]];
    self.distanceValueLbl.text = [NSString stringWithFormat:@"%@", [TYUUtility getStringForDistance:self.distance]];
    self.speedValueLbl.text = [NSString stringWithFormat:@"%@",  [TYUUtility getStringForAvgSpeedFromDist:self.distance overTime:self.seconds]];
}

/**
 *  Method initiating the location updates
 */
- (void)startLocationUpdates
{
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.activityType = CLActivityTypeFitness;
    self.locationManager.distanceFilter = 10; // meters
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    _mapView.settings.myLocationButton = true;
    _mapView.settings.compassButton = true;
    _mapView.myLocationEnabled = YES;
}

#pragma mark - UIActionSheetDelegate

/**
 *  Actionsheet delegate containing option for save and discard of route.
 *
 *  @param actionSheet <#actionSheet description#>
 *  @param buttonIndex <#buttonIndex description#>
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.locationManager stopUpdatingLocation];
    // save
    if (buttonIndex == 0) {
        
    // discard
    } else if (buttonIndex == 1) {
        
    }
}

/**
 *  Alert comes to save the route with a title.
 */
-(void)showAlertForRouteSave
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Enter Title to Path"
                                          message:@"Save"
                                          preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"Title PlaceHolder", @"Route Title");
     }];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *routeTitle = alertController.textFields.firstObject;
                                   routeName = routeTitle.text;
                                   [self saveRoute];
                               }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    

}

#pragma mark - CLLocationManagerDelegate
/**
 *  Dlegate method containing the code for drawing the color pattern and called at each location updated.
 *
 *  @param manager   <#manager description#>
 *  @param locations <#locations description#>
 */
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *newLocation in locations) {
        
        NSDate *eventDate = newLocation.timestamp;
        
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude zoom:16.0];
        _mapView.camera = camera;
        
        if (fabs(howRecent) < 10.0 && newLocation.horizontalAccuracy < 20) {
            
            // update distance
            if (self.locations.count > 0) {
                self.distance += [newLocation distanceFromLocation:self.locations.lastObject];
                
                CLLocationCoordinate2D coords[2];
                coords[0] = ((CLLocation *)self.locations.lastObject).coordinate;
                coords[1] = newLocation.coordinate;
                GMSMutablePath *path = [GMSMutablePath path];
                [path addLatitude:coords[0].latitude longitude:coords[0].longitude];
                [path addLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
                
                GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
                
                double speed = (self.distance/(double)self.seconds) * (18/5);
                if(speed < 20)
                {
                    polyline.strokeColor = [UIColor greenColor];
                }
                else if (speed < 40)
                {
                    polyline.strokeColor = [UIColor yellowColor];
                }
                else
                {
                    polyline.strokeColor = [UIColor redColor];
                }
                polyline.strokeWidth = 5.f;
                polyline.map = self.mapView;
            }
            [self.locations addObject:newLocation];
        }
    }
}

/**
 *  Method that performs save operation of the travelled route.
 */
- (void)saveRoute
{
    Route *newRoute = [NSEntityDescription insertNewObjectForEntityForName:@"Route" inManagedObjectContext:self.managedObjectContext];
    
    newRoute.distance = [NSNumber numberWithFloat:self.distance];
    newRoute.time = [NSNumber numberWithInt:self.seconds];
    newRoute.timeStamp = [NSDate date];
    newRoute.routeTitle = routeName;
    
    NSMutableArray *locationArray = [NSMutableArray array];
    for (CLLocation *location in self.locations) {
        UserLocation *userLocObj = [NSEntityDescription insertNewObjectForEntityForName:@"UserLocation" inManagedObjectContext:self.managedObjectContext];
        
        userLocObj.timeStamp = location.timestamp;
        userLocObj.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
        userLocObj.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
        [locationArray addObject:userLocObj];
    }
    newRoute.userLocations = [NSOrderedSet orderedSetWithArray:locationArray];
    self.route = newRoute;
    // Save the context.
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

/**
 *  Share action to share current user location through mail
 *
 *  @param sender <#sender description#>
 */
- (IBAction)shareAction:(id)sender {
    
    if([self.locations count])
    {
     CLLocation *loc = [self.locations lastObject];
     NSString *texttoshare = [NSString stringWithFormat:@"My Current Location:\nLatitude:%.2f\nLongitude:%.2f",loc.coordinate.latitude,loc.coordinate.longitude];
     NSArray *objectsToShare = @[texttoshare];
    
     UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
     // Exclude all activities except Mail.
     NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                    UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
     controller.excludedActivityTypes = excludedActivities;
     [controller setValue:@"CURRENT LOCATION" forKey:@"subject"];
     [self presentViewController:controller animated:YES completion:nil];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    //[_mapView removeObserver:self forKeyPath:@"myLocation" context:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
