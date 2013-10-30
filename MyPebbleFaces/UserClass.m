                                                                                                                                                                                               //
//  user.m
//  AES
//
//  Created by Jason Smyth on 12/09/2013.
//  Copyright (c) 2013 Jason. All rights reserved.
//

#import "UserClass.h"
#import "RNEncryptor.h"
#import "Base64.h"
#import "AFNetworking.h"
#import <Security/Security.h>
@implementation UserClass


static UserClass *shared = NULL;
- (id)init
{
    if ( self = [super init] )
    {
        // init values
        // here you assign initial values to your variable.
        // in my case, I save all these values into NSUserDefaults as users preference.
        // so i do the necessary things to ensure that happens.
         [self setLoggedIn:NO];
        [self setAutoSignInText:@"Auto-signing in" ];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [self setCookie:[defaults objectForKey:@"cookie"]];
        
        if([self cookie] == nil)
            
        {
            
             [self setCookie: @"0"];
            
        }
        
    }
    return self;
    
}

+ (UserClass *)sharedSingleton
{
    @synchronized(shared)
    {
        if ( !shared || shared == NULL )
        {
            // allocate the shared instance, because it hasn't been done yet
            shared = [[UserClass alloc] init];
        }
        
        return shared;
    }
}

-(NSString *)urlenc:(NSString *)val
{
    CFStringRef safeString =
    CFURLCreateStringByAddingPercentEscapes(NULL,
                                            (CFStringRef)val,
                                            NULL,
                                            CFSTR("/%&=?$#+-~@<>|\\*,.()[]{}^!"),
                                            kCFStringEncodingUTF8);
    return [NSString stringWithFormat:@"%@", safeString];
}

- (NSString *) encryptData:(NSString *)val {
    
    
    NSString *secret = @"GP82y%usT$0Y%TP4_WbAUX)h7mcA8sayuz^7uGXH";
    NSData *data = [val dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSData *encryptedData = [RNEncryptor encryptData:data
                                        withSettings:kRNCryptorAES256Settings
                                            password:secret
                                               error:&error];
    NSString *encryptedData_string = [encryptedData base64EncodedString];
    
    return [self urlenc:encryptedData_string];
}
//
//- (BOOL)shouldLoadQueryBOOL {
//    return self.shouldLoadQuery == YES ? self.shouldLoadQuery == NO : self.shouldLoadQuery == YES;
//}

-(BOOL)isLogged{
    return [self loggedIn];
}

- (NSString *)_sanitizeFileNameString:(NSString *)fileName {
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>^&':"];
    return [[fileName componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
}

-(void)login:(NSString *)username password:(NSString *)password{
    username = [self _sanitizeFileNameString:username];
    username =   [username stringByReplacingOccurrencesOfString:@" " withString:@""];
    password = [self _sanitizeFileNameString:password];
    password =   [password stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"showHUD"
     object:self];
    
    
    NSString *encryptedData_string = [self encryptData:password];
    
    
    
    // 1
    NSString *loginUrl = [NSString stringWithFormat:@"http://www.mypebblefaces.com/pebbleInterface?action=login&user=%@&pass=%@",username,encryptedData_string];
    
    NSURL *url = [NSURL URLWithString:loginUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 2
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request
// 3
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        self.userData = [JSON objectForKey:@"data"];
          app.networkActivityIndicatorVisible = NO;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"hideHUD"
         object:self];
        if([[self.userData objectForKey:@"authorized"] isEqualToString:@"false"]){
            
            
            FUIAlertView *av = [[FUIAlertView alloc] initWithTitle:@"Error Logging In"
                                                         message:@"Please check that your username and password are correct."
                                                        delegate:nil
                                               cancelButtonTitle:@"Dimiss" otherButtonTitles:nil];
            
            av.titleLabel.textColor = [UIColor cloudsColor];
            av.titleLabel.font = [UIFont boldFlatFontOfSize:16];
            av.messageLabel.textColor = [UIColor cloudsColor];
            av.messageLabel.font = [UIFont flatFontOfSize:14];
            av.backgroundOverlay.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
            av.alertContainer.backgroundColor = [UIColor colorWithRed:0.745 green:0.196 blue:0.071 alpha:1.00];
            av.defaultButtonColor = [UIColor cloudsColor];
            av.defaultButtonShadowColor = [UIColor asbestosColor];
            av.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
            av.defaultButtonTitleColor = [UIColor asbestosColor];
            [av show];
            
            
        }
        
        if([[self.userData objectForKey:@"authorized"] isEqualToString:@"true"]){
            
             NSLog(@"Cookie %@",JSON);
            
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[[JSON objectForKey:@"data"] objectForKey:@"uName"] forKey:@"username"];
            [defaults setObject:[self encryptData:[self.userData objectForKey:@"cookie"]] forKey:@"cookie"];
            [defaults setObject: [self.userData objectForKey:@"authorized"] forKey:@"authorized"];
            [defaults synchronize];
            NSLog(@"Data saved");
            [PFPush subscribeToChannelInBackground:[self.userData objectForKey:@"uName"]];
           
            NSString *downloadPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Downloads.plist"];
            
            
            NSMutableArray *downloadList = [[NSMutableArray alloc] init];
            downloadList = [NSMutableArray arrayWithContentsOfFile:downloadPath];
            
            for (NSDictionary *dict in downloadList) {
                [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"Face-%@",[NSString stringWithFormat:@"%@",[dict objectForKey:@"cID"]]]];
            }
            
             [self setLoggedIn:YES];
          
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"login"
             object:self];
            
            
        }
    }
// 4
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
          app.networkActivityIndicatorVisible = NO;
        
        
           [self connectionError:error];
        
                                                            }];
    
    // 5
    [operation start];
}

-(void)autoLogin{
    [self autoLogUser];
    
}
-(void)autoLogUser{
  
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self setCookie:[defaults objectForKey:@"cookie"]];

        if ([self cookie] != nil){
            
            UIApplication* app = [UIApplication sharedApplication];
            app.networkActivityIndicatorVisible = YES;
           [[NSNotificationCenter defaultCenter]
            postNotificationName:@"showHUDAuto"
            object:self];

             // 1
            NSString *loginUrl = [NSString stringWithFormat:@"http://www.mypebblefaces.com/pebbleInterface?action=login&cookie=%@",self.cookie];
            
            NSURL *url = [NSURL URLWithString:loginUrl];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            
            // 2
            AFJSONRequestOperation *operation =
           [AFJSONRequestOperation JSONRequestOperationWithRequest:request
// 3
            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                
               NSLog(@"%@",JSON);

                 app.networkActivityIndicatorVisible = NO;
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"hideHUD"
                 object:self];
                [self setUserData:[JSON objectForKey:@"data"]];
                
                if ([[_userData objectForKey:@"authorized"] isEqualToString:@"false"]) {
                    FUIAlertView *av = [[FUIAlertView alloc] initWithTitle:@"Session Expired"
                                                                 message:@"Sorry, but your session has expired!  Please login again."
                                                                delegate:nil
                                                       cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                    
                    av.titleLabel.textColor = [UIColor cloudsColor];
                    av.titleLabel.font = [UIFont boldFlatFontOfSize:16];
                    av.messageLabel.textColor = [UIColor cloudsColor];
                    av.messageLabel.font = [UIFont flatFontOfSize:14];
                    av.backgroundOverlay.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
                    av.alertContainer.backgroundColor = [UIColor colorWithRed:0.745 green:0.196 blue:0.071 alpha:1.00];
                    av.defaultButtonColor = [UIColor cloudsColor];
                    av.defaultButtonShadowColor = [UIColor asbestosColor];
                    av.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
                    av.defaultButtonTitleColor = [UIColor asbestosColor];
                    [av show];
                                    [self logout];

                 
                }
                
                if ([[_userData objectForKey:@"authorized"] isEqualToString:@"true"]){
                    [defaults setObject:[[JSON objectForKey:@"data"] objectForKey:@"uName"] forKey:@"username"];
                      NSLog(@"Logged in user");
                        NSString *downloadPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Downloads.plist"];
                        
                        
                        NSMutableArray *downloadList = [[NSMutableArray alloc] init];
                        downloadList = [NSMutableArray arrayWithContentsOfFile:downloadPath];
                        
                        for (NSDictionary *dict in downloadList) {
                            [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"Face-%@",[NSString stringWithFormat:@"%@",[dict objectForKey:@"cID"]]]];
                        }
                    
                    [self setLoggedIn:YES];
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"autoLogin"
                     object:self];
                    
                    
                }

                
                
                
            }
// 4
            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                app.networkActivityIndicatorVisible = NO;
                    [self connectionError:error];
            }];

// 5
[operation start];

}
}

-(void)logout{
   self.username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    // 1
    NSString *loginUrl = @"http://www.mypebblefaces.com/pebbleInterface?action=logout";
    
    NSURL *url = [NSURL URLWithString:loginUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 2
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request
     // 3
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                        
                                                        [self setUserData: [JSON objectForKey:@"data"]];
                                                        NSLog(@"TEST %@",self.username);
                                                        if([[_userData objectForKey:@"authorized"] isEqualToString:@"false"]) {
                                                            [self setLoggedIn:NO];
                                                            NSLog(@"SESSION ERASED");
                                                            
                                                            [PFPush unsubscribeFromChannelInBackground:self.username];
                                                          
                                                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
                                                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"cookie"];
                                                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"authorized"];
                                                            [[NSUserDefaults standardUserDefaults]synchronize ];
                                                            
                                                            
                                                                [[NSNotificationCenter defaultCenter]
                                                                 postNotificationName:@"logOut"
                                                                 object:self];
                                                            
                                                            if (self.username.length != 0) {
    
                                                                NSString *downloadPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Downloads.plist"];
                                                                
                                                                
                                                                NSMutableArray *downloadList = [[NSMutableArray alloc] init];
                                                                downloadList = [NSMutableArray arrayWithContentsOfFile:downloadPath];
                                                                
                                                                for (NSDictionary *dict in downloadList) {
                                                                    [PFPush unsubscribeFromChannelInBackground:[NSString stringWithFormat:@"Face-%@",[NSString stringWithFormat:@"%@",[dict
    objectForKey:@"cID"]]]];
                                                                }
                                                               
                                                                [SVProgressHUD dismiss];
                                                            }
                                                        
                                                        }
                                                        
                                                        [PFPush subscribeToChannelInBackground:@""];
                                                        
                                                    }
     // 4
                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                        [self connectionError:error];
                                                    
                                                    }];
    
    // 5
    [operation start];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"" forKey:@"username"];
   
    NSLog(@"Logout");
    
}

-(void)connectionError:(NSError *)error{
    [SVProgressHUD dismiss];
    if(error.code==-1009){
        
       //no internet
        FUIAlertView *av = [[FUIAlertView alloc] initWithTitle:@"Connection Error"
                                                     message:@"Please check your internet connection."
                                                    delegate:nil
                                           cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        av.titleLabel.textColor = [UIColor cloudsColor];
        av.titleLabel.font = [UIFont boldFlatFontOfSize:16];
        av.messageLabel.textColor = [UIColor cloudsColor];
        av.messageLabel.font = [UIFont flatFontOfSize:14];
        av.backgroundOverlay.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
        av.alertContainer.backgroundColor = [UIColor colorWithRed:0.745 green:0.196 blue:0.071 alpha:1.00];
        av.defaultButtonColor = [UIColor cloudsColor];
        av.defaultButtonShadowColor = [UIColor asbestosColor];
        av.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
        av.defaultButtonTitleColor = [UIColor asbestosColor];
        [av show];
        
    }else{
        
        
//        [[NSNotificationCenter defaultCenter]
//         postNotificationName:@"error"
//         object:self];
        FUIAlertView *av = [[FUIAlertView alloc] initWithTitle:@"Connection Error"
                                                     message:@"There was an issue connecting to MyPebbleFaces. Please try again later."
                                                    delegate:nil
                                           cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        av.titleLabel.textColor = [UIColor cloudsColor];
        av.titleLabel.font = [UIFont boldFlatFontOfSize:16];
        av.messageLabel.textColor = [UIColor cloudsColor];
        av.messageLabel.font = [UIFont flatFontOfSize:14];
        av.backgroundOverlay.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
        av.alertContainer.backgroundColor = [UIColor colorWithRed:0.745 green:0.196 blue:0.071 alpha:1.00];
        av.defaultButtonColor = [UIColor cloudsColor];
        av.defaultButtonShadowColor = [UIColor asbestosColor];
        av.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
        av.defaultButtonTitleColor = [UIColor asbestosColor];
        
        [av show];
        
    }
}
@end
