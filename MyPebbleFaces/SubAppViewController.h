//
//  SubAppViewController.h
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 7/18/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PreviewViewController.h"
#import "UITableViewCell+FlatUI.h"
#import "UIColor+FlatUI.h"
#import "GeneralTextViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "UserClass.h"
#import "DownloadsViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <MessageUI/MessageUI.h>

@interface SubAppViewController : UITableViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate>
{
    float downloadProgress;
}

@property (strong,nonatomic) NSDictionary *appData;
@property (nonatomic) int isDesc;
@property (strong, nonatomic) NSIndexPath *indexPath;

@end
