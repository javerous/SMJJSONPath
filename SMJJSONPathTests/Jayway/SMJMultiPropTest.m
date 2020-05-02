/*
 * SMJMultiPropTest.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/MultiPropTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseTest.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJMultiPropTest
*/
#pragma mark - SMJMultiPropTest

@interface SMJMultiPropTest : SMJBaseTest
@end

@implementation SMJMultiPropTest

- (void)test_multi_prop_can_be_read_from_root
{
	NSDictionary *model = @{
		@"a" : @"a-val",
		@"b" : @"b-val",
		@"c" : @"c-val"
	};
	
	[self checkResultForJSONObject:model
					jsonPathString:@"$['a', 'b']"
					expectedResult:@{ @"a" : @"a-val", @"b" : @"b-val" }];
	
	[self checkResultForJSONObject:model
					jsonPathString:@"$['a', 'd']"
					expectedResult:@{ @"a" : @"a-val" }];
}

- (void)test_multi_props_can_be_defaulted_to_null
{
	NSDictionary *model = @{
		@"a" : @"a-val",
		@"b" : @"b-val",
		@"c" : @"c-val"
	};
	
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];
	
	[configuration addOption:SMJOptionDefaultPathLeafToNull];
	
	[self checkResultForJSONObject:model
					jsonPathString:@"$['a', 'd']"
					 configuration:configuration
					expectedResult:@{ @"a" : @"a-val", @"d" : [NSNull null]}];
}

- (void)test_multi_props_can_be_required
{
	NSDictionary *model = @{
		@"a" : @"a-val",
		@"b" : @"b-val",
		@"c" : @"c-val"
	};
	
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];
	
	[configuration addOption:SMJOptionRequireProperties];
	
	[self checkResultForJSONObject:model jsonPathString:@"$['a', 'x']" configuration:configuration expectedError:YES];
}

- (void)test_multi_props_can_be_non_leafs
{
	[self checkResultForJSONString:@"{\"a\": {\"v\": 5}, \"b\": {\"v\": 4}, \"c\": {\"v\": 1}}"
					jsonPathString:@"$['a', 'c'].v"
					 expectedResult:@[ @5, @1 ]];
}

- (void)test_nonexistent_non_leaf_multi_props_ignored
{
	[self checkResultForJSONString:@"{\"a\": {\"v\": 5}, \"b\": {\"v\": 4}, \"c\": {\"v\": 1}}"
					jsonPathString:@"$['d', 'a', 'c', 'm'].v"
					 expectedResult:@[ @5, @1 ]];
}

- (void)test_multi_props_with_post_filter
{
	[self checkResultForJSONString:@"{\"a\": {\"v\": 5}, \"b\": {\"v\": 4}, \"c\": {\"v\": 1, \"flag\": true}}"
					jsonPathString:@"$['a', 'c'][?(@.flag)].v"
					expectedResult:@[ @1 ]];
}

- (void)test_deep_scan_does_not_affect_non_leaf_multi_props
{
	NSString *json = @"{\"v\": [[{}, 1, {\"a\": {\"v\": 5}, \"b\": {\"v\": 4}, \"c\": {\"v\": 1, \"flag\": true}}]]}";
	
	[self checkResultForJSONString:json
					jsonPathString:@"$..['a', 'c'].v"
					expectedResult:@[ @5, @1 ]];
	
		[self checkResultForJSONString:json
					jsonPathString:@"$..['a', 'c'][?(@.flag)].v"
					expectedResult:@[ @1 ]];
}

- (void)test_multi_props_can_be_in_the_middle
{
	NSString *json = @"{\"x\": [null, {\"a\": {\"v\": 5}, \"b\": {\"v\": 4}, \"c\": {\"v\": 1}}]}";
	
	[self checkResultForJSONString:json jsonPathString:@"$.x[1]['a', 'c'].v" expectedResult:@[ @5, @1 ]];
	
	[self checkResultForJSONString:json jsonPathString:@"$.x[*]['a', 'c'].v" expectedResult:@[ @5, @1 ]];
	
	[self checkResultForJSONString:json jsonPathString:@"$[*][*]['a', 'c'].v" expectedResult:@[ @5, @1 ]];

	[self checkResultForJSONString:json jsonPathString:@"$.x[1]['d', 'a', 'c', 'm'].v" expectedResult:@[ @5, @1 ]];

	[self checkResultForJSONString:json jsonPathString:@"$.x[*]['d', 'a', 'c', 'm'].v" expectedResult:@[ @5, @1 ]];
}

- (void)test_non_leaf_multi_props_can_be_required
{
	NSString *json = @"{\"a\": {\"v\": 5}, \"b\": {\"v\": 4}, \"c\": {\"v\": 1}}";
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];
	
	[configuration addOption:SMJOptionRequireProperties];
	
	[self checkResultForJSONString:json jsonPathString:@"$['a', 'c'].v" configuration:configuration expectedResult:@[ @5, @1 ]];
	
	[self checkResultForJSONString:json jsonPathString:@"$['d', 'a', 'c', 'm'].v" configuration:configuration expectedError:YES];
}

@end


NS_ASSUME_NONNULL_END
