/*
 * SMJPathRef.h
 *
 * Copyright 2020 Avérous Julien-Pierre
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/PathRef.java */


#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>

#import "SMJConfiguration.h"


NS_ASSUME_NONNULL_BEGIN


/*
** Types
*/
#pragma mark - Types

typedef _Nonnull id (^SMJPathRefMapper)(id object, SMJConfiguration *configuration);



/*
** SMJPathRef
*/
#pragma mark - SMJPathRef

@interface SMJPathRef : NSObject

// -- Instance --
+ (instancetype)pathRefNull;

+ (instancetype)pathRefWithRootObject:(id)root;

+ (instancetype)pathRefWithObject:(id)object property:(NSString *)property;
+ (instancetype)pathRefWithObject:(id)object properties:(NSArray <NSString *> *)properties;
+ (instancetype)pathRefWithObject:(id)object item:(id)item;

// -- Operations --
- (BOOL)setObject:(id)newVal configuration:(SMJConfiguration *)configuration error:(NSError **)error;
- (BOOL)convertWithMapper:(SMJPathRefMapper)mapper configuration:(SMJConfiguration *)configuration error:(NSError **)error;
- (BOOL)deleteWithConfiguration:(SMJConfiguration *)configuration error:(NSError **)error;
- (BOOL)addObject:(id)newVal configuration:(SMJConfiguration *)configuration error:(NSError **)error;
- (BOOL)putObject:(id)value forKey:(NSString *)key configuration:(SMJConfiguration *)configuration error:(NSError **)error;
- (BOOL)renameKey:(NSString *)oldKey toKey:(NSString *)newKey configuration:(SMJConfiguration *)configuration error:(NSError **)error;

@end


NS_ASSUME_NONNULL_END
