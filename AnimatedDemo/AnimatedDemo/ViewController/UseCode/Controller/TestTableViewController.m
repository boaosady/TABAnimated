//
//  TestTableViewController.m
//  AnimatedDemo
//
//  Created by tigerAndBull on 2018/9/14.
//  Copyright © 2018年 tigerAndBull. All rights reserved.
//

#import "TestTableViewController.h"
#import "TestTableViewCell.h"
#import "XIBTableViewCell.h"
#import "TestHeadView.h"

#import "TABAnimated.h"
#import <TABKit/TABKit.h>

#import "Game.h"

@interface TestTableViewController () <UITableViewDelegate,UITableViewDataSource> {
    NSMutableArray *dataArray;
}

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) UIImageView *topImg;

@end

@implementation TestTableViewController

- (instancetype)init {
    if (self = [super init]) {
        [self tableView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    [self initUI];
    
    /*
        说明：
        在使用原有的启动动画方法`tab_startAnimation`发现一个问题，
        网络非常好的情况下，动画基本没机会展示出来，甚至会有一闪而过的效果。
        如果该方法配合MJRefresh，则会减缓这样的问题，原因是MJRefresh本身有一个延迟效果（为了说明，这么称呼的），大概是0.4秒。
        所以，增加了一个带有延迟时间的启动函数，
        这样的话，在网络卡的情况下，0.4秒并不会造成太大的影响，在网络不卡的情况下，可以有一个短暂的视觉效果。
     */
    
    // 启动动画
    // 这里使用了自定义延迟时间的启动函数，设置3秒是为了演示效果。
    // 非特殊场景情况下，建议使用`tab_startAnimationWithCompletion`。
    [self.tableView tab_startAnimationWithDelayTime:3. completion:^{
        // 请求数据
        // ...
        // 获得数据
        // ...
        [self afterGetData];
    }];
}

- (void)dealloc {
    NSLog(@"==========  dealloc  ==========");
}

#pragma mark - Target Methods

/**
 获取到数据后
 */
- (void)afterGetData {
    
    // 模拟数据
    for (int i = 0; i < 10; i ++) {
        Game *game = [[Game alloc]init];
        game.gameId = [NSString stringWithFormat:@"%d",i];
        game.title = [NSString stringWithFormat:@"这里是测试数据%d",i+1];
        game.cover = @"test.jpg";
        [dataArray addObject:game];
    }
    
    // 停止动画,并刷新数据
    [self.tableView tab_endAnimationEaseOut];
}

#pragma mark - UITableViewDelegate & Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return .1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *str = @"TestTableViewCell";
    TestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (!cell) {
        cell = [[TestTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell initWithData:dataArray[indexPath.row]];
    return cell;
}

#pragma mark - Initize Methods

/**
 load data
 加载数据
 */
- (void)initData {
    dataArray = [NSMutableArray array];
}

/**
 initize view
 视图初始化
 */
- (void)initUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
}

#pragma mark - Lazy Methods

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 160)];
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 80)/2.0, 20, 80, 80)];
        imageV.image = [UIImage imageNamed:@"comic.jpg"];
        imageV.layer.cornerRadius = 80/2.0;
        imageV.layer.masksToBounds = YES;
        [view addSubview:imageV];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 120+10, kScreenWidth, 20)];
        [view addSubview:lab];
        _tableView.tableHeaderView = view;
        
        // 设置tabAnimated相关属性
        // 可以不进行手动初始化，将使用默认属性
        _tableView.tabAnimated = [TABTableAnimated animatedWithCellClass:[TestTableViewCell class]
                                                              cellHeight:100];
        _tableView.tabAnimated.animatedSectionCount = 3;
        _tableView.tabAnimated.showTableHeaderView = YES;
        _tableView.tabAnimated.categoryBlock = ^(UIView * _Nonnull view) {
            view.animation(1).down(3).height(12);
            view.animation(2).height(12).width(110);
            view.animation(3).down(-5).height(12);
        };
        
        // 静态头视图扩展回调使用方法
        _tableView.tableHeaderView.tabAnimated.categoryBlock = ^(UIView * _Nonnull view) {
            
        };
    }
    return _tableView;
}

@end
