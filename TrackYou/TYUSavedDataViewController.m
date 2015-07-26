//
//  TYUSavedDataViewController.m
//  TrackYou
//
//  Created by Sudeep Unnikrishnan on 7/24/15.
//  Copyright (c) 2015 Sudeep Unnikrishnan. All rights reserved.
//

#import "TYUSavedDataViewController.h"
#import "TYURouteDetailViewController.h"
#import "TYUSavedDataTableViewCell.h"
#import "Route.h"
#import "TYUUtility.h"

@interface TYUSavedDataViewController ()

@end

@implementation TYUSavedDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.routeArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
   TYUSavedDataTableViewCell *headerCell = (TYUSavedDataTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"savedRoute"];
    
    if(self.routeArray.count >= section)
    {
        headerCell.routeTItle.text = @"Route Title";
        headerCell.timeStamp.text = @"Time";
        headerCell.distance.text = @"Distance";
        headerCell.backgroundColor = [UIColor lightGrayColor];
        headerCell.accessoryType = UITableViewCellAccessoryNone;
        headerCell.selectionStyle = UITableViewCellSelectionStyleNone;
        headerCell.userInteractionEnabled = NO;
    }
    
    return headerCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TYUSavedDataTableViewCell *cell = (TYUSavedDataTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"savedRoute"];
    Route *routeObject = [self.routeArray objectAtIndex:indexPath.row];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    cell.routeTItle.text = routeObject.routeTitle;
    cell.timeStamp.text = [formatter stringFromDate:routeObject.timeStamp];
    cell.distance.text = [TYUUtility getStringForDistance:routeObject.distance.floatValue];
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue destinationViewController] isKindOfClass:[TYURouteDetailViewController class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Route *route = [self.routeArray objectAtIndex:indexPath.row];
        [(TYURouteDetailViewController *)[segue destinationViewController] setRoute:route];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
