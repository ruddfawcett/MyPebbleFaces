//
//  SettingsViewController.m
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 8/30/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Settings";
    
    self.tableView.separatorColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    self.tableView.backgroundView = nil;
    
    self.tableView.allowsMultipleSelection = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    //[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
//    if ([[UserClass sharedSingleton] isLogged]) {
//        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:0];
//        [cell.textLabel setText:@"Logout"];
//        [self.tableView reloadData];
//    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Link Account";
        
    }
    else if (section == 1) {
       
        return @"Faces";
       
    }
    else if (section == 2) {
         return @"Filters";
    }
    else if (section == 3) {
        return @"Extras - Coming Soon!";
    }
    else {
        return @"Other";   
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 1 || section == 4) {
        return 2;
    }
    else if (section == 3) {
        return 4;
    }
    else return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (indexPath.section == 0) {
        
        
        cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        if ([[UserClass sharedSingleton] isLogged]) {
            cell.textLabel.text = @"Logout";
        }
        else {
            cell.textLabel.text = @"Login";
        }
        
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.cornerRadius = 5.0f;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    }
    else if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.textLabel.text = @"Initial Number of Apps";
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            if (![defaults objectForKey:@"initNumber"]) {
                cell.detailTextLabel.text = @"";
            }
            else {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",[[defaults objectForKey:@"initNumber"] intValue]];
            }
            
            cell.detailTextLabel.textColor = [UIColor whiteColor];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.cornerRadius = 5.0f;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else {
            cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.textLabel.text = @"Paging Number of Apps";
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            if (![defaults objectForKey:@"pageNumber"]) {
                cell.detailTextLabel.text = @"20";
                [defaults setObject:[NSString stringWithFormat:@"20"] forKey:@"pageNumber"];
            }
            else {
                NSLog(@"%@",[NSString stringWithFormat:@"%d",[[defaults objectForKey:@"pageNumber"] intValue]]);
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",[[defaults objectForKey:@"pageNumber"] intValue]];
            }
            
            cell.detailTextLabel.textColor = [UIColor whiteColor];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.cornerRadius = 5.0f;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else if (indexPath.section == 2) {
        
        
        //        if (indexPath.row == 0) {
        //            cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //            cell.textLabel.text = @"Initial Filter to Load";
        //            cell.textLabel.textColor = [UIColor whiteColor];
        //            cell.cornerRadius = 5.0f;
        //            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //        }
        //        else if (indexPath.row == 1) {
        cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.textLabel.text = @"Manage Filters";
        cell.textLabel.textColor = [UIColor whiteColor];
        
        cell.cornerRadius = 5.0f;
        
        NSString *filterPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Filters.plist"];
        
        NSMutableArray *filterList = [[NSMutableArray alloc] init];
        filterList = [NSMutableArray arrayWithContentsOfFile:filterPath];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",filterList.count];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //        }
    
    }
    else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.textLabel.text = @"Push Notifications";
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.cornerRadius = 5.0f;
            cell.detailTextLabel.text = @"$0.99";
            cell.detailTextLabel.textColor = [UIColor whiteColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.userInteractionEnabled = NO;
            
            //            pushSwitch = [[FUISwitch alloc] initWithFrame:CGRectMake(23, 8, 77, 27)];
            //            pushSwitch.onColor = [UIColor whiteColor];
            //            pushSwitch.offColor = [UIColor whiteColor];
            //            pushSwitch.onBackgroundColor = [UIColor colorWithWhite:0.271 alpha:1.0];
            //            pushSwitch.offBackgroundColor = [UIColor colorWithWhite:0.271 alpha:1.0];
            //            pushSwitch.offLabel.font = [UIFont boldSystemFontOfSize:17];
            //            pushSwitch.onLabel.font = [UIFont boldSystemFontOfSize:17];
            //            
            //            [pushSwitch setOn:FALSE];
        
            cell.accessoryView = pushSwitch;
        }
        else if (indexPath.row == 1) {
            cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.textLabel.text = @"QR Code Scanner";
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.cornerRadius = 5.0f;
            // cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.detailTextLabel.text = @"$0.99";
            cell.detailTextLabel.textColor = [UIColor whiteColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.userInteractionEnabled = NO;
            
            //            qrSwitch = [[FUISwitch alloc] initWithFrame:CGRectMake(23, 8, 77, 27)];
            //            qrSwitch.onColor = [UIColor whiteColor];
            //            qrSwitch.offColor = [UIColor whiteColor];
            //            qrSwitch.onBackgroundColor = [UIColor colorWithWhite:0.271 alpha:1.0];
            //            qrSwitch.offBackgroundColor = [UIColor colorWithWhite:0.271 alpha:1.0];
            //            qrSwitch.offLabel.font = [UIFont boldSystemFontOfSize:17];
            //            qrSwitch.onLabel.font = [UIFont boldSystemFontOfSize:17];
            //            
            //            [qrSwitch setOn:FALSE];
            //            
            //            cell.accessoryView = qrSwitch;
        }
        else if (indexPath.row == 2) {
            cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.textLabel.text = @"Custom Filter for Faces";
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.cornerRadius = 5.0f;
            // cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.detailTextLabel.text = @"$0.99";
            cell.detailTextLabel.textColor = [UIColor whiteColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.userInteractionEnabled = NO;
        }
        else {
            cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.textLabel.text = @"All Extras";
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.cornerRadius = 5.0f;
            // cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.detailTextLabel.text = @"$1.99";
            cell.detailTextLabel.textColor = [UIColor whiteColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.userInteractionEnabled = NO;
        }
    }
    else {
        if (indexPath.row == 0) {
            cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.text = @"Feedback";
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.cornerRadius = 5.0f;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else {
            cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.text = @"Credits";
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.cornerRadius = 5.0f;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
     
        
    }
    
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
    if (indexPath.section == 0) {
        
        // If you notice, we can use this, because we hardly even need a storybaord now, it's all done programatically!!
        if ([[UserClass sharedSingleton] isLogged]) {
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                [SVProgressHUD showWithStatus:@"Logging Out..."];
                [[UserClass sharedSingleton] logout];
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                [cell.textLabel setText:@"Login"];
        }
        else {
            LoginViewController *vc = [[LoginViewController alloc] initWithStyle:UITableViewStyleGrouped];
            
            [[self navigationController] pushViewController:vc animated:YES];
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            InitialNumberViewController *vc = [[InitialNumberViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [[self navigationController] pushViewController:vc animated:YES];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        else {
            PaginationNumberViewController *vc = [[PaginationNumberViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [[self navigationController] pushViewController:vc animated:YES];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
   
    }
    else if (indexPath.section == 2)  {
        
        
        //        if (indexPath.row == 0) {
        //        }
        //        else {
        ManageFiltersViewController *vc = [[ManageFiltersViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [[self navigationController] pushViewController:vc animated:YES];
        //        }

    }
    else if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            AAMFeedbackViewController *vc = [[AAMFeedbackViewController alloc] init];
            vc.toRecipients = @[@"mypebblefacesios@email.com"];
            vc.ccRecipients = nil;
            vc.bccRecipients = nil;
            // UINavigationController *feedbackNavigation = [[UINavigationController alloc] initWithRootViewController:vc];
            //[self presentViewController:feedbackNavigation animated:YES completion:nil];
            [[self navigationController] pushViewController:vc animated:YES];
        }
        else {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"credits" ofType:@"txt"];
            NSString *creditString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
            
            GeneralTextViewController *vc = [[GeneralTextViewController alloc] init];
            [vc setTitle:@"Credits"];
            
            [vc setText:creditString];
            
            [[self navigationController] pushViewController:vc animated:YES];
        }

        
        
    }
}

@end
