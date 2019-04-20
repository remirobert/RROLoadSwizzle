//
//  SwizzlingInfoStoreTests.m
//  SwizzlingInfoStoreTests
//
//  Created by Remi Robert on 2019/04/18.
//  Copyright © 2019 Remi Robert. All rights reserved.
//

#import "RROSwizzlingInfo.h"
#import "RROSwizzlingInfoStore.h"

@import XCTest;

void (*gOrig1)(id, SEL);

@interface SwizzlingInfoStoreTests : XCTestCase

@property (nonatomic, strong) RROSwizzlingInfoStore *store;

@end

@implementation SwizzlingInfoStoreTests

- (void)setUp {
    _store = [[RROSwizzlingInfoStore alloc] init];
}

- (void)testEmptyStore {
    Class testCls = [XCTestCase class];
    SEL testSelector = @selector(setUp);

    XCTAssertNil([_store swizzlingInfosFromClass:testCls forSelector:testSelector]);

    NSMutableArray<RROSwizzlingInfo *> *infos = [[NSMutableArray alloc] init];
    [_store enumarateSwizzlingInfosFromClass:testCls block:^(RROSwizzlingInfo * _Nonnull info) {
        [infos addObject:info];
    }];
    XCTAssertTrue([infos count] == 0);
}

- (void)testAddSwizzlingInfoToTheStore {
    Class testCls = [XCTestCase class];

    RROSwizzlingInfo *info1 = [[RROSwizzlingInfo alloc] initWithTargetClass:testCls
                                                             swizzledMethod:@selector(setUp)
                                                          andOriginalMethod:*(void (**)(void))(&gOrig1)];
    RROSwizzlingInfo *info2 = [[RROSwizzlingInfo alloc] initWithTargetClass:testCls
                                                             swizzledMethod:@selector(tearDown)
                                                          andOriginalMethod:*(void (**)(void))(&gOrig1)];

    [_store addSwizzlingInfo:info1];
    [_store addSwizzlingInfo:info2];

    [self _assertSwizzlingInfoEnumerationForClass:testCls
                                          equalTo:@[info1, info2]
                                           inFile:@__FILE__
                                           atLine:__LINE__];

    XCTAssertEqual([_store swizzlingInfosFromClass:testCls forSelector:@selector(setUp)], info1);
    XCTAssertEqual([_store swizzlingInfosFromClass:testCls forSelector:@selector(tearDown)], info2);
}

- (void)testRemoveSwizzlingInfoFromTheStore {
    Class testCls1 = [XCTestCase class];
    Class testCls2 = [NSDictionary class];

    RROSwizzlingInfo *info1 = [[RROSwizzlingInfo alloc] initWithTargetClass:testCls1
                                                             swizzledMethod:@selector(setUp)
                                                          andOriginalMethod:*(void (**)(void))(&gOrig1)];
    RROSwizzlingInfo *info2 = [[RROSwizzlingInfo alloc] initWithTargetClass:testCls1
                                                             swizzledMethod:@selector(tearDown)
                                                          andOriginalMethod:*(void (**)(void))(&gOrig1)];
    RROSwizzlingInfo *info3 = [[RROSwizzlingInfo alloc] initWithTargetClass:testCls2
                                                             swizzledMethod:@selector(keyEnumerator)
                                                          andOriginalMethod:*(void (**)(void))(&gOrig1)];

    [_store addSwizzlingInfo:info1];
    [_store addSwizzlingInfo:info2];
    [_store addSwizzlingInfo:info3];

    [self _assertSwizzlingInfoEnumerationForClass:testCls1
                                          equalTo:@[info1, info2]
                                           inFile:@__FILE__
                                           atLine:__LINE__];

    [self _assertSwizzlingInfoEnumerationForClass:testCls2
                                          equalTo:@[info3]
                                           inFile:@__FILE__
                                           atLine:__LINE__];

    [_store removeSwizzlingInfo:info1];

    XCTAssertNil([_store swizzlingInfosFromClass:testCls1 forSelector:@selector(setUp)]);
    XCTAssertEqual([_store swizzlingInfosFromClass:testCls1 forSelector:@selector(tearDown)], info2);
    XCTAssertEqual([_store swizzlingInfosFromClass:testCls2 forSelector:@selector(keyEnumerator)], info3);

    [_store removeSwizzlingInfo:info2];
    XCTAssertNil([_store swizzlingInfosFromClass:testCls1 forSelector:@selector(tearDown)]);
    XCTAssertEqual([_store swizzlingInfosFromClass:testCls2 forSelector:@selector(keyEnumerator)], info3);

    [_store removeSwizzlingInfo:info3];
    XCTAssertNil([_store swizzlingInfosFromClass:testCls2 forSelector:@selector(keyEnumerator)]);
}

- (void)testRemoveAllSwizzlingInfoFromTheStore {
    Class testCls1 = [XCTestCase class];
    Class testCls2 = [NSDictionary class];

    RROSwizzlingInfo *info1 = [[RROSwizzlingInfo alloc] initWithTargetClass:testCls1
                                                             swizzledMethod:@selector(setUp)
                                                          andOriginalMethod:*(void (**)(void))(&gOrig1)];
    RROSwizzlingInfo *info2 = [[RROSwizzlingInfo alloc] initWithTargetClass:testCls1
                                                             swizzledMethod:@selector(tearDown)
                                                          andOriginalMethod:*(void (**)(void))(&gOrig1)];
    RROSwizzlingInfo *info3 = [[RROSwizzlingInfo alloc] initWithTargetClass:testCls2
                                                             swizzledMethod:@selector(keyEnumerator)
                                                          andOriginalMethod:*(void (**)(void))(&gOrig1)];

    [_store addSwizzlingInfo:info1];
    [_store addSwizzlingInfo:info2];
    [_store addSwizzlingInfo:info3];

    [_store removeAllSwizzlingInfosForClass:testCls1];

    XCTAssertNil([_store swizzlingInfosFromClass:testCls1 forSelector:@selector(setUp)]);
    XCTAssertNil([_store swizzlingInfosFromClass:testCls1 forSelector:@selector(tearDown)]);
    XCTAssertEqual([_store swizzlingInfosFromClass:testCls2 forSelector:@selector(keyEnumerator)], info3);

    [_store removeAllSwizzlingInfosForClass:testCls2];
    XCTAssertNil([_store swizzlingInfosFromClass:testCls2 forSelector:@selector(keyEnumerator)]);
}

- (void)_assertSwizzlingInfoEnumerationForClass:(Class)cls
                                        equalTo:(NSArray<RROSwizzlingInfo *> *)expected
                                         inFile:(NSString *)inFile
                                         atLine:(NSInteger)atLine {
    [_store enumarateSwizzlingInfosFromClass:cls block:^(RROSwizzlingInfo * _Nonnull info) {
        if (![expected containsObject:info]) {
            [self recordFailureWithDescription:@"assert SwizzlingInfo enumeration"
                                        inFile:inFile
                                        atLine:atLine
                                      expected:YES];
            XCTFail();
        }
    }];
}

@end
