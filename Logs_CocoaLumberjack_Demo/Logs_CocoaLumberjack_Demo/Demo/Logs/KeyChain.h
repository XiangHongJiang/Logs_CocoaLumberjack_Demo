//
//  KeyChain.h
//  CangoToB
//
//  Created by KiddieBao on 13/04/2018.
//  Copyright © 2018 Kiddie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyChain : NSObject

+ (void)saveObject:(id)object forKey:(NSString *)key;
+ (id)readObjectForKey:(NSString *)key;
+ (void)deleteObjectForKey:(NSString *)key;
+ (void)deleteAllObject;

@end

@interface SaveKeyChain : NSObject

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service;
+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)delete:(NSString *)service;

@end
