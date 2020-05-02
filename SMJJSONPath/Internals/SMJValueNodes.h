/*
 * SMJValueNodes.h
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/filter/ValueNodes.java */


#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>

#import "SMJValueNode.h"

#import "SMJPredicate.h"

#import "SMJPath.h"


NS_ASSUME_NONNULL_BEGIN


/*
** Forward
*/
#pragma mark - Forward

@class SMJPathNode;
@class SMJNullNode;
@class SMJJsonNode;
@class SMJPatternNode;
@class SMJStringNode;
@class SMJNumberNode;
@class SMJBooleanNode;


/*
** SMJValueNodes
*/
#pragma mark - SMJValueNodes

@interface SMJValueNodes : NSObject

+ (SMJBooleanNode *)valueNodeTRUE;
+ (SMJBooleanNode *)valueNodeFALSE;

+ (SMJNullNode *)nullNode;
+ (SMJJsonNode *)jsonNodeWithString:(NSString *)string;
+ (SMJPatternNode *)patternNodeWithString:(NSString *)string;
+ (SMJStringNode *)stringNodeWithString:(NSString *)string escape:(BOOL)escape;
+ (SMJNumberNode *)numberNodeWithString:(NSString *)string;
+ (SMJBooleanNode *)booleanNodeWithString:(NSString *)string;
+ (SMJPathNode *)pathNodeWithPath:(id <SMJPath>)path;
+ (nullable SMJPathNode *)pathNodeWithPathString:(NSString *)pathString existsCheck:(BOOL)existsCheck shouldExists:(BOOL)shouldExists error:(NSError **)error;

@end


/*
** Subnodes
*/
#pragma mark - Subnodes

@interface SMJPathNode : SMJValueNode

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)copyWithExistsCheckAndShouldExists:(BOOL)existsCheck;

@property (readonly) BOOL shouldExists;
@property (readonly, getter=isExistsCheck) BOOL existsCheck;

- (nullable SMJValueNode *)evaluate:(id <SMJPredicateContext>)context error:(NSError **)error;

- (id <SMJPath>)underlayingObjectWithError:(NSError **)error;

@end


@interface SMJNullNode : SMJValueNode

- (instancetype)init NS_UNAVAILABLE;

- (NSNull *)underlayingObjectWithError:(NSError **)error;

@end


@interface SMJJsonNode : SMJValueNode

- (instancetype)init NS_UNAVAILABLE;

- (nullable id)underlayingObjectWithError:(NSError **)error;

@end


@interface SMJPatternNode : SMJValueNode

- (instancetype)init NS_UNAVAILABLE;

- (nullable NSRegularExpression *)underlayingObjectWithError:(NSError **)error;

@end


@interface SMJStringNode : SMJValueNode

- (instancetype)init NS_UNAVAILABLE;

- (NSString *)underlayingObjectWithError:(NSError **)error;

@end


@interface SMJNumberNode : SMJValueNode

- (instancetype)init NS_UNAVAILABLE;

- (NSNumber *)underlayingObjectWithError:(NSError **)error;

@end


@interface SMJBooleanNode : SMJValueNode

- (instancetype)init NS_UNAVAILABLE;

- (NSNumber *)underlayingObjectWithError:(NSError **)error;

@end


NS_ASSUME_NONNULL_END
