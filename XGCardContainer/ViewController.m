//
//  ViewController.m
//  YSLDraggableCardContainerDemo
//
//  Created by yamaguchi on 2015/11/10.
//  Copyright © 2015年 h.yamaguchi. All rights reserved.
//

#import "ViewController.h"
#import "XGCardContainer.h"
#import "CardView.h"

#define RGB(r, g, b)	 [UIColor colorWithRed: (r) / 255.0 green: (g) / 255.0 blue: (b) / 255.0 alpha : 1]

@interface ViewController () <XGCardContainerDelegate, XGCardContainerDataSource>

@property (nonatomic, strong) XGCardContainer *container;
@property (nonatomic, strong) NSMutableArray *datas;

@end

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(235, 235, 235);
    
    _container = [[XGCardContainer alloc]init];
    _container.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _container.backgroundColor = [UIColor clearColor];
    _container.dataSource = self;
    _container.delegate = self;
    _container.cardDirection =  XGCardDirectionUp;
    [self.view addSubview:_container];
    
    for (int i = 0; i < 4; i++) {
        
        UIView *view = [[UIView alloc]init];
        CGFloat size = self.view.frame.size.width / 4;
        view.frame = CGRectMake(size * i, self.view.frame.size.height - 150, size, size);
        view.backgroundColor = [UIColor clearColor];
        [self.view addSubview:view];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10, 10, size - 20, size - 20);
        [button setBackgroundColor:RGB(66, 172, 225)];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"Futura-Medium" size:18];
        button.clipsToBounds = YES;
        button.layer.cornerRadius = button.frame.size.width / 2;
        button.tag = i;
        [button addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        
        if (i == 0) { [button setTitle:@"添加数据" forState:UIControlStateNormal]; }
        if (i == 1) { [button setTitle:@"减掉数据" forState:UIControlStateNormal]; }
        if (i == 2) { [button setTitle:@"清楚数据" forState:UIControlStateNormal]; }
        if (i == 3) { [button setTitle:@"Right" forState:UIControlStateNormal]; }
    }
    
    [self loadData];
    
    [_container reloadCardContainer];
}

- (void)loadData
{
    _datas = [NSMutableArray array];
    
    for (int i = 0; i < 7; i++) {
        NSDictionary *dict = @{@"image" : [NSString stringWithFormat:@"%d.jpg",i + 1],
                               @"name" : @"XGCardContainer Demo"};
        [_datas addObject:dict];
    }
}
- (void)addData
{
    for (int i = 0; i < 7; i++) {
        NSDictionary *dict = @{@"image" : [NSString stringWithFormat:@"%d",i + 1],
                               @"name" : @"XGCardContainer Demo"};
        [_datas addObject:dict];
    }
    [_container reloadData];
}
-(void)deletData{
    
    [_datas removeLastObject];
    [_datas removeLastObject];
    [_datas removeLastObject];
    [_datas removeLastObject];
    [_container reloadData];
    
}
#pragma mark -- Selector
- (void)buttonTap:(UIButton *)button
{
    if (button.tag == 0) {
        
        [self addData];
    }
    if (button.tag == 1) {

        [self removeAllObject];
    }
    if (button.tag == 2) {
        [_container movePositionWithDirection:XGCardDirectionLeft isAutomatic:YES];
    }
    if (button.tag == 3) {
        [_container movePositionWithDirection:XGCardDirectionRight isAutomatic:YES];
    }
}
-(void)removeAllObject
{
    [_datas removeAllObjects];
    [_container reloadData];
}
#pragma mark -- XGCardContainer DataSource
- (UIView *)cardContainerViewNextViewWithIndex:(NSInteger)index
{
    NSDictionary *dict = _datas[index];
    CardView *view = [[CardView alloc]initWithFrame:CGRectMake(10, 64, self.view.frame.size.width - 20, self.view.frame.size.width - 20)];
    view.backgroundColor = [UIColor whiteColor];
    view.imageView.image = [UIImage imageNamed:dict[@"image"]];
    view.label.text = [NSString stringWithFormat:@"%@  %ld",dict[@"name"],(long)index];
    return view;
}

- (NSInteger)cardContainerViewNumberOfViewInIndex:(NSInteger)index
{
    return _datas.count;
}

#pragma mark -- XGCardContainer Delegate
- (void)cardContainerView:(XGCardContainer *)cardContainerView didEndDraggingAtIndex:(NSInteger)index draggableView:(UIView *)draggableView draggableDirection:(XGCardDirection)draggableDirection
{
    if (draggableDirection == XGCardDirectionLeft) {
        [cardContainerView movePositionWithDirection:draggableDirection
                                         isAutomatic:NO];
    }
    
    if (draggableDirection == XGCardDirectionRight) {
        [cardContainerView movePositionWithDirection:draggableDirection
                                         isAutomatic:NO];
    }
    
    if (draggableDirection == XGCardDirectionUp) {
        [cardContainerView movePositionWithDirection:draggableDirection
                                         isAutomatic:NO];
    }
}

- (void)cardContainderView:(XGCardContainer *)cardContainderView updatePositionWithDraggableView:(UIView *)draggableView draggableDirection:(XGCardDirection)draggableDirection widthRatio:(CGFloat)widthRatio heightRatio:(CGFloat)heightRatio
{
    CardView *view = (CardView *)draggableView;
    
    if (draggableDirection == XGCardDirectionDefault) {
        view.selectedView.alpha = 0;
    }
    
    if (draggableDirection == XGCardDirectionLeft) {
        view.selectedView.backgroundColor = RGB(215, 104, 91);
        view.selectedView.alpha = widthRatio > 0.8 ? 0.8 : widthRatio;
    }
    
    if (draggableDirection == XGCardDirectionRight) {
        view.selectedView.backgroundColor = RGB(114, 209, 142);
        view.selectedView.alpha = widthRatio > 0.8 ? 0.8 : widthRatio;
    }
    
    if (draggableDirection == XGCardDirectionUp) {
        view.selectedView.backgroundColor = RGB(66, 172, 225);
        view.selectedView.alpha = heightRatio > 0.8 ? 0.8 : heightRatio;
    }
}

- (void)cardContainerViewDidCompleteAll:(XGCardContainer *)container;
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [container reloadCardContainer];
    });
}

- (void)cardContainerView:(XGCardContainer *)cardContainerView didSelectAtIndex:(NSInteger)index draggableView:(UIView *)draggableView
{
    NSLog(@"++ index : %ld",(long)index);
}

@end
