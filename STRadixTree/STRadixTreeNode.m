//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#include "STRadixTreeNode.h"


enum STRadixTreeNodePersonality {
    STRadixTreeNodePersonalityTiny = 0,
    STRadixTreeNodePersonalityNormal = 1,
};

static NSUInteger const STRadixTreeNodePersonalityTinyMaxChildren = 8;

@implementation STRadixTreeNode {
@private
    enum STRadixTreeNodePersonality _personality;
    unichar _tinyChildKeys[STRadixTreeNodePersonalityTinyMaxChildren];
    STRadixTreeNode *_tinyChildren[STRadixTreeNodePersonalityTinyMaxChildren];
    NSMutableDictionary *_normalChildren;
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

- (void)st_transitionToPersonalityNormal {
    NSAssert(_personality == STRadixTreeNodePersonalityTiny, @"");
    NSUInteger const childrenCount = self.childrenCount;
    NSNumber *keys[childrenCount];
    for (NSUInteger i = 0; i < childrenCount; ++i) {
        keys[i] = @(_tinyChildKeys[i]);
    }
    _normalChildren = [[NSMutableDictionary alloc] initWithObjects:_tinyChildren forKeys:keys count:childrenCount];
    _personality = STRadixTreeNodePersonalityNormal;
}

- (void)addChild:(STRadixTreeNode *)node {
    NSParameterAssert(node.key.length);
    switch (_personality) {
        case STRadixTreeNodePersonalityTiny:
            return [self st_tiny_addChild:node];
        case STRadixTreeNodePersonalityNormal:
            return [self st_normal_addChild:node];
    }
}
- (void)st_tiny_addChild:(STRadixTreeNode *)node {
    NSUInteger const childrenCount = self.childrenCount;
    if (childrenCount == STRadixTreeNodePersonalityTinyMaxChildren) {
        [self st_transitionToPersonalityNormal];
        [self st_normal_addChild:node];
        return;
    }
    NSString * const nodeKey = node.key;
    unichar const nodeKeyFirstCharacter = [nodeKey characterAtIndex:0];
    _tinyChildKeys[childrenCount] = nodeKeyFirstCharacter;
    _tinyChildren[childrenCount] = node;
}
- (void)st_normal_addChild:(STRadixTreeNode *)node {
    NSString * const nodeKey = node.key;
    unichar const nodeKeyFirstCharacter = [nodeKey characterAtIndex:0];
    _normalChildren[@(nodeKeyFirstCharacter)] = node;
}


- (void)removeChild:(STRadixTreeNode *)node {
    switch (_personality) {
        case STRadixTreeNodePersonalityTiny:
            return [self st_tiny_removeChild:node];
        case STRadixTreeNodePersonalityNormal:
            return [self st_normal_removeChild:node];
    }
}
- (void)st_tiny_removeChild:(STRadixTreeNode *)node {
    NSString * const nodeKey = node.key;
    unichar const nodeKeyFirstCharacter = [nodeKey characterAtIndex:0];
    BOOL found = NO;
    NSUInteger foundIndex = 0; // analyzer has a false-positive on the first use below if uninitialized
    for (NSUInteger i = 0; i < STRadixTreeNodePersonalityTinyMaxChildren; ++i) {
        if (_tinyChildren[i] == nil) {
            if (i > 0 && found) {
                NSUInteger const lastIndex = i - 1;
                _tinyChildKeys[foundIndex] = _tinyChildKeys[lastIndex];
                _tinyChildren[foundIndex] = _tinyChildren[lastIndex];
                _tinyChildKeys[lastIndex] = '\0';
                _tinyChildren[lastIndex] = nil;
            }
            return;
        }
        if (_tinyChildKeys[i] == nodeKeyFirstCharacter) {
            foundIndex = i;
            found = YES;
            _tinyChildKeys[i] = '\0';
            _tinyChildren[i] = nil;
        }
    }
}
- (void)st_normal_removeChild:(STRadixTreeNode *)node {
    NSString * const nodeKey = node.key;
    unichar const nodeKeyFirstCharacter = [nodeKey characterAtIndex:0];
    STRadixTreeNode * const found = _normalChildren[@(nodeKeyFirstCharacter)];
    if (found == node) {
        [_normalChildren removeObjectForKey:@(nodeKeyFirstCharacter)];
    }
}

- (NSUInteger)childrenCount {
    switch (_personality) {
        case STRadixTreeNodePersonalityTiny:
            return [self st_tiny_childrenCount];
        case STRadixTreeNodePersonalityNormal:
            return [self st_normal_childrenCount];
    }
}
- (NSUInteger)st_tiny_childrenCount {
    NSUInteger childrenCount = 0;
    for (unsigned int i = 0; i < STRadixTreeNodePersonalityTinyMaxChildren; ++i) {
        if (_tinyChildren[i]) {
            childrenCount += 1;
        }
    }
    return childrenCount;
}
- (NSUInteger)st_normal_childrenCount {
    return _normalChildren.count;
}

- (NSArray *)children {
    switch (_personality) {
        case STRadixTreeNodePersonalityTiny:
            return [self st_tiny_children];
        case STRadixTreeNodePersonalityNormal:
            return [self st_normal_children];
    }
}
- (NSArray *)st_tiny_children {
    NSUInteger childrenCount = 0;
    for (unsigned int i = 0; i < sizeof(_tinyChildren)/sizeof(_tinyChildren[0]); ++i) {
        if (_tinyChildren[i]) {
            childrenCount += 1;
        }
    }
    return [[NSArray alloc] initWithObjects:_tinyChildren count:childrenCount];
}
- (NSArray *)st_normal_children {
    NSMutableArray * const children = [[NSMutableArray alloc] initWithCapacity:_normalChildren.count];
    [_normalChildren enumerateKeysAndObjectsUsingBlock:^(id key, STRadixTreeNode *child, BOOL *stop) {
        [children addObject:child];
    }];
    return children;
}

- (void)setChildren:(NSArray *)children {
    for (STRadixTreeNode *child in children) {
        [self addChild:child];
    }
}

- (STRadixTreeNode *)childMatchingPrefixOfKey:(NSString *)key {
    NSParameterAssert(key.length);
    switch (_personality) {
        case STRadixTreeNodePersonalityTiny:
            return [self st_tiny_childMatchingPrefixOfKey:key];
        case STRadixTreeNodePersonalityNormal:
            return [self st_normal_childMatchingPrefixOfKey:key];
    }
}
- (STRadixTreeNode *)st_tiny_childMatchingPrefixOfKey:(NSString *)key {
    unichar const keyFirstCharacter = [key characterAtIndex:0];
    for (NSUInteger i = 0; i < STRadixTreeNodePersonalityTinyMaxChildren; ++i) {
        STRadixTreeNode * const candidateChild = _tinyChildren[i];
        if (candidateChild) {
            return nil;
        }
        if (_tinyChildKeys[i] == keyFirstCharacter) {
            return candidateChild;
        }
    }
    return nil;
}
- (STRadixTreeNode *)st_normal_childMatchingPrefixOfKey:(NSString *)key {
    unichar const keyFirstCharacter = [key characterAtIndex:0];
    STRadixTreeNode * const found = _normalChildren[@(keyFirstCharacter)];
    return found;
}

- (void)addObject:(id)object {
    [_objects addObject:object];
}

- (void)setObjects:(NSSet *)objects {
    [_objects setSet:objects];
}

@end
