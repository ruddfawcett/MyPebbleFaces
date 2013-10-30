//
//  AAMFeedbackTopicsViewController.m
//  AAMFeedbackViewController
//
//  Created by 深津 貴之 on 11/11/30.
//  Copyright (c) 2011年 Art & Mobile. All rights reserved.
//

#import "AAMFeedbackTopicsViewController.h"


@interface AAMFeedbackTopicsViewController ()

- (void)_updateCellSelection;

@end


@implementation AAMFeedbackTopicsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedStringFromTable(@"AAMFeedbackTopicsTitle", @"AAMLocalizable", nil);
    
    self.tableView.separatorColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    self.tableView.backgroundView = nil;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    [self _updateCellSelection];
}

- (void)viewDidAppear:(BOOL) animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL) animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL) animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section {
    return [self.topics count];
}

- (UITableViewCell *)tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];;
    }
    NSUInteger row = (NSUInteger)indexPath.row;
    cell.textLabel.textColor = [UIColor whiteColor];
    
    cell.textLabel.text = NSLocalizedString((self.topics)[row], nil);

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath {
    NSInteger row = indexPath.row;
    self.selectedIndex = row;
    [self _updateCellSelection];

    if ([self.delegate respondsToSelector:@selector(feedbackTopicsViewController:didSelectTopicAtIndex:)]) {
        [self.delegate feedbackTopicsViewController:self didSelectTopicAtIndex:row];
    }
    
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - Internal
- (void)_updateCellSelection {
    NSArray *cells = [self.tableView visibleCells];
    int n = [cells count];
    for (int i = 0; i < n; i++) {
        UITableViewCell *cell = cells[(NSUInteger)i];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    NSIndexPath *path = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];

    UITableViewCell *cell;
    cell = [self.tableView cellForRowAtIndexPath:path];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    UIImageView *checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark-white"]];
    cell.accessoryView = checkmark;
    [cell setSelected:NO animated:YES];
}

@end
