//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#include "STRadixTreeNode.h"

@implementation STRadixTreeNodeKey {
@private
    NSString *_string;
    NSRange _range;
}
- (id)initWithString:(NSString *)string range:(NSRange)range {
    if ((self = [super init])) {
        _string = string.copy;
        _range = range;
        if (_range.length > 0) {
            [_string getCharacters:&_firstCharacter range:(NSRange){ .location = _range.location, .length = 1 }];
        }
    }
    return self;
}
- (BOOL)isEqualToString:(NSString *)string range:(NSRange)range {
    if (range.length != _range.length) {
        return NO;
    }
    NSUInteger const length = _range.length;
    unichar subchars[length];
    [_string getCharacters:subchars range:_range];
    NSString * const compare = [[NSString alloc] initWithCharactersNoCopy:subchars length:length freeWhenDone:NO];
    return [string compare:compare options:NSLiteralSearch range:range] == NSOrderedSame;
}
- (BOOL)isPrefixOfString:(NSString *)string range:(NSRange)range {
    if (range.length < _range.length) {
        return NO;
    }
    NSUInteger const length = _range.length;
    unichar subchars[length];
    [_string getCharacters:subchars range:_range];
    NSString * const compare = [[NSString alloc] initWithCharactersNoCopy:subchars length:length freeWhenDone:NO];
    return [string compare:compare options:NSLiteralSearch range:(NSRange){ .location = range.location, .length = length }] == NSOrderedSame;
}
- (BOOL)hasPrefix:(NSString *)string range:(NSRange)range {
    if (range.length > _range.length) {
        return NO;
    }
    NSUInteger const length = _range.length;
    unichar subchars[length];
    [_string getCharacters:subchars range:_range];
    NSString * const compare = [[NSString alloc] initWithCharactersNoCopy:subchars length:length freeWhenDone:NO];
    return [string compare:compare options:NSLiteralSearch range:(NSRange){ .location = range.location, .length = _range.length }] == NSOrderedSame;
}
- (NSUInteger)lengthOfCommonPrefixWithString:(NSString *)string range:(NSRange)range {
    if (range.length == 0) {
        return 0;
    }
    NSUInteger const length = _range.length;
    unichar subchars[length];
    [_string getCharacters:subchars range:_range];
    NSString * const compare = [[NSString alloc] initWithCharactersNoCopy:subchars length:length freeWhenDone:NO];
    NSString * const compareb = [string substringWithRange:range];
    return [compare commonPrefixWithString:compareb options:NSLiteralSearch].length;
}
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p %@[%lu:%lu] (%@)>", NSStringFromClass(self.class), self, _string, _range.location, NSMaxRange(_range), [_string substringWithRange:_range]];
}
@end


@implementation STRadixTreeNode {
@private
    STRadixTreeNodeKey *_key;
    CFMutableDictionaryRef _children;
    id _objects;
    BOOL _objectsIsSet;
}

- (id)init {
    return [self doesNotRecognizeSelector:_cmd], nil;
}
- (id)initWithKey:(NSString *)key range:(NSRange)range {
    if ((self = [super init])) {
        _key = [[STRadixTreeNodeKey alloc] initWithString:key range:range];
    }
    return self;
}

- (void)dealloc {
    if (_children) {
        CFRelease(_children);
    }
}


- (void)addChild:(STRadixTreeNode *)node {
    NSParameterAssert(node.key.range.length);
    CFMutableDictionaryRef const children = self.st_children;
    unichar const nodeKeyFirstCharacter = node.key.firstCharacter;
    void const * const key = (void *)(uintptr_t)nodeKeyFirstCharacter;
    CFDictionarySetValue(children, key, (__bridge const void *)node);
}

- (void)removeChild:(STRadixTreeNode *)node {
    unichar const nodeKeyFirstCharacter = node.key.firstCharacter;
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

- (STRadixTreeNode *)childMatchingPrefixOfKey:(NSString *)nodeKey range:(NSRange)range {
    NSParameterAssert(nodeKey.length);
    if (_children) {
        unichar const nodeKeyFirstCharacter = [nodeKey characterAtIndex:range.location];
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

- (void)setObjects:(NSSet *)objects {
    if (_objects && _objectsIsSet) {
        [(NSMutableSet *)_objects setSet:objects];
    } else {
        id existingObject = _objects;
        _objects = [[NSMutableSet alloc] initWithObjects:existingObject, nil];
        _objectsIsSet = YES;
        [_objects unionSet:objects];
    }
}

@end
