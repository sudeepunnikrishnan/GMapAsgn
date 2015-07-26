//
//  TYUSavedDataTableViewCell.h
//  TrackYou
//
//  Created by Sudeep Unnikrishnan on 7/25/15.
//  Copyright (c) 2015 Sudeep Unnikrishnan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYUSavedDataTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *routeTItle;
@property (weak, nonatomic) IBOutlet UILabel *timeStamp;
@property (weak, nonatomic) IBOutlet UILabel *distance;

@end
