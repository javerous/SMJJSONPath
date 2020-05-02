/*
 * SMJPathFunction.h
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/function/PathFunction.java */


#import <Foundation/Foundation.h>

#import "SMJPathRef.h"
#import "SMJEvaluationContext.h"
#import "SMJParameter.h"


NS_ASSUME_NONNULL_BEGIN


/**
 * Defines the pattern by which a function can be executed over the result set in the particular path
 * being grabbed.  The Function's input is the content of the data from the json path selector and its output
 * is defined via the functions behavior.  Thus transformations in types can take place.  Additionally, functions
 * can accept multiple selectors in order to produce their output.
 *
 * Defines a parameter as passed to a function with late binding support for lazy evaluation.
 */
@protocol SMJPathFunction <NSObject>

/**
 * Invoke the function and output a JSON object (or scalar) value which will be the result of executing the path
 *
 * @param currentPath
 *      The current path location inclusive of the function name
 *
 * @param parentPath
 *      The path location above the current function
 *
 * @param jsonObject
 *      The JSON object as input to this particular function
 *
 * @param context
 *      Eval context, state bag used as the path is traversed, maintains the result of executing
 *
 */
- (nullable id)invokeWithCurrentPathString:(NSString *)currentPath parentPath:(SMJPathRef *)parentPath jsonObject:(id)jsonObject evaluationContext:(id <SMJEvaluationContext>)context parameters:(nullable NSArray <SMJParameter *> *)parameters error:(NSError **)error;
																																
@end


NS_ASSUME_NONNULL_END
