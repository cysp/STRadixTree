//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#import <Foundation/Foundation.h>


@interface STRadixTreeNode : NSObject
@property (nonatomic,copy,readonly) NSString *key;
@property (nonatomic,copy,readonly) NSArray *children;
@property (nonatomic,copy,readonly) NSSet *objects;
@end

@interface STRadixTreeNode ()
- (id)initWithKey:(NSString *)key;
- (void)addChild:(STRadixTreeNode *)node;
- (void)removeChild:(STRadixTreeNode *)node;
- (void)setChildren:(NSArray *)children;
- (STRadixTreeNode *)childMatchingPrefixOfKey:(NSString *)key;
- (void)addObject:(id)object;
- (void)removeObject:(id)object;
- (void)setObject:(id)object;
- (void)setObjects:(NSSet *)objects;
@end
