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
        _root = [[STRadixTreeNode alloc] initWithKey:@"" range:(NSRange){}];
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
    NSRange keyRange = (NSRange){ .length = key.length };

    STRadixTreeNode *parentNode;
lookupAgain:;
    {
        STRadixTreeNode *child = [node childMatchingPrefixOfKey:key range:keyRange];
        if (child) {
            STRadixTreeNodeKey * const childKey = child.key;

            if ([childKey isEqualToString:key range:keyRange]) {
                return child;
            }
            if ([childKey isPrefixOfString:key range:keyRange]) {
                NSUInteger const childKeyLength = childKey.range.length;
                keyRange.location += childKeyLength;
                keyRange.length -= childKeyLength;
                node = child;
                goto lookupAgain;
            }
        }
        parentNode = node;
        node = child;
    }

    if (!create) {
        if (keyRange.length > 0) {
            return nil;
        }
        return node;
    }

    if (!parentNode) {
        parentNode = _root;
    }

    if (!node || node == _root) {
        node = [[STRadixTreeNode alloc] initWithKey:key range:keyRange];
        [parentNode addChild:node];
    } else if (keyRange.length == 0) {
        NSAssert(0, @"unexpected");
    } else {
        STRadixTreeNode *oldNode = node;
        STRadixTreeNodeKey * const oldNodeKey = node.key;
        NSUInteger const commonPrefixLength = [oldNodeKey lengthOfCommonPrefixWithString:key range:keyRange];
        NSUInteger const newNodeSuffixLength = keyRange.length - commonPrefixLength;
        if (commonPrefixLength == 0) {
            STRadixTreeNode *newNode = [[STRadixTreeNode alloc] initWithKey:oldNodeKey.string range:oldNodeKey.range];
            [node addChild:newNode];
            node = newNode;
        } else {
            NSUInteger const oldNodeSuffixLength = oldNodeKey.range.length - commonPrefixLength;

            STRadixTreeNode *intermediary = [[STRadixTreeNode alloc] initWithKey:oldNodeKey.string range:(NSRange){ .location = oldNodeKey.range.location, .length = commonPrefixLength }];
            [parentNode addChild:intermediary];
            [parentNode removeChild:oldNode];

            if (oldNodeSuffixLength == 0) {
                [intermediary setChildren:oldNode.children];
                [intermediary setObjects:oldNode.objects];
            } else {
                STRadixTreeNode *replacement = [[STRadixTreeNode alloc] initWithKey:oldNodeKey.string range:(NSRange){ .location = oldNodeKey.range.location + commonPrefixLength, .length = oldNodeSuffixLength }];
                [replacement setChildren:oldNode.children];
                [replacement setObjects:oldNode.objects];
                [intermediary addChild:replacement];
            }

            if (newNodeSuffixLength == 0) {
                node = intermediary;
            } else {
                node = [[STRadixTreeNode alloc] initWithKey:key range:(NSRange){ .location = keyRange.location + commonPrefixLength, .length = newNodeSuffixLength }];
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
    NSRange prefixRange = (NSRange){ .length = prefix.length };

lookupAgain:;
    STRadixTreeNode *child = [node childMatchingPrefixOfKey:prefix range:prefixRange];
    if (child) {
        STRadixTreeNodeKey * const childKey = child.key;

        if ([childKey isEqualToString:prefix range:prefixRange]) {
            return child;
        }
        if ([childKey isPrefixOfString:prefix range:prefixRange]) {
            NSUInteger const childKeyLength = childKey.range.length;
            prefixRange.location += childKeyLength;
            prefixRange.length -= childKeyLength;
            node = child;
            goto lookupAgain;
        }
    }
    if ([child.key hasPrefix:prefix range:prefixRange]) {
        if (unambiguousCompletion) {
            *unambiguousCompletion = [child.key.string substringFromIndex:NSMaxRange(prefixRange)];
        }
    }
    return child;
}

@end
