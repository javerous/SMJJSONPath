/*
 * SMJDeepScanTest.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/DeepScanTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseTest.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJDeepScanTest
*/
#pragma mark - SMJDeepScanTest

@interface SMJDeepScanTest : SMJBaseTest
@end

@implementation SMJDeepScanTest

- (void)test_when_deep_scanning_non_array_subscription_is_ignored
{
	[self checkResultForJSONString:@"{\"x\": [0,1,[0,1,2,3,null],null]}" jsonPathString:@"$..[2][3]" expectedResult:@[ @3 ]];

	[self checkResultForJSONString:@"{\"x\": [0,1,[0,1,2,3,null],null], \"y\": [0,1,2]}" jsonPathString:@"$..[2][3]" expectedResult:@[ @3 ]];

	[self checkResultForJSONString:@"{\"x\": [0,1,[0,1,2],null], \"y\": [0,1,2]}" jsonPathString:@"$..[2][3]" expectedResult:@[ ]];
}

- (void)test_when_deep_scanning_null_subscription_is_ignored
{
	[self checkResultForJSONString:@"{\"x\": [null,null,[0,1,2,3,null],null]}" jsonPathString:@"$..[2][3]" expectedResult:@[ @3 ]];

	[self checkResultForJSONString:@"{\"x\": [null,null,[0,1,2,3,null],null], \"y\": [0,1,null]}" jsonPathString:@"$..[2][3]" expectedResult:@[ @3 ]];
}

- (void)test_when_deep_scanning_array_index_oob_is_ignored
{
	[self checkResultForJSONString:@"{\"x\": [0,1,[0,1,2,3,10],null]}" jsonPathString:@"$..[4]" expectedResult:@[ @10 ]];

	[self checkResultForJSONString:@"{\"x\": [null,null,[0,1,2,3]], \"y\": [null,null,[0,1]]}" jsonPathString:@"$..[2][3]" expectedResult:@[ @3 ]];
}

- (void)test_definite_upstream_illegal_array_access_throws
{
	[self checkResultForJSONString:@"{\"foo\": {\"bar\": null}}" jsonPathString:@"$.foo.bar.[5]" expectedError:YES];
	[self checkResultForJSONString:@"{\"foo\": {\"bar\": null}}" jsonPathString:@"$.foo.bar.[5, 10]" expectedError:YES];

	[self checkResultForJSONString:@"{\"foo\": {\"bar\": 4}}" jsonPathString:@"$.foo.bar.[5]" expectedError:YES];
	[self checkResultForJSONString:@"{\"foo\": {\"bar\": 4}}" jsonPathString:@"$.foo.bar.[5, 10]" expectedError:YES];
	
	[self checkResultForJSONString:@"{\"foo\": {\"bar\": []}}" jsonPathString:@"$.foo.bar.[5]" expectedError:YES];
}

- (void)test_when_deep_scanning_illegal_property_access_is_ignored
{
	[self checkResultForJSONString:@"{\"x\": {\"foo\": {\"bar\": 4}}, \"y\": {\"foo\": 1}}" jsonPathString:@"$..foo" expectedCount:2];
	
	[self checkResultForJSONString:@"{\"x\": {\"foo\": {\"bar\": 4}}, \"y\": {\"foo\": 1}}" jsonPathString:@"$..foo.bar" expectedResult:@[ @4 ]];
	
	[self checkResultForJSONString:@"{\"x\": {\"foo\": {\"bar\": 4}}, \"y\": {\"foo\": 1}}" jsonPathString:@"$..[*].foo.bar" expectedResult:@[ @4 ]];
	
	[self checkResultForJSONString:@"{\"x\": {\"foo\": {\"baz\": 4}}, \"y\": {\"foo\": 1}}" jsonPathString:@"$..[*].foo.bar" expectedResult:@[ ]];
}

- (void)test_when_deep_scanning_illegal_predicate_is_ignored
{
	[self checkResultForJSONString:@"{\"x\": {\"foo\": {\"bar\": 4}}, \"y\": {\"foo\": 1}}" jsonPathString:@"$..foo[?(@.bar)].bar" expectedResult:@[ @4 ]];
	
	[self checkResultForJSONString:@"{\"x\": {\"foo\": {\"bar\": 4}}, \"y\": {\"foo\": 1}}" jsonPathString:@"$..[*]foo[?(@.bar)].bar" expectedResult:@[ @4 ]];
}

- (void)test_when_deep_scanning_require_properties_is_ignored_on_scan_target
{
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];

	[configuration addOption:SMJOptionRequireProperties];
	
	[self checkResultForJSONString:@"[{\"x\": {\"foo\": {\"x\": 4}, \"x\": null}, \"y\": {\"x\": 1}}, {\"x\": []}]" jsonPathString:@"$..x" expectedCount:5];
	
	id result = [self checkResultForJSONString:@"{\"foo\": {\"bar\": 4}}" jsonPathString:@"$..foo.bar" configuration:configuration expectedError:NO];
	XCTAssertEqualObjects(result, @[ @4 ]);
	
	[self checkResultForJSONString:@"{\"foo\": {\"baz\": 4}}" jsonPathString:@"$..foo.bar" configuration:configuration expectedError:YES];
}

- (void)test_when_deep_scanning_require_properties_is_ignored_on_scan_target_but_not_on_children
{
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];
	
	[configuration addOption:SMJOptionRequireProperties];
	
	[self checkResultForJSONString:@"{\"foo\": {\"baz\": 4}}" jsonPathString:@"$..foo.bar" configuration:configuration expectedError:YES];
}

- (void)test_when_deep_scanning_leaf_multi_props_work
{
	[self checkResultForJSONString:@"[{\"a\": \"a-val\", \"b\": \"b-val\", \"c\": \"c-val\"}, [1, 5], {\"a\": \"a-val\"}]"
					jsonPathString:@"$..['a', 'c']"
					expectedResult:@[ @{ @"a" : @"a-val", @"c" : @"c-val" } ]];
	
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];
	
	[configuration addOption:SMJOptionDefaultPathLeafToNull];
	
	NSArray *result = [self checkResultForJSONString:@"[{\"a\": \"a-val\", \"b\": \"b-val\", \"c\": \"c-val\"}, [1, 5], {\"a\": \"a-val\"}]"
									  jsonPathString:@"$..['a', 'c']"
									   configuration:configuration
									   expectedError:NO];
	
	XCTAssertGreaterThan(((NSArray *)result).count, 0);
	
	for (NSDictionary *node in (NSArray *)result)
	{
		XCTAssertTrue([node isKindOfClass:[NSDictionary class]]);
		XCTAssertEqual(node.count, 2);
		XCTAssertEqualObjects(node[@"a"], @"a-val");
	}
}

- (void)test_require_single_property_ok
{
	NSArray *jsonObject = @[
		@{ @"a" : @"a0"},
		@{ @"a" : @"a1"},
	];
	
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];

	[configuration addOption:SMJOptionRequireProperties];
	
	[self checkResultForJSONObject:jsonObject jsonPathString:@"$..a" configuration:configuration expectedResult:@[ @"a0", @"a1" ]];
}

- (void)test_require_single_property
{
	NSArray *jsonObject = @[
		@{ @"a" : @"a0"},
		@{ @"b" : @"b2"},
	];
	
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];

	[configuration addOption:SMJOptionRequireProperties];
	
	[self checkResultForJSONObject:jsonObject jsonPathString:@"$..a" configuration:configuration expectedResult:@[ @"a0" ]];
}

- (void)test_require_multi_property_all_match
{
	NSArray *jsonObject = @[
		@{ @"a" : @"aa", @"b" : @"bb" },
		@{ @"a" : @"aa", @"b" : @"bb" },
	];
	
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];

	[configuration addOption:SMJOptionRequireProperties];
	
	[self checkResultForJSONObject:jsonObject jsonPathString:@"$..['a', 'b']" configuration:configuration expectedResult:[jsonObject copy]];
}

- (void)test_require_multi_property_some_match
{
	NSArray *jsonObject = @[
		@{ @"a" : @"aa", @"b" : @"bb" },
		@{ @"a" : @"aa", @"d" : @"dd" },
	];
	
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];

	[configuration addOption:SMJOptionRequireProperties];
	
	[self checkResultForJSONObject:jsonObject jsonPathString:@"$..['a', 'b']" configuration:configuration expectedResult:@[ @{ @"a" : @"aa", @"b" : @"bb" } ]];
}

- (void)test_scan_for_single_property
{
	NSDictionary 	*a = @{ @"a" : @"aa" };
	NSDictionary 	*b = @{ @"b" : @"bb" };
	NSDictionary 	*ab = @{ @"a" : a, @"b" : b };
	NSDictionary	*b_ab = @{ @"b" : b, @"ab" : ab};
	NSArray			*jsonObject = @[ a, b, b_ab ];

	[self checkResultForJSONObject:jsonObject jsonPathString:@"$..['a']" expectedResult:@[ @"aa", a, @"aa" ]];
}

- (void)test_scan_for_property_path
{
	NSDictionary 	*a = @{ @"a" : @"aa" };
	NSDictionary 	*x = @{ @"x" : @"xx" };
	NSDictionary 	*y = @{ @"a" : x };
	NSDictionary 	*z = @{ @"z" : y };
	NSArray			*jsonObject = @[ a, x, y, z ];

	[self checkResultForJSONObject:jsonObject jsonPathString:@"$..['a'].x" expectedResult:@[ @"xx", @"xx" ]];
}

- (void)test_scan_for_property_path_missing_required_property
{
	NSDictionary 	*a = @{ @"a" : @"aa" };
	NSDictionary 	*x = @{ @"x" : @"xx" };
	NSDictionary 	*y = @{ @"a" : x };
	NSDictionary 	*z = @{ @"z" : y };
	NSArray			*jsonObject = @[ a, x, y, z ];
	
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];
	
	[configuration addOption:SMJOptionRequireProperties];
	
	[self checkResultForJSONObject:jsonObject jsonPathString:@"$..['a'].x" configuration:configuration expectedResult:@[ @"xx", @"xx" ]];
}

- (void)test_scans_can_be_filtered
{
	NSDictionary *brown = @{ @"val" : @"brown"};
	NSDictionary *white = @{ @"val" : @"white"};
	
	NSDictionary *cow = @{
	  @"mammal" : @YES,
	  @"color" : brown
    };
	
	NSDictionary *dog = @{
	  @"mammal" : @YES,
	  @"color" : white
	};
	
	NSDictionary *frog = @{
	   @"mammal" : @NO
	};
	
	NSArray *animals = @[ cow, dog, frog ];
	
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];
	
	[configuration addOption:SMJOptionRequireProperties];
	
	[self checkResultForJSONObject:animals jsonPathString:@"$..[?(@.mammal == true)].color" configuration:configuration expectedResult:@[ brown, white ]];
}

- (void)test_scan_with_a_function_filter
{
	[self checkResultForJSONString:[self jsonDocument] jsonPathString:@"$..*[?(@.length() > 5)]" expectedCount:1];
}

- (void)test_deepScanPathDefault
{
	[self executeScanPath:[SMJConfiguration defaultConfiguration]];
}

- (void)test_deepScanPathRequireProperties
{
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];
	
	[configuration addOption:SMJOptionRequireProperties];
	
	[self executeScanPath:configuration];
}

- (void)executeScanPath:(SMJConfiguration *)configuration
{
	NSString *jsonString = @"{ \"index\": \"index\", \"data\": { \"array\": [ { \"object1\": { \"name\": \"robert\" } } ] } }";
	
	[self checkResultForJSONString:jsonString jsonPathString:@"$..array[0]" expectedResult:@[ @{ @"object1" : @{ @"name" : @"robert" } } ]];
}

@end


NS_ASSUME_NONNULL_END
