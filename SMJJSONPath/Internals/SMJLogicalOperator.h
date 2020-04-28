/*
 * SMJLogicalOperator.h
 *
 * Copyright 2019 Avérous Julien-Pierre
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/filter/LogicalOperator.java */


#import <Foundation/Foundation.h>
#import <CoreFoundation/CFString.h>
#import <dispatch/dispatch.h>


NS_ASSUME_NONNULL_BEGIN


/*
** Defines
*/
#pragma mark - Defines

#define SMJLogicalOperatorAND	@"&&"
#define SMJLogicalOperatorOR	@"||"
#define SMJLogicalOperatorNOT	@"!"



/*
** SMJLogicalOperator
*/
#pragma mark - SMJLogicalOperator

@interface SMJLogicalOperator : NSObject

// -- Instance --
+ (SMJLogicalOperator *)logicalOperatorAND;
+ (SMJLogicalOperator *)logicalOperatorNOT;
+ (SMJLogicalOperator *)logicalOperatorOR;

+ (nullable instancetype)logicalOperatorFromString:(NSString *)string error:(NSError **)error;

// -- Content --
@property (readonly) NSString *stringOperator;

@end


NS_ASSUME_NONNULL_END
