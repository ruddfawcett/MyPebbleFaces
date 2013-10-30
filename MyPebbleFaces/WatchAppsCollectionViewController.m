//
//  WatchAppsCollectionViewController.m
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 7/17/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "WatchAppsCollectionViewController.h"
#import "AppDelegate.h"

@interface WatchAppsCollectionViewController ()

@end

@implementation WatchAppsCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // app spacing
    self.singleton = [UserClass sharedSingleton];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setMinimumInteritemSpacing:5.0f];
    [flowLayout setMinimumLineSpacing:5.0f];
    [flowLayout setItemSize:CGSizeMake(73.75f, 85.75f)];
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    [self.collectionView setShowsVerticalScrollIndicator:NO];
    
    //
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self.singleton setQueryString:nil];
    [self.singleton setPagingQueryString:nil];
    [self.singleton setShouldLoadQuery:NO];
//    [defaults removeObjectForKey:@"queryString"];
//    [defaults removeObjectForKey:@"pagingQueryString"];
//    [defaults removeObjectForKey:@"shouldLoadQuery"];
    
    self.title = @"Faces";
    self.navigationController.navigationBar.topItem.title = @"My Pebble Faces";
    
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
     
    
    
    if ([self.singleton isLogged]) {
        self.queryURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.mypebblefaces.com/pebbleInterface?action=getApps&offset=0&limit=%d&cookie=%@",initNum,[self.singleton cookie]]];
    }
    else {
        self.queryURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.mypebblefaces.com/pebbleInterface?action=getApps&offset=0&limit=%d",initNum]];
    }
    
    
    NSLog(@"%@", self.queryURL);
    [SVProgressHUD showWithStatus:@"Fetching Faces..."];
    
    [self getFaces];
    
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    //login
    __weak typeof(self) weakSelf = self;
    [self.collectionView addInfiniteScrollingWithActionHandler:^{
        [weakSelf getNext20];
    }];
    //endlogin
    
    [self.tabBarController.tabBar configureFlatTabBarWithColor:[UIColor colorWithRed:0.745 green:0.196 blue:0.071 alpha:1.00] selectedColor:[UIColor colorWithRed:0.631 green:0.000 blue:0.031 alpha:1.00]];
    
    UIBarButtonItem *filterSearchButton = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(bringUpSearch:)];
    UIBarButtonItem *resetButton = [[UIBarButtonItem alloc] initWithTitle:@"Default" style:UIBarButtonItemStylePlain target:self action:@selector(resetView:)];
    
    self.navigationItem.rightBarButtonItem = filterSearchButton;
    self.navigationItem.leftBarButtonItem = resetButton;
    
  
    
    NSString *filterPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Filters.plist"];
    
    self.filterList = [[NSMutableArray alloc] init];
    self.filterList = [NSMutableArray arrayWithContentsOfFile:filterPath];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Faces"
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    
    
    //login

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userHasLoggedIn:)
                                                 name:@"login"
                                               object:self.singleton];
   
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchingData:)
                                                 name:@"showHUDAuto"
                                               object:self.singleton];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchingData:)
                                                 name:@"showHUD"
                                               object:self.singleton];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchingData::)
                                                 name:@"error"
                                               object:self.singleton];
    [[NSNotificationCenter defaultCenter]    addObserver:self
                                                selector:@selector(loggedOut:)
                                                    name:@"logOut"
                                                  object:self.singleton];
    
    NSLog(@"View did appear");
    
    
    [self.singleton autoLogin];
    //endlogin
}

- (IBAction)resetView:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [self.singleton setQueryString:nil];
    [self.singleton setPagingQueryString:nil];
    [self.singleton setShouldLoadQuery:NO];
     
    int initNum;
    
    if (![defaults objectForKey:@"initNumber"]) {
        [defaults setObject:[NSString stringWithFormat:@"40"] forKey:@"initNumber"];
        initNum = 40;
    }
    else {
        initNum = [[defaults objectForKey:@"initNumber"] intValue];
    }
   
    if ([self.singleton isLogged]) {
        self.queryURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.mypebblefaces.com/pebbleInterface?action=getApps&offset=0&limit=%d&cookie=%@",initNum,[self.singleton cookie]]];
    }
    else {
        self.queryURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.mypebblefaces.com/pebbleInterface?action=getApps&offset=0&limit=%d",initNum]];
    }
    
    int pageNum;
    
    if (![defaults objectForKey:@"pageNumber"]) {
        pageNum = 20;
    }
    else {
        pageNum = [[defaults objectForKey:@"pageNumber"] intValue];
    }
   
    if ([self.singleton isLogged]) {
        self.pagingURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.mypebblefaces.com/pebbleInterface?action=getApps&offset=%@&limit=%d&cookie=%@",
                                               [self.paginationDict objectForKey:@"next"],pageNum,[self.singleton cookie]]];
    }
    else {
        self.pagingURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.mypebblefaces.com/pebbleInterface?action=getApps&offset=%@&limit=%d",
                                               [self.paginationDict objectForKey:@"next"],pageNum]];
    }
    
    [SVProgressHUD showWithStatus:@"Resetting..."];
    
    [self getFaces];
}

- (IBAction)bringUpSearch:(id)sender {
    FilterSelectionViewController *vc = [[FilterSelectionViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:navigationController animated:YES completion:nil];
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
  
}
-(void)dealloc{
    
    
    //login
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //endlogin
}
- (void) userHasLoggedIn:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self getFaces];
    
    
    
}

-(void) loggedOut:(NSNotification *) notification{
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self getFaces];
    
    
}
- (void)viewDidAppear:(BOOL)animated {
    if ([self.singleton shouldLoadQuery]) {
        self.queryURL = [NSURL URLWithString:[self.singleton queryString]];
        
        [SVProgressHUD showWithStatus:@"Fetching Faces..."];
        
        [self getFaces];
        
        NSMutableString *pagingURLMutable = [NSMutableString stringWithFormat:@"%@",[self.singleton pagingQueryString]];
        
        [pagingURLMutable appendString:[NSMutableString stringWithFormat:@"&offset=%@",[self.paginationDict objectForKey:@"next"]]];
        
        
        
        if ([self.singleton isLogged]) {
            [pagingURLMutable appendString:[NSMutableString stringWithFormat:@"&cookie=%@",[self.singleton cookie]]];
            self.pagingURL = [NSURL URLWithString:pagingURLMutable];
        }
        else {
            self.pagingURL = [NSURL URLWithString:pagingURLMutable];
        }
    }
}

- (void)pagingURLRefresh {
    
     
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([self.singleton pagingQueryString] != nil) {
        NSMutableString *pagingURLMutable = [NSMutableString stringWithFormat:@"%@",[self.singleton pagingQueryString]];
        
        [pagingURLMutable appendString:[NSMutableString stringWithFormat:@"&offset=%@",[self.paginationDict objectForKey:@"next"]]];
        
        
        
        if ([self.singleton isLogged]) {
            [pagingURLMutable appendString:[NSMutableString stringWithFormat:@"&cookie=%@",[self.singleton cookie]]];
            self.pagingURL = [NSURL URLWithString:pagingURLMutable];
        }
        else {
            self.pagingURL = [NSURL URLWithString:pagingURLMutable];
        }
    }
    else {
        int pageNum;
        
        if (![defaults objectForKey:@"pageNumber"]) {
            pageNum = 20;
        }
        else {
            pageNum = [[defaults objectForKey:@"pageNumber"] intValue];
        }
        
        
        if ([self.singleton isLogged]) {
            self.pagingURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.mypebblefaces.com/pebbleInterface?action=getApps&offset=%@&limit=%d&cookie=%@",[self.paginationDict objectForKey:@"next"],pageNum,[self.singleton cookie]]];
        }
        else {
            self.pagingURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.mypebblefaces.com/pebbleInterface?action=getApps&offset=%@&limit=%d",[self.paginationDict objectForKey:@"next"],pageNum]];
        }
    }
}


- (void)getFaces {
    NSURL *apiURL = self.queryURL;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:apiURL];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject)
                                         {
                                             
                                          //  NSLog(@"%@",responseObject);
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
                                                 // NSLog(@"%@",newDict);
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
                                             
                                             //NSLog(@"%@",self.pebbleApps);
                                             
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
                                             
                                             self.singleton.shouldLoadQuery = NO;
                                             
                                             if (self.pebbleApps.count == 0) {
                                                 [SVProgressHUD showErrorWithStatus:@"No results!"];
                                             }
                                         }
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id responseObject)
                                         {
                                             NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
                                             
                                                UserClass *singleton = [UserClass sharedSingleton];
                                                [singleton connectionError:error];
                                         }];
    
    [operation start];
}

 
- (void) fetchingData:(NSNotification *) notification{
    
    if([[notification name] isEqualToString:@"error" ]) {
        [SVProgressHUD dismiss];
        [self.refreshControl endRefreshing];
        
    }
}

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
                                                 
                                             //    NSLog(@"%@",rootDictMutable);
                                                 
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
                                             
                                             UserClass *singleton = [UserClass sharedSingleton];
                                             [singleton connectionError:error];
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
                
                [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.pebbleApps.count-1 inSection:0]]];
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
