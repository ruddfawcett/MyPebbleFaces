//
//  CustomTabBarViewController.m
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 9/21/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "CustomTabBarViewController.h"

@interface CustomTabBarViewController ()

@end

@implementation CustomTabBarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [[[self tabBar].items objectAtIndex:0] setFinishedSelectedImage:[UIImage imageNamed:@"pebbleTab.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"pebbleTab.png"]];
    [[[self tabBar].items objectAtIndex:1] setFinishedSelectedImage:[UIImage imageNamed:@"pbw.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"pbw.png"]];
    [[[self tabBar].items objectAtIndex:2] setFinishedSelectedImage:[UIImage imageNamed:@"star.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"star.png"]];
    [[[self tabBar].items objectAtIndex:3] setFinishedSelectedImage:[UIImage imageNamed:@"filter.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"filter.png"]];
    [[[self tabBar].items objectAtIndex:4] setFinishedSelectedImage:[UIImage imageNamed:@"settings.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"settings.png"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
