/*
 * SMJInlineFilterTest.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/InlineFilterTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseTest.h"


NS_ASSUME_NONNULL_BEGIN


/*
** Defines
*/
#pragma mark - Defines

#define kBookCount 4


/*
** SMJInlineFilterTest
*/
#pragma mark - SMJInlineFilterTest

@interface SMJInlineFilterTest : SMJBaseTest
@end

@implementation SMJInlineFilterTest

- (void)test_root_context_can_be_referred_in_predicate
{
	[self checkResultForJSONString:[self jsonDocument]
					jsonPathString:@"store.book[?(@.display-price <= $.max-price)].display-price"
					expectedResult:@[ @8.95, @8.99 ]];
}

- (void)test_multiple_context_object_can_be_refered
{
	[self checkResultForJSONString:[self jsonDocument] jsonPathString:@"store.book[ ?(@.category == @.category) ]" expectedCount:kBookCount];
	
	[self checkResultForJSONString:[self jsonDocument] jsonPathString:@"store.book[ ?(@.category == @['category']) ]" expectedCount:kBookCount];

	[self checkResultForJSONString:[self jsonDocument] jsonPathString:@"store.book[ ?(@ == @) ]" expectedCount:kBookCount];

	[self checkResultForJSONString:[self jsonDocument] jsonPathString:@"store.book[ ?(@.category != @.category) ]" expectedCount:0];

	[self checkResultForJSONString:[self jsonDocument] jsonPathString:@"store.book[ ?(@.category != @) ]" expectedCount:kBookCount];
}

- (void)test_simple_inline_or_statement_evaluates
{
	[self checkResultForJSONString:[self jsonDocument]
					jsonPathString:@"store.book[ ?(@.author == 'Nigel Rees' || @.author == 'Evelyn Waugh') ].author"
					expectedResult:@[ @"Nigel Rees", @"Evelyn Waugh" ]];
	
	[self checkResultForJSONString:[self jsonDocument]
					jsonPathString:@"store.book[ ?((@.author == 'Nigel Rees' || @.author == 'Evelyn Waugh') && @.display-price < 15) ].author"
					expectedResult:@[ @"Nigel Rees", @"Evelyn Waugh" ]];

	[self checkResultForJSONString:[self jsonDocument]
					jsonPathString:@"store.book[ ?((@.author == 'Nigel Rees' || @.author == 'Evelyn Waugh') && @.category == 'reference') ].author"
					expectedResult:@[ @"Nigel Rees" ]];
	
	[self checkResultForJSONString:[self jsonDocument]
					jsonPathString:@"store.book[ ?((@.author == 'Nigel Rees') || (@.author == 'Evelyn Waugh' && @.category != 'fiction')) ].author"
					expectedResult:@[ @"Nigel Rees" ]];
}

- (void)test_no_path_ref_in_filter_hit_all
{
	[self checkResultForJSONString:[self jsonDocument]
					jsonPathString:@"$.store.book[?('a' == 'a')].author"
					expectedResult:@[ @"Nigel Rees", @"Evelyn Waugh", @"Herman Melville", @"J. R. R. Tolkien" ]];
}

- (void)test_no_path_ref_in_filter_hit_none
{
	[self checkResultForJSONString:[self jsonDocument]
					jsonPathString:@"$.store.book[?('a' == 'b')].author"
					expectedResult:@[ ]];
}

- (void)test_path_can_be_on_either_side_of_operator
{
	[self checkResultForJSONString:[self jsonDocument]
					jsonPathString:@"$.store.book[?(@.category == 'reference')].author"
					expectedResult:@[ @"Nigel Rees" ]];
	
	[self checkResultForJSONString:[self jsonDocument]
					jsonPathString:@"$.store.book[?('reference' == @.category)].author"
					expectedResult:@[ @"Nigel Rees" ]];
}

- (void)test_path_can_be_on_both_side_of_operator
{
	[self checkResultForJSONString:[self jsonDocument]
					jsonPathString:@"$.store.book[?(@.category == @.category)].author"
					expectedResult:@[ @"Nigel Rees", @"Evelyn Waugh", @"Herman Melville", @"J. R. R. Tolkien" ]];
}

- (void)test_patterns_can_be_evaluated
{
	[self checkResultForJSONString:[self jsonDocument]
					jsonPathString:@"$.store.book[?(@.category =~ /reference/)].author"
					expectedResult:@[ @"Nigel Rees" ]];

	[self checkResultForJSONString:[self jsonDocument]
					jsonPathString:@"$.store.book[?(/reference/ =~ @.category)].author"
					expectedResult:@[ @"Nigel Rees" ]];
}

- (void)test_patterns_can_be_evaluated_with_ignore_case
{
	[self checkResultForJSONString:[self jsonDocument]
					jsonPathString:@"$.store.book[?(@.category =~ /REFERENCE/)].author"
					expectedResult:@[ ]];

	[self checkResultForJSONString:[self jsonDocument]
					jsonPathString:@"$.store.book[?(@.category =~ /REFERENCE/i)].author"
					expectedResult:@[ @"Nigel Rees" ]];
}

- (void)test_negate_exists_check
{
	[self checkResultForJSONString:[self jsonDocument]
					jsonPathString:@"$.store.book[?(@.isbn)].author"
					expectedResult:@[ @"Herman Melville", @"J. R. R. Tolkien" ]];

	[self checkResultForJSONString:[self jsonDocument]
					jsonPathString:@"$.store.book[?(!@.isbn)].author"
					expectedResult:@[ @"Nigel Rees", @"Evelyn Waugh" ]];
}

- (void)test_negate_exists_check_primitive
{
	NSArray	*ints = @[ @0, @1, [NSNull null], @2, @3 ];

	[self checkResultForJSONObject:ints
					jsonPathString:@"$[?(@)]"
					expectedResult:@[ @0, @1, [NSNull null], @2, @3 ]];

	[self checkResultForJSONObject:ints
					jsonPathString:@"$[?(@ != null)]"
					expectedResult:@[ @0, @1, @2, @3 ]];

	[self checkResultForJSONObject:ints
					jsonPathString:@"$[?(!@)]"
					expectedResult:@[ ]];
}

- (void)test_equality_check_does_not_break_evaluation
{
	[self checkResultForJSONString:@"[{\"value\":\"5\"}]" jsonPathString:@"$[?(@.value=='5')]" expectedCount:1];
	[self checkResultForJSONString:@"[{\"value\":5}]" jsonPathString:@"$[?(@.value==5)]" expectedCount:1];
	
	[self checkResultForJSONString:@"[{\"value\":\"5.1.26\"}]" jsonPathString:@"$[?(@.value=='5.1.26')]" expectedCount:1];
	
	[self checkResultForJSONString:@"[{\"value\":\"5\"}]" jsonPathString:@"$[?(@.value=='5.1.26')]" expectedCount:0];
	[self checkResultForJSONString:@"[{\"value\":5}]" jsonPathString:@"$[?(@.value=='5.1.26')]" expectedCount:0];
	[self checkResultForJSONString:@"[{\"value\":5.1}]" jsonPathString:@"$[?(@.value=='5.1.26')]" expectedCount:0];
	
	[self checkResultForJSONString:@"[{\"value\":\"5.1.26\"}]" jsonPathString:@"$[?(@.value=='5')]" expectedCount:0];
	[self checkResultForJSONString:@"[{\"value\":\"5.1.26\"}]" jsonPathString:@"$[?(@.value==5)]" expectedCount:0];
	[self checkResultForJSONString:@"[{\"value\":\"5.1.26\"}]" jsonPathString:@"$[?(@.value==5.1)]" expectedCount:0];
}

- (void)test_lt_check_does_not_break_evaluation
{
	[self checkResultForJSONString:@"[{\"value\":\"5\"}]" jsonPathString:@"$[?(@.value<'7')]" expectedCount:1];
	
	[self checkResultForJSONString:@"[{\"value\":\"7\"}]" jsonPathString:@"$[?(@.value<'5')]" expectedCount:0];
	
	[self checkResultForJSONString:@"[{\"value\":5}]" jsonPathString:@"$[?(@.value<7)]" expectedCount:1];
	[self checkResultForJSONString:@"[{\"value\":7}]" jsonPathString:@"$[?(@.value<5)]" expectedCount:0];
	
	[self checkResultForJSONString:@"[{\"value\":5}]" jsonPathString:@"$[?(@.value<7.1)]" expectedCount:1];
	[self checkResultForJSONString:@"[{\"value\":7}]" jsonPathString:@"$[?(@.value<5.1)]" expectedCount:0];
	
	[self checkResultForJSONString:@"[{\"value\":5.1}]" jsonPathString:@"$[?(@.value<7)]" expectedCount:1];
	[self checkResultForJSONString:@"[{\"value\":7.1}]" jsonPathString:@"$[?(@.value<5)]" expectedCount:0];
}

- (void)test_escape_pattern
{
	[self checkResultForJSONString:@"[\"x\"]" jsonPathString:@"$[?(@ =~ /\\/|x/)]" expectedCount:1];
}

- (void)test_filter_evaluation_does_not_break_path_evaluation
{
	[self checkResultForJSONString:@"[{\"s\": \"fo\", \"expected_size\": \"m\"}, {\"s\": \"lo\", \"expected_size\": 2}]" jsonPathString:@"$[?(@.s size @.expected_size)]" expectedCount:1];
}

@end


NS_ASSUME_NONNULL_END
