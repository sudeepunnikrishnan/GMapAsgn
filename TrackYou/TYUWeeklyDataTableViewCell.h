//
//  TYUWeeklyDataTableViewCell.h
//  TrackYou
//
//  Created by Sudeep Unnikrishnan on 7/25/15.
//  Copyright (c) 2015 Sudeep Unnikrishnan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYUWeeklyDataTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *weekTitle;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet UILabel *speed;
@end
