//
//  NSObject+RROLoadSwizzle.h
//  Swizzle
//
//  Created by Remi Robert on 2019/04/15.
//  Copyright © 2019 Remi Robert. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef IMP _Nonnull *IMPPointer;

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (RROLoadSwizzle)

/**
 Exchange the method selector implementation with another one.

 NSString * (*gOriginalImplementation)(id, SEL);

 static NSString * customCapitalizedString(NSString *self, SEL _cmd) {
    return gOriginalImplementation(self, _cmd);
 }

 [NSString rro_swizzleMethod:@selector(capitalizedString)
          withImplementation:(IMP)customCapitalizedString
             originalPointer:(void (**)(void))(&gOriginalImplementation)];

 @param selector The selector to swizzle.
 @param impl The function pointer which will replace the implementation.
 @param originalPointer The function pointer which will be setted to the original implementation.
 */
+ (void)rro_swizzleMethod:(SEL)selector withImplementation:(IMP)impl originalPointer:(IMPPointer _Nonnull)originalPointer;

/**
 Exchange the method selector implementation with a block.

 NSString * (*gOriginalImplementation)(id, SEL);

 NSString * (^customCapitalizedStringBlock)(Counter *, SEL) = ^NSString * (Counter *counter, SEL _cmd) {
    return gOriginalImplementation(self, _cmd);
 };

 [NSString rro_swizzleMethod:@selector(capitalizedString)
                       block:(id)customCapitalizedStringBlock
             originalPointer:(void (**)(void))(&gOriginalImplementation)];

 @param selector The selector to swizzle.
 @param block The block which will replace the implementation.
 @param originalPointer The function pointer which will be setted to the original implementation.
 */
+ (void)rro_swizzleMethod:(SEL)selector block:(id _Nonnull)block originalPointer:(IMPPointer _Nonnull)originalPointer;

/**
 Revert the method selector implementation to the original one.

 @param selector The selector to revert to the original implementation.
 */
+ (void)rro_revertSwizzleMethod:(SEL)selector;

/**
 Revert all the method selector implementation to the original.
 */
+ (void)rro_revertAllSwizzledMethod;

@end

NS_ASSUME_NONNULL_END

#define RRO_SWIZZLE_METHOD(theClass, theSelector, IMPFuncName, IMPPointerName) \
[theClass rro_swizzleMethod:theSelector withImplementation:(IMP)IMPFuncName originalPointer:(void (**)(void))(IMPPointerName)];

#define RRO_SWIZZLE_BLOCK(theClass, theSelector, b, IMPPointerName) \
[theClass rro_swizzleMethod:theSelector block:b originalPointer:(void (**)(void))(IMPPointerName)];

#define RRO_REVERT_SWIZZLE_METHOD(theClass, theSelector) \
[theClass rro_revertSwizzleMethod:theSelector];

#define RRO_REVERT_SWIZZLE_ALL_METHOD(theClass) \
[theClass rro_revertAllSwizzledMethod];
