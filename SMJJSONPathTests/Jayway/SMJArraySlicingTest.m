/*
 * SMJArraySlicingTest.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/old/ArraySlicingTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseTest.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJArraySlicingTest
*/
#pragma mark - SMJArraySlicingTest

@interface SMJArraySlicingTest : SMJBaseTest
@end

@implementation SMJArraySlicingTest
{
	NSString *_jsonArray;
}
- (void)setUp
{
    [super setUp];
	
	_jsonArray = @"[1, 3, 5, 7, 8, 13, 20]";
}

- (void)test_get_by_position
{
	[self checkResultForJSONString:_jsonArray jsonPathString:@"$[3]" expectedResult:@7];
}

- (void)test_get_from_index
{
	[self checkResultForJSONString:_jsonArray jsonPathString:@"$[:3]" expectedResult:@[ @1, @3, @5 ]];
}

- (void)test_get_between_index
{
	[self checkResultForJSONString:_jsonArray jsonPathString:@"$[1:5]" expectedResult:@[ @3, @5, @7, @8 ]];
}

- (void)test_get_between_index_2
{
	[self checkResultForJSONString:_jsonArray jsonPathString:@"$[0:1]" expectedResult:@[ @1 ]];
}

- (void)test_get_between_index_3
{
	[self checkResultForJSONString:_jsonArray jsonPathString:@"$[0:2]" expectedResult:@[ @1, @3 ]];
}

- (void)test_get_between_index_out_of_bounds
{
	[self checkResultForJSONString:_jsonArray jsonPathString:@"$[1:15]" expectedResult:@[ @3, @5, @7, @8, @13, @20 ]];
}

- (void)test_get_from_tail_index
{
	[self checkResultForJSONString:_jsonArray jsonPathString:@"$[-3:]" expectedResult:@[ @8, @13, @20 ]];
}

- (void)test_get_from_tail
{
	[self checkResultForJSONString:_jsonArray jsonPathString:@"$[3:]" expectedResult:@[ @7, @8, @13, @20 ]];
}

- (void)test_get_indexes
{
	[self checkResultForJSONString:_jsonArray jsonPathString:@"$[0,1,2]" expectedResult:@[ @1, @3, @5 ]];
}

@end


NS_ASSUME_NONNULL_END
