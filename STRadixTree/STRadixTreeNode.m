//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#include "STRadixTreeNode.h"


@implementation STRadixTreeNode {
@private
    CFMutableDictionaryRef _children;
    NSMutableSet *_objects;
}

- (id)init {
    return [self doesNotRecognizeSelector:_cmd], nil;
}
- (id)initWithKey:(NSString *)key {
    if ((self = [super init])) {
        _key = [key copy];
    }
    return self;
}

- (void)addChild:(STRadixTreeNode *)node {
    NSParameterAssert(node.key.length);
    CFMutableDictionaryRef const children = self.st_children;
    NSString * const nodeKey = node.key;
    unichar const nodeKeyFirstCharacter = [nodeKey characterAtIndex:0];
    void const * const key = (void *)(uintptr_t)nodeKeyFirstCharacter;
    CFDictionarySetValue(children, key, (__bridge const void *)node);
}

- (void)removeChild:(STRadixTreeNode *)node {
    NSString * const nodeKey = node.key;
    unichar const nodeKeyFirstCharacter = [nodeKey characterAtIndex:0];
    if (_children) {
        void const * const key = (void *)(uintptr_t)nodeKeyFirstCharacter;
        STRadixTreeNode * const found = CFDictionaryGetValue(_children, key);
        if (found == node) {
            CFDictionaryRemoveValue(_children, key);
        }
    }
}

- (CFMutableDictionaryRef)st_children {
    if (!_children) {
        _children = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
    }
    return _children;
}
- (NSArray *)children {
    if (!_children) {
        return @[];
    }
    CFIndex const childrenCount = CFDictionaryGetCount(_children);
    void const *childrenValues[childrenCount];
    CFDictionaryGetKeysAndValues(_children, NULL, childrenValues);
    CFArrayRef const children = CFArrayCreate(NULL, childrenValues, childrenCount, &kCFTypeArrayCallBacks);
    return (__bridge_transfer NSArray *)children;
}
- (void)setChildren:(NSArray *)children {
    if (_children) {
        CFDictionaryRemoveAllValues(_children);
    }
    for (STRadixTreeNode *child in children) {
        [self addChild:child];
    }
}

- (STRadixTreeNode *)childMatchingPrefixOfKey:(NSString *)nodeKey {
    NSParameterAssert(nodeKey.length);
    if (_children) {
        unichar const nodeKeyFirstCharacter = [nodeKey characterAtIndex:0];
        void const * const key = (void *)(uintptr_t)nodeKeyFirstCharacter;
        STRadixTreeNode * const found = CFDictionaryGetValue(_children, key);
        return found;
    }
    return nil;
}

- (NSMutableSet *)st_objects {
    if (!_objects) {
        _objects = [[NSMutableSet alloc] init];
    }
    return _objects;
}

- (void)addObject:(id)object {
    [self.st_objects addObject:object];
}

- (void)setObjects:(NSSet *)objects {
    [self.st_objects setSet:objects];
}

@end
