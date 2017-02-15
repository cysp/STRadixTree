//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Scott Talbot.

#import <Foundation/Foundation.h>


@interface STRadixTree : NSObject

- (void)addObject:(id __nonnull)object forKey:(NSString * __nonnull)key;
- (void)removeObject:(id __nonnull)object forKey:(NSString * __nonnull)key;
- (void)removeObjectsForKey:(NSString * __nonnull)key;
- (void)removeAllObjects;

- (NSSet * __nullable)objectsForKey:(NSString * __nonnull)key;
- (NSSet * __nullable)objectsForKeyPrefix:(NSString * __nonnull)prefix;
- (NSSet * __nullable)objectsForKeyPrefix:(NSString * __nonnull)prefix unambiguousCompletion:(NSString * __nullable __autoreleasing * __nullable)unambiguousCompletion;

@end
