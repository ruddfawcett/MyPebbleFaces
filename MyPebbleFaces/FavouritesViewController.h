//
//  WatchAppsCollectionViewController.h
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 7/17/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppDetailsViewController.h"
#import "SVProgressHUD.h"
#import "pebbleCell.h"
#import "SVPullToRefresh.h"
#import "FlatUIKit.h"
#import "FilterSelectionViewController.h"
#import "LoginViewController.h"
#import "UserClass.h"

@interface FavouritesViewController  : UICollectionViewController <LoginViewDelegate>

@property (strong, nonatomic) NSMutableArray *pebbleApps;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSDictionary *paginationDict;

@property (strong, nonatomic) NSMutableArray *filterList;

@property (strong, nonatomic) NSURL *queryURL;
@property (strong, nonatomic) NSURL *pagingURL;

@end
