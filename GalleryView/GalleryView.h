//
//  GalleryView.h
//  PenYou
//
//  Created by trgoofi on 13-11-25.
//  Copyright (c) 2013年 Infinite Reader Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DACircularProgressView.h"
@class GalleryView;

@protocol GalleryViewTappedDelegate <NSObject>

- (void)singleTappedGalleryView:(GalleryView *)galleryView;

@end

@interface GalleryView : UIScrollView <UIScrollViewDelegate>

@property (weak, nonatomic)     id<GalleryViewTappedDelegate>   tappedDelegate;
@property (strong, nonatomic)   UIImage                         *image;
@property (strong, nonatomic)   NSMutableDictionary             *cacheImages;


- (void)backToOriginalState;

- (void)setImageUrl:(NSString *)url;

- (void)removeProgressView;

@end

