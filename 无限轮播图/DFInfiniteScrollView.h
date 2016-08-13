//
//  DFInfiniteScrollView.h
//  无限轮播图
//
//  Created by sundefu on 16/6/25.
//  Copyright © 2016年 孙德福. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonCrypto.h>

@interface DFInfiniteScrollView : UIView
{
    NSMutableDictionary *imageDictionary;//存储图片
}

@property (assign, nonatomic) BOOL isFirstLoadImage;
//设置竖向时必须要放在图片数组前
@property (assign, nonatomic, getter=isScrollDirectionPortrait) BOOL scrollDirectionPortrait;

@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIPageControl *pageControl;
@property (weak, nonatomic) NSTimer *timer;

@property (strong, nonatomic) NSArray *imageArray;

@property (nonatomic, strong) UIImage *placeholderImage;

@end


@interface NSString (MD5)

- (id)md5ImagePath;

@end