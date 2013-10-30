//
//  WatchAppsCollectionViewController.m
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 7/17/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "FavouritesViewController.h"
#import "AppDelegate.h"

@interface FavouritesViewController ()

@end

@implementation FavouritesViewController

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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"queryString"];
    [defaults removeObjectForKey:@"pagingQueryString"];
    [defaults removeObjectForKey:@"shouldLoadQuery"];
    
    self.title = @"Favorites";
    self.navigationController.navigationBar.topItem.title = @"My Favorites";
    
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    
    // UIRefresh Control Stuff...
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor darkGrayColor];
    [self.refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    int initNum;
    
    if (![defaults objectForKey:@"initNumber"]) {
        [defaults setObject:[NSString stringWithFormat:@"40"] forKey:@"initNumber"];
        initNum = 40;
    }
    else {
        initNum = [[defaults objectForKey:@"initNumber"] intValue];
    }
    //login
    UserClass *newUser = [UserClass sharedSingleton];
    self.queryURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.mypebblefaces.com/pebbleInterface?action=getFavourites&offset=0&limit=%d&cookie=%@",initNum,[newUser cookie]]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userHasLoggedIn:)
                                                 name:@"login"
                                               object:newUser];
    
    
    [[NSNotificationCenter defaultCenter]    addObserver:self
                                                selector:@selector(loggedOut:)
                                                    name:@"logOut"
                                                  object:newUser];
    [[NSNotificationCenter defaultCenter]    addObserver:self
                                                selector:@selector(fetchingData:)
                                                    name:@"error"
                                                  object:newUser];
    [SVProgressHUD showWithStatus:@"Fetching Favorites..."];
    
   
   
    [self getFaces];
    
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    //login
    __weak typeof(self) weakSelf = self;
    [self.collectionView addInfiniteScrollingWithActionHandler:^{
        [weakSelf getNext20];
    }];
    
    
    if(![newUser loggedIn]){
        
        
        
        [self bringUpLogin:self];
    }
    //endlogin
    
 
    
   }

- (void)dropViewDidBeginRefreshing:(UIRefreshControl *)refreshControl
{
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self getFaces];
    });
}

- (void)viewDidDisappear:(BOOL)animated {
    [SVProgressHUD dismiss];
    //login
 
    //endlogin
}
-(void)dealloc{
    
       [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
}
 

-(void) bringUpLogin:(id)sender{
    [SVProgressHUD dismiss];
    LoginViewController *vc = [[LoginViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [vc setPop:YES];
    
    [[self navigationController] pushViewController:vc animated:YES];
}

- (void) userHasLoggedIn:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    NSLog(@"User logged in notification in favourites view ");
    
    [SVProgressHUD showWithStatus:@"Fetching Favorites..."];
    [self getFaces];
       
  //  self.navigationItem.rightBarButtonItem = nil;
    
    
    
    
}
-(void) loggedOut:(NSNotification *) notification{
    
    [self bringUpLogin:self];
    
}
- (void)pagingURLRefresh {
    
     UserClass *newUser = [UserClass sharedSingleton];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"pagingQueryString"] != nil) {
        NSMutableString *pagingURLMutable = [NSMutableString stringWithFormat:@"%@",[defaults objectForKey:@"pagingQueryString"]];
        
        [pagingURLMutable appendString:[NSMutableString stringWithFormat:@"&offset=%@",[self.paginationDict objectForKey:@"next"]]];
        
        self.pagingURL = [NSURL URLWithString:pagingURLMutable];
    }
    else {
        int pageNum;
        
        if (![defaults objectForKey:@"pageNumber"]) {
            pageNum = 20;
        }
        else {
            pageNum = [[defaults objectForKey:@"pageNumber"] intValue];
        }
        
        self.pagingURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.mypebblefaces.com/pebbleInterface?action=getFavourites&offset=%@&limit=%d&cookie=%@",[self.paginationDict objectForKey:@"next"],pageNum,[newUser cookie]]];
    }
}

- (void)getFaces {
    
    //login
    UserClass *newUser = [UserClass sharedSingleton];
    if([newUser isLogged]){
        
        
        
    
    NSURL *apiURL = self.queryURL;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:apiURL];
    
        
        //NSLog(@"%@", request);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject)
                                         {
                                             
                                             //NSLog(@"%@", responseObject);
                                             NSDictionary *rootDict = [responseObject objectForKey:@"data"];
                                             
                                             NSMutableDictionary *rootDictMutable = [rootDict mutableCopy];
                                             
                                             self.paginationDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                                    [rootDictMutable objectForKey:@"total"],@"total",
                                                                    [rootDictMutable objectForKey:@"chunk"],@"chunk",
                                                                    [rootDictMutable objectForKey:@"order"],@"order",
                                                                    [rootDictMutable objectForKey:@"startAt"],@"startAt",
                                                                    [rootDictMutable objectForKey:@"pages"],@"pages",
                                                                    [rootDictMutable objectForKey:@"current"],@"current",
                                                                    [rootDictMutable objectForKey:@"previous"],@"previous",
                                                                    [rootDictMutable objectForKey:@"next"],@"next",
                                                                    [rootDictMutable objectForKey:@"last"],@"last",
                                                                    [rootDictMutable objectForKey:@"currentStart"],@"currentStart",
                                                                    [rootDictMutable objectForKey:@"currentEnd"],@"currentEnd",
                                                                    [rootDictMutable objectForKey:@"needsPaging"],@"needsPaging", nil];
                                             
                                             // Remove unwanted dictionary keys for testing...
                                             
                                             [rootDictMutable removeObjectForKey:@"total"];
                                             [rootDictMutable removeObjectForKey:@"chunk"];
                                             [rootDictMutable removeObjectForKey:@"order"];
                                             [rootDictMutable removeObjectForKey:@"startAt"];
                                             [rootDictMutable removeObjectForKey:@"pages"];
                                             [rootDictMutable removeObjectForKey:@"current"];
                                             [rootDictMutable removeObjectForKey:@"previous"];
                                             [rootDictMutable removeObjectForKey:@"next"];
                                             [rootDictMutable removeObjectForKey:@"last"];
                                             [rootDictMutable removeObjectForKey:@"currentStart"];
                                             [rootDictMutable removeObjectForKey:@"currentEnd"];
                                             [rootDictMutable removeObjectForKey:@"needsPaging"];
                                             
                                             self.pebbleApps = [[NSMutableArray alloc] init];
                                             
                                             for (NSString *key in rootDictMutable.allKeys) {
                                                 NSDictionary *subDict = [rootDictMutable valueForKey:key];
                                                 NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
                                                 
                                                 [newDict setValue:subDict forKey:@"appData"];
                                                 
                                                 [newDict setValue:key forKey:@"appNumber"];
                                                 
                                                 [self.pebbleApps addObject:newDict];
                                               
                                             }
                                             
                                             NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"appNumber" ascending:YES comparator:^(id obj1, id obj2) {
                                                 
                                                 if ([obj1 integerValue] > [obj2 integerValue]) {
                                                     return (NSComparisonResult)NSOrderedDescending;
                                                 }
                                                 if ([obj1 integerValue] < [obj2 integerValue]) {
                                                     return (NSComparisonResult)NSOrderedAscending;
                                                 }
                                                 return (NSComparisonResult)NSOrderedSame;
                                             }];
                                             
                                             [self.pebbleApps sortUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
                                             
                                            // NSLog(@"%@",self.pebbleApps);
                                             
                                             [self.collectionView performBatchUpdates:^{
                                                 [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                             } completion:nil];
                                             
                                             if ([SVProgressHUD isVisible]) {
                                                 [SVProgressHUD dismiss];
                                             }
                                             else {
                                                 [self.refreshControl endRefreshing];
                                             }
                                             //login
                                             __weak typeof(self) weakSelf = self;
                                             [self.collectionView addInfiniteScrollingWithActionHandler:^{
                                                 [weakSelf getNext20];
                                                 //endlogin
                                             }];
                                             
                                             self.collectionView.showsInfiniteScrolling = YES;
                                             
                                             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                             
                                             [defaults setBool:NO forKey:@"shouldLoadQuery"];
                                             
                                             if (self.pebbleApps.count == 0) {
                                                 [SVProgressHUD showErrorWithStatus:@"No results!"];
                                             }
                                         }
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id responseObject)
                                         {
                                             NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
                                             
                                             [[UserClass sharedSingleton] connectionError:error];
                                         }];
    
    [operation start];
        
    }



}


- (void) fetchingData:(NSNotification *) notification{
    if([[notification name] isEqualToString:@"error" ]){
        [SVProgressHUD dismiss];
   
    }
}
//login

//endlogin
- (void)getNext20 {
    [self pagingURLRefresh];
    
    NSURL *apiURL = self.pagingURL;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:apiURL];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject)
                                         {
                                             NSDictionary *rootDict = [responseObject objectForKey:@"data"];
                                             
                                             NSMutableDictionary *rootDictMutable = [rootDict mutableCopy];
                                             
                                             self.paginationDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                                    [rootDictMutable objectForKey:@"total"],@"total",
                                                                    [rootDictMutable objectForKey:@"chunk"],@"chunk",
                                                                    [rootDictMutable objectForKey:@"order"],@"order",
                                                                    [rootDictMutable objectForKey:@"startAt"],@"startAt",
                                                                    [rootDictMutable objectForKey:@"pages"],@"pages",
                                                                    [rootDictMutable objectForKey:@"current"],@"current",
                                                                    [rootDictMutable objectForKey:@"previous"],@"previous",
                                                                    [rootDictMutable objectForKey:@"next"],@"next",
                                                                    [rootDictMutable objectForKey:@"last"],@"last",
                                                                    [rootDictMutable objectForKey:@"currentStart"],@"currentStart",
                                                                    [rootDictMutable objectForKey:@"currentEnd"],@"currentEnd",
                                                                    [rootDictMutable objectForKey:@"needsPaging"],@"needsPaging", nil];
                                             
                                             // Remove unwanted dictionary keys for testing...
                                             
                                             [rootDictMutable removeObjectForKey:@"total"];
                                             [rootDictMutable removeObjectForKey:@"chunk"];
                                             [rootDictMutable removeObjectForKey:@"order"];
                                             [rootDictMutable removeObjectForKey:@"startAt"];
                                             [rootDictMutable removeObjectForKey:@"pages"];
                                             [rootDictMutable removeObjectForKey:@"current"];
                                             [rootDictMutable removeObjectForKey:@"previous"];
                                             [rootDictMutable removeObjectForKey:@"next"];
                                             [rootDictMutable removeObjectForKey:@"last"];
                                             [rootDictMutable removeObjectForKey:@"currentStart"];
                                             [rootDictMutable removeObjectForKey:@"currentEnd"];
                                             [rootDictMutable removeObjectForKey:@"needsPaging"];
                                             
                                             if ([self.paginationDict objectForKey:@"needsPaging"]) {
                                                 
                                                // NSLog(@"%@",rootDictMutable);
                                                 
                                                 [self insertRows:rootDictMutable];
                                             }
                                             else {
                                                 [self.collectionView.infiniteScrollingView stopAnimating];
                                                 self.collectionView.showsInfiniteScrolling = NO;
                                             }
                                         }
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id responseObject)
                                         {
                                             NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
                                             
                                             [[UserClass sharedSingleton] connectionError:error];
                                         }];
    
    [operation start];
}

- (void)insertRows:(NSMutableDictionary*)newInfo {
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.collectionView performBatchUpdates:^{
            
            NSMutableArray *addedApps = [NSMutableArray new];
            
            for (NSString *key in newInfo.allKeys) {
                NSDictionary *subDict = [newInfo valueForKey:key];
                NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
                
                [newDict setValue:subDict forKey:@"appData"];
                [newDict setValue:key forKey:@"appNumber"];
                
                [addedApps addObject:newDict];
            }
            
            NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"appNumber" ascending:YES comparator:^(id obj1, id obj2) {
                
                if ([obj1 integerValue] > [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                if ([obj1 integerValue] < [obj2 integerValue]) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                return (NSComparisonResult)NSOrderedSame;
            }];
            
            [addedApps sortUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
            
            for (NSDictionary *dict in addedApps) {
                [self.pebbleApps insertObject:dict atIndex:(self.pebbleApps.count)];
                
                [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.pebbleApps.count-1 inSection:0]]];
            }
            
            [self.collectionView.infiniteScrollingView stopAnimating];
        } completion:nil];
    });
}

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
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    CGSize retval = CGSizeMake(68, 79);
//    return retval;
//}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    pebbleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    //login
    __weak pebbleCell *cellWeak = cell;
    //endlogin
    [cell.imageView setImageWithURL:[NSURL URLWithString:[[[self.pebbleApps objectAtIndex:indexPath.item]objectForKey:@"appData"] objectForKey:@"previewURL"]]
                   placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                              if(image == nil) {
                                  NSLog(@"Error: %@",error);
                              }
                              else {
                                  [cellWeak.imageView setImage:image];
                              }
                          }];
    
    cell.backgroundColor = [UIColor blackColor];
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //Set style of app details (flat ui kit)...
    
    AppDetailsViewController *vc = [[AppDetailsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    [vc setAppData:[self.pebbleApps objectAtIndex:indexPath.item]];
    
    // Push to App Details...
    
    [[self navigationController] pushViewController:vc animated:YES];
}

@end
