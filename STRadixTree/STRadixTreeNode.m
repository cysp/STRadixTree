//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#include "STRadixTreeNode.h"


@implementation STRadixTreeNode {
@private
    NSMutableDictionary *_children;
    NSMutableSet *_objects;
}

- (id)init {
    return [self doesNotRecognizeSelector:_cmd], nil;
}
- (id)initWithKey:(NSString *)key {
    if ((self = [super init])) {
        _key = [key copy];
        _objects = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)addChild:(STRadixTreeNode *)node {
    NSParameterAssert(node.key.length);
    NSMutableDictionary * const children = self.st_children;
    NSString * const nodeKey = node.key;
    unichar const nodeKeyFirstCharacter = [nodeKey characterAtIndex:0];
    children[@(nodeKeyFirstCharacter)] = node;
}

- (void)removeChild:(STRadixTreeNode *)node {
    NSString * const nodeKey = node.key;
    unichar const nodeKeyFirstCharacter = [nodeKey characterAtIndex:0];
    STRadixTreeNode * const found = _children[@(nodeKeyFirstCharacter)];
    if (found == node) {
        [_children removeObjectForKey:@(nodeKeyFirstCharacter)];
    }
}

- (NSMutableDictionary *)st_children {
    if (!_children) {
        _children = [[NSMutableDictionary alloc] init];
    }
    return _children;
}
- (NSArray *)children {
    NSMutableArray * const children = [[NSMutableArray alloc] initWithCapacity:_children.count];
    [_children enumerateKeysAndObjectsUsingBlock:^(id key, STRadixTreeNode *child, BOOL *stop) {
        [children addObject:child];
    }];
    return children;
}
- (void)setChildren:(NSArray *)children {
    [_children removeAllObjects];
    for (STRadixTreeNode *child in children) {
        [self addChild:child];
    }
}

- (STRadixTreeNode *)childMatchingPrefixOfKey:(NSString *)key {
    NSParameterAssert(key.length);
    NSMutableDictionary * const children = self.st_children;
    unichar const keyFirstCharacter = [key characterAtIndex:0];
    STRadixTreeNode * const found = _children[@(keyFirstCharacter)];
    return found;
}

- (void)addObject:(id)object {
    [_objects addObject:object];
}

- (void)setObjects:(NSSet *)objects {
    [_objects setSet:objects];
}

@end
