//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#include "STRadixTreeNode.h"


@implementation STRadixTreeNode {
@private
    CFMutableDictionaryRef _children;
    id _objects;
    BOOL _objectsIsSet;
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

- (void)dealloc {
    if (_children) {
        CFRelease(_children);
    }
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

- (BOOL)hasChildren {
    if (!_children) {
        return NO;
    }
    CFIndex const childrenCount = CFDictionaryGetCount(_children);
    return childrenCount != 0;
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


- (NSSet *)objects {
    if (!_objects) {
        return nil;
    }
    if (!_objectsIsSet) {
        id object = _objects;
        _objects = [[NSMutableSet alloc] initWithObjects:object, nil];
        _objectsIsSet = YES;
    }
    return _objects;
}

- (void)addObject:(id)object {
    if (!_objects) {
        _objects = object;
    } else {
        if (_objectsIsSet) {
            [(NSMutableSet *)_objects addObject:object];
        } else {
            id existingObject = _objects;
            _objects = [[NSMutableSet alloc] initWithObjects:existingObject, object, nil];
            _objectsIsSet = YES;
        }
    }
}

- (void)removeObject:(id)object {
    if (_objectsIsSet) {
        [(NSMutableSet *)_objects removeObject:object];
        if (((NSMutableSet *)_objects).count == 0) {
            _objects = nil;
            _objectsIsSet = NO;
        }
    } else if (_objects == object) {
        _objects = nil;
        _objectsIsSet = NO;
    }
    //TODO collapse with parent
}

- (void)setObject:(id)object {
    _objects = object;
    _objectsIsSet = NO;
}
- (void)setObjects:(NSSet *)objects {
    _objects = objects;
    _objectsIsSet = !!objects;
}

@end
