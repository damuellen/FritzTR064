//
//  keychain.h
//  
//
//  Created by Troutslayer33 on 7/13/15.
//  Copyright (c) 2015 Troutslayer33. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

#ifndef Mavia_keychain_h
#define Mavia_keychain_h


#endif

@class keychain;

@interface keychain : NSObject
+ (void) storeData: (NSString * )key data:(NSData *)data;
+ (NSData *) getData: (NSString *)key;
+ (void) deleteKeychainValue:(NSString *)key;
@end