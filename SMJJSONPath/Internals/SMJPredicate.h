/*
 * SMJPredicate.h
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/Predicate.java */


#import <Foundation/Foundation.h>

#import "SMJConfiguration.h"


NS_ASSUME_NONNULL_BEGIN


/*
** Types
*/
#pragma mark - Types

typedef enum SMJPredicateApply
{
	SMJPredicateApplyTrue,
	SMJPredicateApplyFalse,
	SMJPredicateApplyError
} SMJPredicateApply;


/*
** SMJPredicateContext
*/
#pragma mark - SMJPredicateContext

@protocol SMJPredicateContext <NSObject>

/**
 * Returns the current item being evaluated by this predicate
 * @return current item
 */
@property (readonly) id jsonObject;


/**
 * Returns the root json object
 * @return root object
 */
@property (readonly) id rootJsonObject;


/**
 * Configuration to use when evaluating
 * @return configuration
 */
@property (readonly) SMJConfiguration *configuration;


@end



/*
** SMJPredicate
*/
#pragma mark - SMJPredicate

@protocol SMJPredicate <NSObject>

- (SMJPredicateApply)applyWithContext:(id <SMJPredicateContext>)context error:(NSError **)error;

- (NSString *)stringValue;

@end


NS_ASSUME_NONNULL_END
