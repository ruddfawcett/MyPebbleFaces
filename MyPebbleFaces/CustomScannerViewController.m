//
//  CustomScannerViewController.m
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 9/21/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "CustomScannerViewController.h"

@interface CustomScannerViewController ()

@end

@implementation CustomScannerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.922 alpha:1];
    self.title = @"Scan QR Code";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(hideViewController)];
    
    self.readerView = [[ZBarReaderView alloc] init];
    self.readerView.frame = CGRectMake(20,60,280,330);
    self.readerView.readerDelegate = self;
    self.readerView.torchMode = 0;
    self.readerView.trackingColor = [UIColor colorWithRed:0.745 green:0.196 blue:0.071 alpha:1.00];
    
    ZBarImageScanner *scanner = self.readerView.scanner;
    [scanner setSymbology: 0
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    [scanner setSymbology: ZBAR_QRCODE
                   config: ZBAR_CFG_ENABLE
                       to: 1];
    
    [self.readerView start];
    [self.view addSubview:self.readerView];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.readerView stop];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.readerView start];
}

- (void)readerView:(ZBarReaderView*)view didReadSymbols:(ZBarSymbolSet*)syms fromImage:(UIImage*) img
{
    [self.readerView stop];
    [SVProgressHUD setStatus:@"Validating..."];
    // do something useful with results
    ZBarSymbol *symbol = nil;
    for(symbol in syms) {
        break;
    }
    // EXAMPLE: do something useful with the barcode data
    NSLog(@"%@",symbol.data);
    
    NSURL *url = [NSURL URLWithString:symbol.data];
    NSLog(@"HOST: %@",url.host);
    
    if (url && url.scheme && url.host) {
        NSString *ifPebble = [url.host stringByReplacingOccurrencesOfString:@".com" withString:@""];
        ifPebble = [ifPebble stringByReplacingOccurrencesOfString:@"www." withString:@""];
        
        if ([ifPebble isEqualToString:@"mypebblefaces"]) {
            NSDictionary *dict = [self parseQueryString:[url query]];
            NSLog(@"query dict: %@", dict);
            
            if ([dict objectForKey:@"cID"]) {
                [SVProgressHUD dismiss];
                
                AppDetailURLViewController *vc = [[AppDetailURLViewController alloc] initWithStyle:UITableViewStyleGrouped];
                [vc setModalController:0];
                [vc setAppID:[dict objectForKey:@"cID"]];
                
                [[self navigationController] pushViewController:vc animated:YES];
            }
            else {
                [self badURL];
            }
        }
        else {
            [self badURL];
        }
    }
    else {
        [self badURL];
    }
}

- (void)badURL {
    [SVProgressHUD showErrorWithStatus:@"Bad URL!"];
    [self.readerView start];
}

- (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6] ;
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}

- (void)hideViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
