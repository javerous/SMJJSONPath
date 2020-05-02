/*
 * SMJOptionsTest.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/OptionsTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseTest.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJOptionsTest
*/
#pragma mark - SMJOptionsTest

@interface SMJOptionsTest : SMJBaseTest
@end

@implementation SMJOptionsTest

- (void)test_a_leafs_is_not_defaulted_to_null
{
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];
	
	[self checkResultForJSONString:@"{\"foo\" : \"bar\"}" jsonPathString:@"$.baz" configuration:configuration expectedError:YES];
}

- (void)test_a_leafs_can_be_defaulted_to_null
{
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];
	
	[configuration addOption:SMJOptionDefaultPathLeafToNull];
	
	[self checkResultForJSONString:@"{\"foo\" : \"bar\"}" jsonPathString:@"$.baz" configuration:configuration expectedResult:[NSNull null]];
}

- (void)test_a_definite_path_is_not_returned_as_list_by_default
{
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];
	
	[self checkResultForJSONString:@"{\"foo\" : \"bar\"}" jsonPathString:@"$.foo" configuration:configuration expectedResult:@"bar"];
}

- (void)test_a_definite_path_can_be_returned_as_list
{
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];
	
	[configuration addOption:SMJOptionAlwaysReturnList];

	[self checkResultForJSONString:@"{\"foo\" : \"bar\"}" jsonPathString:@"$.foo" configuration:configuration expectedResult:@[ @"bar" ]];
	
	[self checkResultForJSONString:@"{\"foo\": null}" jsonPathString:@"$.foo" configuration:configuration expectedResult:@[ [NSNull null] ]];

	[self checkResultForJSONString:@"{\"foo\": [1, 4, 8]}" jsonPathString:@"$.foo" configuration:configuration expectedResult:@[ @[@1, @4, @8] ]];
}

- (void)test_an_indefinite_path_can_be_returned_as_list
{
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];
	
	[configuration addOption:SMJOptionAlwaysReturnList];
	
	NSArray *result = [self checkResultForJSONString:@"{\"bar\": {\"foo\": null}}" jsonPathString:@"$..foo" configuration:configuration expectedCount:1];
	
	XCTAssertEqualObjects(result[0], [NSNull null]);
	
	
	[self checkResultForJSONString:@"{\"bar\": {\"foo\": [1, 4, 8]}}" jsonPathString:@"$..foo" configuration:configuration expectedResult:@[ @[ @1, @4, @8 ] ]];
 }

- (void)test_a_path_evaluation_is_returned_as_VALUE_by_default
{
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];

	[self checkResultForJSONString:@"{\"foo\" : \"bar\"}" jsonPathString:@"$.foo" configuration:configuration expectedResult:@"bar"];
}

- (void)test_a_path_evaluation_can_be_returned_as_PATH_LIST
{
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];
	
	[configuration addOption:SMJOptionAsPathList];
	
	[self checkResultForJSONString:@"{\"foo\" : \"bar\"}" jsonPathString:@"$.foo" configuration:configuration expectedResult:@[ @"$['foo']" ]];
}

- (void)test_multi_properties_are_merged_by_default
{
	NSDictionary *model = @{
		@"a" : @"a",
		@"b" : @"b",
		@"c" : @"c",
	};
	
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];

	[self checkResultForJSONObject:model jsonPathString:@"$.['a', 'b']" configuration:configuration expectedResult:@{ @"a" : @"a", @"b" : @"b" }];
}

- (void)test_when_property_is_required_exception_is_thrown
{
	NSArray *model = @[
	   @{ @"a" : @"a-val" },
	   @{ @"b" : @"b-val" },
   ];
	
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];

	[configuration addOption:SMJOptionRequireProperties];
	
	[self checkResultForJSONObject:model jsonPathString:@"$[*].a" configuration:configuration expectedError:YES];
}

- (void)test_when_property_is_required_exception_is_thrown_2
{
	NSDictionary *model = @{
		@"a" : @{ @"a-key" : @"a-val" },
		@"b" : @{ @"b-key" : @"b-val" },
	};
	
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];

	[self checkResultForJSONObject:model jsonPathString:@"$.*.a-key" configuration:configuration expectedResult:@[ @"a-val" ]];

	[configuration addOption:SMJOptionRequireProperties];
	
	[self checkResultForJSONObject:model jsonPathString:@"$.*.a-key" configuration:configuration expectedError:YES];
}

- (void)test_issue_suppress_exceptions_does_not_break_indefinite_evaluation
{
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];
	
	[self checkResultForJSONString:@"{\"foo2\": [5]}" jsonPathString:@"$..foo2[0]" configuration:configuration expectedResult:@[ @5 ]];

	[self checkResultForJSONString:@"{\"foo\" : {\"foo2\": [5]}}" jsonPathString:@"$..foo2[0]" configuration:configuration expectedResult:@[ @5 ]];

	[self checkResultForJSONString:@"[null, [{\"foo\" : {\"foo2\": [5]}}]]" jsonPathString:@"$..foo2[0]" configuration:configuration expectedResult:@[ @5 ]];

	[self checkResultForJSONString:@"[null, [{\"foo\" : {\"foo2\": [5]}}]]" jsonPathString:@"$..foo.foo2[0]" configuration:configuration expectedResult:@[ @5 ]];

	[self checkResultForJSONString:@"{\"aoo\" : {}, \"foo\" : {\"foo2\": [5]}, \"zoo\" : {}}" jsonPathString:@"$[*].foo2[0]" configuration:configuration expectedResult:@[ @5 ]];
}

- (void)test_isbn_is_defaulted_when_option_is_provided
{
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];

	[self checkResultForJSONString:[self jsonDocument] jsonPathString:@"$.store.book.*.isbn" configuration:configuration expectedResult:@[ @"0-553-21311-3", @"0-395-19395-8" ]];

	[configuration  addOption:SMJOptionDefaultPathLeafToNull];
	
	[self checkResultForJSONString:[self jsonDocument] jsonPathString:@"$.store.book.*.isbn" configuration:configuration expectedResult:@[ [NSNull null], [NSNull null], @"0-553-21311-3", @"0-395-19395-8" ]];
}

@end


NS_ASSUME_NONNULL_END
