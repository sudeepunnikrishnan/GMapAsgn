//
//  TYUUtility.h
//  TrackYou
//
//  Created by Sudeep Unnikrishnan on 7/24/15.
//  Copyright (c) 2015 Sudeep Unnikrishnan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYUUtility : NSObject

+ (NSString *)getStringForDistance:(float)meters;

+ (NSString *)getStringForSecondCount:(int)seconds usingLongFormat:(BOOL)longFormat;

+ (NSString *)getStringForAvgSpeedFromDist:(float)meters overTime:(int)seconds;

+ (NSArray *)getColorSegmentsForLocations:(NSArray *)locations;

+ (int) getNumberOfDaysBetweenStartDate:(NSDate*) startDate andEndDate:(NSDate*) endDate shouldIgnoreTime:(BOOL) isIgnoreTime;

@end


