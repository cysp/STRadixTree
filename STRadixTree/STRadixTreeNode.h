//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#import <Foundation/Foundation.h>


@interface STRadixTreeNode<__covariant ObjectType : NSObject *> : NSObject

- (id __null_unspecified)init NS_UNAVAILABLE;
- (id __nonnull)initWithKey:(NSString * __nonnull)key NS_DESIGNATED_INITIALIZER;

@property (nonatomic,copy,nonnull,readonly) NSString *key;

@property (nonatomic,copy,null_resettable) NSArray<STRadixTreeNode<ObjectType> *> *children;
- (void)addChild:(STRadixTreeNode<ObjectType> * __nonnull)node;
- (void)removeChild:(STRadixTreeNode<ObjectType> * __nonnull)node;
- (STRadixTreeNode<ObjectType> * __nullable)childMatchingPrefixOfKey:(NSString * __nonnull)key;

@property (nonatomic,copy,nullable,readonly) NSSet<ObjectType> *objects;
- (void)addObject:(ObjectType __nonnull)object;
- (void)removeObject:(ObjectType __nonnull)object;
- (void)setObject:(ObjectType __nullable)object;
- (void)setObjects:(NSSet<ObjectType> * __nullable)objects;

@end
