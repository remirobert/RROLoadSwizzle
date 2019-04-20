//
//  Counter.h
//  Tests
//
//  Created by Remi Robert on 2019/04/19.
//  Copyright © 2019 Remi Robert. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Counter : NSObject

- (NSInteger)incrementNumber:(NSInteger)number;
+ (NSString *)manage;

@end

NS_ASSUME_NONNULL_END
