/*
 * SMJEvaluationListener.h
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/EvaluationListener.java */


#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


/*
** Types
*/
#pragma mark - Types

typedef enum SMJEvaluationContinuation
{
	// Evaluation continues
	SMJEvaluationContinuationContinue,
	
	 // Current result is included but no further evaluation will be performed.
	SMJEvaluationContinuationAbort,
} SMJEvaluationContinuation;



/*
** SMJFoundResult
*/
#pragma mark - SMJFoundResult

@protocol SMJFoundResult <NSObject>

/**
 * the index of this result. First result i 0
 * @return index
 */
@property (readonly) NSInteger index;

/**
 * The path of this result
 * @return path
 */
@property (readonly) NSString *path;


/**
 * The result object
 * @return the result object
 */
@property (readonly) id result;

@end



/*
** SMJEvaluationListener
*/
#pragma mark - SMJEvaluationListener

@protocol SMJEvaluationListener <NSObject>

/**
 * Callback invoked when result is found
 * @param found the found result
 * @return continuation instruction
 */
- (SMJEvaluationContinuation)resultFound:(id <SMJFoundResult>)found;

@end


NS_ASSUME_NONNULL_END
