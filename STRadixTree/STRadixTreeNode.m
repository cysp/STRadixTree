//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#include "STRadixTreeNode.h"


static NSComparator const STRadixTreeNodeKeyComparator = ^(STRadixTreeNode *a, STRadixTreeNode *b) {
    return [a.key compare:b.key];
};
static NSComparator const STRadixTreeNodeKeyFirstCharacterComparator = ^(NSString *a, NSString *b) {
    if ([a isKindOfClass:[STRadixTreeNode class]]) {
        a = ((STRadixTreeNode *)a).key;
    }
    if ([b isKindOfClass:[STRadixTreeNode class]]) {
        b = ((STRadixTreeNode *)b).key;
    }
    unichar aFirstCharacter = 0;
    if (a.length) {
        aFirstCharacter = [a characterAtIndex:0];
    }
    unichar bFirstCharacter = 0;
    if (b.length) {
        bFirstCharacter = [b characterAtIndex:0];
    }
    if (aFirstCharacter > bFirstCharacter) {
        return NSOrderedDescending;
    }
    if (aFirstCharacter < bFirstCharacter) {
        return NSOrderedAscending;
    }
    return NSOrderedSame;
};


@implementation STRadixTreeNode {
@private
    NSMutableArray *_children;
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
    NSMutableArray * const children = self.st_children;
    NSUInteger const insertionIndex = [children indexOfObject:node inSortedRange:(NSRange){ .length = children.count } options:NSBinarySearchingInsertionIndex usingComparator:STRadixTreeNodeKeyComparator];
    [children insertObject:node atIndex:insertionIndex];
}

- (void)removeChild:(STRadixTreeNode *)node {
    [_children removeObject:node];
}

- (NSMutableArray *)st_children {
    if (!_children) {
        _children = [[NSMutableArray alloc] init];
    }
    return _children;
}
- (void)setChildren:(NSArray *)children {
    [self.st_children setArray:children];
}

- (STRadixTreeNode *)childMatchingPrefixOfKey:(NSString *)key {
    NSParameterAssert(key.length);
    NSMutableArray * const children = self.st_children;
    if (!children) {
        return nil;
    }
    NSUInteger const index = [children indexOfObject:key inSortedRange:(NSRange){ .length = children.count } options:0 usingComparator:STRadixTreeNodeKeyFirstCharacterComparator];
    if (index != NSNotFound) {
        return children[index];
    }
    return nil;
}

- (void)addObject:(id)object {
    [_objects addObject:object];
}

- (void)setObjects:(NSSet *)objects {
    [_objects setSet:objects];
}

@end
