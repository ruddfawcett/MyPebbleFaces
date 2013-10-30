//
//  AppDetailsViewController.h
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 7/15/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "PreviewViewController.h"
#import "UITableViewCell+FlatUI.h"
#import "UIColor+FlatUI.h"
#import "GeneralTextViewController.h"
#import "SubAppViewController.h"
#import "AuthorAppsViewController.h"
#import "AFNetworking.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <MessageUI/MessageUI.h>

@interface AppDetailsViewController : UITableViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate, FUIAlertViewDelegate>
{
    float downloadProgress;
}

@property (strong,nonatomic) NSDictionary *appData;
@property (strong, nonatomic) NSMutableDictionary *subApps;
@property (strong, nonatomic) NSMutableArray *subPebbleApp;
@property (nonatomic) int *subAppCount;

@end
