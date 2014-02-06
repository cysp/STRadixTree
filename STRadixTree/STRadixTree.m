//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013-2014 Scott Talbot.

#import "STRadixTree.h"
#import "STRadixTreeNode.h"


@implementation STRadixTree {
@private
    STRadixTreeNode *_root;
}

+ (void)addObjectsUnderNode:(STRadixTreeNode *)node toSet:(NSMutableSet *)set {
    for (id object in node.objects) {
        [set addObject:object];
    }
    for (STRadixTreeNode *child in node.children) {
        [self addObjectsUnderNode:child toSet:set];
    }
}


- (id)init {
    if ((self = [super init])) {
        _root = [[STRadixTreeNode alloc] initWithKey:@""];
    }
    return self;
}


- (void)addObject:(id)object forKey:(NSString *)key {
    NSParameterAssert(key.length);
    STRadixTreeNode *node = [self nodeForKey:key createIfNecessary:YES];
    [node addObject:object];
}

- (void)removeAllObjects {
    [_root setChildren:@[]];
}


- (NSString *)debugDescription {
    NSMutableString *s = [NSMutableString stringWithFormat:@"<%@:%p {\n", NSStringFromClass(self.class), self];
    for (STRadixTreeNode *node in _root.children) {
        [self debugDescription_appendNode:node toString:s atDepth:1];
    }
    [s appendString:@"}"];
    return s;
}
- (void)debugDescription_appendNode:(STRadixTreeNode *)node toString:(NSMutableString *)string atDepth:(NSUInteger)depth {
    NSMutableString *prefix = [NSMutableString string];
    for (NSUInteger i = 0; i < depth; ++i) {
        [prefix appendString:@"\t"];
    }
    [string appendFormat:@"%@\"%@\" = {\n", prefix, node.key];
    for (STRadixTreeNode *child in node.children) {
        [self debugDescription_appendNode:child toString:string atDepth:depth + 1];
    }
    [string appendFormat:@"%@}", prefix];
    NSArray * const nodeObjectsDescriptionLines = [node.objects.description componentsSeparatedByString:@"\n"];
    [nodeObjectsDescriptionLines enumerateObjectsUsingBlock:^(NSString *line, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            [string appendString:@" -> "];
        } else {
            [string appendString:prefix];
        }
        [string appendString:line];
        if (idx != nodeObjectsDescriptionLines.count - 1) {
            [string appendString:@"\n"];
        }
    }];
    [string appendFormat:@",\n"];
}


- (NSSet *)objectsForKey:(NSString *)key {
    STRadixTreeNode *node = [self nodeForKey:key];
    return node.objects.copy;
}

- (NSSet *)objectsForKeyPrefix:(NSString *)prefix {
    return [self objectsForKeyPrefix:prefix unambiguousCompletion:NULL];
}
- (NSSet *)objectsForKeyPrefix:(NSString *)prefix unambiguousCompletion:(NSString *__autoreleasing *)unambiguousCompletion {
    NSMutableSet *set = [[NSMutableSet alloc] init];
    STRadixTreeNode *node = [self nodeForKeyPrefix:prefix unambiguousCompletion:unambiguousCompletion];
    [self.class addObjectsUnderNode:node toSet:set];
    return set.copy;
}

- (STRadixTreeNode *)nodeForKey:(NSString *)key {
    return [self nodeForKey:key createIfNecessary:NO];
}

- (STRadixTreeNode *)nodeForKey:(NSString *)key createIfNecessary:(BOOL)create {
    if (key.length == 0) {
        return _root;
    }

    STRadixTreeNode *node = _root;
    NSMutableString *remainingKey = key.mutableCopy;

    STRadixTreeNode *parentNode;
lookupAgain:;
    {
        STRadixTreeNode *child = [node childMatchingPrefixOfKey:remainingKey];
        if (child) {
            NSString * const childKey = child.key;
            if ([remainingKey isEqualToString:childKey]) {
                return child;
            }
            if ([remainingKey hasPrefix:childKey]) {
                [remainingKey deleteCharactersInRange:(NSRange){ .length = childKey.length }];
                node = child;
                goto lookupAgain;
            }
        }
        parentNode = node;
        node = child;
    }

    if (!create) {
        if (remainingKey.length > 0) {
            return nil;
        }
        return node;
    }

    if (!parentNode) {
        parentNode = _root;
    }

    if (!node || node == _root) {
        node = [[STRadixTreeNode alloc] initWithKey:remainingKey];
        [parentNode addChild:node];
    } else if (remainingKey.length == 0) {
        NSAssert(0, @"unexpected");
    } else {
        STRadixTreeNode *oldNode = node;
        NSString * const oldNodeKey = node.key;
        NSString * const commonPrefix = [remainingKey commonPrefixWithString:oldNodeKey options:NSLiteralSearch|NSAnchoredSearch];
        NSString * const newNodeSuffix = [remainingKey substringFromIndex:commonPrefix.length];
        if (commonPrefix.length == 0) {
            STRadixTreeNode *newNode = [[STRadixTreeNode alloc] initWithKey:newNodeSuffix];
            [node addChild:newNode];
            node = newNode;
        } else {
            NSString * const oldNodeSuffix = [oldNodeKey substringFromIndex:commonPrefix.length];

            STRadixTreeNode *intermediary = [[STRadixTreeNode alloc] initWithKey:commonPrefix];
            [parentNode addChild:intermediary];
            [parentNode removeChild:oldNode];

            if (oldNodeSuffix.length == 0) {
                [intermediary setChildren:oldNode.children];
                [intermediary setObjects:oldNode.objects];
            } else {
                STRadixTreeNode *replacement = [[STRadixTreeNode alloc] initWithKey:oldNodeSuffix];
                [replacement setChildren:oldNode.children];
                [replacement setObjects:oldNode.objects];
                [intermediary addChild:replacement];
            }

            if (newNodeSuffix.length == 0) {
                node = intermediary;
            } else {
                node = [[STRadixTreeNode alloc] initWithKey:newNodeSuffix];
                [intermediary addChild:node];
            }
        }
    }
    return node;
}

- (STRadixTreeNode *)nodeForKeyPrefix:(NSString *)prefix {
    return [self nodeForKeyPrefix:prefix unambiguousCompletion:NULL];
}
- (STRadixTreeNode *)nodeForKeyPrefix:(NSString *)prefix unambiguousCompletion:(NSString * __autoreleasing *)unambiguousCompletion {
    if (prefix.length == 0) {
        return _root;
    }

    STRadixTreeNode *node = _root;
    NSMutableString *remainingKey = prefix.mutableCopy;

lookupAgain:;
    STRadixTreeNode *child = [node childMatchingPrefixOfKey:remainingKey];
    if (child) {
        NSString * const childKey = child.key;
        if ([remainingKey isEqualToString:childKey]) {
            return child;
        }
        if ([remainingKey hasPrefix:childKey]) {
            [remainingKey deleteCharactersInRange:(NSRange){ .length = childKey.length }];
            node = child;
            goto lookupAgain;
        }
    }
    if ([child.key hasPrefix:remainingKey]) {
        if (unambiguousCompletion) {
            *unambiguousCompletion = [child.key substringFromIndex:remainingKey.length];
        }
    }
    return child;
}

@end
