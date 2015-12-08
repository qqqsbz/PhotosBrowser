//
//  GalleryViewController.m
//  PenYou
//
//  Created by trgoofi on 13-11-21.
//  Copyright (c) 2013年 Infinite Reader Ltd. All rights reserved.
//

#import "GalleryViewController.h"
#import "GalleryView.h"
@interface GalleryViewController () <GalleryViewTappedDelegate, UIScrollViewDelegate> {
    int intIOSVersion;
}

@property (strong, nonatomic) UIButton *saveBtn;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSMutableArray *galleryViews;
@property (strong, nonatomic) NSMutableDictionary *cacheImages;

@end

@implementation GalleryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        _galleryViews = [[NSMutableArray alloc] init];
        _cacheImages = [[NSMutableDictionary alloc]init];
        _scrollingGap = 35.f;
        _pageControlHeight = 37.f;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    CGRect frame = self.view.bounds;
    
    CGRect pageControlFrame = CGRectMake(0, frame.size.height - self.pageControlHeight, frame.size.width, self.pageControlHeight);
    _pageControl = [[UIPageControl alloc] initWithFrame:pageControlFrame];
    _pageControl.userInteractionEnabled = NO;
    
    frame.size.width += self.scrollingGap;
    _scrollView = [[UIScrollView alloc] initWithFrame:frame];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    
    _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveBtn.frame  = CGRectMake(0,0, 35, 35);
    _saveBtn.center = CGPointMake(CGRectGetWidth(self.view.frame) - 35, _pageControl.center.y);
    [_saveBtn setImage:[UIImage imageNamed:@"preview_save_icon"] forState:UIControlStateNormal];
    [_saveBtn setImage:[UIImage imageNamed:@"preview_save_icon_highlighted"] forState:UIControlStateHighlighted];
    [_saveBtn addTarget:self action:@selector(downLoadAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_scrollView];
    [self.view addSubview:_pageControl];
    [self.view addSubview:_saveBtn];
    [self getIOSIntVersion];
    [self reloadData];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.pageControl.currentPage = self.currentShowingIndex;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    [UIView animateWithDuration:.2 animations:^(){
        self.scrollView.layer.opacity = .9;
        self.scrollView.layer.opacity = .4;
        self.scrollView.layer.opacity = .0;
    }];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGRect frame;
    [self getIOSIntVersion];
    if (fromInterfaceOrientation == UIInterfaceOrientationPortrait && intIOSVersion < 8) {
        //the coordinate system is changed, if you want to knowe more details see this
        //http://blog.csdn.net/smallmuou/article/details/8238513
        frame = CGRectMake(-[UIScreen mainScreen].bounds.size.width, 0,
                           [UIScreen mainScreen].bounds.size.height,
                           [UIScreen mainScreen].bounds.size.width);
        
    } else {
        
        frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,
                           [UIScreen mainScreen].bounds.size.height);
    }
    
    self.scrollView.frame = CGRectMake(0, 0, frame.size.width + self.scrollingGap,
                                       frame.size.height);
    self.pageControl.frame = CGRectMake(0, frame.size.height - self.pageControlHeight,
                                        frame.size.width, self.pageControlHeight);
    _saveBtn.center = CGPointMake(CGRectGetWidth(frame) - 35, _pageControl.center.y);
    
    [self reloadData];
    
    [UIView animateWithDuration:.2 animations:^(){
        self.scrollView.layer.opacity = .0;
        self.scrollView.layer.opacity = .4;
        self.scrollView.layer.opacity = .9;
    }];
}

- (void)reloadData
{
    if (![self.delegate respondsToSelector:@selector(numberOfGalleryViews)]) {
        return;
    }
    
    UIScrollView *scrollView = self.scrollView;
    
    CGRect frame = scrollView.bounds;
    frame.size.width -= self.scrollingGap;
    
    CGFloat width = scrollView.frame.size.width;
    NSUInteger numberOfGalleryViews = [self.delegate numberOfGalleryViews];
    self.pageControl.numberOfPages = numberOfGalleryViews;
    for (UIView *subView in scrollView.subviews) {
        [subView removeFromSuperview];
    }
    [self.galleryViews removeAllObjects];
    for (NSUInteger i = 0; i < numberOfGalleryViews; i++) {
        frame.origin.x = width * i;
        GalleryView *galleryView = [[GalleryView alloc] initWithFrame:frame];
        galleryView.tag = i;
        galleryView.tappedDelegate = self;
        galleryView.cacheImages = self.cacheImages;
        
        NSString *key = [self formatToNSString:galleryView.tag];
        UIImage *image = [self.cacheImages valueForKey:key];
        if (!image) {
            if ([self.delegate respondsToSelector:@selector(galleryView:atIndex:)]) {
                if (i == 0 || i == self.currentShowingIndex) {
                    [self.delegate galleryView:galleryView atIndex:i];
                }
            }
        } else {
            [galleryView removeProgressView];
            galleryView.image = image;
        }
        
        [scrollView addSubview:galleryView];
        [self.galleryViews addObject:galleryView];
    }
    
    scrollView.contentSize = CGSizeMake(width * numberOfGalleryViews, scrollView.frame.size.height);
    
    frame = scrollView.bounds;
    frame.origin.x = width * self.currentShowingIndex;
    [scrollView scrollRectToVisible:frame animated:NO];
}

- (void)singleTappedGalleryView:(GalleryView *)galleryView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSUInteger page = floor(scrollView.contentOffset.x / scrollView.frame.size.width);
    if ([self.galleryViews count] > 0 && page != self.currentShowingIndex) {
        GalleryView *galleryView = [self.galleryViews objectAtIndex:page];
        NSString *key = [self formatToNSString:galleryView.tag];
        UIImage *image = [self.cacheImages valueForKey:key];
        if (!image) {
            [self.delegate galleryView:galleryView atIndex:page];
        } else {
            galleryView.image = image;
        }
        
        [galleryView backToOriginalState];
    }
    
    self.currentShowingIndex = page;
    self.pageControl.currentPage = page;
}

- (void)getIOSIntVersion
{
    if (intIOSVersion == 0) {
        NSString *version = [UIDevice currentDevice].systemVersion;
        intIOSVersion = [[version substringFromIndex:0] intValue];
    }
}

#pragma mark -- DownLoad Action
- (void)downLoadAction:(UIButton *)sender
{
    GalleryView *galleryView = self.scrollView.subviews[self.pageControl.currentPage];
    if ([self.delegate respondsToSelector:@selector(galleryView:image:)]) {
        UIImage *image = galleryView.image;
        [self.delegate galleryView:galleryView image:image];
    }
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

