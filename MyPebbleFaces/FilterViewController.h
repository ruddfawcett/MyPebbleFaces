//
//  FilterViewController.h
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 9/3/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlatUIKit.h"
#import "UITableViewCell+FlatUI.h"
#import "UIColor+FlatUI.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "UserClass.h"
#import "DGTextField.h"

@interface FilterViewController : UITableViewController <UITextFieldDelegate, FUIAlertViewDelegate>
{
    IBOutlet DGTextField *filterNameField;
}

@property (strong, nonatomic) NSDictionary *filters;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSIndexPath *selectedPathForSection1;
@property (strong, nonatomic) NSIndexPath *selectedPathForSection2;
@property (strong, nonatomic) NSIndexPath *selectedPathForSection3;
@property (strong, nonatomic) NSIndexPath *selectedPathForSection4;
@property (strong, nonatomic) NSMutableArray *selectedPaths;
@property (strong, nonatomic) NSArray *yesNo;
@property (strong, nonatomic) NSMutableDictionary *filterParams;
@property (strong, nonatomic) NSString *filterNameText;

@property (strong, nonatomic) FUIAlertView *alert;

@end
