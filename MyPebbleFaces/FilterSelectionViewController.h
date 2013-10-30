//
//  FilterSelectionViewController.h
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 9/5/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlatUIKit.h"
#import "UITableViewCell+FlatUI.h"
#import "UIColor+FlatUI.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "DGTextField.h"
#import "UserClass.h"

@interface FilterSelectionViewController : UITableViewController <UITextFieldDelegate, FUIAlertViewDelegate>
{
    IBOutlet DGTextField *searchField;
}

@property (strong, nonatomic) NSDictionary *filters;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSIndexPath *selectedPathForSection2;
@property (strong, nonatomic) NSIndexPath *selectedPathForSection3;
@property (strong, nonatomic) NSIndexPath *selectedPathForSection4;
@property (strong, nonatomic) NSIndexPath *selectedPathSpecial;
@property (strong, nonatomic) NSMutableArray *selectedPaths;
@property (strong, nonatomic) NSMutableDictionary *filterParams;
@property (strong, nonatomic) NSString *searchFieldText;
@property (strong, nonatomic) NSArray *yesNo;
@property (strong, nonatomic) NSIndexPath *selectedPathForSection1;

@property (strong, nonatomic) FUIAlertView *alert;

@property (strong, nonatomic) NSMutableArray *filterList;

@property (strong, nonatomic) UserClass *singleton;

@end
