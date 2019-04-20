//
//  RROSwizzlingInfo.m
//  Swizzle
//
//  Created by Remi Robert on 2019/04/17.
//  Copyright © 2019 Remi Robert. All rights reserved.
//

#import "RROSwizzlingInfo.h"

NSString * _Nonnull RROSwizzlingInfoHashKey(Class _Nonnull class, SEL _Nonnull selector);

@implementation RROSwizzlingInfo

- (instancetype)init {
    return [self init];
}

- (instancetype)initWithTargetClass:(Class)targetClass
                     swizzledMethod:(SEL)swizzled
                  andOriginalMethod:(IMP)original {
    if ((self = [super init])) {
        _targetClass = targetClass;
        _swizzled = swizzled;
        _original = original;
    }
    return self;
}

- (NSUInteger)hash {
    return [RROSwizzlingInfoHashKey(_targetClass, _swizzled) hash];
}

@end

NSString * _Nonnull RROSwizzlingInfoHashKey(Class _Nonnull class, SEL _Nonnull selector) {
    return [NSString stringWithFormat:@"%@%@",
            NSStringFromClass(class),
            NSStringFromSelector(selector)];
}
