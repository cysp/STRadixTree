//  Copyright (c) 2013 Scott Talbot. All rights reserved.

#import <XCTest/XCTest.h>

#import "STRadixTree.h"


@interface STRadixTreeTests : XCTestCase
@end

@implementation STRadixTreeTests

- (void)testCreation {
    STRadixTree *tree = [[STRadixTree alloc] init];

    [tree addObject:@(1) forKey:@"2"];
    [tree addObject:@(2) forKey:@"2000"];
    [tree addObject:@(3) forKey:@"2001"];
    [tree addObject:@(4) forKey:@"2200"];
    [tree addObject:@(5) forKey:@"2233"];
    [tree addObject:@(6) forKey:@"2230"];

    XCTAssertEqualObjects(@(1), [tree objectsForKey:@"2"].anyObject, @"");
    XCTAssertEqualObjects(@(2), [tree objectsForKey:@"2000"].anyObject, @"");
    XCTAssertEqualObjects(@(3), [tree objectsForKey:@"2001"].anyObject, @"");
    XCTAssertEqualObjects(@(4), [tree objectsForKey:@"2200"].anyObject, @"");
    XCTAssertEqualObjects(@(5), [tree objectsForKey:@"2233"].anyObject, @"");

    XCTAssertEqual((NSUInteger)6, [tree objectsForKeyPrefix:@"2"].count, @"");
    XCTAssertEqual((NSUInteger)2, [tree objectsForKeyPrefix:@"20"].count, @"");
    XCTAssertEqual((NSUInteger)3, [tree objectsForKeyPrefix:@"22"].count, @"");

    XCTAssertEqualObjects(@(1), [tree objectsForKey:@"2"].anyObject, @"");
    XCTAssertEqualObjects(@(2), [tree objectsForKeyPrefix:@"2000"].anyObject, @"");
    XCTAssertEqualObjects(@(3), [tree objectsForKeyPrefix:@"2001"].anyObject, @"");
    XCTAssertEqualObjects(@(4), [tree objectsForKeyPrefix:@"2200"].anyObject, @"");
    XCTAssertEqualObjects(@(5), [tree objectsForKeyPrefix:@"2233"].anyObject, @"");

    XCTAssertEqualObjects(([NSSet setWithObjects:@(2), @(3), nil]), [tree objectsForKeyPrefix:@"20"], @"");

    XCTAssertEqualObjects(([NSSet setWithObjects:@(4), @(5), @(6), nil]), [tree objectsForKeyPrefix:@"22"], @"");
}

- (void)testDeletion {
    STRadixTree *tree = [[STRadixTree alloc] init];

    [tree addObject:@(1) forKey:@"a"];
    XCTAssertEqualObjects(@(1), [tree objectsForKey:@"a"].anyObject, @"");

    [tree removeObject:@(1) forKey:@"a"];
    XCTAssertNil([tree objectsForKey:@"a"].anyObject, @"");
}

@end
