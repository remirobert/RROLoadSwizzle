//
//  Counter.m
//  Tests
//
//  Created by Remi Robert on 2019/04/19.
//  Copyright © 2019 Remi Robert. All rights reserved.
//

#import "Counter.h"

@implementation Counter

- (NSInteger)incrementNumber:(NSInteger)number {
    return number + 1;
}

+ (NSString *)manage {
    return NSStringFromClass([Counter class]);
}

@end
