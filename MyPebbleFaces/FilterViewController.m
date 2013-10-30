//
//  FilterViewController.m
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 9/3/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "FilterViewController.h"

@interface FilterViewController ()

@end

@implementation FilterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Filters";
    
    self.navigationController.navigationBar.topItem.title = @"Filter Builder";
    
    self.tableView.separatorColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    self.tableView.backgroundView = nil;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor darkGrayColor];
    [self.refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];

    [SVProgressHUD showWithStatus:@"Fetching Filters..."];
    [self getFilters];
    
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.autoresizesSubviews = YES;
    
    self.yesNo = [[NSArray alloc] initWithObjects:@"Yes", @"No", nil];
    
    self.selectedPaths = [NSMutableArray new];
    self.selectedPathForSection1 = nil;
    self.selectedPathForSection2 = nil;
    self.selectedPathForSection3 = nil;
    self.selectedPathForSection4 = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == filterNameField) {
        [filterNameField resignFirstResponder];
        
        // self.filterNameText = filterNameField.text;
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == filterNameField) {
        self.filterNameText = [filterNameField.text stringByReplacingCharactersInRange:range withString:string];
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dropViewDidBeginRefreshing:(UIRefreshControl *)refreshControl
{
    [self.view endEditing:YES];
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self getFilters];
    });
}

- (void)viewDidDisappear:(BOOL)animated {
    [SVProgressHUD dismiss];
}

- (IBAction)clearTable:(id)sender {
    [self reloadReset];
}

- (IBAction)saveFilterQuery:(id)sender {
    self.filterParams = [[NSMutableDictionary alloc] init];
    
    if (filterNameField.text.length != 0) {
        [self.filterParams setObject:filterNameField.text forKey:@"filter_name"];
        
        if ([self.selectedPaths count] !=0) {
            NSMutableArray *filters = [NSMutableArray new];
            
            for (NSIndexPath *indexPath in self.selectedPaths) {
                NSString *tag = [[self.filters objectForKey:@"pebble_tags"] objectAtIndex:indexPath.row];
                
                [filters addObject:tag];
            }
            [self.filterParams setObject:filters forKey:@"pebble_tags"];
        }
        
        if (self.selectedPathForSection1 != nil) {
            if ([[self.yesNo objectAtIndex:self.selectedPathForSection1.row] isEqualToString:@"Yes"]) {
                [self.filterParams setObject:@"0" forKey:@"pebble_generated"];
            }
        }
        
        if (self.selectedPathForSection2 != nil) {
            NSString *text = [[[self.filters objectForKey:@"sortBy"] allKeys] objectAtIndex:self.selectedPathForSection2.row];
            
            [self.filterParams setObject:[[[self.filters objectForKey:@"sortBy"] allKeys] objectAtIndex:self.selectedPathForSection2.row] forKey:@"sortBy"];
            [self.filterParams setObject:[[self.filters objectForKey:@"sortBy"] objectForKey:text] forKey:@"sortByValue"];
        }
        
        if (self.selectedPathForSection3 != nil) {
            [self.filterParams setObject:[[self.filters objectForKey:@"pebble_appType"] objectAtIndex:self.selectedPathForSection3.row] forKey:@"pebble_appType"];
        }
        
        if (self.selectedPathForSection4 != nil) {
            [self.filterParams setObject:[[self.filters objectForKey:@"pebble_language"] objectAtIndex:self.selectedPathForSection4.row] forKey:@"pebble_language"];
        }

        NSLog(@"%@",self.filterParams);
        
        [self saveFilter:self.filterParams];
    }
    else {
        self.alert = [[FUIAlertView alloc] initWithTitle:@"Error!" message:@"Please don't leave the title blank!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        self.alert.titleLabel.textColor = [UIColor cloudsColor];
        self.alert.titleLabel.font = [UIFont boldFlatFontOfSize:16];
        self.alert.messageLabel.textColor = [UIColor cloudsColor];
        self.alert.messageLabel.font = [UIFont flatFontOfSize:14];
        self.alert.backgroundOverlay.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
        self.alert.alertContainer.backgroundColor = [UIColor colorWithRed:0.745 green:0.196 blue:0.071 alpha:1.00];
        self.alert.defaultButtonColor = [UIColor cloudsColor];
        self.alert.defaultButtonShadowColor = [UIColor asbestosColor];
        self.alert.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
        self.alert.defaultButtonTitleColor = [UIColor asbestosColor];
        [self.alert show];
    }
}

- (void)saveFilter:(NSMutableDictionary *)filterParams {
    NSString *filterPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Filters.plist"];

    NSMutableArray *filterList = [[NSMutableArray alloc] init];
    filterList = [NSMutableArray arrayWithContentsOfFile:filterPath];
    [filterList addObject:filterParams];
    
    NSLog(@"%@",filterList);
    
    [filterList writeToFile:filterPath atomically:YES];
    
    if ([filterList writeToFile:filterPath atomically:YES]) {
        NSLog(@"Success!");
        
        NSLog(@"Final array:\n\n%@",[NSMutableArray arrayWithContentsOfFile:filterPath]);
        
        [SVProgressHUD showSuccessWithStatus:@"Saved Filter!"];
        
        [self reloadReset];
    }
    else {
        [SVProgressHUD showErrorWithStatus:@"Error!"];
        NSLog(@"Error saving to plist...");
    }

}

#pragma mark - Table view data source

- (void)reloadReset {
    self.selectedPaths = [NSMutableArray new];
    self.filterNameText = nil;
    self.selectedPathForSection1 = nil;
    self.selectedPathForSection2 = nil;
    self.selectedPathForSection3 = nil;
    self.selectedPathForSection4 = nil;
    
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)getFilters {
    NSURL *apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.mypebblefaces.com/pebbleInterface?action=getAttributeList"]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:apiURL];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
         JSONRequestOperationWithRequest:request
         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject)
         {
             NSDictionary *rootDict = [responseObject objectForKey:@"data"];
             
             self.filters = [[NSDictionary alloc] init];
             self.filters = rootDict;
             
             //NSLog(@"FILTERS: %@",self.filters);
             
             NSLog(@"%@",self.filters);
             
             self.selectedPaths = [NSMutableArray new];
             self.filterNameText = nil;
             self.selectedPathForSection1 = nil;
             self.selectedPathForSection2 = nil;
             self.selectedPathForSection3 = nil;
             self.selectedPathForSection4 = nil;
             
             NSRange range = NSMakeRange(0,6);
             NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
             [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
             
             if ([SVProgressHUD isVisible]) {
                 [SVProgressHUD dismiss];
             }
             else {
                 [self.refreshControl endRefreshing];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 6;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.filters.count != 0) {
        if (section == 0) {
            return nil;
        }
        else if (section == 1) {
            return @"Hide Generated:";
        }
        else if (section == 2) {
            return @"Filter By:";
        }
        else if (section == 3) {
            return @"Sort By:";
        }
        else if (section == 4) {
            return @"App Type:";
        }
        else {
            return @"Language:";
        }
    }
    else return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (self.filters.count == 0) {
        return 0;
    }
    else {
        if (section == 0) {
            return 1;
        }
        else if (section == 1) {
            return [self.yesNo count];
        }
        else if (section == 2) {
            return [[self.filters objectForKey:@"pebble_tags"] count];
        }
        else if (section == 3) {
            return [[self.filters objectForKey:@"sortBy"] count];
        }
        else if (section == 4) {
            return [[self.filters objectForKey:@"pebble_appType"] count];
        }
        else {
            return [[self.filters objectForKey:@"pebble_language"] count];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (indexPath.section == 0) {
        cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.271 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        filterNameField = [[DGTextField alloc] initWithFrame:CGRectMake(20, 12, cell.bounds.size.width-40, 21)];
        filterNameField.textColor = [UIColor whiteColor];
        filterNameField.autocorrectionType = UITextAutocorrectionTypeNo;
        filterNameField.font = [UIFont boldSystemFontOfSize:17.0];
        
        if (self.filterNameText.length == 0) {
            filterNameField.placeholder = @"My Custom Filter";
        }
        else {
            filterNameField.text = self.filterNameText;
        }
        
        filterNameField.adjustsFontSizeToFitWidth = YES;
        filterNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
        filterNameField.cursorColor = [UIColor whiteColor];
        filterNameField.returnKeyType = UIReturnKeyDone;
        filterNameField.delegate = self;
        
        [cell addSubview:filterNameField];
    }
    else if (indexPath.section == 1) {
        cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.271 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.text = [self.yesNo objectAtIndex:indexPath.row];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.cornerRadius = 5.0f;
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        UIImageView *checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark-white"]];
        cell.accessoryView = checkmark;
        
        
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        
        if ([self.selectedPathForSection1 isEqual:indexPath]) {
            cell.accessoryView.hidden = NO;
        } else {
            cell.accessoryView.hidden = YES;
        }
    }
    else if (indexPath.section == 2) {
        cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.271 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.text = [[self.filters objectForKey:@"pebble_tags"] objectAtIndex:indexPath.row];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.cornerRadius = 5.0f;
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        UIImageView *checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark-white"]];
        cell.accessoryView = checkmark;
       
        
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        
        if ([self.selectedPathForSection2 isEqual:indexPath] || [self.selectedPathForSection3 isEqual:indexPath] || [self.selectedPathForSection4 isEqual:indexPath] || [self.selectedPaths containsObject:indexPath]) {
            cell.accessoryView.hidden = NO;
        } else {
            cell.accessoryView.hidden = YES;
        }
    }
    else if (indexPath.section == 3) {
        cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.271 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.text = [[[self.filters objectForKey:@"sortBy"] allKeys] objectAtIndex:indexPath.row];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.cornerRadius = 5.0f;
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        UIImageView *checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark-white"]];
        cell.accessoryView = checkmark;
       
        
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        
        if ([self.selectedPathForSection2 isEqual:indexPath] || [self.selectedPathForSection3 isEqual:indexPath] || [self.selectedPathForSection4 isEqual:indexPath] || [self.selectedPaths containsObject:indexPath]) {
            cell.accessoryView.hidden = NO;
        } else {
            cell.accessoryView.hidden = YES;
        }
    }
    else if (indexPath.section == 4) {
        cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.271 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.text = [[self.filters objectForKey:@"pebble_appType"] objectAtIndex:indexPath.row];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.cornerRadius = 5.0f;
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        UIImageView *checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark-white"]];
        cell.accessoryView = checkmark;
        
        
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        
        if ([self.selectedPathForSection2 isEqual:indexPath] || [self.selectedPathForSection3 isEqual:indexPath] || [self.selectedPathForSection4 isEqual:indexPath] || [self.selectedPaths containsObject:indexPath]) {
            cell.accessoryView.hidden = NO;
        } else {
            cell.accessoryView.hidden = YES;
        }
    }
    else {
        cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.271 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.text = [[self.filters objectForKey:@"pebble_language"] objectAtIndex:indexPath.row];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.cornerRadius = 5.0f;
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        UIImageView *checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark-white"]];
        cell.accessoryView = checkmark;
      
        
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        
        if ([self.selectedPathForSection2 isEqual:indexPath] || [self.selectedPathForSection3 isEqual:indexPath] || [self.selectedPathForSection4 isEqual:indexPath] || [self.selectedPaths containsObject:indexPath]) {
            cell.accessoryView.hidden = NO;
        } else {
            cell.accessoryView.hidden = YES;
        }
    }

    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 1:
            if (![self.selectedPathForSection1 isEqual:indexPath]) {
                self.selectedPathForSection1 = indexPath;
            }else{
                self.selectedPathForSection1 = nil;
            }
        break;
        case 2:
            if (! [self.selectedPaths containsObject:indexPath]) {
                [self.selectedPaths addObject:indexPath];
            }else{
                [self.selectedPaths removeObject:indexPath];
            }
            break;
        case 3:
            if (![self.selectedPathForSection2 isEqual:indexPath]) {
                self.selectedPathForSection2 = indexPath;
            }else{
                self.selectedPathForSection2 = nil;
            }
            break;
        case 4:
            if (![self.selectedPathForSection3 isEqual:indexPath]) {
                self.selectedPathForSection3 = indexPath;
            }else{
                self.selectedPathForSection3 = nil;
            }
            break;
        case 5:
            if (![self.selectedPathForSection4 isEqual:indexPath]) {
                self.selectedPathForSection4 = indexPath;
            }else{
                self.selectedPathForSection4 = nil;
            }
            break;
    }
    [tableView reloadData];
}

@end
