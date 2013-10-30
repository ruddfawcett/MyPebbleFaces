//
//  AuthorAppsViewController.h
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 7/18/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppDetailsViewController.h"
#import "SVProgressHUD.h"
#import "LoginViewController.h"
#import "UserClass.h"

@interface AuthorAppsViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *pebbleApps;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSDictionary *paginationDict;
@property (strong, nonatomic) NSString *authorName;
@property (strong, nonatomic) NSString *authorID;

@end
