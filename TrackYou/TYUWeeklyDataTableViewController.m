//
//  TYUWeeklyDataTableViewController.m
//  TrackYou
//
//  Created by Sudeep Unnikrishnan on 7/24/15.
//  Copyright (c) 2015 Sudeep Unnikrishnan. All rights reserved.
//

#import "TYUWeeklyDataTableViewController.h"
#import "TYUWeeklyDataTableViewCell.h"
#import "TYUUtility.h"
#import "Route.h"
#import "WeekData.h"

@interface TYUWeeklyDataTableViewController ()
{
    NSMutableArray *historicalData;
    NSString *filePath;
}

@end

@implementation TYUWeeklyDataTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self generatedWeeklyData];
}

/**
 *  Method that performs operation for creating weekly record
 */
-(void)generatedWeeklyData
{
    historicalData = [NSMutableArray new];
    if([self.routeArray count])
    {
        
        NSDate *firstDate = [[self.routeArray firstObject] valueForKey:@"timeStamp"];
        NSDate *lastDate = [[self.routeArray lastObject] valueForKey:@"timeStamp"];
        int noOfDays = [TYUUtility getNumberOfDaysBetweenStartDate:lastDate andEndDate:firstDate shouldIgnoreTime:NO];
        if(noOfDays % 7 !=0)
        {
            noOfDays = 7+noOfDays-(noOfDays%7);
        }
        else if (noOfDays == 0)
        {
            noOfDays = 7;
        }
        NSDate *finalDate;
        finalDate = lastDate;
        
        for(int i=7;i<=noOfDays;i+=7)
        {
            NSDate *sevenDayPlusDate = [NSDate dateWithTimeInterval:3600 * 24 * i sinceDate:lastDate];
            NSPredicate *sevenDayCheckPredicate = [NSPredicate predicateWithFormat:@"SELF.timeStamp >= %@ && SELF.timeStamp<%@",finalDate,sevenDayPlusDate];
            NSArray *weekRoutes = [[self.routeArray filteredArrayUsingPredicate:sevenDayCheckPredicate] mutableCopy];
            
            
            WeekData *weekDataObj = [WeekData new];
            for(Route *routeObj in weekRoutes)
            {
                weekDataObj.distance = [NSNumber numberWithDouble:(weekDataObj.distance.doubleValue + routeObj.distance.doubleValue)];
                weekDataObj.time = [NSNumber numberWithInt:(weekDataObj.time.intValue + routeObj.time.intValue)];
            }
             NSDateFormatter *df = [NSDateFormatter new];
             [df setDateFormat:@"dd/MM"];
            weekDataObj.weekTitle = [NSString stringWithFormat:@"%@-%@",[df stringFromDate:finalDate],[df stringFromDate:sevenDayPlusDate]];
            [historicalData addObject:weekDataObj];
            finalDate = sevenDayPlusDate;
        }
        [self performSelectorInBackground:@selector(createHistoricalDataTextFile) withObject:nil];
        [self.tableView reloadData];
        [self.view layoutIfNeeded];
        
        
    }
}

/**
 *  Method generating text file for share
 */
-(void)createHistoricalDataTextFile
{
    NSError *error;
    NSString *stringToWrite = @"\t\t\t\t Historical Data Summary \t\t\n";
    stringToWrite = [stringToWrite stringByAppendingString:@"\nWeek Title \t\tSpeed \t\t Distance\n"];
    
    for(WeekData *weekObj in historicalData)
    {
        stringToWrite = [stringToWrite stringByAppendingFormat:@"%@ \t\t%@\t\t%@",weekObj.weekTitle,
                         [TYUUtility getStringForAvgSpeedFromDist:weekObj.distance.floatValue overTime:weekObj.time.intValue],
                         [TYUUtility getStringForDistance:weekObj.distance.floatValue]];
    }
    filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"HistoricalData.txt"];
    [stringToWrite writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TYUWeeklyDataTableViewCell *headerCell = (TYUWeeklyDataTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"weeklyData"];
    headerCell.weekTitle.text = @"Week Title";
    headerCell.speed.text = @"Speed";
    headerCell.distance.text = @"Distance";
    headerCell.backgroundColor = [UIColor lightGrayColor];
    headerCell.accessoryType = UITableViewCellAccessoryNone;
    headerCell.selectionStyle = UITableViewCellSelectionStyleNone;
    headerCell.userInteractionEnabled = NO;
    
    return headerCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [historicalData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TYUWeeklyDataTableViewCell *cell = (TYUWeeklyDataTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"weeklyData"];
    if([historicalData count] && indexPath.row<[historicalData count])
    {
        WeekData *weekObj = [historicalData objectAtIndex:(([historicalData count]-1)-indexPath.row)];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        
        cell.weekTitle.text = weekObj.weekTitle;
        cell.speed.text = [TYUUtility getStringForAvgSpeedFromDist:weekObj.distance.floatValue overTime:weekObj.time.intValue];
        cell.distance.text = [TYUUtility getStringForDistance:weekObj.distance.floatValue];
    }
    return cell;
}

- (IBAction)shareAction:(id)sender {
    
    if([historicalData count] && filePath)
    {
        NSURL *URL = [NSURL fileURLWithPath:filePath];
        NSArray *objectsToShare = @[URL];
        
        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
        
        // Exclude all activities except Mail.
        NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                        UIActivityTypePostToWeibo,
                                        UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                        UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                        UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                        UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
        controller.excludedActivityTypes = excludedActivities;
        [controller setValue:@"Weekly Data" forKey:@"subject"];
        // Present the controller
        [self presentViewController:controller animated:YES completion:nil];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
