//
//  TYUViewController.m
//  TrackYou
//
//  Created by Sudeep Unnikrishnan on 7/23/15.
//  Copyright (c) 2015 Sudeep Unnikrishnan. All rights reserved.
//

#import "TYUViewController.h"
#import "TYUTrackViewController.h"
#import "TYUSavedDataViewController.h"
#import "TYUWeeklyDataTableViewController.h"

@interface TYUViewController ()
@property (strong, nonatomic) NSArray *routeArray;

@end

@implementation TYUViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

/**
 *  viewWillAppear contains Coredata data fetching
 *
 *  @param animated <#animated description#>
 */
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Route" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.routeArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *pushedViewController = [segue destinationViewController];
    if ([pushedViewController isKindOfClass:[TYUTrackViewController class]]) {
        ((TYUTrackViewController *) pushedViewController).managedObjectContext = self.managedObjectContext;
    } else if ([pushedViewController isKindOfClass:[TYUSavedDataViewController class]]) {
        ((TYUSavedDataViewController *) pushedViewController).routeArray = self.routeArray;
    }else if ([pushedViewController isKindOfClass:[TYUWeeklyDataTableViewController class]]) {
        ((TYUWeeklyDataTableViewController *) pushedViewController).routeArray = self.routeArray;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
