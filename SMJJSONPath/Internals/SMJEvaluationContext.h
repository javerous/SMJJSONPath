/*
 * SMJEvaluationContext.h
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/EvaluationContext.java */


#import <Foundation/Foundation.h>

#import "SMJConfiguration.h"

#import "SMJPathRef.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJEvaluationContext
*/
#pragma mark - SMJEvaluationContext

@protocol SMJEvaluationContext <NSObject>

/**
 *
 * @return the configuration used for this evaluation
 */
@property (readonly) SMJConfiguration *configuration;


/**
 * The json object that is evaluated
 *
 * @return the json object
 */
@property (readonly) id rootJsonObject;

/**
 * This method does not adhere to configuration settings. It will return a single object (not wrapped in a List) even if the
 * configuration contains the {@link com.jayway.jsonpath.Option#SMJOptionAlwaysReturnList}
 *
 * @return evaluation result
 */
- (nullable id)jsonObjectWithError:(NSError **)error;


/**
 * Get list of hits as String path representations
 *
 * @return list of path representations
 */
@property (readonly) NSArray <NSString *> *pathList;


/**
 * Get list of updaptables nodes.
 *
 * @return list of path references
 */
@property (readonly) NSArray <SMJPathRef *> *updateOperations;

@end


NS_ASSUME_NONNULL_END
