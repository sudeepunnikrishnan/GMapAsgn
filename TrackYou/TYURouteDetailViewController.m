//
//  TYURouteDetailViewController.m
//  TrackYou
//
//  Created by Sudeep Unnikrishnan on 7/24/15.
//  Copyright (c) 2015 Sudeep Unnikrishnan. All rights reserved.
//

#import "TYURouteDetailViewController.h"
#import "Route.h"
#import "TYUPolyLineSegment.h"
#import "UserLocation.h"
#import "TYUUtility.h"
#import <GoogleMaps/GoogleMaps.h>


@interface TYURouteDetailViewController ()
{
    GMSMarker *locationMarker;
    GMSMarker *originMarker;
    GMSMarker *destinationMarker;
}

@property (strong, nonatomic) NSArray *colorSegmentArray;


@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (nonatomic, weak) IBOutlet UILabel *timeValueLbl;
@property (nonatomic, weak) IBOutlet UILabel *distanceValueLbl;
@property (nonatomic, weak) IBOutlet UILabel *speedValueLbl;

@end

@implementation TYURouteDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureView];
    [self loadMap];
}

- (void)configureView
{
    self.distanceValueLbl.text = [TYUUtility getStringForDistance:self.route.distance.floatValue];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    self.timeValueLbl.text = [formatter stringFromDate:self.route.timeStamp];
    
    self.timeValueLbl.text = [NSString stringWithFormat:@"%@",[TYUUtility getStringForSecondCount:self.route.time.intValue usingLongFormat:YES]];
    
    self.speedValueLbl.text = [NSString stringWithFormat:@"%@",[TYUUtility getStringForAvgSpeedFromDist:self.route.distance.floatValue overTime:self.route.time.intValue]];
    
 
}

- (void)loadMap
{
    if (self.route.userLocations.count > 0) {
        
        self.mapView.hidden = NO;
        
        // set the map bounds
        [self.mapView setCamera:[self mapRegion]];
        
        // make the line(s!) on the map
        [self createRoute];
        
        
    } else {
        
        // no locations were found!
        self.mapView.hidden = YES;
        
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:@"Sorry, this route has no locations available."
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - Public

- (void)setRoute:(Route *)newRoute
{
    if (_route != newRoute) {
        _route = newRoute;
        
        self.colorSegmentArray = [TYUUtility getColorSegmentsForLocations:newRoute.userLocations.array];
    }
}
/**
 *  Setting up map region
 *
 *  @return <#return value description#>
 */
- (GMSCameraPosition *)mapRegion
{
    GMSCameraPosition * region;
    UserLocation *initialLoc = self.route.userLocations.firstObject;
    
    float minLat = initialLoc.latitude.floatValue;
    float minLng = initialLoc.longitude.floatValue;
    float maxLat = initialLoc.latitude.floatValue;
    float maxLng = initialLoc.longitude.floatValue;
    
    for (UserLocation *location in self.route.userLocations) {
        if (location.latitude.floatValue < minLat) {
            minLat = location.latitude.floatValue;
        }
        if (location.longitude.floatValue < minLng) {
            minLng = location.longitude.floatValue;
        }
        if (location.latitude.floatValue > maxLat) {
            maxLat = location.latitude.floatValue;
        }
        if (location.longitude.floatValue > maxLng) {
            maxLng = location.longitude.floatValue;
        }
    }
    region = [GMSCameraPosition cameraWithLatitude:((minLat + maxLat) / 2.0f) longitude:((minLng + maxLng) / 2.0f) zoom:2];
    return region;
}
/**
 *  Method that defines the path
 */
-(void)createRoute
{
    UserLocation *initialLoc = self.route.userLocations.firstObject;
    UserLocation *lastLoc = self.route.userLocations.lastObject;
    self.mapView.camera = [GMSCameraPosition cameraWithLatitude:initialLoc.latitude.doubleValue longitude:initialLoc.longitude.doubleValue zoom:14.0];
    
    CLLocationCoordinate2D coord[2];
    coord[0].latitude = initialLoc.latitude.doubleValue;
    coord[0].longitude = initialLoc.longitude.doubleValue;
    originMarker = [GMSMarker markerWithPosition:coord[0]];
    originMarker.map = self.mapView;
    originMarker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
    originMarker.title = @"Source";
    
    coord[1].latitude = lastLoc.latitude.doubleValue;
    coord[1].longitude = lastLoc.longitude.doubleValue;
    destinationMarker = [GMSMarker markerWithPosition:coord[1]];
    destinationMarker.map = self.mapView;
    destinationMarker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
    destinationMarker.title = @"Destination";
    
    for(TYUPolyLineSegment *polyLineObj in self.colorSegmentArray)
    {
        GMSPolyline *polyline = [GMSPolyline polylineWithPath:polyLineObj.path];
        polyline.strokeColor = polyLineObj.color;
        polyline.strokeWidth = 5.f;
        polyline.map = self.mapView;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
