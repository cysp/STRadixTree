//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Scott Talbot.

#import <Foundation/Foundation.h>


@interface STRadixTree : NSObject

- (NSUInteger)count;
- (NSUInteger)height;
- (NSUInteger)countAtDepth:(NSUInteger)depth;

- (void)addObject:(id)object forKey:(NSString *)key;
- (void)removeObject:(id)object forKey:(NSString *)key;
- (void)removeObjectsForKey:(NSString *)key;
- (void)removeAllObjects;

- (NSSet *)objectsForKey:(NSString *)key;
- (NSSet *)objectsForKeyPrefix:(NSString *)prefix;
- (NSSet *)objectsForKeyPrefix:(NSString *)prefix unambiguousCompletion:(NSString * __autoreleasing *)unambiguousCompletion;

@end
