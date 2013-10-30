//
//  WebViewController.m
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 9/8/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Feedback";
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.922 alpha:1.0];
	
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, -50, self.view.bounds.size.width, self.view.bounds.size.height-40)];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.URL]]];
    webView.scrollView.bounces = NO;
    webView.scrollView.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:webView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
