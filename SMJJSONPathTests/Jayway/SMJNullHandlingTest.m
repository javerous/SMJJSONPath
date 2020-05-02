/*
 * SMJNullHandlingTest.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/old/NullHandlingTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseTest.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJNullHandlingTest
*/
#pragma mark - SMJNullHandlingTest

@interface SMJNullHandlingTest : SMJBaseTest
{
	NSString *_jsonDocument;
}

@end

@implementation SMJNullHandlingTest


- (void)setUp
{
    [super setUp];
	
	_jsonDocument = @"{\n"
	@"   \"root-property\": \"root-property-value\",\n"
	@"   \"root-property-null\": null,\n"
	@"   \"children\": [\n"
	@"      {\n"
	@"         \"id\": 0,\n"
	@"         \"name\": \"name-0\",\n"
	@"         \"age\": 0\n"
	@"      },\n"
	@"      {\n"
	@"         \"id\": 1,\n"
	@"         \"name\": \"name-1\",\n"
	@"         \"age\": null"
	@"      },\n"
	@"      {\n"
	@"         \"id\": 3,\n"
	@"         \"name\": \"name-3\"\n"
	@"      }\n"
	@"   ]\n"
	@"}";
}

- (void)test_not_defined_property_throws_PathNotFoundException
{
	[self checkResultForJSONObject:_jsonDocument jsonPathString:@"$.children[0].child.age" expectedError:YES];
}

- (void)test_last_token_defaults_to_null
{
	[self checkResultForJSONString:_jsonDocument
					jsonPathString:@"$.children[2].age"
					 configuration:[SMJConfiguration configurationWithOption:SMJOptionDefaultPathLeafToNull]
					 expectedResult:[NSNull null]];
}

- (void)test_null_property_returns_null
{
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$.children[1].age" expectedResult:[NSNull null]];
}

- (void)test_the_age_of_all_with_age_defined
{
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$.children[*].age" expectedResult:@[ @0, [NSNull null]]];
}

- (void)test_path2
{
	[self checkResultForJSONString:@"{\"a\":[{\"b\":1,\"c\":2},{\"b\":5,\"c\":2}]}" jsonPathString:@"a[?(@.b==4)].c" expectedResult:@[]];
}

- (void)test_path
{
	[self checkResultForJSONString:@"{\"a\":[{\"b\":1,\"c\":2},{\"b\":5,\"c\":2}]}"
					jsonPathString:@"a[?(@.b==5)].d"
					 configuration:[SMJConfiguration configurationWithOption:SMJOptionDefaultPathLeafToNull]
					expectedResult:@[ [NSNull null] ]];
}

@end


NS_ASSUME_NONNULL_END
