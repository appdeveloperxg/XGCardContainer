//
//  XGCardContainer.h
//  XGCardContainer
//
//  Created by user on 2017/4/26.
//  Copyright © 2017年 郭晓广. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XGCardContainer;

typedef NS_OPTIONS(NSInteger, XGCardDirection) {
    XGCardDirectionDefault     = 0,
    XGCardDirectionLeft        = 1 << 0,
    XGCardDirectionRight       = 1 << 1,
    XGCardDirectionUp          = 1 << 2,
    XGCardDirectionDown        = 1 << 3
};


@protocol XGCardContainerDataSource <NSObject>

- (UIView *)cardContainerViewNextViewWithIndex:(NSInteger)index;
- (NSInteger)cardContainerViewNumberOfViewInIndex:(NSInteger)index;

@end

@protocol XGCardContainerDelegate <NSObject>

- (void)cardContainerView:(XGCardContainer *)cardContainerView
    didEndDraggingAtIndex:(NSInteger)index
            draggableView:(UIView *)draggableView
       draggableDirection:(XGCardDirection)draggableDirection;

@optional
- (void)cardContainerViewDidCompleteAll:(XGCardContainer *)container;

- (void)cardContainerView:(XGCardContainer *)cardContainerView
         didSelectAtIndex:(NSInteger)index
            draggableView:(UIView *)draggableView;

- (void)cardContainderView:(XGCardContainer *)cardContainderView updatePositionWithDraggableView:(UIView *)draggableView draggableDirection:(XGCardDirection)draggableDirection widthRatio:(CGFloat)widthRatio heightRatio:(CGFloat)heightRatio;

@end

@interface XGCardContainer : UIView


/**
 *  default is XGCardDirectionLeft | XGCardDirectionRight
 */
@property (nonatomic, assign) XGCardDirection cardDirection;
@property (nonatomic, weak) id <XGCardContainerDataSource> dataSource;
@property (nonatomic, weak) id <XGCardContainerDelegate> delegate;

/**
 *  reloads everything from scratch. redisplays card.
 */
- (void)reloadCardContainer;
- (void)reloadData;
- (void)movePositionWithDirection:(XGCardDirection)direction isAutomatic:(BOOL)isAutomatic;
- (void)movePositionWithDirection:(XGCardDirection)direction isAutomatic:(BOOL)isAutomatic undoHandler:(void (^)())undoHandler;

- (UIView *)getCurrentView;

@end
