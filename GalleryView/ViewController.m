//
//  ViewController.m
//  GalleryView
//
//  Created by coder on 15/12/2.
//  Copyright © 2015年 coder. All rights reserved.
//

#import "ViewController.h"
#import "GalleryViewController.h"
#import "MBProgressHUD.h"
@interface ViewController ()<GalleryViewControllerDelegate>
{
    NSArray *datas;
    MBProgressHUD *progressView;
    GalleryViewController *galleryViewController;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    datas = @[
              @"http://img.pconline.com.cn/images/upload/upc/tx/itbbs/1308/19/c3/24613975_1376859905025.jpg",
              @"http://img.pconline.com.cn/images/upload/upc/tx/wallpaper/1402/08/c0/31073074_1391823903156.jpg",
              @"http://img.club.pchome.net/kdsarticle/2014/04/21/6758499a484626476bb30b35d54dd3fb.jpg",
              @"http://abc.2008php.com/2014_Website_appreciate/2015-01-22/20150122012424.jpg",
              @"http://www.forestry.gov.cn/uploadfile/lyjj/2011-12/image/2011-12-7-62ac6bb510114530b722abde63979e42.jpg",
              @"http://img.gzdsw.com/2013/0909/20130909111149224.jpg",
              @"http://www.deskcar.com/desktop/fengjing/2015329224504/8.jpg",
              @"http://att2.citysbs.com/hangzhou/2013/10/04/11/2784x1856-110411_15811380855851074_7f985550d0b486f2661b047c0a25bad4.jpg",
              @"http://abc.2008php.com/2013_Website_appreciate/2013-11-03/20131103232949.jpg"
              ];

}
- (IBAction)pushAction:(UIButton *)sender {
    galleryViewController = [[GalleryViewController alloc] init];
    galleryViewController.delegate = self;
    [self.navigationController presentViewController:galleryViewController animated:YES completion:nil];
}

- (NSUInteger)numberOfGalleryViews
{
    return datas.count;
}

- (void)galleryView:(GalleryView *)galleryView atIndex:(NSUInteger)index
{
    [galleryView setImageUrl:datas[index]];
}

- (void)galleryView:(GalleryView *)galleryView image:(UIImage *)image
{
    UIView *view = galleryViewController.view;
    progressView = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:progressView];
    progressView.labelText = @"正在保存";
    [progressView show:YES];
    
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    if (!error) {
        progressView.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        progressView.mode = MBProgressHUDModeCustomView;
        progressView.labelText = @"保存成功";
        [progressView hide:YES afterDelay:1];
    } else {
        progressView.labelText = @"保存失败";
        [progressView hide:YES afterDelay:1];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
