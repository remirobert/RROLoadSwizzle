//
//  SwizzlingInfo.h
//  Swizzle
//
//  Created by Remi Robert on 2019/04/17.
//  Copyright © 2019 Remi Robert. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * _Nonnull RROSwizzlingInfoHashKey(Class _Nonnull class, SEL _Nonnull selector);

NS_ASSUME_NONNULL_BEGIN

@interface RROSwizzlingInfo: NSObject

@property (nonatomic, assign) Class targetClass;
@property (nonatomic, assign) SEL swizzled;
@property (nonatomic, assign) IMP original;

- (instancetype)initWithTargetClass:(Class)targetClass
                     swizzledMethod:(SEL)swizzled
                  andOriginalMethod:(IMP)original NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
