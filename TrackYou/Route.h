//
//  Route.h
//  TrackYou
//
//  Created by Sudeep Unnikrishnan on 7/24/15.
//  Copyright (c) 2015 Sudeep Unnikrishnan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserLocation;

@interface Route : NSManagedObject

@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * routeTitle;
@property (nonatomic, retain) NSOrderedSet *userLocations;
@end

@interface Route (CoreDataGeneratedAccessors)

- (void)insertObject:(UserLocation *)value inUserLocationsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromUserLocationsAtIndex:(NSUInteger)idx;
- (void)insertUserLocations:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeUserLocationsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInUserLocationsAtIndex:(NSUInteger)idx withObject:(UserLocation *)value;
- (void)replaceUserLocationsAtIndexes:(NSIndexSet *)indexes withUserLocations:(NSArray *)values;
- (void)addUserLocationsObject:(UserLocation *)value;
- (void)removeUserLocationsObject:(UserLocation *)value;
- (void)addUserLocations:(NSOrderedSet *)values;
- (void)removeUserLocations:(NSOrderedSet *)values;
@end
