//
//  ZPRecommendNewViewController.m
//  PlayDemo
//
//  Created by HZP on 2017/6/16.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import "ZPRecommendNewViewController.h"
#import "ZPChannelInfo.h"
#import "ZPVideoInfo.h"
#import "ZPPlayerViewController.h"
#import "ZYBannerView.h"
#import "UIImageView+AFNetworking.h"

static const CGFloat kCycleViewHeight = 180.0f;
static NSString* const kRecommendURL = @"http://iface.qiyi.com/openapi/batch/recommend?app_k=f0f6c3ee5709615310c0f053dc9c65f2&app_v=8.4&app_t=0&platform_id=12&dev_os=10.3.1&dev_ua=iPhone9,3&dev_hw=%7B%22cpu%22%3A0%2C%22gpu%22%3A%22%22%2C%22mem%22%3A%2250.4MB%22%7D&net_sts=1&scrn_sts=1&scrn_res=1334*750&scrn_dpi=153600&qyid=87390BD2-DACE-497B-9CD4-2FD14354B2A4&secure_v=1&secure_p=iPhone&core=1&req_sn=1493946331320&req_times=1";

@interface ZPRecommendNewViewController () <ZYBannerViewDataSource, ZYBannerViewDelegate>

/**
 *  频道列表
 */
@property (nonatomic, strong) NSArray *channelsInfos;
/**
 *  上方的轮播图
 */
@property (nonatomic, weak) ZYBannerView *cycleScrollView;

@property (nonatomic, weak) UICollectionView *collectionView;
@end

@implementation ZPRecommendNewViewController

#pragma mark - Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubView];
    
    [self requestUrl];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  创建子控件
 */
-(void)setupSubView {
    [self setupCycleView];
//    [self setupCollectionView];
}

/**
 *  创建轮播图
 */
-(void)setupCycleView {
    ZYBannerView *banner = [[ZYBannerView alloc]init];
    banner.dataSource = self;
    banner.delegate = self;
    //是否需要循环滚动
    banner.shouldLoop = YES;
    //是否需要自动滚动
    banner.autoScroll = YES;
    banner.scrollInterval = 5.0f;
    
    // 设置frame
    CGFloat bannerX = 0;
    CGFloat bannerY = 0;
    CGFloat bannerW = self.view.bounds.size.width;
    CGFloat bannerH = kCycleViewHeight;
    banner.frame = CGRectMake(bannerX, bannerY, bannerW, bannerH);

    [self.view addSubview:banner];
    self.cycleScrollView = banner;
}

/**
 *  创建collection view
 */
-(void)setupCollectionView {
    UICollectionView *collectionView = [[UICollectionView alloc]init];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];

    
}

#pragma network request
/**
 *  请求网络数据
 */
-(void)requestUrl
{
    //1.创建请求
    NSURL *url = [NSURL URLWithString:kRecommendURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //2.创建连接
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *sesson = [NSURLSession sessionWithConfiguration:configuration];
    
    //3.创建任务
    NSURLSessionDataTask *dataTask = [sesson dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed];
            });
        } else {
            NSDictionary *tmpDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *data = [tmpDic objectForKey:@"data"];
            
            NSMutableArray *dataArr = [NSMutableArray array];
            for (NSDictionary *dict in data) {
                [dataArr addObject:[ZPChannelInfo channelInfoWithDict:dict]];
            }
            self.channelsInfos = dataArr;
            
            NSNumber* resultCode = [tmpDic valueForKey:@"code"];
            if (resultCode.integerValue == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self showDataMessage:data];
                    [self reloadData];
                });
            }
        }
    }];
    
    //4.执行任务
    [dataTask resume];
}

/**
 *  网络请求失败
 */
- (void)requestFailed {
    NSLog(@"网络请求失败");
}

/**
 *  刷新数据
 */
- (void)reloadData {
    [self.cycleScrollView reloadData];
}



#pragma mark - ZYBannerViewDataSource
/**
 *  返回Banner需要显示Item(View)的个数
 */
- (NSInteger)numberOfItemsInBanner:(ZYBannerView *)banner
{
    ZPChannelInfo *channelCycle = [self.channelsInfos firstObject];
    if ([channelCycle.title isEqualToString:@"轮播图"]) {
        return channelCycle.video_list.count;
    }
    return 0;
}

// 返回Banner在不同的index所要显示的View
- (UIView *)banner:(ZYBannerView *)banner viewForItemAtIndex:(NSInteger)index
{
    ZPChannelInfo *cycleChannel = [self.channelsInfos firstObject];
    ZPVideoInfo *video = cycleChannel.video_list[index];
    
    UIImageView *imageView = [[UIImageView alloc]init];
    [imageView setImageWithURL:[NSURL URLWithString:video.img]placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
    
    return imageView;
}

-(void)banner:(ZYBannerView *)banner didSelectItemAtIndex:(NSInteger)index {
    ZPChannelInfo *cycleChannel = [self.channelsInfos firstObject];
    ZPVideoInfo *video = cycleChannel.video_list[index];
    
    
    ZPPlayerViewController *playVC = [[ZPPlayerViewController alloc]init];
    playVC.videoInfo = video;
    [self presentViewController:playVC animated:YES completion:nil];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
