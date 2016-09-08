//
//  CoinsFallingView.h
//  UIDynamicsDemo
//
//  Created by Amay on 5/22/16.
//  Copyright © 2016 Beddup. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CoinsFallingViewDelegate <NSObject>

- (void)fallingAnimationFinished;

@end

@interface CoinsFallingView : UIView

@property (nonatomic, weak) id<CoinsFallingViewDelegate> delegate;

- (void)willAddCoins:(NSInteger)coinsNumbers;
- (void)addCoins:(NSInteger)coinsNumber;
- (void)willConfirmCoinAdded:(NSInteger)coinNumber;
- (void)confirmCoinAdded:(NSInteger)coinNumber;

@end
