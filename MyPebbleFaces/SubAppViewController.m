//
//  SubAppViewController.m
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 7/18/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "SubAppViewController.h"

@interface SubAppViewController ()

@end

@implementation SubAppViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    //  self.tableView.backgroundColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    self.tableView.backgroundView = nil;
    
    self.title = [self.appData objectForKey:@"title"];
    
    UIBarButtonItem *rightButton;
    
    if ([[self.appData objectForKey:@"installed"] intValue] == 1) {
        rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(sharePop)];
    }
    else {
        rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showOptions)];
    }
    self.navigationItem.rightBarButtonItem = rightButton;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
}

- (void)showOptions {
    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove from Updates" otherButtonTitles:@"Share", nil];
    
    [actSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self sharePop];
    }
    else if (buttonIndex == 0) {
        [self removeFaceFromUpdates];
    }
}

- (void)removeFaceFromUpdates {
    [SVProgressHUD showWithStatus:@"Removing..."];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://mypebblefaces.com/"]];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                            path:[NSString stringWithFormat:@"http://www.mypebblefaces.com/pebbleInterface?action=removeUpdate&cID=%@&cookie=%@",[self.appData objectForKey:@"cID"],[[UserClass sharedSingleton] cookie]]
                                                      parameters:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Print the response body in text
        NSLog(@"Response: %@", responseObject);
        NSError *error = nil;
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSLog(@"Error serializing %@", error);
        }
        NSDictionary *responseDict = [JSON objectForKey:@"data"];
        
        if ([[responseDict objectForKey:@"success"] isEqualToString:@"true"]) {
            [SVProgressHUD showSuccessWithStatus:@"Removed!"];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObject:self.indexPath forKey:@"indexPath"];
            
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:@"didDeleteFace"
                                              object:nil
                                            userInfo:dict];
            [[self navigationController] popToRootViewControllerAnimated:YES];
        }
        else {
            [SVProgressHUD showErrorWithStatus:@"Failure!"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [[UserClass sharedSingleton] connectionError:error];
    }];
    [operation start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        
        // NSLog(@"%@",[[self.appData objectForKey:@"appData"] objectForKey:@"previewURL"] );
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 320,177)];
        
        UIImageView *backgroundImg  = [[UIImageView alloc]  initWithFrame:CGRectMake(0, 10, 320,177)];
        [backgroundImg setImage:[UIImage imageNamed:@"detail.png"]];
        
        
        UIImageView *pebbleFrame  = [[UIImageView alloc]  initWithFrame:CGRectMake(0, 10, 320,177)];
        [pebbleFrame setImage:[UIImage imageNamed:@"pebble_frame.png"]];
        
        UIImageView *overlay  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 320,177)];
        [overlay setImage:[UIImage imageNamed:@"detail_overlay.png"]];
        overlay.alpha = 0.25;
        
        NSLog(@"%@",self.appData);
        
        UIImageView *faceImg = [[UIImageView alloc] initWithFrame:CGRectMake(99, 21, 123, 143)];
        [faceImg setImageWithURL: [self.appData objectForKey:@"previewURL"]
                placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {}];
        
        faceImg.contentMode = UIViewContentModeScaleAspectFit;
        faceImg.alpha = 0.56;
        
        [headerView addSubview:backgroundImg];
        [headerView addSubview:faceImg];
        [headerView addSubview:pebbleFrame];
        [headerView addSubview:overlay];
        
        return headerView;
    }
    
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 190.0;
    }
    
    return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        return 3;
    }
    else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    else if (section == 1) {
        return @"General Information";;
    }
    else {
        return @"Preview";;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0 && self.isDesc == 0 && [[self.appData objectForKey:@"installed"] intValue] == 1) {
        return @"Updating will delete all old versions.";
    }
    else if (section == 0 && self.isDesc == 0) {
        return @"This will download the latest version.";
    }
    else return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.cornerRadius = 5.0f;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
            if (self.isDesc == 1) {
                cell.textLabel.text = @"Download";
            }
            else {
                if ([[self.appData objectForKey:@"installed"] intValue] == 1) {
                    cell.textLabel.text = [NSString stringWithFormat:@"Update to Version %@",[self.appData objectForKey:@"version"]];
                }
                else {
                    cell.textLabel.text = @"Download This Update";
                }
            }
            
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            
            if (self.isDesc == 1) {
                cell.textLabel.text = @"Description";
            }
            else {
                cell.textLabel.text = @"Release Notes";
            }
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.row == 1) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"Current Version";
            
            
            NSString *version  = [NSString stringWithFormat:@"%@", [self.appData objectForKey:@"version"]];
            
            cell.detailTextLabel.text = version;
            
            
        }
        else if (indexPath.row == 2) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"Downloads";
            
            cell.detailTextLabel.text = [[self.appData  objectForKey:@"dlCount"] stringValue];
            
            
        }
        
    }
    else if (indexPath.section == 2) {
        
        
        cell.textLabel.text = @"Pebble";
        
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //            }
    }
    
    return cell;
}

- (void)sharePop {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Share"
                                                 message:[NSString stringWithFormat:@"Share %@ with Facebook, Twitter or Email.",[self.appData objectForKey:@"title"]]
                                                delegate:nil
                                       cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Facebook",@"Twitter",@"Email",nil];
    
    //    av.titleLabel.textColor = [UIColor cloudsColor];
    //    av.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    //    av.messageLabel.textColor = [UIColor cloudsColor];
    //    av.messageLabel.font = [UIFont flatFontOfSize:14];
    //    av.backgroundOverlay.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
    //    av.alertContainer.backgroundColor = [UIColor colorWithRed:0.745 green:0.196 blue:0.071 alpha:1.00];
    //    av.defaultButtonColor = [UIColor cloudsColor];
    //    av.defaultButtonShadowColor = [UIColor asbestosColor];
    //    av.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    //    av.defaultButtonTitleColor = [UIColor asbestosColor];
    av.delegate = self;
    
    [av show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self shareToFacebook];
    }
    else if (buttonIndex == 2) {
        [self shareToTwitter];
    }
    else if (buttonIndex == 3) {
        [self sendMail];
    }
}

-(void)shareToFacebook {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *facebookSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [facebookSheet setInitialText:[NSString stringWithFormat:@"Check out %@ by %@ on http://mypebblefaces.com! %@",[self.appData objectForKey:@"title"],[self.appData objectForKey:@"author"],[self.appData objectForKey:@"shortURL"]]];
        
        [facebookSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Post Sucessful");
                    break;
                    
                default:
                    break;
            }
        }];
        
        [self presentViewController:facebookSheet animated:YES completion:nil];
    }
    
}

-(void)shareToTwitter {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        SLComposeViewController *twittterSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [twittterSheet setInitialText:[NSString stringWithFormat:@"Check out %@ by %@ on http://mypebblefaces.com! %@",[self.appData objectForKey:@"title"],[self.appData objectForKey:@"author"],[self.appData objectForKey:@"shortURL"]]];
        
        [twittterSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Post Sucessful");
                    break;
                    
                default:
                    break;
            }
        }];
        
        [self presentViewController:twittterSheet animated:YES completion:nil];
    }
    
}

-(void)sendMail {
    
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    mailer.mailComposeDelegate = self;
    
    //    NSString *subject = [[self.eachSheet objectForKey:@"title"] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    //    NSString *authorEmail = [self.eachSheet objectForKey:@"author_email"];
    
    [mailer setSubject:[NSString stringWithFormat:@"%@",[self.appData objectForKey:@"title"]]];
    
    NSString *emailBody = [NSString stringWithFormat:@"Check out %@ by %@ on #MyPebbleFaces! %@",[self.appData  objectForKey:@"title"],[self.appData objectForKey:@"author"],[self.appData objectForKey:@"shortURL"]];
    
    [mailer setMessageBody:emailBody isHTML:NO];
    
    [self presentViewController:mailer animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSString *)downloadPBWTitle:(NSString *)title withVersion:(NSString *)version {
    return [NSString stringWithFormat:@"%@_%@.pbw",title,[NSString stringWithFormat:@"%@", version]];
}

-(NSString *)downloadPBWPreview:(NSString *)title withVersion:(NSString *)version {
    return [NSString stringWithFormat:@"%@_%@.%@",title,[NSString stringWithFormat:@"%@", version],[[self.appData objectForKey:@"previewURL"] pathExtension]];
}

-(void)downloadPBW {
    //NSLog(@"Saving File...");
    [SVProgressHUD showWithStatus:@"Downloading..."];
    
    UserClass *newUser = [UserClass sharedSingleton];
    
    NSMutableString *url = [[NSMutableString alloc] initWithString:[self.appData objectForKey:@"dlURL"]];
    
    if([newUser isLogged])
    {
        
        NSLog(@"User is logged in");
        
        [url appendString:[NSMutableString stringWithFormat:@"&uID=%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"uID"]]];
    }
    
    NSURLRequest *initialRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSLog(@"This is the link you are downloading: %@",initialRequest);
    
    AFHTTPRequestOperation *downloadOperation = [[AFHTTPRequestOperation alloc] initWithRequest:initialRequest];
    
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[filePaths objectAtIndex:0] stringByAppendingPathComponent:[self downloadPBWTitle:[self.appData  objectForKey:@"title"] withVersion:[self.appData objectForKey:@"version"]]];
    
    [downloadOperation setOutputStream:[NSOutputStream outputStreamToFileAtPath:filePath append:NO]];
    
    [downloadOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
     {
         downloadProgress = (float)totalBytesRead / totalBytesExpectedToRead;
         
         [SVProgressHUD showProgress:downloadProgress status:@"Downloading..."];
     }];
    
    [downloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        
        NSURLRequest *initialRequest2 = [NSURLRequest requestWithURL:[NSURL URLWithString:[self.appData objectForKey:@"previewURL"]]];
        
        NSLog(@"This is the link you are downloading: %@",initialRequest2);
        
        AFHTTPRequestOperation *downloadOperation2 = [[AFHTTPRequestOperation alloc] initWithRequest:initialRequest2];
        
        NSArray *filePaths2 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filePath2 = [[filePaths2 objectAtIndex:0] stringByAppendingPathComponent:[self downloadPBWPreview:[self.appData objectForKey:@"title"] withVersion:[self.appData objectForKey:@"version"]]];
        
        [downloadOperation2 setOutputStream:[NSOutputStream outputStreamToFileAtPath:filePath2 append:NO]];
        
        [downloadOperation2 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation2, id responseObject2) {
            NSLog(@"image downloaded!");
        } failure:^(AFHTTPRequestOperation *downloadOperation, NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Error downloading PBW..."];
            
            NSLog(@"ERROR: %@",error);
        }];
        
        [downloadOperation2 start];
        
        
        NSDictionary *appInfo = self.appData;
        
        NSString *downloadPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Downloads.plist"];
        
        //NSLog(@"%@",appInfo);
        
        NSMutableArray *downloadList = [[NSMutableArray alloc] init];
        downloadList = [NSMutableArray arrayWithContentsOfFile:downloadPath];
        [downloadList addObject:appInfo];
        
        // NSLog(@"%@",downloadList);
        
        [downloadList writeToFile:downloadPath atomically:YES];
        
        if ([downloadList writeToFile:downloadPath atomically:YES]) {
            NSLog(@"Success!");
            [SVProgressHUD showSuccessWithStatus:@"Updated!"];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.indexPath, @"indexPath", @"0", @"installed", nil];
            
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:@"didUpdateFace"
                                              object:nil
                                            userInfo:dict];
            [[self navigationController] popToRootViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadCompleted" object:nil];
            
        }
        else {
            NSLog(@"Error saving to plist...");
        }
    } failure:^(AFHTTPRequestOperation *downloadOperation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Error downloading PBW..."];
        
        NSLog(@"ERROR: %@",error);
    }];
    
    [downloadOperation start];
}

- (void)deleteOld {
    NSString *downloadPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Downloads.plist"];
    
    NSMutableArray *downloads = [[NSMutableArray alloc] init];
    downloads = [NSMutableArray arrayWithContentsOfFile:downloadPath];
    NSMutableArray *newMutableArray = [downloads mutableCopy];
    
    int index;
    NSDictionary *oldDict;
    
    for (NSDictionary *eachApp in downloads) {
        if ([[eachApp objectForKey:@"cID"] isEqualToString:[self.appData objectForKey:@"cID"]]) {
            index = [downloads indexOfObject:eachApp];
            oldDict = eachApp;
            [newMutableArray replaceObjectAtIndex:index withObject:self.appData];
        }
    }
    
    [newMutableArray writeToFile:downloadPath atomically:YES];
    
    if ([newMutableArray writeToFile:downloadPath atomically:YES]) {
        [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@_%@.%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [[downloads objectAtIndex:index] objectForKey:@"title"], [NSString stringWithFormat:@"%@",[[downloads objectAtIndex:index] objectForKey:@"version"]], [[[downloads objectAtIndex:index] objectForKey:@"previewURL"] pathExtension]]] error:nil];
        
        [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@_%@.pbw", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [[downloads objectAtIndex:index] objectForKey:@"title"], [NSString stringWithFormat:@"%@",[[downloads objectAtIndex:index] objectForKey:@"version"]]]] error:nil];
        
        [SVProgressHUD showWithStatus:@"Downloading..."];
        
        NSURLRequest *initialRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[self.appData objectForKey:@"dlURL"]]];
        
        NSLog(@"This is the link you are downloading: %@",initialRequest);
        
        AFHTTPRequestOperation *downloadOperation = [[AFHTTPRequestOperation alloc] initWithRequest:initialRequest];
        
        NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filePath = [[filePaths objectAtIndex:0] stringByAppendingPathComponent:[self downloadPBWTitle:[self.appData  objectForKey:@"title"] withVersion:[self.appData objectForKey:@"version"]]];
        
        [downloadOperation setOutputStream:[NSOutputStream outputStreamToFileAtPath:filePath append:NO]];
        
        [downloadOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
         {
             downloadProgress = (float)totalBytesRead / totalBytesExpectedToRead;
             
             [SVProgressHUD showProgress:downloadProgress status:@"Downloading..."];
         }];
        
        [downloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [SVProgressHUD dismiss];
            
            //if user is logged in append user ID to download link
            
            
            NSURLRequest *initialRequest2 = [NSURLRequest requestWithURL:[NSURL URLWithString:[self.appData objectForKey:@"previewURL"]]];
            
            NSLog(@"This is the link you are downloading: %@",initialRequest2);
            
            AFHTTPRequestOperation *downloadOperation2 = [[AFHTTPRequestOperation alloc] initWithRequest:initialRequest2];
            
            NSArray *filePaths2 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *filePath2 = [[filePaths2 objectAtIndex:0] stringByAppendingPathComponent:[self downloadPBWPreview:[self.appData objectForKey:@"title"] withVersion:[self.appData objectForKey:@"version"]]];
            
            [downloadOperation2 setOutputStream:[NSOutputStream outputStreamToFileAtPath:filePath2 append:NO]];
            
            [downloadOperation2 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation2, id responseObject2) {
                NSLog(@"image downloaded!");
                
                [SVProgressHUD showSuccessWithStatus:@"Updated!"];
                
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.indexPath, @"indexPath", @"1", @"installed", nil];
                
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:@"didUpdateFace"
                                                  object:nil
                                                userInfo:dict];
                [[self navigationController] popToRootViewControllerAnimated:YES];
            } failure:^(AFHTTPRequestOperation *downloadOperation, NSError *error) {
                [SVProgressHUD showErrorWithStatus:@"Error downloading PBW..."];
                
                NSLog(@"ERROR: %@",error);
            }];
            
            [downloadOperation2 start];
            
            
            NSDictionary *appInfo = self.appData;
            
            NSString *downloadPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Downloads.plist"];
            
            //NSLog(@"%@",appInfo);
            
            NSMutableArray *downloadList = [[NSMutableArray alloc] init];
            downloadList = [NSMutableArray arrayWithContentsOfFile:downloadPath];
            
            if ([downloadList containsObject:appInfo]) {
                NSLog(@"Success!");
                [SVProgressHUD showSuccessWithStatus:@"Done!"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadCompleted" object:nil];
                
            }
            else {
                NSLog(@"Error saving to plist...");
            }
        } failure:^(AFHTTPRequestOperation *downloadOperation, NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Error downloading PBW..."];
            
            NSLog(@"ERROR: %@",error);
        }];
        
        [downloadOperation start];
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[self.appData objectForKey:@"appData"] objectForKey:@"dlURL"]]];
            if (self.isDesc == 1 || [[self.appData objectForKey:@"installed"] intValue] != 1) {
                [self downloadPBW];
            }
            else {
                [self deleteOld];
            }
            
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            GeneralTextViewController *vc = [[GeneralTextViewController alloc] init];
            
            if (self.isDesc == 1) {
                [vc setText:[self.appData objectForKey:@"description"]];
                [vc setTitle:@"Description"];
            }
            else {
                [vc setText:[self.appData objectForKey:@"releaseNotes"]];
                [vc setTitle:@"Release Notes"];
            }
            
            [vc setAppTitle:[self.appData objectForKey:@"title"]];
            
            [[self navigationController] pushViewController:vc animated:YES];
        }
    }
    else if (indexPath.section == 2) {
        PreviewViewController *vc = [[PreviewViewController alloc] init];
        
        [vc setPreviewURL:[NSURL URLWithString:[self.appData objectForKey:@"previewURL"]]];
        //  [vc setColor:indexPath.row];
        [vc setAppName:@"Preview"];
        
        // Push to Preview
        
        [[self navigationController] pushViewController:vc animated:YES];
    }
}

@end
