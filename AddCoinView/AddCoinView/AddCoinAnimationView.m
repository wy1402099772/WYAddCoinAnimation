//
//  AddCoinAnimationView.m
//  AddCoinView
//
//  Created by wyan assert on 9/8/16.
//  Copyright © 2016 wyan assert. All rights reserved.
//

#import "AddCoinAnimationView.h"
#import "AddCoinAnimationParameter.h"
#import "CoinAnimationItemView.h"
#import "CoinsAnimationController.h"

static NSString *CoinPopControllerIdentifer = @"CoinPopControllerIdentifer";
static NSString *CoinBornControllerIdentifer = @"CoinBornControllerIdentifer";
static NSString *CoinRemoveControllerIdentifier = @"CoinRemoveControllerIdentifier";

@interface AddCoinAnimationView () <UIDynamicAnimatorDelegate, CoinsAnimationControllerDelegate>

@property (assign, nonatomic) BOOL                       isPopAnimationWillStop;
@property (assign, nonatomic) BOOL                       isCoinsHide;

@property (assign, nonatomic) CGRect                     coinBirthRect;
@property (assign, nonatomic) CGFloat                    bouncePositionY;

@property (strong, nonatomic) UIDynamicAnimator         *animator;
@property (nonatomic, strong) UIGravityBehavior         *gravityBehavior;
@property (strong, nonatomic) UIDynamicItemBehavior     *itemBehavior;
@property (strong, nonatomic) UIDynamicItemBehavior     *popItemBehavior;

@property (strong, nonatomic) NSMutableSet              *pushBehaviors;

@property (strong, nonatomic) CoinsAnimationController  *coinBirthController;
@property (strong, nonatomic) CoinsAnimationController  *coinPopController;
@property (strong, nonatomic) CoinsAnimationController  *coinRemoveController;

@end

@implementation AddCoinAnimationView

#pragma  mark - Init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}


#pragma mark - LifeCycle
- (void)layoutSubviews {
    [self configureGeometryInfo];
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
}


#pragma mark - Configure
-(void)configure {
    self.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor clearColor];
    
    [self configureGeometryInfo];
    
}


#pragma mark - Public
- (void)willAddCoins:(NSInteger)coinsNumbers {
    NSInteger coinsToBeBorn = coinsNumbers;
    if (coinsToBeBorn > 500) {
        coinsToBeBorn = 500;
    }
    [self.coinBirthController prepareForCoinsBirth:coinsNumbers];
}

- (void)addCoins:(NSInteger)coinsNumber {
    if (coinsNumber <= 0 ) {
        return;
    }
    
    if (self.coinBirthRect.size.width <= 0 || self.coinBirthRect.size.height <= 0) {
        [self.delegate allTheAnimationDinished];
    }
    
    NSInteger coinsToBeBorn = coinsNumber;
    if (coinsToBeBorn > 500) {
        coinsToBeBorn = 500;
    }
    
    [self.coinBirthController makeCoinsBorn:coinsToBeBorn];
    
}

- (void)willConfirmCoinAdded:(NSInteger)coinNumber {
    [self addWillPopOrRemovetag:coinNumber];
    [self.coinPopController prepareForCoinsBirth:coinNumber];
}

- (void)confirmCoinAdded:(NSInteger)coinNumber {
    if (coinNumber <= 0 ) {
        return;
    }
    
    NSInteger coinsToBeBorn = coinNumber;
    if (coinsToBeBorn > 500) {
        coinsToBeBorn = 500;
    }
    
    [self.coinPopController makeCoinsBorn:coinsToBeBorn];
}

- (void)willRemoveCoins:(NSInteger)coinNumber {
    [self addWillPopOrRemovetag:coinNumber];
    [self.coinRemoveController prepareForCoinsBirth:coinNumber];
    
}

- (void)removeCoins:(NSInteger)coinNumber {
    if (coinNumber <= 0 ) {
        return;
    }
    
    [self.coinRemoveController makeCoinsBorn:coinNumber];
}

- (void)stop {
    [self.coinBirthController clear];
    [self.coinPopController clear];
    for(UIView *view in self.subviews) {
        if([view isKindOfClass:[CoinAnimationItemView class]]) {
            CoinAnimationItemView *item = (CoinAnimationItemView *)view;
            if(item.dismissAction) {
                item.dismissAction();
            }
            [self.itemBehavior removeItem:item];
            [self.popItemBehavior removeItem:item];
            [item removeFromSuperview];
        }
    }
}

- (NSUInteger)numberOfCoinItems {
    NSUInteger result = 0;
    for(UIView *view in self.subviews) {
        if([view isKindOfClass:[CoinAnimationItemView class]]) {
            if(!((CoinAnimationItemView *)view).hasAttached && !((CoinAnimationItemView *)view).isSigned) {
                result ++;
            }
        }
    }
    return result;
}

- (void)setCoinsHide:(BOOL)hide {
    self.isCoinsHide = hide;

    for(CoinAnimationItemView *view in self.subviews) {
        if(view.isSigned || view.hasAttached) {
            continue;
        }
        [view setHidden:hide];
    }
}


#pragma mark - Private
- (void)configureGeometryInfo {
    CGRect rect = self.displayRect;
    self.coinBirthRect = CGRectMake(rect.origin.x + rect.size.width * 2.0 / 5.0,
                                    rect.origin.y + rect.size.height * 3.0 / 5.0,
                                    rect.size.width / 5.0,
                                    rect.size.height / 5.0);
    
    self.bouncePositionY = CGRectGetMaxY(rect);
}

- (void)addCoinsToDynamics:(NSInteger)number {
    if (number <= 0 ) {
        return;
    }
    // add new coin to dynamic system
    for (NSInteger index = 0; index < number; index ++) {
        CoinAnimationItemView *view = [[CoinAnimationItemView alloc]init];
        
        view.animationImages = [AddCoinAnimationParameter getAnimateImageArray];
        view.animationDuration = [AddCoinAnimationParameter randomCycleTime];
        view.animationRepeatCount = 0;
        [view startAnimating];
        
        CGSize size = [AddCoinAnimationParameter randomCoinSize];
        CGPoint center = [AddCoinAnimationParameter randomPointInRect:self.coinBirthRect];
        CGRect frame = CGRectMake(center.x - size.width / 2, center.y - size.height / 2, size.width, size.height);
        view.frame = frame;
        view.alpha = 0.6;
        [view setHidden:self.isCoinsHide];
        
        [self addSubview:view];
        
        [self.itemBehavior addItem:view];
        [self.gravityBehavior addItem:view];
        
        // give each a up instant push with random angle
        UIPushBehavior *pushBehavior = [[UIPushBehavior alloc]initWithItems:@[view] mode:UIPushBehaviorModeInstantaneous];
        [pushBehavior setAngle: [AddCoinAnimationParameter randomCoinBirthAngle] magnitude:[AddCoinAnimationParameter randomCoinBirthmagnitude]];
        [self.animator addBehavior:pushBehavior];
        [self.pushBehaviors addObject:pushBehavior];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, [AddCoinAnimationParameter getBirthDuration] * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.itemBehavior removeItem:view];
            [self.gravityBehavior removeItem:view];
        });
    }
    
}

- (void)popCoinsToDynamics:(NSInteger)number {
    if(0 >= number) {
        return ;
    }
    for(UIView *view in self.subviews) {
        if([view isKindOfClass:[CoinAnimationItemView class]]) {
            CoinAnimationItemView *item = (CoinAnimationItemView *)view;
            if(!item.hasAttached && item.isSigned) {
                if(0 >= number) {
                    break;
                }
                CGRect endRect  = self.snapRect;
                [self popItem:item toSnap:CGPointMake(CGRectGetMidX(endRect), CGRectGetMidY(endRect))];
                number--;
            }
        }
    }
}

- (void)removeCoinsToDynamics:(NSInteger)number {
    if(0 >= number) {
        return ;
    }
    for(UIView *view in self.subviews) {
        if([view isKindOfClass:[CoinAnimationItemView class]]) {
            CoinAnimationItemView *item = (CoinAnimationItemView *)view;
            if(!item.hasAttached && item.isSigned) {
                if(item.dismissAction) {
                    item.dismissAction();
                }
                [self.itemBehavior removeItem:item];
                [self.popItemBehavior removeItem:item];
                [item removeFromSuperview];
                
                number--;
                if(0 >= number) {
                    break;
                }
            }
        }
    }
}

- (void)popItem:(CoinAnimationItemView *)item toSnap:(CGPoint)point {
    
    item.hasAttached = YES;
    
    UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:item snapToPoint:point];
    snapBehavior.damping = 1;
    
    __weak typeof(self) weakSelf = self;
    __weak UISnapBehavior *weakSnap =  snapBehavior;
    item.dismissAction = ^(void) {
        [weakSelf.animator removeBehavior:weakSnap];
    };
    [self.popItemBehavior addItem:item];
    [self.animator addBehavior:snapBehavior];
}

- (void)addWillPopOrRemovetag:(NSInteger)coinsNumber {
    for(CoinAnimationItemView *item in self.subviews) {
        if(!item.isSigned) {
            item.isSigned = YES;
            coinsNumber --;
            if(coinsNumber <= 0) {
                break;
            }
        }
    }
}


#pragma mark - CoinsAnimationControllerDelegate
- (void)coinsDidBorn:(NSInteger)coinsNumber withControllerIdentify:(NSString *)identifer{
    if([identifer isEqualToString:CoinBornControllerIdentifer]) {
        [self addCoinsToDynamics:coinsNumber];
    } else if([identifer isEqualToString:CoinPopControllerIdentifer]) {
        [self popCoinsToDynamics:coinsNumber];
    } else if([identifer isEqualToString:CoinRemoveControllerIdentifier]) {
        [self removeCoinsToDynamics:coinsNumber];
    }
}

- (void)coinDidFinishedWithControllerIdentify:(NSString *)identifer{
    if([identifer isEqualToString:CoinBornControllerIdentifer]) {
        _isPopAnimationWillStop = NO;
    } else if([identifer isEqualToString:CoinPopControllerIdentifer]) {
        _isPopAnimationWillStop = YES;
    } else if([identifer isEqualToString:CoinRemoveControllerIdentifier]) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(removeActionFinished)]) {
            [self.delegate removeActionFinished];
        }
    }
}


#pragma mark - UIDynamicAnimatorDelegate
- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator {
//    NSLog(@"did pause, %ld, %ld", (long)self.coinBirthController.notBornCoinsNumer, (long)self.coinPopController.notBornCoinsNumer);
    
    if(!_isPopAnimationWillStop) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(birthCoinAnimationFinished)]) {
            [self.delegate birthCoinAnimationFinished];
        }
    } else if(_isPopAnimationWillStop) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(popCoinAnimationFinished)]) {
            [self.delegate popCoinAnimationFinished];
        }
//        NSLog(@"pop animation finished");
    }
    if(self.subviews.count == 0 && self.coinPopController.notBornCoinsNumer <= 0) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(allTheAnimationDinished)]) {
            [self.delegate allTheAnimationDinished];
        }
    }
}


#pragma mark - Getter
- (UIDynamicAnimator *)animator {
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc]initWithReferenceView:self];
        _animator.delegate = self;
        [_animator addBehavior:self.itemBehavior];
        [_animator addBehavior:self.popItemBehavior];
        [_animator addBehavior:self.gravityBehavior];
    }
    return _animator;
}

- (UIDynamicItemBehavior *)itemBehavior {
    if (!_itemBehavior) {
        _itemBehavior = [[UIDynamicItemBehavior alloc]init];
        _itemBehavior.allowsRotation = YES;
        _itemBehavior.density = 0.7;
        _itemBehavior.elasticity = [AddCoinAnimationParameter coinElasticity];
        
        __weak UIDynamicItemBehavior *weakItemBehavior = _itemBehavior;
        __weak typeof(self) weakSelf = self;
        weakItemBehavior.action = ^() {
            if (!weakSelf) {
                NSLog(@"weakself is nil");
                return;
            }
        
            for (CoinAnimationItemView *item in weakItemBehavior.items) {
                if(item.alpha < 1) {
                    item.alpha += 0.03;
                }
            }
            // no longer need pushbehavior after birth
            for (UIPushBehavior *pushBehavior in weakSelf.pushBehaviors) {
                [weakSelf.animator removeBehavior:pushBehavior];
            }
            [weakSelf.pushBehaviors removeAllObjects];
        };
        
    }
    return _itemBehavior;
}

- (UIDynamicItemBehavior *)popItemBehavior {
    if(!_popItemBehavior) {
        _popItemBehavior = [[UIDynamicItemBehavior alloc]init];
        _popItemBehavior.allowsRotation = YES;
        
        __weak UIDynamicItemBehavior *weakPopItemBehavior = _popItemBehavior;
        __weak typeof(self) weakSelf = self;
        _popItemBehavior.action = ^() {
            if(!weakSelf) {
                return ;
            }
            NSArray *array = [weakPopItemBehavior.items copy];
            for(CoinAnimationItemView *item in array) {
                if(weakSelf.snapRect.size.width <= 0 || CGRectContainsPoint(weakSelf.snapRect, item.center)) {
                    [weakPopItemBehavior removeItem:item];
                    if(item.dismissAction) {
                        item.dismissAction();
                    }
                    [item removeFromSuperview];
                }
            }
        };
        
    }
    return _popItemBehavior;
}

- (NSMutableSet *)pushBehaviors {
    if (!_pushBehaviors) {
        _pushBehaviors = [ NSMutableSet set];
    }
    return _pushBehaviors;
}

- (CoinsAnimationController *)coinBirthController {
    if (!_coinBirthController) {
        _coinBirthController = [[CoinsAnimationController alloc] initWithIdentifier:CoinBornControllerIdentifer];
        _coinBirthController.delegate = self;
    }
    return _coinBirthController;
}

- (CoinsAnimationController *)coinPopController {
    if(!_coinPopController) {
        _coinPopController = [[CoinsAnimationController alloc] initWithIdentifier:CoinPopControllerIdentifer];
        _coinPopController.delegate = self;
    }
    return _coinPopController;
}

- (CoinsAnimationController *)coinRemoveController {
    if(!_coinRemoveController) {
        _coinRemoveController = [[CoinsAnimationController alloc] initWithIdentifier:CoinRemoveControllerIdentifier];
        _coinRemoveController.delegate = self;
    }
    return _coinRemoveController;
}

- (UIGravityBehavior *)gravityBehavior {
    if (!_gravityBehavior) {
        _gravityBehavior = [[UIGravityBehavior alloc]init];
        _gravityBehavior.magnitude = [AddCoinAnimationParameter gravityMagnitude];
    }
    return _gravityBehavior;
}


#pragma mark - Setter
- (void)setDisplayRect:(CGRect)displayRect {
    _displayRect = displayRect;
    [self configureGeometryInfo];
}

@end
