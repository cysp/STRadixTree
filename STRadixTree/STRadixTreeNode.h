//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#import <Foundation/Foundation.h>


@interface STRadixTreeNode : NSObject

- (id __null_unspecified)init NS_UNAVAILABLE;
- (id __nonnull)initWithKey:(NSString * __nonnull)key NS_DESIGNATED_INITIALIZER;

@property (nonatomic,copy,nonnull,readonly) NSString *key;

@property (nonatomic,copy,null_resettable) NSArray *children;
- (void)addChild:(STRadixTreeNode * __nonnull)node;
- (void)removeChild:(STRadixTreeNode * __nonnull)node;
- (STRadixTreeNode * __nullable)childMatchingPrefixOfKey:(NSString * __nonnull)key;

@property (nonatomic,copy,nullable,readonly) NSSet *objects;
- (void)addObject:(id __nonnull)object;
- (void)removeObject:(id __nonnull)object;
- (void)setObject:(id __nullable)object;
- (void)setObjects:(NSSet * __nullable)objects;

@end
