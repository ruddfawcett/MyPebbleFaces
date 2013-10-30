//
//  AppDelegate.m
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 7/12/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)dealloc
{

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithRed:0.745 green:0.196 blue:0.071 alpha:1.00]];
    
    
    [[UIToolbar appearance] setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [[UIToolbar appearance] setBackgroundColor:[UIColor colorWithRed:0.745 green:0.196 blue:0.071 alpha:1.00]];
    
    [UIBarButtonItem configureFlatButtonsWithColor:[UIColor colorWithRed:0.900 green:0.237 blue:0.086 alpha:1.00]
                                  highlightedColor:[UIColor colorWithRed:0.631 green:0.000 blue:0.031 alpha:1.00]
                                      cornerRadius:3];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor whiteColor]];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor whiteColor],} forState:UIControlStateNormal];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Downloads.plist"]]) {
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"Downloads" ofType:@"plist"] toPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Downloads.plist"] error:nil];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Filters.plist"]]) {
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"Filters" ofType:@"plist"] toPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Filters.plist"] error:nil];
    }
    
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    tabBarController.delegate = self;
    
    [application registerForRemoteNotificationTypes:
                             UIRemoteNotificationTypeBadge |
                             UIRemoteNotificationTypeAlert |
                             UIRemoteNotificationTypeSound];
    
    NSDictionary *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notification && [[UserClass sharedSingleton] isLogged]) {
        NSLog(@"Opened via notification, also this notification opened that app at launch, here's the data:\n\n%@",notification);
        
        [self updateModal:[notification objectForKey:@"app"]];
    }
    
    [Parse setApplicationId:@"d4Rbs27Xt4pHKGxK4fES7v0BvFUhKjIuHg4D9qzf" clientKey:@"DJyIKkaFvmc2e5a9S93JzCwwvs1g6l9b5QHA4ls8"];
    [TestFlight takeOff:@"c6c20f0b-4c2a-4440-b11f-9f96246e459d"];
    
    return YES;
}

- (void)updateModal:(NSDictionary *)appInfo {
    [self.window makeKeyAndVisible];
    
    AppDetailURLViewController *controller = [[AppDetailURLViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [controller setModalController:1];
    [controller setAppID:[appInfo objectForKey:@"cID"]];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    [self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];

    [PFPush subscribeToChannelInBackground:@""];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive)
    {
        FUIAlertView *av = [[FUIAlertView alloc] initWithTitle:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
                                                       message:@"You have an update available for an app that you downloaded!"
                                                      delegate:nil
                                             cancelButtonTitle:@"Dismiss" otherButtonTitles:@"View Details",nil];
        
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
    else  if (state == UIApplicationStateInactive || state == UIApplicationStateBackground) {
        FUIAlertView *av = [[FUIAlertView alloc] initWithTitle:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
                                                       message:@"Opened from background!"
                                                      delegate:nil
                                             cancelButtonTitle:@"Dismiss" otherButtonTitles:@"View Details",nil];
        
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
    
    if ([[userInfo objectForKey:@"aps"] objectForKey:@"badge"]) {
        NSInteger badgeNumber = [[[userInfo objectForKey:@"aps"] objectForKey:@"badge"] integerValue];
        [application setApplicationIconBadgeNumber:badgeNumber];
    }
}

- (BOOL)tabBarController:(UITabBarController *)tbc shouldSelectViewController:(UIViewController *)vc {
    
     UserClass *newUser = [UserClass sharedSingleton];
    
    if(![newUser loggedIn]){
    UIViewController *tbSelectedController = tbc.selectedViewController;
    
    if ([tbSelectedController isEqual:vc]) {
        return NO;
    }
    
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //login
    UserClass *newUser = [UserClass sharedSingleton];
    
    
    NSLog(@"View did enter foreground");
    
    
    [newUser autoLogin];
    //endlogin
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    
//    [defaults removeObjectForKey:@"queryString"];
//    [defaults removeObjectForKey:@"pagingQueryString"];
//    [defaults removeObjectForKey:@"shouldLoadQuery"];
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
//    NSLog(@"url recieved: %@", url);
//    NSLog(@"query string: %@", [url query]);
//    NSLog(@"host: %@", [url host]);
//    NSLog(@"url path: %@", [url path]);
//////    NSDictionary *dict = [self parseQueryString:[url query]];
////    NSLog(@"query dict: %@", dict);
//    NSMutableArray *params = [[[url path] componentsSeparatedByString:@"/"] mutableCopy];
//    [params removeObjectAtIndex:0];
//    
//    if ([[url host] isEqualToString:@"app"]) {
//        AppDetailURLViewController *controller = [[AppDetailURLViewController alloc] initWithStyle:UITableViewStyleGrouped];
//        [controller setAppID:[params objectAtIndex:0]];
//        [controller setModalController:1];
//        
//        if (params.count == 3) {
//            [controller setAppName:[params objectAtIndex:1]];
//        }
//        
//        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
//        
//        [self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
//    }
//    
//    return YES;
//}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"url recieved: %@", url);
    NSLog(@"query string: %@", [url query]);
    NSLog(@"host: %@", [url host]);
    NSLog(@"url path: %@", [url path]);
    ////    NSDictionary *dict = [self parseQueryString:[url query]];
    //    NSLog(@"query dict: %@", dict);
    NSMutableArray *params = [[[url path] componentsSeparatedByString:@"/"] mutableCopy];
    [params removeObjectAtIndex:0];
    
    if ([[url host] isEqualToString:@"app"]) {
        AppDetailURLViewController *controller = [[AppDetailURLViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [controller setAppID:[params objectAtIndex:0]];
        [controller setModalController:1];
        
        if (params.count == 3) {
            [controller setAppName:[params objectAtIndex:1]];
        }
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        
        [self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
    }
    
    return YES;
}

//- (NSDictionary *)parseQueryString:(NSString *)query {
//    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6] ;
//    NSArray *pairs = [query componentsSeparatedByString:@"&"];
//    
//    for (NSString *pair in pairs) {
//        NSArray *elements = [pair componentsSeparatedByString:@"="];
//        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        
//        [dict setObject:val forKey:key];
//    }
//    return dict;
//}


@end
