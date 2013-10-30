//
//  DescriptionViewController.m
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 7/18/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "GeneralTextViewController.h"

@interface GeneralTextViewController ()

@end

@implementation GeneralTextViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - self.tabBarController.tabBar.frame.size.height - self.navigationController.navigationBar.frame.size.height)];
    self.textView.backgroundColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    
    if (self.appTitle.length == 0) {
        self.textView.text = self.text;
    }
    else {
        self.textView.text = [NSString stringWithFormat:@"%@\n\n %@",self.appTitle,self.text];
    }
        
    self.textView.editable = NO;
    self.textView.dataDetectorTypes = UIDataDetectorTypeAll;
    
    self.textView.font = [UIFont systemFontOfSize:17];
    
    [self.view addSubview:self.textView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
