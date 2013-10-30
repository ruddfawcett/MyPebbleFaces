//
//  LoginViewController.m
//  MyPebbleFaces
//
//  Created by Jason Smyth on 16/09/2013.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    NSString *loggedInUsername = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]];
    
    if (loggedInUsername.length == 0) {
        self.title = @"Login";
    }
    else {
        self.title = @"Account";
    }
    
    [self.view addGestureRecognizer:tap];
    
    if(self.pop){
        NSLog(@"Popped view did load");
       [self showLogin];
        self.navigationItem.leftBarButtonItem=nil;
        self.navigationItem.hidesBackButton=YES;
    }
    
    self.tableView.separatorColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    self.tableView.backgroundView = nil;
    
    
    UserClass *newUser = [UserClass sharedSingleton];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchingData:)
                                                 name:@"showHUDAuto"
                                               object:newUser];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchingData:)
                                                 name:@"showHUD"
                                               object:newUser];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchingData:)
                                                 name:@"hideHUD"
                                               object:newUser];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userHasLoggedIn:)
                                                 name:@"autoLogin"
                                               object:newUser];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userHasLoggedIn:)
                                                 name:@"login"
                                               object:newUser];
    [[NSNotificationCenter defaultCenter]    addObserver:self
                                                selector:@selector(loggedOut:)
                                                    name:@"logOut"
                                                  object:newUser];
    [[NSNotificationCenter defaultCenter]    addObserver:self
                                                selector:@selector(fetchingData:)
                                                    name:@"error"
                                                  object:newUser];
    
    NSLog(@"View did appear");
    [newUser autoLogin];
    
    if (loggedInUsername.length == 0 || ![[NSUserDefaults standardUserDefaults] objectForKey:@"username"]) {
        self.submit = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:self action:@selector(submit:)];
    }
    else {
        self.submit = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(submit:)];
    }
    
    self.navigationItem.rightBarButtonItem = self.submit;
    
    if (![newUser isLogged]) {
  
    }
    else {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [self.submit setTitle:@"Logout"];
        [self.welcome setText:[NSString stringWithFormat: @"You are logged in as %@",[defaults objectForKey:@"username"]]];
        [username setHidden:YES];
        [password setHidden:YES];
       
//        [self.welcome setHidden:NO];
        
    }
    
    if (self.poppedFromDls) {
        UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(closeModal)];
    
        self.navigationItem.leftBarButtonItem = close;
    }
}

-(void)closeModal {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == username) {
        [username resignFirstResponder];
        [password becomeFirstResponder];
        // self.filterNameText = filterNameField.text;
    }
    else {
        [password resignFirstResponder];
        [self submit:nil];
    }
    return YES;
}

-(void)dismissKeyboard {
    // ends any keyboard for any view - basically ends all editing (works for editing cells too i think)
    [self.view endEditing:YES];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
-(void)loggedOut:(NSNotification *) notification{

    [self showLogin];
      NSLog(@"LoggedOut Login View Notification Received");
}

-(void)showLogin{
    
    [username setHidden:NO];
    [password setHidden:NO];
    
    [self.submit setTitle:@"Login"];
//    [self.welcome setHidden:YES];
    
}
- (void)fetchingData:(NSNotification *) notification{
    if([[notification name] isEqualToString:@"showHUD" ]){
        [SVProgressHUD showWithStatus:@"Logging In..."];
    }
    if([[notification name] isEqualToString:@"showHUDAuto" ]){
       // [SVProgressHUD showWithStatus:newUser.autoSignInText];
    }
    if([[notification name] isEqualToString:@"hideHUD" ]){
        [SVProgressHUD dismiss];
    }
    if([[notification name] isEqualToString:@"error" ]){
        [SVProgressHUD showErrorWithStatus:@"Login Failed!"];
        [SVProgressHUD dismiss];
    }
    
}

- (void)userHasLoggedIn:(NSNotification *) notification
{
    if (self.poppedFromDls) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [[self navigationController] popToRootViewControllerAnimated:YES];
        if ([self pop]){
             [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submit:(id)sender {
    [self dismissKeyboard];
    
    UserClass *newUser = [UserClass sharedSingleton];
    
    //Changed this as i removed the auto synthesization 
    NSString *passwordString = [password text];
    NSString *usernameString = [username text];
    
    
    if ([newUser loggedIn]) {
        [SVProgressHUD showWithStatus:@"Logging Out..."];
        [newUser logout];
        [self.tableView reloadData];
    }
    else{
        [newUser login:usernameString password:passwordString];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Your Credentials";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *loggedInUsername = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]];
    
    if (loggedInUsername.length != 0) {
        return @"Your password is not saved in the app.  You will be automatically logged in.";
    }
    else return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (indexPath.row == 0) {
        cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.271 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        username = [[DGTextField alloc] initWithFrame:CGRectMake(20, 12, cell.bounds.size.width-40, 21)];
        username.textColor = [UIColor whiteColor];
        username.autocorrectionType = UITextAutocorrectionTypeNo;
        username.font = [UIFont boldSystemFontOfSize:17.0];
        
        NSString *loggedInUsername = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]];
        
        if (loggedInUsername.length == 0 || ![[NSUserDefaults standardUserDefaults] objectForKey:@"username"]) {
            username.placeholder = @"Username";
        }
        else {
            username.text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]];
        }
        
        username.adjustsFontSizeToFitWidth = YES;
        username.clearButtonMode = UITextFieldViewModeWhileEditing;
        username.cursorColor = [UIColor whiteColor];
        username.returnKeyType = UIReturnKeyNext;
        username.delegate = self;
        
        [cell addSubview:username];
    }
    else {
        cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:0.271 alpha:1.0] selectedColor:[UIColor colorWithWhite:0.271 alpha:1.0] style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        password = [[DGTextField alloc] initWithFrame:CGRectMake(20, 12, cell.bounds.size.width-40, 21)];
        password.textColor = [UIColor whiteColor];
        password.autocorrectionType = UITextAutocorrectionTypeNo;
        password.font = [UIFont boldSystemFontOfSize:17.0];
        
        NSString *loggedInUsername = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]];
        
        if (loggedInUsername.length == 0) {
            password.placeholder = @"Password";
        }
        else {
            password.placeholder = @"Your Password";
        }
        
        password.secureTextEntry = YES;
        password.adjustsFontSizeToFitWidth = YES;
        password.clearButtonMode = UITextFieldViewModeWhileEditing;
        password.cursorColor = [UIColor whiteColor];
        password.returnKeyType = UIReturnKeyDone;
        password.delegate = self;
        
        [cell addSubview:password];
    }
    
    return cell;
}


@end
