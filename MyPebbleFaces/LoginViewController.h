//
//  LoginViewController.h
//  MyPebbleFaces
//
//  Created by Jason Smyth on 16/09/2013.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "UserClass.h"
#import "SVProgressHUD.h"
#import "DGTextField.h"

@protocol LoginViewDelegate <NSObject>
@end

@interface LoginViewController : UITableViewController <UITextFieldDelegate>
{
    IBOutlet DGTextField *username;
    IBOutlet DGTextField *password;
}

@property (weak, nonatomic) id<LoginViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *loginHeader;
@property (assign,nonatomic) BOOL pop;
@property (assign,nonatomic) BOOL poppedFromDls;
@property (weak, nonatomic) IBOutlet UILabel *welcome;

@property (strong, nonatomic) UIBarButtonItem *submit;

@end
