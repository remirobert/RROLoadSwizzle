//
//  SwizzlingInfoStore.h
//  Swizzle
//
//  Created by Remi Robert on 2019/04/17.
//  Copyright © 2019 Remi Robert. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RROSwizzlingInfo;

NS_ASSUME_NONNULL_BEGIN

@interface RROSwizzlingInfoStore : NSObject

- (void)addSwizzlingInfo:(RROSwizzlingInfo *)info;
- (RROSwizzlingInfo * _Nullable)swizzlingInfosFromClass:(Class)cls forSelector:(SEL)selector;
- (void)enumarateSwizzlingInfosFromClass:(Class)cls block:(void (^)(RROSwizzlingInfo *info))block;
- (void)removeSwizzlingInfo:(RROSwizzlingInfo *)info;
- (void)removeAllSwizzlingInfosForClass:(Class)cls;

@end

NS_ASSUME_NONNULL_END
