/*
 * SMJIssue234.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/internal/function/Issue234.java */


#import <XCTest/XCTest.h>

#import "SMJBaseTest.h"


NS_ASSUME_NONNULL_BEGIN


/**
 * TDD for Issue #234
 *
 * Verifies the use-case where-in the function path expression is cached and re-used but the JsonPath includes a function
 * whose arguments are then dependent upon state that changes externally from the internal Cache.getCache state.  The
 * prior implementation had a bug where-in the parameter values were cached -- the present implementation (as of Issue #234)
 * now uses a late binding approach to eval the function parameters.  Cache invalidation isn't an option given the need
 * for nested function calls.
 *
 * Once this bug is fixed, most of the concern then centers around the need to ensure nested functions are processed
 * correctly.
 *
 * @see NestedFunctionTest for examples of where that is performed.
 *
 */


/*
** SMJIssue234
*/
#pragma mark - SMJIssue234

@interface SMJIssue234 : SMJBaseTest
@end

@implementation SMJIssue234

- (void)testIssue234
{
	NSDictionary *context;
	
	context = @{ @"key" : @"first" };
	[self checkResultForJSONObject:context jsonPathString:@"concat(\"/\", $.key)" expectedResult:@"/first"];
	
	context = @{ @"key" : @"second" };
	[self checkResultForJSONObject:context jsonPathString:@"concat(\"/\", $.key)" expectedResult:@"/second"];
}

@end


NS_ASSUME_NONNULL_END
