//
//  AppDetailURLViewController.m
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 9/20/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "AppDetailURLViewController.h"

@interface AppDetailURLViewController ()

@end

@implementation AppDetailURLViewController

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

    self.title = @"Loading...";
    
    self.tableView.separatorColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    self.tableView.backgroundView = nil;
    
    if (self.modalController == 1) {
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeView)];
        self.navigationItem.leftBarButtonItem = closeButton;
    }
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:@selector(sharePop)];
    self.navigationItem.rightBarButtonItem = rightButton;
    // NSLog(@"What we have to work with: %@",self.appData);
    
    [SVProgressHUD showWithStatus:@"Getting Details..."];
    [self getApplicationInfo];
    
    NSLog(@"%d",self.subApps.count);
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
}

- (void)closeView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)getApplicationInfo {
    NSURL *apiURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.mypebblefaces.com/pebbleInterface?action=getApp&cID=%@",self.appID]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:apiURL];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject)
     {
         
         self.applicationInfo = [[NSDictionary alloc] init];
         self.applicationInfo = responseObject;
         //NSLog(@"%@",self.pebbleApps);

        [SVProgressHUD dismiss];
         
         if ([[responseObject objectForKey:@"success"] isEqualToString:@"false"]) {
             [SVProgressHUD showErrorWithStatus:@"Error Loading App!"];
             
             if (self.modalController == 1) {
             }
             else {
                 [[self navigationController] popToRootViewControllerAnimated:YES];
             }
         }
         
         // NSLog(@"%@",self.applicationInfo);
         
         if ([[self.applicationInfo objectForKey:@"subApp"] objectForKey:@"total"] != 0) {
             self.subApps = [[self.applicationInfo objectForKey:@"subApp"] mutableCopy];
             [self.subApps removeObjectForKey:@"total"];
             
             self.subPebbleApp = [[NSMutableArray alloc] init];
             
             for (NSString *key in self.subApps.allKeys) {
                 NSDictionary *subDict = [self.subApps valueForKey:key];
                 NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
                 
                 [newDict setValue:subDict forKey:@"appData"];
                 [newDict setValue:key forKey:@"appNumber"];
                 
                 [self.subPebbleApp addObject:newDict];
             }
         }
         self.title = [self.applicationInfo objectForKey:@"title"];
         [self.tableView reloadData];
     
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id responseObject)
     {
         NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
         
         UserClass *singleton = [UserClass sharedSingleton];
         [singleton connectionError:error];
     }];
    
    [operation start];
}

#pragma mark - Table view data source

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.applicationInfo != nil) {
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
            
            UIImageView *faceImg = [[UIImageView alloc] initWithFrame:CGRectMake(99, 21, 123, 143)];
            [faceImg setImageWithURL: [self.applicationInfo objectForKey:@"previewURL"]
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
    }
    else {
        return nil;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.applicationInfo != nil) {
        if (section == 0) {
            return 190.0;
        }
    
        else return UITableViewAutomaticDimension;
    }
    else {
        return UITableViewAutomaticDimension;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.applicationInfo != nil) {
        return self.subPebbleApp.count == 0 ? 3 : 4;
    }
    else {
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.applicationInfo != nil) {
        if (self.subPebbleApp.count == 0) {
            if (section == 1) {
                return @"General Information";
            }
            else if (section == 2) {
                return @"Preview";
            }
            else {
                return nil;
            }
        }
        else {
            if (section == 1) {
                return @"General Information";
            }
            else if (section == 2) {
                return @"Other App Versions";
            }
            else if (section == 3) {
                return @"Preview";
            }
            else {
                return nil;
            }
        }
    }
    else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.applicationInfo != nil) {
        if (self.subPebbleApp.count == 0) {
            if (section == 1) {
                return 4;
            }
            else if (section == 2) {
                return 1;
            }
            else {
                return 1;
            }
        }
        else {
            if (section == 0) {
                return 1;
            }
            else if (section == 1) {
                return 4;
            }
            else if (section == 3) {
                return 1;
            }
            else {
                return self.subPebbleApp.count;
            }
        }
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (self.subPebbleApp.count == 0) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.textLabel.text = @"Download";
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.cornerRadius = 5.0f;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.textLabel.text = @"Description";
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.cornerRadius = 5.0f;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else if (indexPath.row == 1) {
                cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.textLabel.text = @"Author";
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.detailTextLabel.text = [self.applicationInfo objectForKey:@"author"];
                cell.detailTextLabel.textColor = [UIColor whiteColor];
                cell.cornerRadius = 5.0f;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else if (indexPath.row == 2) {
                cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.text = @"Current Version";
                cell.textLabel.textColor = [UIColor whiteColor];
                
                NSString *version  = [NSString stringWithFormat:@"%@", [self.applicationInfo objectForKey:@"version"]];
                
                cell.detailTextLabel.text = version;
                cell.detailTextLabel.textColor = [UIColor whiteColor];
                cell.cornerRadius = 5.0f;
            }
            else if (indexPath.row == 3) {
                cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.text = @"Downloads";
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.detailTextLabel.text = [[self.applicationInfo objectForKey:@"dlCount"] stringValue];
                cell.detailTextLabel.textColor = [UIColor whiteColor];
                cell.cornerRadius = 5.0f;
            }
            
        }
        else if (indexPath.section == 2) {
            cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.text = @"Pebble";
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.cornerRadius = 5.0f;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.textLabel.text = @"Download";
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.cornerRadius = 5.0f;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.textLabel.text = @"Description";
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.cornerRadius = 5.0f;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else if (indexPath.row == 1) {
                cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.textLabel.text = @"Author";
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.detailTextLabel.text = [self.applicationInfo objectForKey:@"author"];
                cell.detailTextLabel.textColor = [UIColor whiteColor];
                cell.cornerRadius = 5.0f;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else if (indexPath.row == 2) {
                cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.text = @"Current Version";
                cell.textLabel.textColor = [UIColor whiteColor];
                
                NSString *version  = [NSString stringWithFormat:@"%@", [self.applicationInfo objectForKey:@"version"]];
                
                cell.detailTextLabel.text = version;
                cell.detailTextLabel.textColor = [UIColor whiteColor];
                cell.cornerRadius = 5.0f;
            }
            else if (indexPath.row == 3) {
                cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.text = @"Downloads";
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.detailTextLabel.text = [[self.applicationInfo objectForKey:@"dlCount"] stringValue];
                cell.detailTextLabel.textColor = [UIColor whiteColor];
                cell.cornerRadius = 5.0f;
            }
            
        }
        else if (indexPath.section == 2) {
            cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.textLabel.text = [[[self.subPebbleApp objectAtIndex:indexPath.row] objectForKey:@"appData"] objectForKey:@"title"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.cornerRadius = 5.0f;
        }
        else if (indexPath.section == 3) {
            cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.500 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.text = @"Pebble";
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.cornerRadius = 5.0f;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
    }
    
    return cell;
}

- (void)sharePop {
    FUIAlertView *av = [[FUIAlertView alloc] initWithTitle:@"Share"
                                                   message:[NSString stringWithFormat:@"Share %@ with Facebook, Twitter or Email.",[self.applicationInfo objectForKey:@"title"]]
                                                  delegate:nil
                                         cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Facebook",@"Twitter",@"Email",nil];
    
    av.titleLabel.textColor = [UIColor cloudsColor];
    av.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    av.messageLabel.textColor = [UIColor cloudsColor];
    av.messageLabel.font = [UIFont flatFontOfSize:14];
    av.backgroundOverlay.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
    av.alertContainer.backgroundColor = [UIColor colorWithRed:0.745 green:0.196 blue:0.071 alpha:1.00];
    av.defaultButtonColor = [UIColor cloudsColor];
    av.defaultButtonShadowColor = [UIColor asbestosColor];
    av.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    av.defaultButtonTitleColor = [UIColor asbestosColor];
    av.delegate = self;
    
    [av show];
}

-(void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self shareToFacebook];
    }
    else if (buttonIndex == 1) {
        [self shareToTwitter];
    }
    else if (buttonIndex == 2) {
        [self sendMail];
    }
}

-(void)shareToFacebook {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *facebookSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [facebookSheet setInitialText:[NSString stringWithFormat:@"Check out %@ by %@ on http://mypebblefaces.com! %@",[self.applicationInfo objectForKey:@"title"],[self.applicationInfo objectForKey:@"author"],[self.applicationInfo objectForKey:@"shortURL"]]];
        
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
        
        [twittterSheet setInitialText:[NSString stringWithFormat:@"Check out %@ by %@ on #MyPebbleFaces! %@",[self.applicationInfo objectForKey:@"title"],[self.applicationInfo objectForKey:@"author"],[self.applicationInfo objectForKey:@"shortURL"]]];
        
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
    
    [mailer setSubject:[NSString stringWithFormat:@"%@",[self.applicationInfo objectForKey:@"title"]]];
    
    NSString *emailBody = [NSString stringWithFormat:@"Check out %@ by %@ on http://mypebblefaces.com! %@",[self.applicationInfo objectForKey:@"title"],[self.applicationInfo objectForKey:@"author"],[self.applicationInfo objectForKey:@"shortURL"]];
    
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.subPebbleApp.count == 0) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[self.appData objectForKey:@"appData"] objectForKey:@"dlURL"]]];
                
                [self downloadPBW];
                
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }
        else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                // Open description - need to figure out (<a href=''>links</a> showing in raw [&lt; a href etc...]
                
                GeneralTextViewController *vc = [[GeneralTextViewController alloc] init];
                
                [vc setText:[self.applicationInfo objectForKey:@"description"]];
                [vc setAppTitle:[self.applicationInfo objectForKey:@"title"]];
                [vc setTitle:@"Description"];
                
                [[self navigationController] pushViewController:vc animated:YES];
            }
            else if (indexPath.row == 1) {
                AuthorAppsViewController *vc = [[AuthorAppsViewController alloc] initWithStyle:UITableViewStyleGrouped];
                
                [vc setAuthorName:[self.applicationInfo objectForKey:@"author"]];
                [vc setAuthorID:[[self.applicationInfo objectForKey:@"authorID"] stringValue]];
                
                [[self navigationController] pushViewController:vc animated:YES];
            }
        }
        else {
            PreviewViewController *vc = [[PreviewViewController alloc] init];
            
            [vc setPreviewURL:[NSURL URLWithString:[self.applicationInfo objectForKey:@"previewURL"]]];
            //            [vc setColor:indexPath.row];
            [vc setAppName:@"Preview"];
            
            // Push to Preview
            
            [[self navigationController] pushViewController:vc animated:YES];
        }
    }
    else {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[self.appData objectForKey:@"appData"] objectForKey:@"dlURL"]]];
                
                [self downloadPBW];
                
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }
        else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                // Open description - need to figure out (<a href=''>links</a> showing in raw [&lt; a href etc...]
                
                GeneralTextViewController *vc = [[GeneralTextViewController alloc] init];
                
                [vc setText:[self.applicationInfo objectForKey:@"description"]];
                [vc setAppTitle:[self.applicationInfo objectForKey:@"title"]];
                [vc setTitle:@"Description"];
                
                [[self navigationController] pushViewController:vc animated:YES];
            }
            else if (indexPath.row == 1) {
                AuthorAppsViewController *vc = [[AuthorAppsViewController alloc] initWithStyle:UITableViewStyleGrouped];
                
                [vc setAuthorName:[self.applicationInfo objectForKey:@"author"]];
                [vc setAuthorID:[[self.applicationInfo objectForKey:@"authorID"] stringValue]];
                
                [[self navigationController] pushViewController:vc animated:YES];
            }
        }
        else if (indexPath.section == 2) {
            SubAppViewController *vc = [[SubAppViewController alloc] initWithStyle:UITableViewStyleGrouped];
            
            [vc setAppData:[[self.subPebbleApp objectAtIndex:indexPath.row] objectForKey:@"appData"]];
            
            [[self navigationController] pushViewController:vc animated:YES];
        }
        else {
            PreviewViewController *vc = [[PreviewViewController alloc] init];
            
            [vc setPreviewURL:[NSURL URLWithString:[self.applicationInfo objectForKey:@"previewURL"]]];
            //            [vc setColor:indexPath.row];
            [vc setAppName:@"Preview"];
            
            // Push to Preview
            
            [[self navigationController] pushViewController:vc animated:YES];
        }
    }
}

-(NSString *)downloadPBWTitle:(NSString *)title withVersion:(NSString *)version {
    return [NSString stringWithFormat:@"%@_%@.pbw",title,[NSString stringWithFormat:@"%@", version]];
}

-(NSString *)downloadPBWPreview:(NSString *)title withVersion:(NSString *)version {
    return [NSString stringWithFormat:@"%@_%@.%@",title,[NSString stringWithFormat:@"%@", version],[[self.applicationInfo objectForKey:@"previewURL"] pathExtension]];
}

-(void)downloadPBW {
    //NSLog(@"Saving File...");
    [SVProgressHUD showWithStatus:@"Downloading..."];
    
    
    NSURLRequest *initialRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[self.applicationInfo objectForKey:@"dlURL"]]];
    
    NSLog(@"This is the link you are downloading: %@",initialRequest);
    
    AFHTTPRequestOperation *downloadOperation = [[AFHTTPRequestOperation alloc] initWithRequest:initialRequest];
    
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[filePaths objectAtIndex:0] stringByAppendingPathComponent:[self downloadPBWTitle:[self.applicationInfo objectForKey:@"title"] withVersion:[self.applicationInfo objectForKey:@"version"]]];
    
    [downloadOperation setOutputStream:[NSOutputStream outputStreamToFileAtPath:filePath append:NO]];
    
    [downloadOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
     {
         downloadProgress = (float)totalBytesRead / totalBytesExpectedToRead;
         
         [SVProgressHUD showProgress:downloadProgress status:@"Downloading..."];
     }];
    
    [downloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        
        //if user is logged in append user ID to download link
        
        
        
        
        UserClass *newUser = [UserClass sharedSingleton];
        
        if([newUser isLogged])
        {
            
            NSLog(@"User is logged in");
            
            
        }
        
        
        NSURLRequest *initialRequest2 = [NSURLRequest requestWithURL:[NSURL URLWithString:[self.applicationInfo objectForKey:@"previewURL"]]];
        
        NSLog(@"This is the link you are downloading: %@",initialRequest2);
        
        AFHTTPRequestOperation *downloadOperation2 = [[AFHTTPRequestOperation alloc] initWithRequest:initialRequest2];
        
        NSArray *filePaths2 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filePath2 = [[filePaths2 objectAtIndex:0] stringByAppendingPathComponent:[self downloadPBWPreview:[self.applicationInfo objectForKey:@"title"] withVersion:[self.applicationInfo objectForKey:@"version"]]];
        
        [downloadOperation2 setOutputStream:[NSOutputStream outputStreamToFileAtPath:filePath2 append:NO]];
        
        [downloadOperation2 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation2, id responseObject2) {
            NSLog(@"image downloaded!");
        } failure:^(AFHTTPRequestOperation *downloadOperation, NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Error downloading PBW..."];
            
            NSLog(@"ERROR: %@",error);
        }];
        
        [downloadOperation2 start];
        
        
        NSDictionary *appInfo = self.applicationInfo;
        
        NSString *downloadPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Downloads.plist"];
        
        //NSLog(@"%@",appInfo);
        
        NSMutableArray *downloadList = [[NSMutableArray alloc] init];
        downloadList = [NSMutableArray arrayWithContentsOfFile:downloadPath];
        [downloadList addObject:appInfo];
        
        // NSLog(@"%@",downloadList);
        
        [downloadList writeToFile:downloadPath atomically:YES];
        
        if ([downloadList writeToFile:downloadPath atomically:YES]) {
            NSLog(@"Success!");
            //NSMutableArray *finalData = [NSMutableArray arrayWithContentsOfFile:downloadPath];
            // NSLog(@"Final array:\n\n%@",[NSMutableArray arrayWithContentsOfFile:downloadPath]);
            
            if ([[UserClass sharedSingleton] isLogged]) {
                if ([[PFInstallation currentInstallation].channels containsObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]]) {
                    [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"Face-%@",[self.applicationInfo objectForKey:@"cID"]]];
                }
            }
            
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

- (void)dealloc {
    
}


@end
