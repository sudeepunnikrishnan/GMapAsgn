//
//  TYUUtility.m
//  TrackYou
//
//  Created by Sudeep Unnikrishnan on 7/24/15.
//  Copyright (c) 2015 Sudeep Unnikrishnan. All rights reserved.
//

#import "TYUUtility.h"
#import "UserLocation.h"
#import "TYUPolyLineSegment.h"

static float const metersInKM = 1000;
//static const int idealSmoothReachSize = 33; // about 133 locations/mi

@implementation TYUUtility

+ (NSString *)getStringForDistance:(float)meters {
    
    float unitDivider;
    NSString *unitName;
    unitName = @"km";
    // to get from meters to kilometers divide by this
    unitDivider = metersInKM;
    return [NSString stringWithFormat:@"%.2f %@", (meters / unitDivider), unitName];
}

+ (NSString *)getStringForSecondCount:(int)seconds usingLongFormat:(BOOL)longFormat
{

    int remainingSeconds = seconds;
    
    int hours = remainingSeconds / 3600;
    
    remainingSeconds = remainingSeconds - hours * 3600;
    
    int minutes = remainingSeconds / 60;
    
    remainingSeconds = remainingSeconds - minutes * 60;
    
    if (longFormat) {
        if (hours > 0) {
            return [NSString stringWithFormat:@"%ihr %imin %isec", hours, minutes, remainingSeconds];
            
        } else if (minutes > 0) {
            return [NSString stringWithFormat:@"%imin %isec", minutes, remainingSeconds];
            
        } else {
            return [NSString stringWithFormat:@"%isec", remainingSeconds];
        }
    } else {
        if (hours > 0) {
            return [NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, remainingSeconds];
            
        } else if (minutes > 0) {
            return [NSString stringWithFormat:@"%02i:%02i", minutes, remainingSeconds];
            
        } else {
            return [NSString stringWithFormat:@"00:%02i", remainingSeconds];
        }
    }
}

+ (NSString *)getStringForAvgSpeedFromDist:(float)meters overTime:(int)seconds
{
    if (seconds == 0 || meters == 0) {
        return @"0";
    }
    NSString *unitName = @"km/hr";
    // to get from meters to kilometers divide by this
    double hour = (double)seconds/3600;
    double km = meters/metersInKM;
    double speed = km/hour;
    
    return [NSString stringWithFormat:@"%.2f %@",speed, unitName];
}

+ (NSArray *)getColorSegmentsForLocations:(NSArray *)locations
{
    if (locations.count == 1){
        UserLocation *loc      = [locations firstObject];
        CLLocationCoordinate2D coords[1];
        coords[0].latitude      = loc.latitude.doubleValue;
        coords[0].longitude     = loc.longitude.doubleValue;
        
        GMSMutablePath *path = [GMSMutablePath path];
        [path addLatitude:coords[0].latitude longitude:coords[0].longitude];
        [path addLatitude:coords[0].latitude longitude:coords[0].latitude];
        
        
        TYUPolyLineSegment *segment = [TYUPolyLineSegment polylineWithPath:path];
        segment.color = [UIColor blackColor];
        return @[segment];
    }
    
    NSMutableArray *colorSegments = [NSMutableArray array];
    
    for (int i = 1; i < locations.count; i++) {
        UserLocation *firstLoc = [locations objectAtIndex:(i-1)];
        UserLocation *secondLoc = [locations objectAtIndex:i];
        
        CLLocationCoordinate2D coords[2];
        coords[0].latitude = firstLoc.latitude.doubleValue;
        coords[0].longitude = firstLoc.longitude.doubleValue;
        
        coords[1].latitude = secondLoc.latitude.doubleValue;
        coords[1].longitude = secondLoc.longitude.doubleValue;
        
        
        GMSMutablePath *path = [GMSMutablePath path];
        [path addLatitude:coords[0].latitude longitude:coords[0].longitude]; // Sydney
        [path addLatitude:coords[1].latitude longitude:coords[1].longitude]; // Fiji
        
        CLLocation *firstLocCL = [[CLLocation alloc] initWithLatitude:firstLoc.latitude.doubleValue longitude:firstLoc.longitude.doubleValue];
        CLLocation *secondLocCL = [[CLLocation alloc] initWithLatitude:secondLoc.latitude.doubleValue longitude:secondLoc.longitude.doubleValue];
        
        double distance = [secondLocCL distanceFromLocation:firstLocCL];
        double time = [secondLoc.timeStamp timeIntervalSinceDate:firstLoc.timeStamp];
        double speed = (distance/time) * (18/5);
        UIColor *color;
        if(speed < 20)
        {
            color = [UIColor greenColor];
        }
        else if (speed < 40)
        {
            color = [UIColor yellowColor];
        }
        else
        {
            color = [UIColor redColor];
        }
        TYUPolyLineSegment *segment = [TYUPolyLineSegment polylineWithPath:path];
        segment.color = color;
        
        [colorSegments addObject:segment];
    }
    
    return colorSegments;
}

+ (int) getNumberOfDaysBetweenStartDate:(NSDate*) startDate andEndDate:(NSDate*) endDate shouldIgnoreTime:(BOOL) isIgnoreTime
{
    if(!startDate || !endDate)
        return 0;
    
    //GET # OF DAYS
    NSDateFormatter *df = [NSDateFormatter new];
    if(isIgnoreTime)
    {
        [df setDateFormat:@"MM dd yyyy"]; //Remove the time part
    }
    else
    {
        [df setDateFormat:@"MM dd yyyy 'at' HH:mm"];
    }
    
    NSString *startDateString = [df stringFromDate:startDate];
    NSString *endDateString = [df stringFromDate:endDate];
    NSTimeInterval time = [[df dateFromString:endDateString] timeIntervalSinceDate:[df dateFromString:startDateString]];
    
    int days = time / 60 / 60/ 24;
    
    return days;
}

@end
