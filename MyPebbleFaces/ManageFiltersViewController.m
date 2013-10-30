//
//  ManageFiltersViewController.m
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 9/5/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "ManageFiltersViewController.h"

@interface ManageFiltersViewController ()

@end

@implementation ManageFiltersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *filterPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Filters.plist"];
    
    self.filterList = [[NSMutableArray alloc] init];
    self.filterList = [NSMutableArray arrayWithContentsOfFile:filterPath];
    
    self.title = @"Manage Filters";
    
    self.tableView.separatorColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    self.tableView.backgroundView = nil;
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.filterList.count == 0) {
        [self.navigationController popToRootViewControllerAnimated:YES];
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
    return [self.filterList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    cell.textLabel.text = [[self.filterList objectAtIndex:indexPath.row] objectForKey:@"filter_name"];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.cornerRadius = 5.0f;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    UIImageView *deleteButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TrashGlyph"]];
//    cell.editingAccessoryView = deleteButton;
//    [deleteButton release];
    
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

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSString *filterPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Filters.plist"];
        
        [self.filterList removeObjectAtIndex:indexPath.row];
        [self.filterList writeToFile:filterPath atomically:YES];
        if ([self.filterList writeToFile:filterPath atomically:YES]) {
            NSLog(@"Success!");
            NSMutableArray *finalData = [NSMutableArray arrayWithContentsOfFile:filterPath];
            NSLog(@"Final array:\n\n%@",finalData);
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            if (self.filterList.count == 0) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
        else {
            NSLog(@"Error...");
        }
    }
}

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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
