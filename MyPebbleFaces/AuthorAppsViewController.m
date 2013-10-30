//
//  AuthorAppsViewController.m
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 7/18/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "AuthorAppsViewController.h"

@interface AuthorAppsViewController ()

@end

@implementation AuthorAppsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.authorName;
    
    self.tableView.separatorColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    self.tableView.backgroundView = nil;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor darkGrayColor];
    [self.refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    [SVProgressHUD showWithStatus:@"Fetching Faces..."];
    
    [self getFaces];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dropViewDidBeginRefreshing:(UIRefreshControl *)refreshControl
{
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self getFaces];
    });
}

- (void)getFaces {
    NSURL *apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://mypebbleapps.com/pebbleInterface?action=getApps&offset=0&limit=40&author=%@",self.authorID]];
    // NSURL *apiURL = [NSURL URLWithString:@"http://localhost/~rfawcett/test.json"];
    
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
             
             self.pebbleApps = [[NSMutableArray alloc] init];
             
             for (NSString *key in rootDictMutable.allKeys) {
                 NSDictionary *subDict = [rootDictMutable valueForKey:key];
                 NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
                 
                 [newDict setValue:subDict forKey:@"appData"];
                 [newDict setValue:key forKey:@"appNumber"];
                 
                 [self.pebbleApps addObject:newDict];
             }
             
             [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
             
             if ([SVProgressHUD isVisible]) {
                 [SVProgressHUD dismiss];
             }
             else {
                 [self.refreshControl endRefreshing];
             }
             NSLog(@"TEST: %@",self.pebbleApps);
         }
         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id responseObject)
         {
             NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
             UserClass *singleton = [UserClass sharedSingleton];
             [singleton connectionError:error];
         }];
    
    [operation start];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.pebbleApps.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.pebbleApps.count == 0) {
        return nil;
    }
    else {
        return [NSString stringWithFormat:@"%@'s Apps",self.authorName];

    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.textLabel.text = [[[self.pebbleApps objectAtIndex:indexPath.row] objectForKey:@"appData"] objectForKey:@"title"];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.cornerRadius = 5.0f;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Set style of app details (flat ui kit)...
    
    AppDetailsViewController *vc = [[AppDetailsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    [vc setAppData:[self.pebbleApps objectAtIndex:indexPath.item]];
    
    // Push to App Details...
    
    [[self navigationController] pushViewController:vc animated:YES];
}

@end
