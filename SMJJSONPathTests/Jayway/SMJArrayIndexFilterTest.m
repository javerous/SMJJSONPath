/*
 * SMJArrayIndexFilterTest.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/old/internal/ArrayIndexFilterTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseTest.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJArrayIndexFilterTest
*/
#pragma mark - SMJArrayIndexFilterTest

@interface SMJArrayIndexFilterTest : SMJBaseTest
{
	NSString *_jsonString;
}
@end

@implementation SMJArrayIndexFilterTest

- (void)setUp
{
	[super setUp];

	_jsonString = @"[1, 3, 5, 7, 8, 13, 20]";
}

- (void)test_tail_does_not_throw_when_index_out_of_bounds
{
	[self checkResultForJSONString:_jsonString jsonPathString:@"$[-10:]" expectedResult:@[ @1, @3, @5, @7, @8, @13, @20 ]];
}

- (void)test_head_does_not_throw_when_index_out_of_bounds
{
	[self checkResultForJSONString:_jsonString jsonPathString:@"$[:10]" expectedResult:@[ @1, @3, @5, @7, @8, @13, @20 ]];
}

- (void)test_head_grabs_correct
{
	[self checkResultForJSONString:_jsonString jsonPathString:@"$[:3]" expectedResult:@[ @1, @3, @5 ]];
}


- (void)test_tail_grabs_correct
{
	[self checkResultForJSONString:_jsonString jsonPathString:@"$[-3:]" expectedResult:@[ @8, @13, @20 ]];
}

- (void)test_head_tail_grabs_correct
{
	[self checkResultForJSONString:_jsonString jsonPathString:@"$[0:3]" expectedResult:@[ @1, @3, @5 ]];
}

- (void)test_can_access_items_from_end_with_negative_index
{
	[self checkResultForJSONString:_jsonString jsonPathString:@"$[-3]" expectedResult:@8];
}

@end


NS_ASSUME_NONNULL_END
