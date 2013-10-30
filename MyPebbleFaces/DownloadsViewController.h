//
//  DownloadsViewController.h
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 9/2/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppDetailsViewController.h"
#import "SVProgressHUD.h"
#import "pebbleCell.h"
#import "FlatUIKit.h"
#import "LoginViewController.h"
#import "CustomScannerViewController.h"
#import "UpdatesViewController.h"

@interface DownloadsViewController : UICollectionViewController <UIAlertViewDelegate, FUIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *pebbleApps;
@property (strong, nonatomic) FUIAlertView *appAlert;
@property (nonatomic, strong) UIDocumentInteractionController *controller;

@end
