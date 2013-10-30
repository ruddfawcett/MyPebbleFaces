//
//  PreviewViewController.m
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 7/15/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "PreviewViewController.h"

@interface PreviewViewController ()

@end

@implementation PreviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.appName;
    
    NSString *imageName;
    
    switch (self.color) {
        case 1:
            imageName = @"pebble_red.png";
            break;
        case 2:
            imageName = @"pebble_orange.png";
            break;
        case 3:
            imageName = @"pebble_grey.png";
            break;
        case 4:
            imageName = @"pebble_white.png";
            break;
            
        default:
            imageName = @"pebble_black.png";
            break;
    }
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (screenSize.height > 480.0f) {
        //self.shadowImage = [[UIImageView alloc] initWithFrame:CGRectMake(115, 192, 90, 106)];
        
        self.appPreview = [[UIImageView alloc] initWithFrame:CGRectMake(98, 141, 115, 147)];
        
        self.watchImage = [[UIImageView alloc] initWithFrame:CGRectMake(60, 58, 195, 328)];
        
        swipeToChange  = [[UILabel alloc] initWithFrame:CGRectMake(0, 400, 320, 20)];
    } else {
        //self.shadowImage = [[UIImageView alloc] initWithFrame:CGRectMake(115, 152, 90, 106)];
        
        self.appPreview = [[UIImageView alloc] initWithFrame:CGRectMake(98, 101, 115, 147)];
        
        self.watchImage = [[UIImageView alloc] initWithFrame:CGRectMake(60, 18, 195, 328)];
        
        swipeToChange  = [[UILabel alloc] initWithFrame:CGRectMake(0, 340, 320, 20)];
    }
    
    //[self.shadowImage setImage:[UIImage imageNamed:@"shadow.png"]];
    // self.shadowImage.contentMode = UIViewContentModeScaleAspectFit;
    //[self.view addSubview:self.shadowImage];
    
    [self.appPreview setImageWithURL:self.previewURL placeholderImage:[UIImage imageNamed:@"placeholder.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {}];
    self.appPreview.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.appPreview];
    
    [self.watchImage setImage:[UIImage imageNamed:imageName]];
    self.watchImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.watchImage];
    
    swipeToChange.backgroundColor = [UIColor clearColor];
    swipeToChange.text = @"Swipe to change watch color...";
    swipeToChange.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:swipeToChange];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.922 alpha:1.0];
    
    //    CGSize endImageSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    //    UIGraphicsBeginImageContext(endImageSize);
    //
    //    [[UIImage imageNamed:imageName] drawInRect:CGRectMake(85, 82, 150, 255)];
    //    [[UIImage imageNamed:@"shadow.png"] drawInRect:CGRectMake(115, 152, 90, 106)];
    //    [[UIImage imageWithData:[NSData dataWithContentsOfURL:self.previewURL]] drawInRect:CGRectMake(116, 153, 88, 104)];
    //
    //    UIImage *endImage = UIGraphicsGetImageFromCurrentImageContext();
    //
    //    UIGraphicsEndImageContext();
    //
    //    self.shadowImage = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    //    [self.shadowImage setImage:endImage];
    //    self.shadowImage.contentMode = UIViewContentModeScaleAspectFit;
    //    [self.view addSubview:self.shadowImage];
    //
    //    UIImageWriteToSavedPhotosAlbum(endImage, nil, nil, nil);
    UISwipeGestureRecognizer *rightSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    rightSwipe.direction=UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *leftSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    leftSwipe.direction=UISwipeGestureRecognizerDirectionLeft;
    
    [self.view addGestureRecognizer:leftSwipe];
    [self.view addGestureRecognizer:rightSwipe];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)recognizer {
    
    switch (recognizer.direction)
    {
        case (UISwipeGestureRecognizerDirectionRight):
            [self performSelector:@selector(previousColor)];
            swipeToChange.text = nil;
            
            break;
            
        case (UISwipeGestureRecognizerDirectionLeft):
            [self performSelector:@selector(nextColor)];
            swipeToChange.text = nil;
            
            break;
            
        default:
            break;
    }
    
}

- (void)nextColor {
    
    self.color++;
    
    if( self.color > 4){
        
        self.color = 0;
        
        
    }
    NSString *imageName;
    switch (self.color) {
        case 1:
            imageName = @"pebble_red.png";
            break;
        case 2:
            imageName = @"pebble_orange.png";
            break;
        case 3:
            imageName = @"pebble_grey.png";
            break;
        case 4:
            imageName = @"pebble_white.png";
            break;
            
        default:
            imageName = @"pebble_black.png";
            break;
    }
    
    
    
    [self.watchImage setImage:[UIImage imageNamed: imageName]];
}

- (void)previousColor {
    
    self.color = self.color - 1;
    
    
    if( self.color < 0 ){
        
        
        self.color = 4;
        
        
    }
    
    NSLog(@"%i", self.color);
    NSString *imageName;
    switch (self.color) {
        case 1:
            imageName = @"pebble_red.png";
            break;
        case 2:
            imageName = @"pebble_orange.png";
            break;
        case 3:
            imageName = @"pebble_grey.png";
            break;
        case 4:
            imageName = @"pebble_white.png";
            break;
            
        default:
            imageName = @"pebble_black.png";
            break;
    }
    
    
    
    [self.watchImage setImage:[UIImage imageNamed: imageName]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {

}
@end
