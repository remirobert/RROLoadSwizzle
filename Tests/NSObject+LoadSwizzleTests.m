//
//  NSObject+LoadSwizzleTests.m
//  Tests
//
//  Created by Remi Robert on 2019/04/19.
//  Copyright © 2019 Remi Robert. All rights reserved.
//

#import "RROSwizzlingInfo.h"
#import "RROSwizzlingInfoStore.h"
#import "NSObject+RROLoadSwizzle.h"
#import "Counter.h"

NSInteger (*gOriginalInstanceMethodPointer)(id, SEL, NSInteger);
NSString * (*gOriginalClassMethodPointer)(id, SEL);

@import XCTest;

@interface NSObject_LoadSwizzleTests : XCTestCase

@property (nonatomic, strong) Counter *counter;

@end

@implementation NSObject_LoadSwizzleTests

- (void)setUp {
    _counter = [[Counter alloc] init];
    gOriginalInstanceMethodPointer = nil;
}

- (void)tearDown {
    RRO_REVERT_SWIZZLE_ALL_METHOD([Counter class]);
}

- (void)testSwizzleInstanceMethodWithBlock {
    __block NSInteger originalValue;

    NSInteger (^printBlock)(Counter *, SEL, NSInteger) = ^NSInteger (Counter *counter, SEL _cmd, NSInteger number) {
        originalValue = gOriginalInstanceMethodPointer(counter, _cmd, number);
        return number;
    };

    RRO_SWIZZLE_BLOCK([Counter class], @selector(incrementNumber:), printBlock, &gOriginalInstanceMethodPointer);

    XCTAssertEqual([_counter incrementNumber:10], 10);
    XCTAssertEqual(originalValue, 11);

    RRO_REVERT_SWIZZLE_METHOD([Counter class], @selector(incrementNumber:));

    XCTAssertEqual([_counter incrementNumber:10], 11);
}

- (void)testSwizzleClassMethodWithBlock {
    XCTAssertTrue([[Counter manage] isEqualToString:NSStringFromClass([Counter class])]);

    __block NSString * originalValue;

    NSString * (^classNameBlock)(Counter *, SEL) = ^NSString * (Counter *counter, SEL _cmd) {
        originalValue = gOriginalClassMethodPointer(counter, _cmd);
        return NSStringFromClass([XCTestCase class]);
    };

    RRO_SWIZZLE_BLOCK([Counter class], @selector(manage), classNameBlock, &gOriginalClassMethodPointer);

    XCTAssertTrue([[Counter manage] isEqualToString:NSStringFromClass([XCTestCase class])]);
    XCTAssertTrue([originalValue isEqualToString:NSStringFromClass([Counter class])]);

    RRO_REVERT_SWIZZLE_METHOD([Counter class], @selector(manage));

    XCTAssertTrue([[Counter manage] isEqualToString:NSStringFromClass([Counter class])]);
}

static NSString * customManage(Counter *self, SEL _cmd) {
    return NSStringFromClass([XCTestCase class]);
}

- (void)testSwizzleClassMethodWithFunction {
    XCTAssertTrue([[Counter manage] isEqualToString:NSStringFromClass([Counter class])]);

    RRO_SWIZZLE_METHOD([Counter class], @selector(manage), customManage, &gOriginalClassMethodPointer);

    XCTAssertTrue([[Counter manage] isEqualToString:NSStringFromClass([XCTestCase class])]);
    XCTAssertTrue([gOriginalClassMethodPointer(_counter, @selector(manage)) isEqualToString:NSStringFromClass([Counter class])]);

    RRO_REVERT_SWIZZLE_METHOD([Counter class], @selector(manage));

    XCTAssertTrue([[Counter manage] isEqualToString:NSStringFromClass([Counter class])]);
}

static NSInteger customIncrementer(Counter *self, SEL _cmd, NSInteger number) {
    return number + 2;
}

- (void)testSwizzleInstanceMethodWithFunction {
    XCTAssertEqual([_counter incrementNumber:10], 11);

    RRO_SWIZZLE_METHOD([Counter class], @selector(incrementNumber:), customIncrementer, &gOriginalInstanceMethodPointer);

    XCTAssertEqual([_counter incrementNumber:10], 12);
    XCTAssertEqual(gOriginalInstanceMethodPointer(_counter, @selector(incrementNumber:), 10), 11);

    RRO_REVERT_SWIZZLE_METHOD([Counter class], @selector(incrementNumber:));

    XCTAssertEqual([_counter incrementNumber:10], 11);
}

- (void)testRevertAllSwizzlingForTheClass {
    RRO_SWIZZLE_METHOD([Counter class], @selector(incrementNumber:), customIncrementer, &gOriginalInstanceMethodPointer);
    RRO_SWIZZLE_METHOD([Counter class], @selector(manage), customManage, &gOriginalClassMethodPointer);

    XCTAssertTrue([[Counter manage] isEqualToString:NSStringFromClass([XCTestCase class])]);
    XCTAssertEqual([_counter incrementNumber:10], 12);

    RRO_REVERT_SWIZZLE_ALL_METHOD([Counter class]);

    XCTAssertTrue([[Counter manage] isEqualToString:NSStringFromClass([Counter class])]);
    XCTAssertEqual([_counter incrementNumber:10], 11);
}

@end
