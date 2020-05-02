/*
 * SMJPath.h
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/Path.java */


#import <Foundation/Foundation.h>

#import "SMJConfiguration.h"
#import "SMJEvaluationContext.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJPath
*/
#pragma mark - SMJPath

@protocol SMJPath <NSObject>

/**
 * String representation of this path
 *
 * @return Representation of this path
 */
- (NSString *)stringValue;


/**
 * Evaluates this path
 *
 * @param jsonObject the json object to apply the path on
 * @param rootJsonObject the root json object that started this evaluation
 * @param configuration configuration to use
 * @return EvaluationContext containing results of evaluation
 */
- (nullable id <SMJEvaluationContext>)evaluateJsonObject:(id)jsonObject rootJsonObject:(id)rootJsonObject configuration:(SMJConfiguration *)configuration error:(NSError **)error;


/**
 * Evaluates this path
 *
 * @param jsonObject the json object to apply the path on
 * @param rootJsonObject the root json object that started this evaluation
 * @param configuration configuration to use
 * @param forUpdate is this a read or a write operation
 * @return EvaluationContext containing results of evaluation
 */
- (nullable id <SMJEvaluationContext>)evaluateJsonObject:(id)jsonObject rootJsonObject:(id)rootJsonObject configuration:(SMJConfiguration *)configuration forUpdate:(BOOL)forUpdate error:(NSError **)error;


/**
 *
 * true if this path is definite
 */
@property (readonly, getter=isDefinite) BOOL definite;


/**
 *
 * true if this path is a function
 */
@property (readonly, getter=isFunctionPath) BOOL functionPath;


/**
 *
 * true id this path is starts with '$' and false if the path starts with '@'
 */
@property (readonly, getter=isRootPath) BOOL rootPath;

@end


NS_ASSUME_NONNULL_END
