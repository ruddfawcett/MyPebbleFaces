//
//  UpdatesViewController.m
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 9/21/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "UpdatesViewController.h"

@interface UpdatesViewController ()

@end

@implementation UpdatesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Updates";
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(dismissController)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    //UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Update All" style:UIBarButtonItemStylePlain target:self action:@selector(updateAll)];
    // self.navigationItem.rightBarButtonItem = rightButton;
    
    
    self.navigationController.navigationBar.translucent = NO;
    //  self.tableView.backgroundColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    self.tableView.backgroundView = nil;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor colorWithRed:1.000 green:0.231 blue:0.188 alpha:1.00];
    [self.refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    [SVProgressHUD showWithStatus:@"Fetching Updates..."];
    [self getUpdates];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDeleteFace:)
                                                 name:@"didDeleteFace"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateFace:)
                                                 name:@"didUpdateFace"
                                               object:nil];
}

//- (void)viewWillAppear:(BOOL)animated {
//    [SVProgressHUD showWithStatus:@"Fetching Updates..."];
//    [self getUpdates];
//}

-(void)didDeleteFace:(NSNotification *)notification {
    NSIndexPath *indexPath = [[notification userInfo] objectForKey:@"indexPath"];
    
    [self.pebbleApps removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.tableView reloadData];
}

-(void)didUpdateFace:(NSNotification *)notification {
    NSIndexPath *indexPath = [[notification userInfo] objectForKey:@"indexPath"];
    
    if ([[[notification userInfo] objectForKey:@"installed"] integerValue] == 1) {
        [self.installed removeObjectAtIndex:indexPath.row];
    }
    else {
        [self.pebbleApps removeObjectAtIndex:indexPath.row];
    }
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.tableView reloadData];
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
        [self getUpdates];
    });
}

- (void)dismissController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateAll {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)getUpdates {
    NSURL *apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.mypebblefaces.com/pebbleInterface?action=getUpdates&cookie=%@",[[UserClass sharedSingleton] cookie]]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:apiURL];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject)
                                         {
                                             NSLog(@"%@",responseObject);
                                             //  NSLog(@"%@",responseObject);
                                             NSDictionary *rootDict = [responseObject objectForKey:@"data"];
                                             
                                             NSMutableDictionary *rootDictMutable = [rootDict mutableCopy];
                                             
                                             NSString *downloadPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Downloads.plist"];
                                             
                                             NSMutableArray *downloads = [[NSMutableArray alloc] init];
                                             downloads = [NSMutableArray arrayWithContentsOfFile:downloadPath];
                                             
                                             self.pebbleApps = [[NSMutableArray alloc] init];
                                             self.installed = [[NSMutableArray alloc] init];
                                             
                                             for (NSString *key in rootDictMutable.allKeys) {
                                                 NSDictionary *subDict = [rootDictMutable valueForKey:key];
                                                 NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
                                                 
                                                 [newDict setValue:[subDict mutableCopy] forKey:@"appData"];
                                                 
                                                 
                                                 [newDict setValue:key forKey:@"appNumber"];
                                                 
                                                 if ([[[newDict objectForKey:@"appData"] objectForKey:@"update"] isEqualToString:@"true"]) {
                                                     for (NSDictionary *eachApp in downloads) {
                                                         NSLog(@"%@\n%@",[eachApp objectForKey:@"cID"],[[newDict objectForKey:@"appData"] objectForKey:@"cID"]);
                                                         if ([[eachApp objectForKey:@"cID"] intValue] == [[[newDict objectForKey:@"appData"] objectForKey:@"cID"] intValue]) {
                                                             [[newDict objectForKey:@"appData"] setValue:@"1" forKey:@"installed"];
                                                             [self.pebbleApps removeObject:newDict];
                                                             [self.installed addObject:newDict];
                                                         }
                                                         else {
                                                             NSLog(@"%@",[newDict objectForKey:@"appData"]);
                                                             if (![self.pebbleApps containsObject:newDict] && ![self.installed containsObject:newDict]) {
                                                                 if ([[[newDict objectForKey:@"appData"] objectForKey:@"installed"] integerValue] != 1) {
                                                                     [self.pebbleApps addObject:newDict];
                                                                 }
                                                             }
                                                         }
                                                     }
                                                 }
                                             }
                                             
                                             [self.tableView reloadData];
                                             
                                             if (self.pebbleApps.count != 0 && self.installed.count != 0) {
                                                 [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,2)] withRowAnimation:UITableViewRowAnimationFade];
                                             }
                                             else [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                                             
                                             if ([SVProgressHUD isVisible]) {
                                                 [SVProgressHUD dismiss];
                                             }
                                             else {
                                                 [self.refreshControl endRefreshing];
                                             }
                                             NSLog(@"TEST: %@",self.pebbleApps);
                                             if (self.installed.count == 0 && self.pebbleApps.count == 0) {
                                                 [SVProgressHUD showErrorWithStatus:@"No updates!"];
                                                 [self dismissViewControllerAnimated:YES completion:nil];
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

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (self.pebbleApps.count == 0 && self.installed.count == 0) {
        return nil;
    }
    else {
        if (self.pebbleApps.count == 0) {
            if (section == 0) {
                return nil;
            }
        }
        else if (self.installed.count == 0) {
            if (section == 0) {
                return @"You may permenantly delete a face from receiving updates by tapping on it, and removing it from updates.";
            }
        }
        else {
            if (section == 0) {
                return nil;
            }
            else return @"You may permenantly delete a face from receiving updates by tapping on it, and removing it from updates.";
        }
    }
    return nil;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.pebbleApps.count == 0 && self.installed.count == 0) {
        return nil;
    }
    else {
        if (self.pebbleApps.count == 0) {
            if (section == 0) {
                return @"Downloaded Faces";
            }
        }
        else if (self.installed.count == 0) {
            if (section == 0) {
                return @"Undownloaded Faces";
            }
        }
        else {
            if (section == 0) {
                return @"Downloaded Faces";
            }
            else return @"Undownloaded Faces";
        }
    }
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // #warning Potentially incomplete method implementation.
    // Return the number of sections.
    
    if (self.pebbleApps.count != 0 && self.installed.count != 0) {
        return 2;
    }
    else return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // #warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (self.pebbleApps.count == 0) {
        if (section == 0) {
            return self.installed.count;
        }
    }
    else if (self.installed.count == 0) {
        if (section == 0) {
            return self.pebbleApps.count;
        }
    }
    else {
        if (section == 0) {
            return self.installed.count;
        }
        else return self.pebbleApps.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    cell.cornerRadius = 5.0f;
    
    if (self.pebbleApps.count == 0) {
        if (indexPath.section == 0) {
            if (indexPath.section == 0) {
                cell.textLabel.text = [[[self.installed objectAtIndex:indexPath.row] objectForKey:@"appData"] objectForKey:@"title"];
            }
        }
    }
    else if (self.installed.count == 0) {
        if (indexPath.section == 0) {
            cell.textLabel.text = [[[self.pebbleApps objectAtIndex:indexPath.row] objectForKey:@"appData"] objectForKey:@"title"];
        }
    }
    else {
        if (indexPath.section == 0) {
            cell.textLabel.text = [[[self.installed objectAtIndex:indexPath.row] objectForKey:@"appData"] objectForKey:@"title"];
        }
        else {
            cell.textLabel.text = [[[self.pebbleApps objectAtIndex:indexPath.row] objectForKey:@"appData"] objectForKey:@"title"];
        }
    }
    
    //    if ([[[[self.pebbleApps objectAtIndex:indexPath.row] objectForKey:@"appData"] objectForKey:@"installed"] integerValue] == 1) {
    //        //cell.detailTextLabel.text = @"Downloaded";
    //        cell.textLabel.textColor = [UIColor colorWithRed:1.000 green:0.231 blue:0.188 alpha:1.00];
    //    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SubAppViewController *vc = [[SubAppViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    if (self.pebbleApps.count == 0) {
        if (indexPath.section == 0) {
            [vc setAppData:[[self.installed objectAtIndex:indexPath.row] objectForKey:@"appData"]];
        }
    }
    else if (self.installed.count == 0) {
        if (indexPath.section == 0) {
            [vc setAppData:[[self.pebbleApps objectAtIndex:indexPath.row] objectForKey:@"appData"]];
        }
    }
    else {
        if (indexPath.section == 0) {
            [vc setAppData:[[self.installed objectAtIndex:indexPath.row] objectForKey:@"appData"]];
        }
        else [vc setAppData:[[self.pebbleApps objectAtIndex:indexPath.row] objectForKey:@"appData"]];
    }
    
    [vc setIndexPath:indexPath];
    [vc setIsDesc:0];
    
    [[self navigationController] pushViewController:vc animated:YES];
}

@end
