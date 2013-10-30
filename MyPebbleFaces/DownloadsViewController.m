//
//  DownloadsViewController.m
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 9/2/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "DownloadsViewController.h"

@interface DownloadsViewController ()


@end

@implementation DownloadsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // app spacing
    
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setMinimumInteritemSpacing:5.0f];
    [flowLayout setMinimumLineSpacing:5.0f];
    [flowLayout setItemSize:CGSizeMake(73.75f, 85.75f)];
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    [self.collectionView setShowsVerticalScrollIndicator:NO];
    //
    self.title = @"Downloads";
    
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //login
    //Login User
    
    UIBarButtonItem *qrCode = [[UIBarButtonItem alloc] initWithTitle:@"Scan QR" style:UIBarButtonItemStylePlain target:self action:@selector(qrCode)];
    
    self.navigationItem.leftBarButtonItem = qrCode;
    
    UserClass *newUser = [UserClass sharedSingleton];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchingData:)
                                                 name:@"showHUDAuto"
                                               object:newUser];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchingData:)
                                                 name:@"showHUD"
                                               object:newUser];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchingData:)
                                                 name:@"hideHUD"
                                               object:newUser];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userHasLoggedIn:)
                                                 name:@"autoLogin"
                                               object:newUser];
    [[NSNotificationCenter defaultCenter]    addObserver:self
                                                selector:@selector(loggedOut:)
                                                    name:@"logOut"
                                                  object:newUser];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDownloads) name:@"downloadCompleted" object:nil];

    
    NSLog(@"View did appear");
    [newUser autoLogin];
    
    //endlogin
    if(![newUser loggedIn]){
        
        
        
        UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:self action:@selector(bringUpLogin)];
        
        self.navigationItem.rightBarButtonItem = loginButton;
    }else{
        
        
        UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Updates" style:UIBarButtonItemStylePlain target:self action:@selector(bringUpUpdates)];
        
        self.navigationItem.rightBarButtonItem = logoutButton;
    }
 
}

- (void)viewDidAppear:(BOOL)animated {
    [self.collectionView reloadData];
    
    NSString *downloadPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Downloads.plist"];
    
    
    NSMutableArray *downloadList = [[NSMutableArray alloc] init];
    downloadList = [NSMutableArray arrayWithContentsOfFile:downloadPath];
    
    self.pebbleApps = downloadList;
    
    if (![[UserClass sharedSingleton] loggedIn]) {
        
        UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:self action:@selector(bringUpLogin)];
        
        self.navigationItem.rightBarButtonItem = loginButton;
    } else {
        if (self.pebbleApps.count != 0) {
            UIBarButtonItem *updatesButton = [[UIBarButtonItem alloc] initWithTitle:@"Updates" style:UIBarButtonItemStylePlain target:self action:@selector(bringUpUpdates)];
            
            self.navigationItem.rightBarButtonItem = updatesButton;
        }
    }
}

-(void)bringUpLogin {
    LoginViewController *vc = [[LoginViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [vc setPoppedFromDls:YES];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)bringUpUpdates {
    UpdatesViewController *vc = [[UpdatesViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)qrCode {
    CustomScannerViewController *vc = [[CustomScannerViewController alloc] init];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

-(void)reloadDownloads {
    NSString *downloadPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Downloads.plist"];
    
    
    NSMutableArray *downloadList = [[NSMutableArray alloc] init];
    downloadList = [NSMutableArray arrayWithContentsOfFile:downloadPath];
    
    self.pebbleApps = downloadList;
    
    
    [self.collectionView reloadData];
}

//login
- (void)fetchingData:(NSNotification *) notification{
    if([[notification name] isEqualToString:@"showHUD" ]){
        [SVProgressHUD showWithStatus:@"Signing in..."];
    }
    if([[notification name] isEqualToString:@"showHUDAuto" ]){
        
      //  [SVProgressHUD showWithStatus:@"Signing in..."];
    }
    if([[notification name] isEqualToString:@"hideHUD" ]){
        [SVProgressHUD dismiss];
        
        
    }
    
    
}
-(void) loggedOut:(NSNotification *) notification{
    UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:self action:@selector(bringUpLogin)];
    
    self.navigationItem.rightBarButtonItem = loginButton;
}

- (void) userHasLoggedIn:(NSNotification *) notification
{
    UIBarButtonItem *updateButton = [[UIBarButtonItem alloc] initWithTitle:@"Updates" style:UIBarButtonItemStylePlain target:self action:@selector(bringUpUpdates)];
    
    self.navigationItem.rightBarButtonItem = updateButton;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//endlogin
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pebbleApps.count;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    pebbleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //return [NSString stringWithFormat:@"%@_%@.%@",title,[NSString stringWithFormat:@"%@", version],[[[self.appData objectForKey:@"appData"] objectForKey:@"previewURL"] pathExtension]];
    
    NSString *previewPath = [NSString stringWithFormat:@"%@/%@_%@.%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [[self.pebbleApps objectAtIndex:indexPath.item] objectForKey:@"title"], [NSString stringWithFormat:@"%@",[[self.pebbleApps objectAtIndex:indexPath.item] objectForKey:@"version"]], [[[self.pebbleApps objectAtIndex:indexPath.item] objectForKey:@"previewURL"] pathExtension]];
    UIImage *cellImage = [[UIImage alloc] initWithContentsOfFile:previewPath];
    
    //NSLog(@"%@",previewPath);
    
    [cell.imageView setImage:cellImage];
    
    cell.backgroundColor = [UIColor blackColor];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.appAlert = [[FUIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",[[self.pebbleApps objectAtIndex:indexPath.item] objectForKey:@"title"]]
                                                message:@"What would you like to do with this PBW?"
                                               delegate:self
                                      cancelButtonTitle:@"Dismiss"
                                      otherButtonTitles:@"Install", @"Delete", nil];
    
    self.appAlert.titleLabel.textColor = [UIColor cloudsColor];
    self.appAlert.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    self.appAlert.messageLabel.textColor = [UIColor cloudsColor];
    self.appAlert.messageLabel.font = [UIFont flatFontOfSize:14];
    self.appAlert.backgroundOverlay.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
    self.appAlert.alertContainer.backgroundColor = [UIColor colorWithRed:0.745 green:0.196 blue:0.071 alpha:1.00];
    self.appAlert.defaultButtonColor = [UIColor cloudsColor];
    self.appAlert.defaultButtonShadowColor = [UIColor asbestosColor];
    self.appAlert.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    self.appAlert.defaultButtonTitleColor = [UIColor asbestosColor];
    
    self.appAlert.tag = indexPath.item;
    
    NSLog(@"%ld",(long)self.appAlert.tag);
    
    [self.appAlert show];
}

- (void)InstallApp:(int)location {
    NSString *pbwPath = [NSString stringWithFormat:@"%@/%@_%@.pbw", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [[self.pebbleApps objectAtIndex:location] objectForKey:@"title"], [NSString stringWithFormat:@"%@",[[self.pebbleApps objectAtIndex:location] objectForKey:@"version"]]];
    
    self.controller = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:pbwPath]];
    
    [self.controller presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
}

- (void)deleteApp:(int)location {
    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    if ([[UserClass sharedSingleton] isLogged] && types != UIRemoteNotificationTypeNone) {
        Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];

        if (networkStatus != NotReachable && [[UserClass sharedSingleton] isLogged] && [[PFInstallation currentInstallation].channels containsObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]] && [[PFInstallation currentInstallation].channels containsObject:[NSString stringWithFormat:@"Face-%@",[NSString stringWithFormat:@"%@",[[self.pebbleApps objectAtIndex:location] objectForKey:@"cID"]]]]) {
            NSString *downloadPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Downloads.plist"];
            
            NSMutableArray *downloads = [[NSMutableArray alloc] init];
            downloads = [NSMutableArray arrayWithContentsOfFile:downloadPath];
            [downloads removeObjectAtIndex:location];
            [downloads writeToFile:downloadPath atomically:YES];
            
            if ([downloads writeToFile:downloadPath atomically:YES]) {
                [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@_%@.%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [[self.pebbleApps objectAtIndex:location] objectForKey:@"title"], [NSString stringWithFormat:@"%@",[[self.pebbleApps objectAtIndex:location] objectForKey:@"version"]], [[[self.pebbleApps objectAtIndex:location] objectForKey:@"previewURL"] pathExtension]]] error:nil];
                
                [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@_%@.pbw", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [[self.pebbleApps objectAtIndex:location] objectForKey:@"title"], [NSString stringWithFormat:@"%@",[[self.pebbleApps objectAtIndex:location] objectForKey:@"version"]]]] error:nil];
                
                [PFPush unsubscribeFromChannelInBackground:[NSString stringWithFormat:@"Face-%@",[NSString stringWithFormat:@"%@",[[self.pebbleApps objectAtIndex:location] objectForKey:@"cID"]]]];
                
                [self.pebbleApps removeObjectAtIndex:location];
                
                if (self.pebbleApps.count == 0  && [[UserClass sharedSingleton] isLogged]) {
                    self.navigationItem.rightBarButtonItem = nil;
                }
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:location inSection:0];
                [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
                [PFPush subscribeToChannelInBackground:@""];
            }
        }
        else if (networkStatus == NotReachable && ![[PFInstallation currentInstallation].channels containsObject:[NSString stringWithFormat:@"Face-%@",[NSString stringWithFormat:@"%@",[[self.pebbleApps objectAtIndex:location] objectForKey:@"cID"]]]]) {
            
            NSString *downloadPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Downloads.plist"];
            
            NSMutableArray *downloads = [[NSMutableArray alloc] init];
            downloads = [NSMutableArray arrayWithContentsOfFile:downloadPath];
            [downloads removeObjectAtIndex:location];
            [downloads writeToFile:downloadPath atomically:YES];
            
            if ([downloads writeToFile:downloadPath atomically:YES]) {
                [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@_%@.%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [[self.pebbleApps objectAtIndex:location] objectForKey:@"title"], [NSString stringWithFormat:@"%@",[[self.pebbleApps objectAtIndex:location] objectForKey:@"version"]], [[[self.pebbleApps objectAtIndex:location] objectForKey:@"previewURL"] pathExtension]]] error:nil];
                
                [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@_%@.pbw", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [[self.pebbleApps objectAtIndex:location] objectForKey:@"title"], [NSString stringWithFormat:@"%@",[[self.pebbleApps objectAtIndex:location] objectForKey:@"version"]]]] error:nil];
                
                [self.pebbleApps removeObjectAtIndex:location];
                
                if (self.pebbleApps.count == 0  && [[UserClass sharedSingleton] isLogged]) {
                    self.navigationItem.rightBarButtonItem = nil;
                }
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:location inSection:0];
                [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
            }
        }
        else {
            FUIAlertView *av = [[FUIAlertView alloc] initWithTitle:@"Unable to Delete"
                                                           message:@"This watch-face is setup with push notifications.  Please try deleting the watch-face when you have an internet connection."
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
    }
    else {
        NSString *downloadPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Downloads.plist"];
        
        NSMutableArray *downloads = [[NSMutableArray alloc] init];
        downloads = [NSMutableArray arrayWithContentsOfFile:downloadPath];
        [downloads removeObjectAtIndex:location];
        [downloads writeToFile:downloadPath atomically:YES];
        
        if ([downloads writeToFile:downloadPath atomically:YES]) {
            [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@_%@.%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [[self.pebbleApps objectAtIndex:location] objectForKey:@"title"], [NSString stringWithFormat:@"%@",[[self.pebbleApps objectAtIndex:location] objectForKey:@"version"]], [[[self.pebbleApps objectAtIndex:location] objectForKey:@"previewURL"] pathExtension]]] error:nil];
            
            [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@_%@.pbw", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [[self.pebbleApps objectAtIndex:location] objectForKey:@"title"], [NSString stringWithFormat:@"%@",[[self.pebbleApps objectAtIndex:location] objectForKey:@"version"]]]] error:nil];
            
            [self.pebbleApps removeObjectAtIndex:location];
            
            if (self.pebbleApps.count == 0  && [[UserClass sharedSingleton] isLogged]) {
                self.navigationItem.rightBarButtonItem = nil;
            }
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:location inSection:0];
            [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        }
    }

}

-(void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self InstallApp:self.appAlert.tag];
    }
    else if (buttonIndex == 1) {
        [self deleteApp:self.appAlert.tag];
    }
    else if (buttonIndex == 2) {
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
