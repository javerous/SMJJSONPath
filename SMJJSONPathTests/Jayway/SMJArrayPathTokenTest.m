/*
 * SMJArrayPathTokenTest.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/old/internal/ArrayPathTokenTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseTest.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJArrayPathTokenTest
*/
#pragma mark - SMJArrayPathTokenTest

@interface SMJArrayPathTokenTest : SMJBaseTest
@end

@implementation SMJArrayPathTokenTest

- (void)test_array_can_select_multiple_indexes
{
	[self checkResultForJSONString:[self jsonArray]
					jsonPathString:@"$[0,1]"
					expectedResult:@[ @{ @"foo" : @"foo-val-0" }, @{@"foo" : @"foo-val-1" } ]];
}

- (void)test_array_can_be_sliced_to_2
{
	[self checkResultForJSONString:[self jsonArray]
					jsonPathString:@"$[:2]"
					expectedResult:@[ @{ @"foo" : @"foo-val-0" }, @{ @"foo" : @"foo-val-1" }]];
	
}

- (void)test_array_can_be_sliced_to_2_from_tail
{
	[self checkResultForJSONString:[self jsonArray]
					jsonPathString:@"$[:-5]"
					expectedResult:@[ @{ @"foo" : @"foo-val-0" }, @{ @"foo" : @"foo-val-1" }]];
	
}

- (void)test_array_can_be_sliced_from_2
{
	[self checkResultForJSONString:[self jsonArray]
					jsonPathString:@"$[5:]"
					expectedResult:@[ @{ @"foo" : @"foo-val-5" }, @{ @"foo" : @"foo-val-6" }]];
	
}

- (void)test_array_can_be_sliced_from_2_from_tail
{
	[self checkResultForJSONString:[self jsonArray]
					jsonPathString:@"$[-2:]"
					expectedResult:@[ @{ @"foo" : @"foo-val-5" }, @{ @"foo" : @"foo-val-6" }]];
	
}

- (void)test_array_can_be_sliced_between
{
	[self checkResultForJSONString:[self jsonArray]
					jsonPathString:@"$[2:4]"
					expectedResult:@[ @{ @"foo" : @"foo-val-2" }, @{ @"foo" : @"foo-val-3" } ]];
}

@end


NS_ASSUME_NONNULL_END
