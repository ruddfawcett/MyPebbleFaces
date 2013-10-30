//
//  pebbleCell.h
//  MyPebbleFaces
//
//  Created by Rudd Fawcett on 7/17/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface pebbleCell : UICollectionViewCell

@property(nonatomic, strong) IBOutlet UIImageView *imageView;
@property(nonatomic, strong) UIImage *previewImage;

@end
