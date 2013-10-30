//
//  CustomScannerViewController.h
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 9/21/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"
#import "AppDetailURLViewController.h"
#import "SVProgressHUD.h"

@interface CustomScannerViewController : UIViewController <ZBarReaderViewDelegate>

@property (strong, nonatomic) ZBarReaderView *readerView;
@property (strong, nonatomic) UIImageView *imageView;

@end
