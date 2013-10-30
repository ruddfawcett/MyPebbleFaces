//
//  PreviewViewController.h
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 7/15/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface PreviewViewController : UIViewController
{
    IBOutlet UILabel *swipeToChange;
}

@property (retain, nonatomic) UIImageView *watchImage;
@property (retain, nonatomic) UIImageView *shadowImage;
@property (retain, nonatomic) UIImageView *appPreview;

@property (strong, nonatomic) NSURL *previewURL;
@property (strong, nonatomic) NSString *appName;
@property int color;

@end
