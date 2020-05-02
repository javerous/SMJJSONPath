/*
 * SMJPredicatePathTokenTest.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/old/internal/PredicatePathTokenTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseTest.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJPredicatePathTokenTest
*/
#pragma mark - SMJPredicatePathTokenTest

@interface SMJPredicatePathTokenTest : SMJBaseTest
@end

@implementation SMJPredicatePathTokenTest

- (NSString *)jsonArray2
{
	return @"["
	@"{\n"
	@"   \"foo\" : \"foo-val-0\",\n"
	@"   \"int\" : 0\n,"
	@"   \"decimal\" : 0.0\n"
	@"},"
	@"{\n"
	@"   \"foo\" : \"foo-val-1\",\n"
	@"   \"int\" : 1,\n"
	@"   \"decimal\" : 0.1\n"
	@"},"
	@"{\n"
	@"   \"foo\" : \"foo-val-2\",\n"
	@"   \"int\" : 2,\n"
	@"   \"decimal\" : 0.2\n"
	@"},"
	@"{\n"
	@"   \"foo\" : \"foo-val-3\",\n"
	@"   \"int\" : 3,\n"
	@"   \"decimal\" : 0.3\n"
	@"},"
	@"{\n"
	@"   \"foo\" : \"foo-val-4\",\n"
	@"   \"int\" : 4,\n"
	@"   \"decimal\" : 0.4\n"
	@"},"
	@"{\n"
	@"   \"foo\" : \"foo-val-5\",\n"
	@"   \"int\" : 5,\n"
	@"   \"decimal\" : 0.5\n"
	@"},"
	@"{\n"
	@"   \"foo\" : \"foo-val-6\",\n"
	@"   \"int\" : 6,\n"
	@"   \"decimal\" : 0.6\n"
	@"},"
	@"{\n"
	@"   \"foo\" : \"foo-val-7\",\n"
	@"   \"int\" : 7,\n"
	@"   \"decimal\" : 0.7,\n"
	@"   \"bool\" : true\n"
	@"}"
	@"]";
}

- (void)test_a_filter_predicate_can_be_evaluated_on_string_criteria
{
	[self checkResultForJSONString:[self jsonArray] jsonPathString:@"$[?(@.foo == 'foo-val-1')]" expectedResult:@[ @{ @"foo" : @"foo-val-1" } ]];
}

- (void)test_a_filter_predicate_can_be_evaluated_on_int_criteria
{
	NSArray *result = [self checkResultForJSONString:[self jsonArray2] jsonPathString:@"$[?(@.int == 1)]" expectedCount:1];
	
	XCTAssertEqualObjects([result[0] objectForKey:@"int"], @1);
}

- (void)test_a_filter_predicate_can_be_evaluated_on_decimal_criteria
{
	NSArray *result = [self checkResultForJSONString:[self jsonArray2] jsonPathString:@"$[?(@.decimal == 0.1)]" expectedCount:1];

	XCTAssertEqualObjects([result[0] objectForKey:@"decimal"], @0.1);
}

- (void)test_multiple_criteria_can_be_used
{
	NSArray *result = [self checkResultForJSONString:[self jsonArray2] jsonPathString:@"$[?(@.decimal == 0.1 && @.int == 1)]" expectedCount:1];

	XCTAssertEqualObjects([result[0] objectForKey:@"foo"], @"foo-val-1");
}

- (void)test_field_existence_can_be_checked
{
	NSArray *result = [self checkResultForJSONString:[self jsonArray2] jsonPathString:@"$[?(@.bool)]" expectedCount:1];

	XCTAssertEqualObjects([result[0] objectForKey:@"foo"], @"foo-val-7");
}

- (void)test_boolean_criteria_evaluates
{
	NSArray *result = [self checkResultForJSONString:[self jsonArray2] jsonPathString:@"$[?(@.bool == true)]" expectedCount:1];

	XCTAssertEqualObjects([result[0] objectForKey:@"foo"], @"foo-val-7");
}

@end


NS_ASSUME_NONNULL_END
