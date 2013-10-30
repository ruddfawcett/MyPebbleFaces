//
//  user.h
//  AES
//
//  Created by Jason Smyth on 12/09/2013.
//  Copyright (c) 2013 Jason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVProgressHUD.h"
#import "FlatUIKit.h"

@protocol UserClassDelegate <NSObject>

- (void)userCompletedLogin;

@end


@interface UserClass :NSObject;

@property (weak, nonatomic) id<UserClassDelegate> UserClassDelegate;

@property(nonatomic,strong) NSString *cookie;
@property(nonatomic,strong) NSString *username;
@property (nonatomic, strong) NSDictionary *userData;
@property (nonatomic, strong) NSString *autoSignInText;

-(BOOL) isLogged;
@property (nonatomic, assign) BOOL loggedIn;


+(UserClass *)sharedSingleton;

-(void)autoLogin;
-(void)logout;
-(void)login:(NSString *)name password:(NSString *)passoword;
-(void)connectionError:(NSError *)error;
- (NSString *) encryptData:(NSString *)val;

// I am going to manipulate hte singleton a bit, so i can store filter data in here
@property (strong, nonatomic) NSIndexPath *selectedPathForSection2;
@property (strong, nonatomic) NSIndexPath *selectedPathForSection3;
@property (strong, nonatomic) NSIndexPath *selectedPathForSection4;
@property (strong, nonatomic) NSIndexPath *selectedPathSpecial;
@property (strong, nonatomic) NSMutableArray *selectedPaths;
@property (strong, nonatomic) NSString *searchFieldText;
@property (strong, nonatomic) NSDictionary *filters;
@property (strong, nonatomic) NSArray *yesNo;
@property (strong, nonatomic) NSIndexPath *selectedPathForSection1;

@property (strong, nonatomic) NSMutableString *queryString;
@property (strong, nonatomic) NSMutableString *pagingQueryString;
@property (nonatomic, assign) BOOL shouldLoadQuery;

@property (nonatomic) int shouldRefresh;

@end
