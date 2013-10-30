//
//  SettingsViewController.h
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 8/30/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlatUIKit.h"
#import "UITableViewCell+FlatUI.h"
#import "UIColor+FlatUI.h"
#import "InitialNumberViewController.h"
#import "PaginationNumberViewController.h"
#import "ManageFiltersViewController.h"
#import "GeneralTextViewController.h"
#import "WebViewController.h"
#import "LoginViewController.h"
#import "UserClass.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "AAMFeedbackViewController.h"
//#import "UserVoice.h"

@interface SettingsViewController : UITableViewController
{
    IBOutlet FUISwitch *pushSwitch;
    IBOutlet FUISwitch *qrSwitch;
}
    
@end
