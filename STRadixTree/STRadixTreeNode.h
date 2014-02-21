//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#import <Foundation/Foundation.h>


@interface STRadixTreeNodeKey : NSObject
- (id)initWithString:(NSString *)string range:(NSRange)range;
@property (nonatomic,copy,readonly) NSString *string;
@property (nonatomic,assign,readonly) NSRange range;
@property (nonatomic,assign,readonly) unichar firstCharacter;
- (BOOL)isEqualToString:(NSString *)string range:(NSRange)range;
- (BOOL)isPrefixOfString:(NSString *)string range:(NSRange)range;
- (BOOL)hasPrefix:(NSString *)string range:(NSRange)range;
- (NSUInteger)lengthOfCommonPrefixWithString:(NSString *)string range:(NSRange)range;
@end

@interface STRadixTreeNode : NSObject
@property (nonatomic,copy,readonly) STRadixTreeNodeKey *key;
@property (nonatomic,copy,readonly) NSArray *children;
@property (nonatomic,copy,readonly) NSSet *objects;
@end

@interface STRadixTreeNode ()
- (id)initWithKey:(NSString *)key range:(NSRange)range;
- (void)addChild:(STRadixTreeNode *)node;
- (void)removeChild:(STRadixTreeNode *)node;
- (void)setChildren:(NSArray *)children;
- (STRadixTreeNode *)childMatchingPrefixOfKey:(NSString *)key range:(NSRange)range;
- (void)addObject:(id)object;
- (void)setObjects:(NSSet *)objects;
@end
