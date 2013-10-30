//
//  InitialNumberViewController.m
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 9/3/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "InitialNumberViewController.h"

@interface InitialNumberViewController ()

@end

@implementation InitialNumberViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Initial Number of Apps";
    
    self.tableView.separatorColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    self.tableView.backgroundView = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults objectForKey:@"initNumber"] ) {
        
    }
    else {
        int num = [[defaults objectForKey:@"initNumber"] intValue];
        NSLog(@"%d",num);
        int row = num/4;
        
        NSLog(@"%d",row);
        row = row - 1;
        
        NSLog(@"%d",row);
        
        // [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
        
        self.lastIndexPath = [NSIndexPath indexPathForRow:row inSection:0];
        
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.271 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    int row;
    
    if (indexPath.row == 0) {
        row = 1;
    }
    else {
        row = indexPath.row + 1;
    }

    int textLabel = row * 4;
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d Apps",textLabel];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.cornerRadius = 5.0f;
    
    cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    
    if ([indexPath compare:self.lastIndexPath] == NSOrderedSame)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        UIImageView *checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark-white"]];
        cell.accessoryView = checkmark;
       
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.lastIndexPath = indexPath;
    
    int row;
    
    if (indexPath.row == 0) {
        row = 1;
    }
    else {
        row = indexPath.row + 1;
    }
    
    int textLabel = row * 4;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%d",textLabel] forKey:@"initNumber"];
    
    [self.navigationController popToRootViewControllerAnimated:YES];

}

@end
