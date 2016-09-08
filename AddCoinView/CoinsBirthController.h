//
//  CoinsBirthController.h
//  AddCoinView
//
//  Created by wyan assert on 9/7/16.
//  Copyright © 2016 wyan assert. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CoinsBirthControllerDelegate;

@interface CoinsBirthController : NSObject

@property (nonatomic, assign) NSInteger                         totalCoinsNumber;
@property (nonatomic, assign) NSInteger                         notBornCoinsNumer;
@property (nonatomic, assign) NSInteger                         totalBornCoinsNumber;

@property (weak, nonatomic  ) id<CoinsBirthControllerDelegate>  delegate;

- (instancetype)initWithIdentifier:(NSString *)identifer;

- (void)prepareForCoinsBirth:(NSInteger)coinsNumber;
- (void)makeCoinsBorn:(NSInteger)coinsNumber;
- (void)clear;

@end


@protocol CoinsBirthControllerDelegate <NSObject>

- (void)coinsDidBorn:(NSInteger)coinsNumber withCnntrollerIdentify:(NSString *)identifer;
- (void)coinBornDidFinishedWithCnntrollerIdentify:(NSString *)identifer;

@end