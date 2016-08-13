//
//  ViewController.m
//  无限轮播图
//
//  Created by sundefu on 16/6/25.
//  Copyright © 2016年 孙德福. All rights reserved.
//

#import "ViewController.h"
#import "DFInfiniteScrollView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    DFInfiniteScrollView *scrollView = [[DFInfiniteScrollView alloc] initWithFrame:CGRectMake(10, 60, self.view.frame.size.width - 20, 140)];
    scrollView.pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
    scrollView.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    //需要显示的所有图片
    //使用本地图片
//    scrollView.imageArray = @[@"0.jpg", @"1.jpg", @"2.jpg", @"3.jpg", @"4.jpg"];
    
    //使用网络图片 带缓存
    scrollView.placeholderImage = [UIImage imageNamed:@"0.jpg"];
    NSArray *array = @[@"http://dl.bizhi.sogou.com/images/2012/09/30/44928.jpg",
                        @"http://www.deskcar.com/desktop/star/world/20081017165318/27.jpg",
                        @"http://www.0739i.com.cn/data/attachment/portal/201603/09/120156l1yzzn747ji77ugx.jpg",
                        @"http://image.tianjimedia.com/uploadImages/2012/320/8N5IGLFH4HDY_1920x1080.jpg",
                        @"http://b.hiphotos.baidu.com/zhidao/pic/item/10dfa9ec8a136327c3f37f95938fa0ec08fac77e.jpg",
                        @"http://pic15.nipic.com/20110628/7398485_105718357143_2.jpg"];
    
    scrollView.imageArray = array;
    

    [self.view addSubview:scrollView];
    
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(10, 280 ,self.view.frame.size.width - 20, 140)];
    imageview.backgroundColor = [UIColor redColor];
    [self.view addSubview:imageview];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
