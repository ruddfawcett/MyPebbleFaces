//
//  UpdatesViewController.h
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 9/21/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlatUIKit.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "UserClass.h"
#import "SubAppViewController.h"

@interface UpdatesViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *pebbleApps;
@property (strong, nonatomic) NSMutableArray *installed;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end
