//
//  GalleryViewController.h
//  PenYou
//
//  Created by trgoofi on 13-11-21.
//  Copyright (c) 2013年 Infinite Reader Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GalleryView.h"

@protocol GalleryViewControllerDelegate <NSObject>

- (NSUInteger)numberOfGalleryViews;

- (void)galleryView:(GalleryView *)galleryView atIndex:(NSUInteger)index;

- (void)galleryView:(GalleryView *)galleryView image:(UIImage *)image;

@end

@interface GalleryViewController : UIViewController

@property (assign, nonatomic) NSUInteger currentShowingIndex;
@property (assign, nonatomic) CGFloat scrollingGap;
@property (assign, nonatomic) CGFloat pageControlHeight;
@property (weak, nonatomic) id<GalleryViewControllerDelegate> delegate;


@end