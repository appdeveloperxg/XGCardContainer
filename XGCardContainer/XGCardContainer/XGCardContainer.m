//
//  XGCardContainer.m
//  XGCardContainer
//
//  Created by user on 2017/4/26.
//  Copyright © 2017年 郭晓广. All rights reserved.
//

#import "XGCardContainer.h"


static const CGFloat kPreloadViewCount = 3.0f;
static const CGFloat kSecondCard_Scale = 0.98f;
static const CGFloat kTherdCard_Scale = 0.96f;
static const CGFloat kCard_Margin = 7.0f;
static const CGFloat kDragCompleteCoefficient_width_default = 0.8f;
static const CGFloat kDragCompleteCoefficient_height_default = 0.6f;

typedef NS_ENUM(NSInteger, MoveSlope) {
    MoveSlopeTop = 1,
    MoveSlopeBottom = -1
};

@interface XGCardContainer ()

@property (nonatomic, assign) MoveSlope moveSlope;
@property (nonatomic, assign) CGRect defaultFrame;
@property (nonatomic, assign) CGFloat cardCenterX;
@property (nonatomic, assign) CGFloat cardCenterY;
@property (nonatomic, assign) NSInteger loadedIndex;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *currentViews;
@property (nonatomic, assign) BOOL recordActionTop;//记录手势是否需要返回界面
@property (nonatomic, assign) BOOL isInitialAnimation;
@property (nonatomic, strong) UIView *publicView;//公共View
@property (nonatomic, assign) BOOL recordisPublickView;//记录一下是否是publicView 是否已经结束动画
@property (nonatomic, assign) BOOL isNeedLoadIndex;
@property (nonatomic, assign) NSInteger AllNum;

@end

@implementation XGCardContainer

- (id)init
{
    self = [super init];
    if (self) {
        [self setUp];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cardViewTap:)];
        [self addGestureRecognizer:tapGesture];
        
        self.cardDirection = XGCardDirectionUp;
    }
    return self;
}

- (void)setUp
{
    _moveSlope = MoveSlopeTop;
    _loadedIndex = 0.0f;
    _currentIndex = 0.0f;
    _currentViews = [NSMutableArray array];
    _isNeedLoadIndex = YES;
}

#pragma mark -- Public
//重置容器
-(void)reloadCardContainer
{
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    [_currentViews removeAllObjects];
    _currentViews = [NSMutableArray array];
    [self setUp];
    [self loadNextView];
    _isInitialAnimation = NO;
    [self viewInitialAnimation];
}
//重置数据
- (void)reloadData
{
    [self loadNextView];
}
//移动位置
- (void)movePositionWithDirection:(XGCardDirection)direction isAutomatic:(BOOL)isAutomatic undoHandler:(void (^)())undoHandler
{
    [self cardViewDirectionAnimation:direction isAutomatic:isAutomatic undoHandler:undoHandler];
}
//移动位置
- (void)movePositionWithDirection:(XGCardDirection)direction isAutomatic:(BOOL)isAutomatic
{
    [self cardViewDirectionAnimation:direction isAutomatic:isAutomatic undoHandler:nil];
}
#pragma mark -- 获取第一视图
- (UIView *)getCurrentView
{
    return [_currentViews firstObject];
}
#pragma mark -- Private
#pragma mark -- 跟新视图
- (void)loadNextView
{
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(cardContainerViewNumberOfViewInIndex:)]) {
        NSInteger index = [self.dataSource cardContainerViewNumberOfViewInIndex:_loadedIndex];
        self.AllNum = index;
        // all cardViews Dragging end
        if (index != 0 && index == _currentIndex) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(cardContainerViewDidCompleteAll:)]) {
                [self.delegate cardContainerViewDidCompleteAll:self];
            }
            return;
        }
        //删除公共View
        if (_publicView) {
            if (_currentIndex+3>=self.AllNum) {
                
            }else
            {
                UIView * view = [_currentViews lastObject];
                [view removeFromSuperview];
                [_currentViews removeLastObject];
            }
            [_publicView removeFromSuperview];
            _publicView = nil;
        }
        
        // load next cardView
        if (_loadedIndex < index) {
            
            NSInteger preloadViewCont = index <= kPreloadViewCount ? index : kPreloadViewCount;
            NSInteger count = _currentViews.count;
            
            if (_recordisPublickView) {
                if (_currentIndex+2==self.AllNum) {
                    preloadViewCont = 2;
                }
            }
            for (NSInteger i = count; i < preloadViewCont; i++) {
                if (self.dataSource && [self.dataSource respondsToSelector:@selector(cardContainerViewNextViewWithIndex:)]) {
                    
                    UIView *view;
                    if (_recordisPublickView) {
                        view = [self.dataSource cardContainerViewNextViewWithIndex:_currentIndex];
                    }else
                    {
                        view = [self.dataSource cardContainerViewNextViewWithIndex:_loadedIndex];
                    }
                    
                    if (view) {
                        _defaultFrame = view.frame;
                        _cardCenterX = view.center.x;
                        _cardCenterY = view.center.y;
                        [self addSubview:view];
                        
                        if (_recordisPublickView) {
                            [_currentViews insertObject:view atIndex:0];
                            _recordisPublickView = NO;
                        }else
                        {
                            [self sendSubviewToBack:view];
                            [_currentViews addObject:view];
                            
                        }
                        if (_isNeedLoadIndex) {
                            _loadedIndex++;
                            
                        }
                        if (i == 1 && _currentIndex != 0) {
                            view.frame = CGRectMake(_defaultFrame.origin.x, _defaultFrame.origin.y + kCard_Margin, _defaultFrame.size.width, _defaultFrame.size.height);
                            view.transform = CGAffineTransformScale(CGAffineTransformIdentity,kSecondCard_Scale,kSecondCard_Scale);
                        }
                        
                        if (i == 2 && _currentIndex != 0) {
                            view.frame = CGRectMake(_defaultFrame.origin.x, _defaultFrame.origin.y + (kCard_Margin * 2), _defaultFrame.size.width, _defaultFrame.size.height);
                            view.transform = CGAffineTransformScale(CGAffineTransformIdentity,kTherdCard_Scale,kTherdCard_Scale);
                        }
                    }
                    
                }
            }
        }
        
        UIView *view = [self getCurrentView];
        if (view) {
            UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
            [view addGestureRecognizer:gesture];
        }
    }
    
    
}
#pragma mark -- 添加视图把最后的添加到第一个
- (void)addFirstViewWithMovePoint:(CGPoint)movePoint
{
    if (_currentIndex==0) {return;}
    UIView *view = [self.dataSource cardContainerViewNextViewWithIndex:_currentIndex-1];
    if (!view) { return; }
    _recordisPublickView = YES;
    if (!_publicView) {
        self.publicView = view;
        self.publicView.center = CGPointMake(_cardCenterX, -_cardCenterY);
        
        switch (self.cardDirection) {
            case XGCardDirectionRight:
            {
                self.publicView.center = CGPointMake(_cardCenterX*3, _cardCenterY);
            }
                
                break;
            case XGCardDirectionLeft:
            {
                self.publicView.center = CGPointMake(-_cardCenterX, -_cardCenterY);
                
            }
                break;
            case XGCardDirectionUp:
            {
                self.publicView.center = CGPointMake(_cardCenterX, -_cardCenterY);
                
            }
                break;
                
            default:
                break;
        }
        [self addSubview:self.publicView];
    }
    
}

#pragma mark -- 删除控件视图
- (void)cardViewDirectionAnimation:(XGCardDirection)direction isAutomatic:(BOOL)isAutomatic undoHandler:(void (^)())undoHandler
{
    if (!_isInitialAnimation) { return; }
    UIView *view = [self getCurrentView];
    if (!view) { return; }
    
    __weak XGCardContainer *weakself = self;
    if (direction == XGCardDirectionDefault) {
        view.transform = CGAffineTransformIdentity;
        [UIView animateWithDuration:0.55
                              delay:0.0
             usingSpringWithDamping:0.6
              initialSpringVelocity:0.0
                            options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             view.frame = _defaultFrame;
                             
                             [weakself cardViewDefaultScale];
                         } completion:^(BOOL finished) {
                         }];
        
        return;
    }
    
    if (!undoHandler) {
        [_currentViews removeObject:view];
        _currentIndex++;
        _isNeedLoadIndex = YES;
        [self loadNextView];
    }
    
    if (direction == XGCardDirectionRight || direction == XGCardDirectionLeft || direction == XGCardDirectionDown) {
        
        [UIView animateWithDuration:0.35
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             
                             if (direction == XGCardDirectionLeft) {
                                 view.center = CGPointMake(-1 * (weakself.frame.size.width), view.center.y);
                                 
                                 if (isAutomatic) {
                                     view.transform = CGAffineTransformMakeRotation(-1 * M_PI_4);
                                 }
                             }
                             
                             if (direction == XGCardDirectionRight) {
                                 view.center = CGPointMake((weakself.frame.size.width * 2), view.center.y);
                                 
                                 if (isAutomatic) {
                                     view.transform = CGAffineTransformMakeRotation(direction * M_PI_4);
                                 }
                             }
                             
                             if (direction == XGCardDirectionDown) {
                                 view.center = CGPointMake(view.center.x, (weakself.frame.size.height * 1.5));
                             }
                             
                             if (!undoHandler) {
                                 [weakself cardViewDefaultScale];
                             }
                         } completion:^(BOOL finished) {
                             if (!undoHandler) {
                                 [view removeFromSuperview];
                             } else  {
                                 if (undoHandler) { undoHandler(); }
                             }
                         }];
    }
    
    if (direction == XGCardDirectionUp) {
        _isNeedLoadIndex = YES;
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             
                             if (direction == XGCardDirectionUp) {
                                 if (isAutomatic) {
                                     view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.03,0.97);
                                     view.center = CGPointMake(view.center.x, view.center.y + kCard_Margin);
                                 }
                             }
                             
                         } completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.35
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                                              animations:^{
                                                  view.center = CGPointMake(view.center.x, -1 * ((weakself.frame.size.height) / 2));
                                                  [weakself cardViewDefaultScale];
                                              } completion:^(BOOL finished) {
                                                  if (!undoHandler) {
                                                      [view removeFromSuperview];
                                                  } else  {
                                                      if (undoHandler) { undoHandler(); }
                                                  }
                                              }];
                         }];
    }
}

- (void)cardViewUpDateScale
{
    UIView *view = [self getCurrentView];
    
    float ratio_w = fabs((view.center.x - _cardCenterX) / _cardCenterX);
    float ratio_h = fabs((view.center.y - _cardCenterY) / _cardCenterY);
    float ratio = ratio_w > ratio_h ? ratio_w : ratio_h;
    
    if (_currentViews.count == 2) {
        if (ratio <= 1) {
            UIView *view = _currentViews[1];
            view.transform = CGAffineTransformIdentity;
            view.frame = CGRectMake(_defaultFrame.origin.x, _defaultFrame.origin.y + (kCard_Margin - (ratio * kCard_Margin)), _defaultFrame.size.width, _defaultFrame.size.height);
            view.transform = CGAffineTransformScale(CGAffineTransformIdentity,kSecondCard_Scale + (ratio * (1 - kSecondCard_Scale)),kSecondCard_Scale + (ratio * (1 - kSecondCard_Scale)));
        }
    }
    if (_currentViews.count == 3) {
        if (ratio <= 1) {
            {
                UIView *view = _currentViews[1];
                view.transform = CGAffineTransformIdentity;
                view.frame = CGRectMake(_defaultFrame.origin.x, _defaultFrame.origin.y + (kCard_Margin - (ratio * kCard_Margin)), _defaultFrame.size.width, _defaultFrame.size.height);
                view.transform = CGAffineTransformScale(CGAffineTransformIdentity,kSecondCard_Scale + (ratio * (1 - kSecondCard_Scale)),kSecondCard_Scale + (ratio * (1 - kSecondCard_Scale)));
            }
            {
                UIView *view = _currentViews[2];
                view.transform = CGAffineTransformIdentity;
                view.frame = CGRectMake(_defaultFrame.origin.x, _defaultFrame.origin.y + ((kCard_Margin * 2) - (ratio * kCard_Margin)), _defaultFrame.size.width, _defaultFrame.size.height);
                view.transform = CGAffineTransformScale(CGAffineTransformIdentity,kTherdCard_Scale + (ratio * (kSecondCard_Scale - kTherdCard_Scale)),kTherdCard_Scale + (ratio * (kSecondCard_Scale - kTherdCard_Scale)));
            }
        }
    }
}

#pragma  mark -- 更新视图
- (void)cardViewDefaultScale
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardContainderView:updatePositionWithDraggableView:draggableDirection:widthRatio:heightRatio:)]) {
        
        [self.delegate cardContainderView:self updatePositionWithDraggableView:[self getCurrentView]
                       draggableDirection:XGCardDirectionDefault
                               widthRatio:0 heightRatio:0];
    }
    
    for (int i = 0; i < _currentViews.count; i++) {
        UIView *view = _currentViews[i];
        if (i == 0) {
            view.transform = CGAffineTransformIdentity;
            view.frame = _defaultFrame;
        }
        if (i == 1) {
            view.transform = CGAffineTransformIdentity;
            view.frame = CGRectMake(_defaultFrame.origin.x, _defaultFrame.origin.y + kCard_Margin, _defaultFrame.size.width, _defaultFrame.size.height);
            view.transform = CGAffineTransformScale(CGAffineTransformIdentity,kSecondCard_Scale,kSecondCard_Scale);
        }
        if (i == 2) {
            view.transform = CGAffineTransformIdentity;
            view.frame = CGRectMake(_defaultFrame.origin.x, _defaultFrame.origin.y + (kCard_Margin * 2), _defaultFrame.size.width, _defaultFrame.size.height);
            view.transform = CGAffineTransformScale(CGAffineTransformIdentity,kTherdCard_Scale,kTherdCard_Scale);
        }
    }
}

- (void)viewInitialAnimation
{
    for (UIView *view in _currentViews) {
        view.alpha = 0.0;
    }
    
    UIView *view = [self getCurrentView];
    if (!view) { return; }
    __weak XGCardContainer *weakself = self;
    view.alpha = 1.0;
    view.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.5f,0.5f);
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.05f,1.05f);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.1
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              view.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.95f,0.95f);
                                          }
                                          completion:^(BOOL finished) {
                                              [UIView animateWithDuration:0.1
                                                                    delay:0.0
                                                                  options:UIViewAnimationOptionCurveEaseOut
                                                               animations:^{
                                                                   view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0f,1.0f);
                                                               }
                                                               completion:^(BOOL finished) {
                                                                   
                                                                   for (UIView *view in _currentViews) {
                                                                       view.alpha = 1.0;
                                                                   }
                                                                   
                                                                   [UIView animateWithDuration:0.25f
                                                                                         delay:0.01f
                                                                                       options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                                                                                    animations:^{
                                                                                        [weakself cardViewDefaultScale];
                                                                                    } completion:^(BOOL finished) {
                                                                                        weakself.isInitialAnimation = YES;
                                                                                    }];
                                                               }
                                               ];
                                          }
                          ];
                     }
     ];
}

#pragma mark -- Gesture Selector

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture
{
    if (!_isInitialAnimation) { return; }
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint touchPoint = [gesture locationInView:self];
        //        NSLog(@"touchPoint.x==%f  touchPoint.y==%f",touchPoint.x,touchPoint.y);
        if (touchPoint.y <= _cardCenterY) {
            _moveSlope = MoveSlopeTop;
        } else {
            _moveSlope = MoveSlopeBottom;
        }
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint point = [gesture translationInView:self];
        //        NSLog(@"touchPoint.x==%f  touchPoint.y==%f",point.x,point.y);
        
        switch (self.cardDirection) {
            case XGCardDirectionUp:
            {
                if ( gesture.view.center.y + point.y>_cardCenterY) {
                    
                    [self addFirstViewWithMovePoint:CGPointMake(_cardCenterX,gesture.view.center.y+point.y)];
                    
                    _recordActionTop = NO;
                    
                }else
                {
                    _recordActionTop = YES;
                    CGPoint movedPoint = CGPointMake(_cardCenterX, gesture.view.center.y + point.y);
                    gesture.view.center = movedPoint;
                    
                }
                
            }
                
                break;
            case XGCardDirectionLeft:
            {
                
                if ( gesture.view.center.x + point.x>_cardCenterX) {
                    
                    [self addFirstViewWithMovePoint:CGPointMake(gesture.view.center.y+point.y,_cardCenterX)];
                    
                    _recordActionTop = NO;
                    
                }else
                {
                    _recordActionTop = YES;
                    CGPoint movedPoint = CGPointMake(gesture.view.center.x + point.x, _cardCenterY);
                    gesture.view.center = movedPoint;
                    
                }
                
            }
                break;
            case XGCardDirectionRight:
            {
                if ( gesture.view.center.x + point.x<_cardCenterX) {
                    
                    [self addFirstViewWithMovePoint:CGPointMake(_cardCenterX,gesture.view.center.y+point.y)];
                    
                    _recordActionTop = NO;
                    
                }else
                {
                    _recordActionTop = YES;
                    CGPoint movedPoint = CGPointMake(gesture.view.center.x + point.x, _cardCenterY);
                    gesture.view.center = movedPoint;
                    
                }
                
                
            }
                
            default:
                break;
        }
        
        if (self.cardDirection == XGCardDirectionRight||self.cardDirection == XGCardDirectionLeft) {
            
            [gesture.view setTransform:
             CGAffineTransformMakeRotation((gesture.view.center.x - _cardCenterX) / _cardCenterX * (_moveSlope * (M_PI / 20)))];
            
            [self cardViewUpDateScale];

        }
        
        //原版的
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(cardContainderView:updatePositionWithDraggableView:draggableDirection:widthRatio:heightRatio:)]) {
            if ([self getCurrentView]) {
                
                float ratio_w = (gesture.view.center.x - _cardCenterX) / _cardCenterX;
                float ratio_h = (gesture.view.center.y - _cardCenterY) / _cardCenterY;
                XGCardDirection direction = XGCardDirectionDefault;
                
                if (fabs(ratio_h) > fabs(ratio_w)) {
                    
                    if (ratio_h <= 0) {
                        // up
                        if (_cardDirection & XGCardDirectionUp) {
                            direction = XGCardDirectionUp;
                        } else {
                            direction = ratio_w <= 0 ? XGCardDirectionLeft : XGCardDirectionRight;
                        }
                    } else {
                        // down
                        if (_cardDirection & XGCardDirectionDown) {
                            direction = XGCardDirectionDown;
                        } else {
                            direction = ratio_w <= 0 ? XGCardDirectionLeft : XGCardDirectionRight;
                        }
                    }
                    
                } else {
                    if (ratio_w <= 0) {
                        // left
                        if (_cardDirection & XGCardDirectionLeft) {
                            direction = XGCardDirectionLeft;
                        } else {
                            direction = ratio_h <= 0 ? XGCardDirectionUp : XGCardDirectionDown;
                        }
                    } else {
                        // right
                        if (_cardDirection & XGCardDirectionRight) {
                            direction = XGCardDirectionRight;
                        } else {
                            direction = ratio_h <= 0 ? XGCardDirectionUp : XGCardDirectionDown;
                        }
                    }
                    
                }
                
                [self.delegate cardContainderView:self updatePositionWithDraggableView:gesture.view
                               draggableDirection:direction
                                       widthRatio:fabs(ratio_w) heightRatio:fabsf(ratio_h)];
            }
        }
        
        [gesture setTranslation:CGPointZero inView:self];
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded ||
        gesture.state == UIGestureRecognizerStateCancelled) {
        
        
        if (_recordisPublickView&&!_recordActionTop) {
            __weak XGCardContainer *weakself = self;
            
            self.publicView.transform = CGAffineTransformIdentity;
            [UIView animateWithDuration:0.55
                                  delay:0.0
                 usingSpringWithDamping:0.6
                  initialSpringVelocity:0.0
                                options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                                 weakself.publicView.frame = _defaultFrame;
                                 
                             } completion:^(BOOL finished) {
                                 
                                 
                                 _currentIndex -- ;
                                 if (_loadedIndex>0) {
                                     _loadedIndex --;
                                     if (_loadedIndex - _currentIndex==3) {
                                         
                                         if (_loadedIndex==3) {
                                             _loadedIndex = 3;
                                             _isNeedLoadIndex = NO;
                                             
                                         }else if(_loadedIndex==self.AllNum-1)
                                         {
                                             _isNeedLoadIndex = NO;
                                             
                                         }else
                                         {
                                             _loadedIndex = _currentIndex +2;
                                             _isNeedLoadIndex = YES;
                                         }
                                         
                                     }
                                 }
                                 NSLog(@"删除_currentIndex==%ld,_loadedIndex==%ld",_currentIndex,_loadedIndex);
                                 
                                 [weakself loadNextView];
                                 [weakself cardViewDefaultScale];
                                 
                             }];
            
            return;
            
            
        }
        
        _recordActionTop = NO;
        
        float ratio_w = (gesture.view.center.x - _cardCenterX) / _cardCenterX;
        float ratio_h = (gesture.view.center.y - _cardCenterY) / _cardCenterY;
        
        XGCardDirection direction = XGCardDirectionDefault;
        if (fabs(ratio_h) > fabs(ratio_w)) {
            if (ratio_h < - kDragCompleteCoefficient_height_default && (_cardDirection & XGCardDirectionUp)) {
                // up
                direction = XGCardDirectionUp;
            }
            
            if (ratio_h > kDragCompleteCoefficient_height_default && (_cardDirection & XGCardDirectionDown)) {
                // down
                direction = XGCardDirectionDown;
            }
            
        } else {
            
            if (ratio_w > kDragCompleteCoefficient_width_default && (_cardDirection & XGCardDirectionRight)) {
                // right
                direction = XGCardDirectionRight;
            }
            
            if (ratio_w < - kDragCompleteCoefficient_width_default && (_cardDirection & XGCardDirectionLeft)) {
                // left
                direction = XGCardDirectionLeft;
            }
        }
        
        if (direction == XGCardDirectionDefault) {
            [self cardViewDirectionAnimation:XGCardDirectionDefault isAutomatic:NO undoHandler:nil];
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(cardContainerView:didEndDraggingAtIndex:draggableView:draggableDirection:)]) {
                [self.delegate cardContainerView:self didEndDraggingAtIndex:_currentIndex draggableView:gesture.view draggableDirection:direction];
            }
        }
    }
    
}

- (void)cardViewTap:(UITapGestureRecognizer *)gesture
{
    if (!_currentViews || _currentViews.count == 0) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardContainerView:didSelectAtIndex:draggableView:)]) {
        [self.delegate cardContainerView:self didSelectAtIndex:_currentIndex draggableView:gesture.view];
    }
}

@end
