/*
 * SMJJSONPath.h
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/JsonPath.java */


#import <Foundation/Foundation.h>

#import <SMJJSONPath/SMJConfiguration.h>
#import <SMJJSONPath/SMJEvaluationListener.h>
#import <SMJJSONPath/SMJOption.h>


NS_ASSUME_NONNULL_BEGIN


/*
** Framework
*/
#pragma mark - Framework

//! Project version number for SMJJSONPath.
FOUNDATION_EXPORT double SMJJSONPathVersionNumber;

//! Project version string for SMJJSONPath.
FOUNDATION_EXPORT const unsigned char SMJJSONPathVersionString[];



/*
** Types
*/
#pragma mark - Types

typedef _Nonnull id (^SMJJSONPathMapper)(id object, SMJConfiguration *configuration);



/*
** SMJJSONPath
*/
#pragma mark - SMJJSONPath

@interface SMJJSONPath : NSObject

// Instance.
- (nullable instancetype)initWithJSONPathString:(NSString *)jsonPathString error:(NSError **)error NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

// Apply path to JSON.
- (nullable id)resultForJSONData:(NSData *)data configuration:(nullable SMJConfiguration *)configuration error:(NSError **)error;
- (nullable id)resultForJSONFile:(NSURL *)url configuration:(nullable SMJConfiguration *)configuration error:(NSError **)error;
- (nullable id)resultForJSONObject:(id)jsonObject configuration:(nullable SMJConfiguration *)configuration error:(NSError **)error;

// Update JSON at path result. The json object need to use mutable containers.
- (nullable id)updateMutableJSONObject:(id)jsonObject setObject:(id)object configuration:(nullable SMJConfiguration *)configuration error:(NSError **)error;
- (nullable id)updateMutableJSONObject:(id)jsonObject mapObjects:(SMJJSONPathMapper)mapper configuration:(nullable SMJConfiguration *)configuration error:(NSError **)error;
- (nullable id)updateMutableJSONObject:(id)jsonObject deleteWithConfiguration:(nullable SMJConfiguration *)configuration error:(NSError **)error;
- (nullable id)updateMutableJSONObject:(id)jsonObject addObject:(id)object configuration:(nullable SMJConfiguration *)configuration error:(NSError **)error;
- (nullable id)updateMutableJSONObject:(id)jsonObject putObject:(id)object key:(NSString *)key configuration:(nullable SMJConfiguration *)configuration error:(NSError **)error;
- (nullable id)updateMutableJSONObject:(id)jsonObject renameKey:(NSString *)oldKey toKey:(NSString *)newKey configuration:(nullable SMJConfiguration *)configuration error:(NSError **)error;

@end


NS_ASSUME_NONNULL_END

