//
//  RROSwizzlingInfoStore.m
//  Swizzle
//
//  Created by Remi Robert on 2019/04/17.
//  Copyright © 2019 Remi Robert. All rights reserved.
//

#import "RROSwizzlingInfo.h"
#import "RROSwizzlingInfoStore.h"

typedef NSString * ClassName;
typedef NSString * SwizzlingInfoHash;

@interface RROSwizzlingInfoStore ()

@property (nonatomic, strong) NSMutableDictionary<ClassName, NSMutableDictionary<SwizzlingInfoHash, RROSwizzlingInfo *> *> *swizzleInfos;
@property (nonatomic) dispatch_semaphore_t semaphore;

@end

@implementation RROSwizzlingInfoStore

- (instancetype)init {
    if ((self = [super init])) {
        _swizzleInfos = [NSMutableDictionary new];
        _semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)addSwizzlingInfo:(RROSwizzlingInfo *)info {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    NSMutableDictionary<SwizzlingInfoHash, RROSwizzlingInfo *> * _Nullable store;
    SwizzlingInfoHash key = RROSwizzlingInfoHashKey(info.targetClass, info.swizzled);

    if (!(store = [_swizzleInfos objectForKey:NSStringFromClass(info.targetClass)])) {
        NSMutableDictionary *infos = [NSMutableDictionary dictionaryWithObject:info forKey:key];
        [_swizzleInfos setObject:infos forKey:NSStringFromClass(info.targetClass)];
    } else {
        [store setObject:info forKey:key];
    }
    dispatch_semaphore_signal(_semaphore);
}

- (RROSwizzlingInfo * _Nullable)swizzlingInfosFromClass:(Class)cls forSelector:(SEL)selector {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    SwizzlingInfoHash key = RROSwizzlingInfoHashKey(cls, selector);
    RROSwizzlingInfo * _Nullable info = [[_swizzleInfos objectForKey:NSStringFromClass(cls)] objectForKey:key];
    dispatch_semaphore_signal(_semaphore);
    return info;
}

- (void)enumarateSwizzlingInfosFromClass:(Class)cls block:(void (^)(RROSwizzlingInfo *info))block {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    NSMutableDictionary<SwizzlingInfoHash, RROSwizzlingInfo *> * _Nullable store;
    store = [_swizzleInfos objectForKey:NSStringFromClass(cls)];

    [store enumerateKeysAndObjectsUsingBlock:^(SwizzlingInfoHash _Nonnull key,
                                               RROSwizzlingInfo * _Nonnull obj,
                                               BOOL * _Nonnull stop)
    {
        block(obj);
    }];
    dispatch_semaphore_signal(_semaphore);
}

- (void)removeSwizzlingInfo:(RROSwizzlingInfo *)info {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    NSMutableDictionary<SwizzlingInfoHash, RROSwizzlingInfo *> * _Nullable store;
    SwizzlingInfoHash key = RROSwizzlingInfoHashKey(info.targetClass, info.swizzled);

    if ((store = [_swizzleInfos objectForKey:NSStringFromClass(info.targetClass)])) {
        [store removeObjectForKey:key];
    }
    dispatch_semaphore_signal(_semaphore);
}

- (void)removeAllSwizzlingInfosForClass:(Class)cls {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    [_swizzleInfos removeObjectForKey:NSStringFromClass(cls)];
    dispatch_semaphore_signal(_semaphore);
}

@end
