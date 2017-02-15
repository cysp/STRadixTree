//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Scott Talbot.

#import <Foundation/Foundation.h>


@interface STRadixTree<__covariant ObjectType : NSObject *> : NSObject

- (void)addObject:(ObjectType __nonnull)object forKey:(NSString * __nonnull)key;
- (void)removeObject:(ObjectType __nonnull)object forKey:(NSString * __nonnull)key;
- (void)removeObjectsForKey:(NSString * __nonnull)key;
- (void)removeAllObjects;

- (NSSet<ObjectType> * __nullable)objectsForKey:(NSString * __nonnull)key;
- (NSSet<ObjectType> * __nullable)objectsForKeyPrefix:(NSString * __nonnull)prefix;
- (NSSet<ObjectType> * __nullable)objectsForKeyPrefix:(NSString * __nonnull)prefix unambiguousCompletion:(NSString * __nullable __autoreleasing * __nullable)unambiguousCompletion;

@end
