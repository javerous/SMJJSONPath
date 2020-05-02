/*
 * SMJReturnTypeTest.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/ReturnTypeTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseTest.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJReturnTypeTest
*/
#pragma mark - SMJReturnTypeTest

@interface SMJReturnTypeTest : SMJBaseTest
@end

@implementation SMJReturnTypeTest

- (void)test_assert_strings_can_be_read
{
	[self checkResultForJSONString:[self jsonDocument] jsonPathString:@"$.string-property" expectedResult:@"string-value"];
}

- (void)test_assert_ints_can_be_read
{
	[self checkResultForJSONString:[self jsonDocument] jsonPathString:@"$.int-max-property" expectedResult:@(UINT64_MAX)];
}

- (void)test_assert_longs_can_be_read
{
	[self checkResultForJSONString:[self jsonDocument] jsonPathString:@"$.long-max-property" expectedResult:@(INT64_MIN)];
}

- (void)test_assert_boolean_values_can_be_read
{
	[self checkResultForJSONString:[self jsonDocument] jsonPathString:@"$.boolean-property" expectedResult:@YES];
}

- (void)test_assert_arrays_can_be_read
{
	[self checkResultForJSONString:[self jsonDocument] jsonPathString:@"$.store.book" expectedCount:4];
}

- (void)test_assert_maps_can_be_read
{
	[self checkResultForJSONString:[self jsonDocument]
					jsonPathString:@"$.store.book[0]"
					expectedResult:@{ @"category" : @"reference", @"author" : @"Nigel Rees", @"title" : @"Sayings of the Century", @"display-price" : @8.95 }];
}

- (void)test_a_path_evaluation_can_be_returned_as_PATH_LIST
{
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];
	
	[configuration addOption:SMJOptionAsPathList];
	
	[self checkResultForJSONString:[self jsonDocument]
					jsonPathString:@"$..author"
					 configuration:configuration
					expectedResult:@[ @"$['store']['book'][0]['author']", @"$['store']['book'][1]['author']", @"$['store']['book'][2]['author']", @"$['store']['book'][3]['author']" ]];
}

@end


NS_ASSUME_NONNULL_END
