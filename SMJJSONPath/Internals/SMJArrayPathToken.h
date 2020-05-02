/*
 * SMJArrayPathToken.h
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/path/ArrayPathToken.java */


#import <Foundation/Foundation.h>

#import "SMJPathToken.h"


NS_ASSUME_NONNULL_BEGIN


/*
** Types
*/
#pragma mark - Types

typedef enum SMJArrayPathCheck
{
	SMJArrayPathCheckHandle,
	SMJArrayPathCheckSkip,
	SMJArrayPathCheckError
} SMJArrayPathCheck;


/*
** SMJArrayPathToken
*/
#pragma mark - SMJArrayPathToken

@interface SMJArrayPathToken : SMJPathToken

- (SMJArrayPathCheck)checkArrayWithCurrentPathString:(NSString *)currentPath jsonObject:(id)jsonObject evaluationContext:(SMJEvaluationContextImpl *)context error:(NSError **)error;

@end


NS_ASSUME_NONNULL_END
