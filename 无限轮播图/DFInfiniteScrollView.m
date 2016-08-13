//
//  DFInfiniteScrollView.m
//  无限轮播图
//
//  Created by sundefu on 16/6/25.
//  Copyright © 2016年 孙德福. All rights reserved.
//

#import "DFInfiniteScrollView.h"

#define PAGE_W 80.0
#define PAGE_H 20.0
static int const ImageViewCount = 3;

@interface DFInfiniteScrollView()<UIScrollViewDelegate>

@end

@implementation DFInfiniteScrollView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        imageDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
        
        // 滚动视图
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.pagingEnabled = YES;
        scrollView.bounces = NO;
        scrollView.delegate = self;
        [self addSubview:scrollView];
        self.scrollView = scrollView;
        
        // 图片控件
        for (int i = 0; i < ImageViewCount; i++) {
            UIImageView *imageView = [[UIImageView alloc] init];
            [scrollView addSubview:imageView];
        }
        
        // 页码视图
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        [self addSubview:pageControl];
        _pageControl = pageControl;
    }
    
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_scrollDirectionPortrait) {
        //竖向
        self.scrollView.contentSize = CGSizeMake(0, ImageViewCount * self.bounds.size.height);
    }else{
        //横向
        self.scrollView.contentSize = CGSizeMake(ImageViewCount * self.bounds.size.width, 0);
    }
    
    for (int i = 0; i < ImageViewCount; i++) {
        UIImageView *imageView = self.scrollView.subviews[i];
        if (_scrollDirectionPortrait) {
            //竖向滚动时imageview的frame
            imageView.frame = CGRectMake(0, i * self.scrollView.frame.size.height, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        }else{
            //横向滚动时imageview的frame
            imageView.frame = CGRectMake(i * self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        }
    }
    
    CGFloat pageX = self.scrollView.frame.size.width - PAGE_W;
    CGFloat pageY = self.scrollView.frame.size.height - PAGE_H;
    self.pageControl.frame = CGRectMake(pageX, pageY, PAGE_W, PAGE_H);
    
}

#pragma mark - setter方法
- (void)setImageArray:(NSArray *)imageArray
{
    self.isFirstLoadImage = YES;
    _imageArray = imageArray;
    // 设置页码
    self.pageControl.numberOfPages = imageArray.count;
    self.pageControl.currentPage = 0;
    // 设置内容
    [self displayImage];
    
    // 开始定时器
    [self startTimer];
}

#pragma mark - 显示图片处理
- (void)displayImage
{
    // 设置图片，三张imageview显示无限张图片
    for (int i = 0; i < ImageViewCount; i++) {
        UIImageView *imageView = self.scrollView.subviews[i];
        NSInteger index = self.pageControl.currentPage;
        
        if (i == 0) {
            index--;
        }else if (i == 2) {
            //滚到最后一张图片，index加1
            index++;
        }
        
        if (index < 0) {//如果滚到第一张还继续向前滚，那么就显示最后一张
            index = self.pageControl.numberOfPages - 1 ;
        }else if (index >= self.pageControl.numberOfPages) {//滚动到最后一张的时候，由于index加了一，导致index大于总的图片个数，此时把index重置为0，所以此时滚动到最后再继续向后滚动就显示第一张图片了
            index = 0;
        }
        
        imageView.tag = index;
        [self loadImage:imageView WithIndex:index];
    }
    
    // 偏移一个scrollview的高度或者宽度，让scrollview显示中间的imageview
    if (self.isScrollDirectionPortrait) {
        self.scrollView.contentOffset = CGPointMake(0, self.scrollView.frame.size.height);
    } else {
        self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
    }
    
}

- (void)displayNextImage
{
    if (self.isScrollDirectionPortrait) {
        [self.scrollView setContentOffset:CGPointMake(0, 2 * self.scrollView.frame.size.height) animated:YES];
    } else {
        [self.scrollView setContentOffset:CGPointMake(2 * self.scrollView.frame.size.width, 0) animated:YES];
    }
}

#pragma mark - 加载图片

- (void)loadImage:(UIImageView *)imageView WithIndex:(NSInteger)index{
    
    NSString *imageName = self.imageArray[index];
    
    if ([imageName hasPrefix:@"http://"] || [imageName hasPrefix:@"https://"]) {
        
        if ([self imageExistsAtLocal:imageName]) {
            [self getImagesWithPath:self.imageArray[index] completionBlock:^(UIImage *image) {
                if (image) {
                   imageView.image = image;
                    
                }
            }];
        }else{
            imageView.image = _placeholderImage;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self getImagesWithPath:self.imageArray[index] completionBlock:^(UIImage *image) {
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            imageView.image = image;
                        });
                        
                    }
                }];
            });
        }
        
        
    }else{
        imageView.image = [UIImage imageNamed:self.imageArray[index]];
    }
    
}

#pragma mark - UIScrollView 代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 当两张图片同时显示在屏幕中，找出占屏幕比例超过一半的那张图片
    NSInteger page = 0;
    CGFloat minDistance = MAXFLOAT;
    
    for (int i = 0; i<self.scrollView.subviews.count; i++) {
        UIImageView *imageView = self.scrollView.subviews[i];
        CGFloat distance = 0;
        if (self.isScrollDirectionPortrait) {
            distance = ABS(imageView.frame.origin.y - scrollView.contentOffset.y);
        } else {
            distance = ABS(imageView.frame.origin.x - scrollView.contentOffset.x);
        }
        
        if (distance < minDistance) {
            minDistance = distance;
            page = imageView.tag;
        }
    }
    
    if (_isFirstLoadImage) {
        _isFirstLoadImage = NO;
    }else{
        self.pageControl.currentPage = page;
    }
    
}

//用手开始拖拽的时候，就停止定时器，不然用户拖拽的时候，也会出现换页的情况
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopTimer];
}
//用户停止拖拽的时候，就启动定时器
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startTimer];
}

//手指拖动scroll停止的时候，显示下一张图片
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self displayImage];
    
}

//定时器滚动scrollview停止的时候，显示下一张图片
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self displayImage];
}

#pragma mark - 定时器处理
- (void)startTimer
{
    NSTimer *timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(displayNextImage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}

- (void)stopTimer
{
    [self.timer invalidate];
    //需要手动设置timer为nil，因为定时器被系统强引用了，必须手动释放
    self.timer = nil;
}

#pragma mark - 网络加载图片
//缓存路径
- (NSString *)cachePath
{
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *path = [directory stringByAppendingPathComponent:[[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".scrollImage"]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

-(BOOL)imageExistsAtLocal:(NSString*)imagePath
{
    NSString *md5Path = [imagePath md5ImagePath];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[self cachePath],md5Path];
    
    
    
    return [imageDictionary objectForKey:md5Path] || [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

// 获取网络图片
- (void)getImagesWithPath:(NSString *)imagePath completionBlock:(void(^)(UIImage *image))block
{
    NSString *md5Path = [imagePath md5ImagePath];
    
    // 查看内存是否有缓存图片
    if ([imageDictionary objectForKey:md5Path]) {
        
        if (block) {
            block([imageDictionary objectForKey:md5Path]);
        }
        
    }else{
        
        // 查看磁盘是否有缓存图片
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",[self cachePath],md5Path];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            
            // 磁盘有缓存，先读入内存，再使用
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            UIImage *image = [UIImage imageWithData:data];
            [imageDictionary setObject:image forKey:md5Path];
            if (block) {
                block(image);
            }
            
        }else{
            
            
            NSURL *url = [NSURL URLWithString:imagePath];
            // 磁盘没有缓存，下载图片
            [self downloadImageWithURL:url completionBlock:^(UIImage *image) {
                if (image) {
                    // 存入内存
                    [imageDictionary setObject:image forKey:md5Path];
                    
                    // 存入磁盘
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        NSData *data = UIImagePNGRepresentation(image);
                        [data writeToFile:filePath atomically:YES];
                    });
                    
                    if (block) {
                        block(image);
                    }
                }
            }];
        }
    }
}

//下载图片
- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void(^)(UIImage *image))block
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        __block UIImage *image = nil;
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
        
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            image = [UIImage imageWithData:data];
            
            if (block) {
                block(image);
            }
        }] resume];
        
    });
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end


@implementation NSString (MD5)

- (id)md5ImagePath{
    
    const char* cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (uint32_t)strlen(cStr), digest);
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X",digest[i]];
    }
    
    return result;
    
}

@end
