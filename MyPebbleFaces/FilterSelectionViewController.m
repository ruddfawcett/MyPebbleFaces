//
//  FilterSelectionViewController.m
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 9/5/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "FilterSelectionViewController.h"

@interface FilterSelectionViewController ()

@end

@implementation FilterSelectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Filter and Search";
    
    self.singleton = [UserClass sharedSingleton];
    
    self.yesNo = [[NSArray alloc] initWithObjects:@"Yes", @"No", nil];
    
    self.tableView.separatorColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    self.tableView.backgroundView = nil;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor darkGrayColor];
    [self.refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];

    self.tableView.allowsMultipleSelection = YES;
    self.tableView.autoresizesSubviews = YES;    
    self.selectedPaths = [NSMutableArray new];
    self.selectedPathForSection1 = nil;
    self.selectedPathForSection2 = nil;
    self.selectedPathForSection3 = nil;
    self.selectedPathForSection4 = nil;
    self.selectedPathSpecial = nil;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissController:)];
    UIBarButtonItem *loadButton = [[UIBarButtonItem alloc] initWithTitle:@"Load" style:UIBarButtonItemStylePlain target:self action:@selector(loadButtonAction:)];
    
    self.navigationItem.rightBarButtonItem = loadButton;
    self.navigationItem.leftBarButtonItem = cancelButton;
    
   
    
    NSString *filterPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Filters.plist"];
    
    self.filterList = [[NSMutableArray alloc] init];
    self.filterList = [NSMutableArray arrayWithContentsOfFile:filterPath];
}

- (void)viewDidAppear:(BOOL)animated {

    if (self.singleton.filters == nil) {
        [SVProgressHUD showWithStatus:@"Fetching Filters..."];
        [self getFilters];
        
        self.singleton.selectedPaths = [NSMutableArray new];
        self.singleton.selectedPathForSection1 = nil;
        self.singleton.selectedPathForSection2 = nil;
        self.singleton.selectedPathForSection3 = nil;
        self.singleton.selectedPathForSection4 = nil;
        self.singleton.selectedPathSpecial = nil;
    }
    else {
        self.selectedPaths = self.singleton.selectedPaths;
        self.selectedPathForSection1 = self.singleton.selectedPathForSection1;
        self.selectedPathForSection2 = self.singleton.selectedPathForSection2;
        self.selectedPathForSection3 = self.singleton.selectedPathForSection3;
        self.selectedPathForSection4 = self.singleton.selectedPathForSection4;
        self.selectedPathSpecial = self.singleton.selectedPathSpecial;
        self.searchFieldText = self.singleton.searchFieldText;
        
        [self.tableView reloadData];
    }
}

- (IBAction)dismissController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)loadButtonAction:(id)sender {
    [self loadFilterQuery:nil];
}

- (void)buildQuery:(NSDictionary *)pebbleAppFilter {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //NSLog(@"%@",pebbleAppFilter);
    
    int initNum;
    
    if (![defaults objectForKey:@"initNumber"]) {
        [defaults setObject:[NSString stringWithFormat:@"40"] forKey:@"initNumber"];
        initNum = 40;
    }
    else {
        initNum = [[defaults objectForKey:@"initNumber"] intValue];
    }
    
    int pageNum;
    
    if (![defaults objectForKey:@"pageNumber"]) {
        pageNum = 20;
    }
    else {
        pageNum = [[defaults objectForKey:@"pageNumber"] intValue];
    }
    
    NSMutableString *baseURL = [NSMutableString stringWithFormat:@"http://mypebblefaces.com/pebbleInterface?action=getApps&limit=%d",initNum];
    NSMutableString *pagingURL = [NSMutableString stringWithFormat:@"http://mypebblefaces.com/pebbleInterface?action=getApps&limit=%d",pageNum];
    
    if ([pebbleAppFilter objectForKey:@"pebble_language"] != nil) {
        [baseURL appendString:[NSString stringWithFormat:@"&pebble_language=%@",[pebbleAppFilter objectForKey:@"pebble_language"]]];
        [pagingURL appendString:[NSString stringWithFormat:@"&pebble_language=%@",[pebbleAppFilter objectForKey:@"pebble_language"]]];
    }
    
    NSLog(@"%@",baseURL);
    
    if ([pebbleAppFilter objectForKey:@"pebble_appType"] != nil) {
        [baseURL appendString:[NSString stringWithFormat:@"&pebble_appType=%@",[pebbleAppFilter objectForKey:@"pebble_appType"]]];
        [pagingURL appendString:[NSString stringWithFormat:@"&pebble_appType=%@",[pebbleAppFilter objectForKey:@"pebble_appType"]]];
    }
    
    NSLog(@"%@",baseURL);
    
    if ([pebbleAppFilter objectForKey:@"sortByValue"] != nil) {
        [baseURL appendString:[NSString stringWithFormat:@"&sortBy=%@",[pebbleAppFilter objectForKey:@"sortByValue"]]];
        [pagingURL appendString:[NSString stringWithFormat:@"&sortBy=%@",[pebbleAppFilter objectForKey:@"sortByValue"]]];
    }
    
    NSLog(@"%@",baseURL);
    
    if ([pebbleAppFilter objectForKey:@"pebble_generated"] != nil) {
        [baseURL appendString:[NSString stringWithFormat:@"&pebble_generated=0"]];
        [pagingURL appendString:[NSString stringWithFormat:@"&pebble_generated=0"]];
    }
    
    NSLog(@"%@",baseURL);
    
    if ([pebbleAppFilter objectForKey:@"pebble_tags"] != nil) {
        
        [baseURL appendString:@"&pebble_tags="];
        [pagingURL appendString:@"&pebble_tags="];
        
        for (NSString *eachTag in [pebbleAppFilter objectForKey:@"pebble_tags"]) {
            if ([eachTag isEqualToString:[[pebbleAppFilter objectForKey:@"pebble_tags"] objectAtIndex:0]]) {
                [baseURL appendString:eachTag];
                [pagingURL appendString:eachTag];
            }
            else {
                [baseURL appendString:[NSString stringWithFormat:@"+%@",eachTag]];
                [pagingURL appendString:[NSString stringWithFormat:@"+%@",eachTag]];
            }
        }
    }
    
    NSLog(@"%@",baseURL);
    
    if ([pebbleAppFilter objectForKey:@"searchQuery"] != nil) {
        [baseURL appendString:[NSString stringWithFormat:@"&query=%@",[pebbleAppFilter objectForKey:@"searchQuery"]]];
        [pagingURL appendString:[NSString stringWithFormat:@"&query=%@",[pebbleAppFilter objectForKey:@"searchQuery"]]];
    }
    
    NSLog(@"%@",baseURL);
    
//    [defaults setObject:baseURL forKey:@"queryString"];
//    [defaults setObject:pagingURL forKey:@"pagingQueryString"];
//    [defaults setBool:YES forKey:@"shouldLoadQuery"];

    [self.singleton setShouldLoadQuery:YES];
    [self.singleton setPagingQueryString:pagingURL];
    [self.singleton setQueryString:baseURL];

    self.singleton.selectedPaths = self.selectedPaths;
    self.singleton.selectedPathForSection1 = self.selectedPathForSection1;
    self.singleton.selectedPathForSection2 = self.selectedPathForSection2;
    self.singleton.selectedPathForSection3 = self.selectedPathForSection3;
    self.singleton.selectedPathForSection4 = self.selectedPathForSection4;
    self.singleton.selectedPathSpecial = self.selectedPathSpecial;
    self.singleton.searchFieldText = self.searchFieldText;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == searchField) {
        [searchField resignFirstResponder];
        
        // self.searchField = searchField.text;
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == searchField) {
        self.searchFieldText = [searchField.text stringByReplacingCharactersInRange:range withString:string];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField == searchField) {
        self.searchFieldText = nil;
        self.singleton.searchFieldText = self.searchFieldText;
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

- (NSString *)_sanitizeFileNameString:(NSString *)fileName {
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>^&':"];
    return [[fileName componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
}

- (IBAction)loadFilterQuery:(id)sender {
    if (self.selectedPathSpecial == nil) {
        self.filterParams = [[NSMutableDictionary alloc] init];
        
        if (searchField.text.length != 0) {
            
            NSString *searchTextSanitized = [self _sanitizeFileNameString:searchField.text];
            searchTextSanitized = [searchTextSanitized stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            [self.filterParams setObject:searchTextSanitized forKey:@"searchQuery"];
        }
        
        if ([self.selectedPaths count] !=0) {
            NSMutableArray *filters = [NSMutableArray new];
            
            for (NSIndexPath *indexPath in self.selectedPaths) {
                NSString *tag = [[self.singleton.filters objectForKey:@"pebble_tags"] objectAtIndex:indexPath.row];
                
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
            NSString *text = [[[self.singleton.filters objectForKey:@"sortBy"] allKeys] objectAtIndex:self.selectedPathForSection2.row];
            
            [self.filterParams setObject:[[[self.singleton.filters objectForKey:@"sortBy"] allKeys] objectAtIndex:self.selectedPathForSection2.row] forKey:@"sortBy"];
            [self.filterParams setObject:[[self.singleton.filters objectForKey:@"sortBy"] objectForKey:text] forKey:@"sortByValue"];
        }
        else {
            [self.filterParams setObject:@"Newest" forKey:@"sortBy"];
            [self.filterParams setObject:@"pebble_dateAdded" forKey:@"sortByValue"];
        }
        
        if (self.selectedPathForSection3 != nil) {
            [self.filterParams setObject:[[self.singleton.filters objectForKey:@"pebble_appType"] objectAtIndex:self.selectedPathForSection3.row] forKey:@"pebble_appType"];
        }
        
        if (self.selectedPathForSection4 != nil) {
            [self.filterParams setObject:[[self.singleton.filters objectForKey:@"pebble_language"] objectAtIndex:self.selectedPathForSection4.row] forKey:@"pebble_language"];
        }
    }
    else {
        self.filterParams = [self.filterList objectAtIndex:self.selectedPathSpecial.row];
    }
    
    // NSLog(@"%@",self.filterParams);
    
    [self buildQuery:self.filterParams];
}

#pragma mark - Table view data source

- (void)reloadReset {
    self.selectedPaths = [NSMutableArray new];
    self.searchFieldText = nil;
    self.selectedPathForSection1 = nil;
    self.selectedPathForSection2 = nil;
    self.selectedPathForSection3 = nil;
    self.selectedPathForSection4 = nil;
    self.selectedPathSpecial = nil;
    
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
         
         self.singleton.filters = [[NSDictionary alloc] init];
         self.singleton.filters = rootDict;
         // NSLog(@"FILTERS: %@",self.singleton.filters);
         
         // NSLog(@"%@",self.singleton.filters);
         
         self.selectedPaths = [NSMutableArray new];
         self.searchFieldText = nil;
         self.selectedPathForSection1 = nil;
         self.selectedPathForSection2 = nil;
         self.selectedPathForSection3 = nil;
         self.selectedPathForSection4 = nil;
         self.selectedPathSpecial = nil;
         
         
         if (self.filterList.count == 0) {
             NSRange range = NSMakeRange(0, 6);
             NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
             [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
         }
         else {
             NSRange range = NSMakeRange(0, 7);
             NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
             [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
         }
         
         
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
     }];
    
    [operation start];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    
    if (self.filterList.count == 0) {
        return 6;
    }
    else return 7;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.singleton.filters.count != 0) {
        if (self.filterList.count == 0) {
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
        else {
            if (section == 0) {
                return nil;
            }
            else if (section == 1) {
                return @"Use Custom Filter:";
            }
            else if (section == 2) {
                return @"Hide Generated:";
            }
            else if (section == 3) {
                return @"Filter By:";
            }
            else if (section == 4) {
                return @"Sort By:";
            }
            else if (section == 5) {
                return @"App Type:";
            }
            else {
                return @"Language:";
            }
        }
    }
    else return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (self.singleton.filters.count == 0) {
        return 0;
    }
    else {
        if (self.filterList.count == 0) {
            if (section == 0) {
                return 1;
            }
            else if (section == 1) {
                return [self.yesNo count];
            }
            else if (section == 2) {
                return [[self.singleton.filters objectForKey:@"pebble_tags"] count];
            }
            else if (section == 3) {
                return [[self.singleton.filters objectForKey:@"sortBy"] count];
            }
            else if (section == 4) {
                return [[self.singleton.filters objectForKey:@"pebble_appType"] count];
            }
            else {
                return [[self.singleton.filters objectForKey:@"pebble_language"] count];
            }
            
        }
        else {
            if (section == 0) {
                return 1;
            }
            else if (section == 1) {
                return [self.filterList count];
            }
            else if (section == 2) {
                return [self.yesNo count];
            }
            else if (section == 3) {
                return [[self.singleton.filters objectForKey:@"pebble_tags"] count];
            }
            else if (section == 4) {
                return [[self.singleton.filters objectForKey:@"sortBy"] count];
            }
            else if (section == 5) {
                return [[self.singleton.filters objectForKey:@"pebble_appType"] count];
            }
            else {
                return [[self.singleton.filters objectForKey:@"pebble_language"] count];
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (self.filterList.count == 0) {
        if (indexPath.section == 0) {
            cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.271 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            searchField = [[DGTextField alloc] initWithFrame:CGRectMake(20, 12, cell.bounds.size.width-40, 21)];
            searchField.textColor = [UIColor whiteColor];
            searchField.autocorrectionType = UITextAutocorrectionTypeNo;
            searchField.font = [UIFont boldSystemFontOfSize:17.0];
            
            if (self.searchFieldText.length == 0) {
                searchField.placeholder = @"Search Query";
            }
            else {
                searchField.text = self.searchFieldText;
            }
            
            searchField.adjustsFontSizeToFitWidth = YES;
            searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
            searchField.cursorColor = [UIColor whiteColor];
            searchField.returnKeyType = UIReturnKeyDone;
            searchField.delegate = self;
            
            [cell addSubview:searchField];
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
            cell.textLabel.text = [[self.singleton.filters objectForKey:@"pebble_tags"] objectAtIndex:indexPath.row];
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
            cell.textLabel.text = [[[self.singleton.filters objectForKey:@"sortBy"] allKeys] objectAtIndex:indexPath.row];
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
            cell.textLabel.text = [[self.singleton.filters objectForKey:@"pebble_appType"] objectAtIndex:indexPath.row];
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
            cell.textLabel.text = [[self.singleton.filters objectForKey:@"pebble_language"] objectAtIndex:indexPath.row];
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
    }
    else {
        if (indexPath.section == 0) {
            cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.271 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
            searchField = [[DGTextField alloc] initWithFrame:CGRectMake(20, 12, cell.bounds.size.width-40, 21)];
            searchField.textColor = [UIColor whiteColor];
            searchField.autocorrectionType = UITextAutocorrectionTypeNo;
            searchField.font = [UIFont boldSystemFontOfSize:17.0];
            
            if (self.searchFieldText.length == 0) {
                searchField.placeholder = @"Search Query";
            }
            else {
                searchField.text = self.searchFieldText;
            }
            
            searchField.adjustsFontSizeToFitWidth = YES;
            searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
            searchField.cursorColor = [UIColor whiteColor];
            searchField.returnKeyType = UIReturnKeyDone;
            searchField.delegate = self;
            
            [cell addSubview:searchField];
        }
        else if (indexPath.section == 1) {
            cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.271 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.text = [[self.filterList objectAtIndex:indexPath.row] objectForKey:@"filter_name"];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.cornerRadius = 5.0f;
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            UIImageView *checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark-white"]];
            cell.accessoryView = checkmark;
         
            
            cell.textLabel.highlightedTextColor = [UIColor whiteColor];
            
            if ([self.selectedPathForSection2 isEqual:indexPath] || [self.selectedPathForSection3 isEqual:indexPath] || [self.selectedPathForSection4 isEqual:indexPath] || [self.selectedPaths containsObject:indexPath] || [self.selectedPathSpecial isEqual:indexPath]) {
                cell.accessoryView.hidden = NO;
            } else {
                cell.accessoryView.hidden = YES;
            }
        }
        else if (indexPath.section == 2) {
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
        else if (indexPath.section == 3) {
            cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.271 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.text = [[self.singleton.filters objectForKey:@"pebble_tags"] objectAtIndex:indexPath.row];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.cornerRadius = 5.0f;
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            UIImageView *checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark-white"]];
            cell.accessoryView = checkmark;
        
            
            cell.textLabel.highlightedTextColor = [UIColor whiteColor];
            
            if ([self.selectedPathForSection2 isEqual:indexPath] || [self.selectedPathForSection3 isEqual:indexPath] || [self.selectedPathForSection4 isEqual:indexPath] || [self.selectedPaths containsObject:indexPath] || [self.selectedPathSpecial isEqual:indexPath]) {
                cell.accessoryView.hidden = NO;
            } else {
                cell.accessoryView.hidden = YES;
            }
        }
        else if (indexPath.section == 4) {
            cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.271 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.text = [[[self.singleton.filters objectForKey:@"sortBy"] allKeys] objectAtIndex:indexPath.row];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.cornerRadius = 5.0f;
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            UIImageView *checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark-white"]];
            cell.accessoryView = checkmark;
           
            
            cell.textLabel.highlightedTextColor = [UIColor whiteColor];
            
            if ([self.selectedPathForSection2 isEqual:indexPath] || [self.selectedPathForSection3 isEqual:indexPath] || [self.selectedPathForSection4 isEqual:indexPath] || [self.selectedPaths containsObject:indexPath] || [self.selectedPathSpecial isEqual:indexPath]) {
                cell.accessoryView.hidden = NO;
            } else {
                cell.accessoryView.hidden = YES;
            }
        }
        else if (indexPath.section == 5) {
            cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.271 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.text = [[self.singleton.filters objectForKey:@"pebble_appType"] objectAtIndex:indexPath.row];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.cornerRadius = 5.0f;
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            UIImageView *checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark-white"]];
            cell.accessoryView = checkmark;
           
            
            cell.textLabel.highlightedTextColor = [UIColor whiteColor];
            
            if ([self.selectedPathForSection2 isEqual:indexPath] || [self.selectedPathForSection3 isEqual:indexPath] || [self.selectedPathForSection4 isEqual:indexPath] || [self.selectedPaths containsObject:indexPath] || [self.selectedPathSpecial isEqual:indexPath]) {
                cell.accessoryView.hidden = NO;
            } else {
                cell.accessoryView.hidden = YES;
            }
        }
        else {
            cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.271 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.text = [[self.singleton.filters objectForKey:@"pebble_language"] objectAtIndex:indexPath.row];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.cornerRadius = 5.0f;
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            UIImageView *checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark-white"]];
            cell.accessoryView = checkmark;
      
            
            cell.textLabel.highlightedTextColor = [UIColor whiteColor];
            
            if ([self.selectedPathForSection2 isEqual:indexPath] || [self.selectedPathForSection3 isEqual:indexPath] || [self.selectedPathForSection4 isEqual:indexPath] || [self.selectedPaths containsObject:indexPath] || [self.selectedPathSpecial isEqual:indexPath]) {
                cell.accessoryView.hidden = NO;
            } else {
                cell.accessoryView.hidden = YES;
            }
        }
        
    }
    
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.filterList.count == 0) {
        switch (indexPath.section) {
            case 1:
                if (![self.selectedPathForSection1 isEqual:indexPath]) {
                    self.selectedPathForSection1 = indexPath;
                    self.selectedPathSpecial = nil;
                }else{
                    self.selectedPathForSection1 = nil;
                    self.selectedPathSpecial = nil;
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
    }
    else {
        switch (indexPath.section) {
            case 1:
                if (![self.selectedPathSpecial isEqual:indexPath]) {
                    self.selectedPathSpecial = indexPath;
                    
                    self.selectedPaths = [NSMutableArray new];
                    self.selectedPathForSection1 = nil;
                    self.selectedPathForSection2 = nil;
                    self.selectedPathForSection3 = nil;
                    self.selectedPathForSection4 = nil;
                }else{
                    self.selectedPathSpecial = nil;
                }
                break;
            case 2:
                if (![self.selectedPathForSection1 isEqual:indexPath]) {
                    self.selectedPathForSection1 = indexPath;
                    self.selectedPathSpecial = nil;
                }else{
                    self.selectedPathForSection1 = nil;
                    self.selectedPathSpecial = nil;
                }
                break;
            case 3:
                if (! [self.selectedPaths containsObject:indexPath]) {
                    [self.selectedPaths addObject:indexPath];
                    self.selectedPathSpecial = nil;
                }else{
                    [self.selectedPaths removeObject:indexPath];
                    self.selectedPathSpecial = nil;
                }
                break;
            case 4:
                if (![self.selectedPathForSection2 isEqual:indexPath]) {
                    self.selectedPathForSection2 = indexPath;
                    self.selectedPathSpecial = nil;
                }else{
                    self.selectedPathForSection2 = nil;
                    self.selectedPathSpecial = nil;
                }
                break;
            case 5:
                if (![self.selectedPathForSection3 isEqual:indexPath]) {
                    self.selectedPathForSection3 = indexPath;
                    self.selectedPathSpecial = nil;
                }else{
                    self.selectedPathForSection3 = nil;
                    self.selectedPathSpecial = nil;
                }
                break;
            case 6:
                if (![self.selectedPathForSection4 isEqual:indexPath]) {
                    self.selectedPathForSection4 = indexPath;
                    self.selectedPathSpecial = nil;
                }else{
                    self.selectedPathForSection4 = nil;
                    self.selectedPathSpecial = nil;
                }
                break;
        }
    }
    
    [tableView reloadData];
}


@end
