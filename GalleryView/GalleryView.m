//
//  GalleryView.m
//  PenYou
//
//  Created by trgoofi on 13-11-25.
//  Copyright (c) 2013年 Infinite Reader Ltd. All rights reserved.
//

#import "GalleryView.h"

@interface GalleryView ()<NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (strong, nonatomic) UIImageView *imageView;
@property (assign, nonatomic) CGFloat zoomInScaleAtATime;
@property (assign, nonatomic) NSUInteger maxZoomInTimes;
@property (strong, nonatomic) DACircularProgressView *progressView;

@property (nonatomic) NSMutableData *data;
@property (nonatomic) double expectedBytes;

@end

@implementation GalleryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _zoomInScaleAtATime = 2.f;
        _maxZoomInTimes = 2;
        
        self.delegate = self;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        singleTap.numberOfTapsRequired = 1;
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        [self addGestureRecognizer:singleTap];
        [self addGestureRecognizer:doubleTap];
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _progressView = [[DACircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];;
        _progressView.center = self.imageView.center                                                                                                                                       ;
        _progressView.thicknessRatio = 0.1f;
        _progressView.trackTintColor = [UIColor grayColor];
        
        [self addSubview:_imageView];
        [self addSubview:_progressView];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self centerSubviews];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)singleTap:(UITapGestureRecognizer *)recognizer
{
    if ([self.tappedDelegate respondsToSelector:@selector(singleTappedGalleryView:)]) {
        [self.tappedDelegate singleTappedGalleryView:self];
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)gesture
{
    CGFloat zoomScale = self.zoomScale;
    if (zoomScale == self.minimumZoomScale) {
        UIImage *image = self.imageView.image;
        CGFloat scaleX = image.size.width >  image.size.height ? 8 : 5;
        CGPoint loc = [gesture locationInView:gesture.view];
        loc = CGPointMake(loc.x * scaleX, loc.y * 2);
        CGRect rect = (CGRect){loc,self.imageView.frame.size};
        [self zoomToRect:rect animated:YES];
    
    } else if (zoomScale == self.maximumZoomScale) {
        [self setZoomScale:.0f animated:YES];
    }
}

- (void)setImageUrl:(NSString *)url
{
    if (!self.imageView.image) {
        [self.progressView bringSubviewToFront:self];
        [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[[NSURL alloc]initWithString:url]] delegate:self];
    }
}

- (void)setImage:(UIImage *)image
{
    if (image == nil || CGSizeEqualToSize(CGSizeZero, image.size)) {
        return;
    }
    
    UIImageView *imageView = self.imageView;
    imageView.image = image;
    [imageView sizeToFit];
    
    CGSize bound = self.bounds.size;
    
    CGFloat xScale = bound.width  / imageView.bounds.size.width;
    CGFloat yScale = bound.height / imageView.bounds.size.height;
    
    CGFloat minScale = MIN(xScale, yScale);
    CGFloat maxScale = minScale * (self.maxZoomInTimes * self.zoomInScaleAtATime);
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    
    self.zoomScale = self.minimumZoomScale;
    self.contentSize = imageView.frame.size;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)centerSubviews
{
    CGSize bound = self.bounds.size;
    CGRect center = _imageView.frame;
    
    if (center.size.width < bound.width) {
        center.origin.x = (bound.width - center.size.width) / 2;
    } else {
        center.origin.x = 0;
    }
    if (center.size.height < bound.height) {
        center.origin.y = (bound.height - center.size.height) / 2;
    } else {
        center.origin.y = 0;
    }
    
    _imageView.frame = center;
}

- (void)backToOriginalState
{
    [self setZoomScale:self.minimumZoomScale animated:NO];
}

#pragma mark -- ProgressView delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.expectedBytes = response.expectedContentLength;
    self.data = [NSMutableData dataWithCapacity:self.expectedBytes];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [self.data appendData:data];
    double receivedBytes = self.data.length ;
    double dataLength = receivedBytes / self.expectedBytes;
    self.progressView.progress = dataLength;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.progressView removeFromSuperview];
    [self loadImage];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    _progressView.progress = 1.0;
}

- (void)loadImage
{
    self.imageView.hidden = NO;
    UIImage *image = [UIImage imageWithData:self.data];    [self setImage:image];
    [self.cacheImages setObject:image forKey:[self formatToNSString:self.tag]];
}

- (void)removeProgressView
{
    [self.progressView removeFromSuperview];
}

- (NSString *)formatToNSString:(NSInteger)value {
    NSString *result;
#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
    result = [NSString stringWithFormat:@"%ld", value];
#else
    result = [NSString stringWithFormat:@"%d", value];
#endif
    return result;
}

@end