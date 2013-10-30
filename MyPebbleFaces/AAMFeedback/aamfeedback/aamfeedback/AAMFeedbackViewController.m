//
//  AAMFeedbackViewController.m
//  AAMFeedbackViewController
//
//  Created by 深津 貴之 on 11/11/30.
//  Copyright (c) 2011年 Art & Mobile. All rights reserved.
//

#import "AAMFeedbackViewController.h"
#import "AAMFeedbackTopicsViewController.h"
#import "UIDeviceHardware.h"

@interface AAMFeedbackViewController ()

- (NSString *)_platformString;

- (NSString *)_feedbackSubject;

- (NSString *)_feedbackBody;

- (NSString *)_appName;

- (NSString *)_appVersion;

- (NSString *)_selectedTopic;

- (NSString *)_selectedTopicToSend;

- (void)_updatePlaceholder;
@end


@implementation AAMFeedbackViewController

+ (BOOL)isAvailable {
    return [MFMailComposeViewController canSendMail];
}

- (id)initWithStyle:(UITableViewStyle) style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self == nil) {
        return nil;
    }
    return self;
}

- (id)initWithTopics:(NSArray *) theIssues {
    self = [self init];
    if (self) {
        self.topics = theIssues;
        self.topicsToSend = theIssues;
    }
    return self;
}



#pragma mark - View lifecycle

- (void)loadView {
    [super loadView];

    self.title = NSLocalizedStringFromTable(@"AAMFeedbackTitle", @"AAMLocalizable", nil);
    BOOL isModal = (self.presentingViewController != nil);
    if (isModal) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelDidPress:)];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"AAMFeedbackButtonMail", @"AAMLocalizable", nil) style:UIBarButtonItemStyleDone target:self action:@selector(nextDidPress:)];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.separatorColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    self.tableView.backgroundView = nil;
    
    if (self.topics == nil) {
        self.topics = @[
                        NSLocalizedStringFromTable(@"AAMFeedbackTopicsQuestion", @"AAMLocalizable", nil),
                        NSLocalizedStringFromTable(@"AAMFeedbackTopicsRequest", @"AAMLocalizable", nil),
                        NSLocalizedStringFromTable(@"AAMFeedbackTopicsBugReport", @"AAMLocalizable", nil),
                        NSLocalizedStringFromTable(@"AAMFeedbackTopicsMedia", @"AAMLocalizable", nil),
                        NSLocalizedStringFromTable(@"AAMFeedbackTopicsBusiness", @"AAMLocalizable", nil),
                        NSLocalizedStringFromTable(@"AAMFeedbackTopicsOther", @"AAMLocalizable", nil)
                        ];
    }

    self.topicsToSend = [self.topics copy];
    [self updateBackGroundImage];
}

- (void)setBackgroundImage:(UIImage *) backgroundImage {
    _backgroundImage = backgroundImage;
    if ([self isViewLoaded]) {
        [self updateBackGroundImage];
    }
}

- (void)updateBackGroundImage {
    if (self.backgroundImage != nil) {
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:self.backgroundImage];
        self.tableView.backgroundView = backgroundImageView;
    }
}


- (void)viewDidUnload {
    [super viewDidUnload];
    _descriptionPlaceHolder = nil;
    _descriptionTextView = nil;
}

- (void)viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    [self _updatePlaceholder];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL) animated {
    [super viewDidAppear:animated];
    if (_isFeedbackSent) {
        [[self navigationController] popToRootViewControllerAnimated:YES];
    }
}

- (void)viewWillDisappear:(BOOL) animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL) animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *) tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section {
    if (section == 0) {
        return 2;
    }
    return 4;
}

- (float)tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *) indexPath {
    if (indexPath.section == 0 && indexPath.row == 1) {
        return MAX(150, _descriptionTextView.contentSize.height + 10);
    }
    
    return 44;
}

- (NSString *)tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section {
    switch (section) {
        case 0:
            return NSLocalizedStringFromTable(@"AAMFeedbackTableHeaderTopics", @"AAMLocalizable", nil);
        case 1:
            return NSLocalizedStringFromTable(@"AAMFeedbackTableHeaderBasicInfo", @"AAMLocalizable", nil);
        default:
            break;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if (indexPath.section == 1) {
            //General Infos
            cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.textColor = [UIColor whiteColor];
            cell.cornerRadius = 5;
        } else {
            if (indexPath.row == 0) {
                //Topics
                cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.detailTextLabel.textColor = [UIColor whiteColor];
            } else {
                //Topics Description
                cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

                cell.textLabel.textColor = [UIColor whiteColor];
                cell.detailTextLabel.textColor = [UIColor whiteColor];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                _descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, 300,
                    150)];
                _descriptionTextView.textColor = [UIColor whiteColor];
                _descriptionTextView.backgroundColor = [UIColor clearColor];
                _descriptionTextView.font = [UIFont systemFontOfSize:16];
                _descriptionTextView.delegate = self;
                _descriptionTextView.scrollEnabled = NO;
                _descriptionTextView.text = self.descriptionText;
                [cell.contentView addSubview:_descriptionTextView];

                _descriptionPlaceHolder = [[UITextField alloc] initWithFrame:CGRectMake(16, 8, 300,
                    20)];
                _descriptionPlaceHolder.textColor = [UIColor whiteColor];
                _descriptionPlaceHolder.font = [UIFont systemFontOfSize:16];
                _descriptionPlaceHolder.placeholder = NSLocalizedStringFromTable(@"AAMFeedbackDescriptionPlaceholder", @"AAMLocalizable", nil);
                _descriptionPlaceHolder.userInteractionEnabled = NO;
                [cell.contentView addSubview:_descriptionPlaceHolder];

                [self _updatePlaceholder];
            }
        }
    }

    // Configure the cell...
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:

                    cell.textLabel.text = NSLocalizedStringFromTable(@"AAMFeedbackTopicsTitle", @"AAMLocalizable", nil);
                    cell.detailTextLabel.text = NSLocalizedStringFromTable([self _selectedTopic], @"AAMLocalizable", nil);
                    break;
                case 1:
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Your Device";
                    cell.detailTextLabel.text = [self _platformString];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 1:
                    cell.textLabel.text = @"iOS Version";
                    cell.detailTextLabel.text = [UIDevice currentDevice].systemVersion;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 2:
                    cell.textLabel.text = @"Application Name";
                    cell.detailTextLabel.text = [self _appName];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 3:
                    cell.textLabel.text = @"Application Version";
                    cell.detailTextLabel.text = [self _appVersion];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }

    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        [_descriptionTextView resignFirstResponder];
        AAMFeedbackTopicsViewController *topicsViewController = [[AAMFeedbackTopicsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        if (self.backgroundImage != nil) {
            UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:self.backgroundImage];
            topicsViewController.tableView.backgroundView = backgroundImageView;
        }
        topicsViewController.topics = [self.topics copy];
        topicsViewController.delegate = self;
        topicsViewController.selectedIndex = _selectedTopicsIndex;
        [self.navigationController pushViewController:topicsViewController animated:YES];
    }
    else if (indexPath.section == 0 && indexPath.row == 2) {
        [self _updatePlaceholder];
        [_descriptionTextView becomeFirstResponder];
    }
}


- (void)cancelDidPress:(id) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)nextDidPress:(id) sender {
    [_descriptionTextView resignFirstResponder];

    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    picker.navigationController.navigationBar.tintColor = [UIColor colorWithRed:1.000 green:0.231 blue:0.188 alpha:1.00];
    [picker setToRecipients:self.toRecipients];
    [picker setCcRecipients:self.ccRecipients];
    [picker setBccRecipients:self.bccRecipients];

    [picker setSubject:[self _feedbackSubject]];
    [picker setMessageBody:[self _feedbackBody] isHTML:NO];
    [self presentViewController:picker animated:YES completion:nil];
}

//- (CGSize)textViewSize:(UITextView*)textView {
//    float fudgeFactor = 16.0;
//    CGSize tallerSize = CGSizeMake(_descriptionTextView.frame.size.width-fudgeFactor, );
//    NSString *testString = @" ";
//    if ([textView.text length] > 0) {
//        testString = textView.text;
//    }
//    CGSize stringSize = [testString @{NSFontAttributeName:[UIFont systemFontOfSize:17.0f],NSLineBreakMode:NSLineBreakByWordWrapping]};;;];
//    return stringSize;
//}
//
//// based on the proper text view size, sets the UITextView's frame
//- (void) setTextViewSize:(UITextView*)textView {
//    CGSize stringSize = [self textViewSize:textView];
//    if (stringSize.height != textView.frame.size.height) {
//        [textView setFrame:CGRectMake(textView.frame.origin.x,
//                                      textView.frame.origin.y,
//                                      textView.frame.size.width,
//                                      stringSize.height+10)];  // +10 to allow for the space above the text itself
//    }
//}
//
//// as per: http://stackoverflow.com/questions/3749746/uitextview-in-a-uitableviewcell-smooth-auto-resize
- (void)textViewDidChange:(UITextView *)textView {
    
    [self _updatePlaceholder];
    self.descriptionText = _descriptionTextView.text;

    //Magic for updating Cell height
//    [self.tableView beginUpdates];
//    [self.tableView endUpdates];
}


- (void)mailComposeController:(MFMailComposeViewController *) controller
          didFinishWithResult:(MFMailComposeResult) result error:(NSError *) error {
    if (result == MFMailComposeResultCancelled) {
    } else if (result == MFMailComposeResultSent) {
        _isFeedbackSent = YES;
    } else if (result == MFMailComposeResultFailed) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"AAMFeedbackMailDidFinishWithError"
                                                                    delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}


- (void)feedbackTopicsViewController:(AAMFeedbackTopicsViewController *) feedbackTopicsViewController
               didSelectTopicAtIndex:(NSInteger) selectedIndex {
    _selectedTopicsIndex = selectedIndex;
}

#pragma mark - Internal Info

- (void)_updatePlaceholder {
    if ([_descriptionTextView.text length] > 0) {
        _descriptionPlaceHolder.hidden = YES;
    } else {
        _descriptionPlaceHolder.hidden = NO;
    }
}

- (NSString *)_feedbackSubject {
    return [NSString stringWithFormat:@"%@: %@", [self _appName], [self _selectedTopicToSend]];
}

- (NSString *)_feedbackBody {
    NSString *body = [NSString stringWithFormat:@"%@\n\n---------------------------------------\nYour Device:  %@\niOS Version:  %@\nApplication Name:  %@\nApplication Version:%@",
                                                _descriptionTextView.text,
                                                [self _platformString],
                                                [UIDevice currentDevice].systemVersion,
                                                [self _appName],
                                                [self _appVersion]];

    return body;
}


- (NSString *)_selectedTopic {
    return (self.topics)[(NSUInteger)_selectedTopicsIndex];
}

- (NSString *)_selectedTopicToSend {
    return (self.topicsToSend)[(NSUInteger)_selectedTopicsIndex];
}

- (NSString *)_appName {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
}

- (NSString *)_appVersion {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
}


- (NSString *)_platformString {
    return [UIDeviceHardware platformString];
}

@end
