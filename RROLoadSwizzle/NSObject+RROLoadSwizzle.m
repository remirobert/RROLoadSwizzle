//
//  NSObject+RROLoadSwizzle.m
//  Swizzle
//
//  Created by Remi Robert on 2019/04/15.
//  Copyright © 2019 Remi Robert. All rights reserved.
//

#import "NSObject+RROLoadSwizzle.h"
#import "RROSwizzlingInfo.h"
#import "RROSwizzlingInfoStore.h"
#import <objc/runtime.h>

static RROSwizzlingInfoStore *swizzleStore;

@implementation NSObject (RROLoadSwizzle)

+ (RROSwizzlingInfoStore *)swizzleStore {
    if (!swizzleStore) {
        swizzleStore = [[RROSwizzlingInfoStore alloc] init];
    }
    return swizzleStore;
}

+ (void)rro_swizzleMethod:(SEL)selector withImplementation:(IMP)impl originalPointer:(IMPPointer _Nonnull)originalPointer {
    Class _Nullable cls = self;
    Method originalMethod = class_getInstanceMethod([self class], selector);

    if (!originalMethod) {
        originalMethod = class_getClassMethod([self class], selector);
        cls = object_getClass([self class]);
    }
    NSAssert(originalMethod, @"Can't swizzle selector \"%@\": no types found for original method for class %@",
             NSStringFromSelector(selector),
             NSStringFromClass([self class]));

    const char * _Nullable methodArgumentsTypes = method_getTypeEncoding(originalMethod);

    if (!class_addMethod(cls, selector, impl, methodArgumentsTypes)) {
        RROSwizzlingInfo * _Nullable alreadySwizzlingSetInfo;

        if ((alreadySwizzlingSetInfo = [[self swizzleStore] swizzlingInfosFromClass:[self class] forSelector:selector])) {
            [self rro_revertSwizzleMethod:selector];
        }
        *originalPointer = method_setImplementation(originalMethod, impl);

        RROSwizzlingInfo *info = [[RROSwizzlingInfo alloc] initWithTargetClass:[self class]
                                                                swizzledMethod:selector
                                                             andOriginalMethod:*originalPointer];
        [[self swizzleStore] addSwizzlingInfo:info];
    }
}

+ (void)rro_swizzleMethod:(SEL)selector block:(id _Nonnull)block originalPointer:(IMPPointer _Nonnull)originalPointer {
    IMP blockImplementation = imp_implementationWithBlock(block);
    [self rro_swizzleMethod:selector withImplementation:blockImplementation originalPointer:originalPointer];
}

+ (void)rro_revertSwizzleMethod:(SEL)selector {
    RROSwizzlingInfo * _Nullable info = [[self swizzleStore] swizzlingInfosFromClass:[self class] forSelector:selector];
    if (!info) {
        return;
    }
    [self _replaceOrioginalImplementationWithSwizzlingInfo:info];
    [[self swizzleStore] removeSwizzlingInfo:info];
}

+ (void)rro_revertAllSwizzledMethod {
    [[self swizzleStore] enumarateSwizzlingInfosFromClass:[self class] block:^(RROSwizzlingInfo * _Nonnull info) {
        [self _replaceOrioginalImplementationWithSwizzlingInfo:info];
    }];
    [[self swizzleStore] removeAllSwizzlingInfosForClass:[self class]];
}

+ (void)_replaceOrioginalImplementationWithSwizzlingInfo:(RROSwizzlingInfo * _Nonnull)info {
    Method originalMethod = class_getInstanceMethod(info.targetClass, info.swizzled);
    if (!originalMethod) {
        originalMethod = class_getClassMethod(info.targetClass, info.swizzled);
    }
    method_setImplementation(originalMethod, info.original);
}

@end
