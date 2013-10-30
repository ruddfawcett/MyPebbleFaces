//
//  AppDetailURLViewController.h
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 9/20/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlatUIKit.h"
#import "AFNetworking.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <MessageUI/MessageUI.h>
#import "SVProgressHUD.h"
#import "UserClass.h"
#import "SubAppViewController.h"
#import "GeneralTextViewController.h"
#import "PreviewViewController.h"
#import "AuthorAppsViewController.h"
#import "UserClass.h"

@interface AppDetailURLViewController : UITableViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate, FUIAlertViewDelegate>
{
    float downloadProgress;
}

@property (strong, nonatomic) NSString *appID;
@property (strong, nonatomic) NSString *appName;
@property (strong, nonatomic) NSDictionary *applicationInfo;
@property (strong, nonatomic) NSMutableArray *subPebbleApp;
@property (strong, nonatomic) NSMutableDictionary *subApps;
@property (nonatomic) int modalController;

@end
