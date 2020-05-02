/*
 * SMJPropertyPathTokenTest.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/old/internal/PropertyPathTokenTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseTest.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJPropertyPathTokenTest
*/
#pragma mark - SMJPropertyPathTokenTest

@interface SMJPropertyPathTokenTest : SMJBaseTest
{
	NSString *_jsonSimpleMap;
	NSString *_jsonSimpleArray;
}

@end

@implementation SMJPropertyPathTokenTest

- (void)setUp
{
    [super setUp];

	_jsonSimpleMap = @"{\n"
	@"   \"foo\" : \"foo-val\",\n"
	@"   \"bar\" : \"bar-val\",\n"
	@"   \"baz\" : {\"baz-child\" : \"baz-child-val\"}\n"
	@"}";
	
	_jsonSimpleArray = @"["
	@"{\n"
	@"   \"foo\" : \"foo-val-0\",\n"
	@"   \"bar\" : \"bar-val-0\",\n"
	@"   \"baz\" : {\"baz-child\" : \"baz-child-val\"}\n"
	@"},"
	@"{\n"
	@"   \"foo\" : \"foo-val-1\",\n"
	@"   \"bar\" : \"bar-val-1\",\n"
	@"   \"baz\" : {\"baz-child\" : \"baz-child-val\"}\n"
	@"}"
	@"]";
}


- (void)test_property_not_found
{
	[self checkResultForJSONString:_jsonSimpleMap jsonPathString:@"$.not-found" expectedError:YES];
}

- (void)test_property_not_found_deep
{
	[self checkResultForJSONString:_jsonSimpleMap jsonPathString:@"$.foo.not-found" expectedError:YES];
}

- (void)test_property_not_found_option_throw
{
	[self checkResultForJSONString:_jsonSimpleMap jsonPathString:@"$.not-found" expectedError:YES];
}

- (void)test_map_value_can_be_read_from_map
{
	[self checkResultForJSONString:_jsonSimpleMap jsonPathString:@"$.foo" expectedResult:@"foo-val"];
}

- (void)test_map_value_can_be_read_from_array
{
	[self checkResultForJSONString:_jsonSimpleArray jsonPathString:@"$[*].foo" expectedResult:@[ @"foo-val-0", @"foo-val-1" ]];
}

- (void)test_map_value_can_be_read_from_child_map
{
	[self checkResultForJSONString:_jsonSimpleMap jsonPathString:@"$.baz.baz-child" expectedResult:@"baz-child-val"];
}

@end


NS_ASSUME_NONNULL_END
