/*
 * SMJFilterTest.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/FilterTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseTest.h"
#import "SMJFilterCompiler.h"

#import "SMJJSONPath.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJFilterTest
*/
@interface SMJFilterTest : SMJBaseTest
@end

@implementation SMJFilterTest


/*
** SMJFilterTest - Helper
*/
#pragma mark - SMJFilterTest - Helper

- (id)jsonObject
{
	static dispatch_once_t	onceToken;
	static id				jsonObject;
	
	dispatch_once(&onceToken, ^{
		
		NSMutableString *jsonString = [NSMutableString new];
		
		[jsonString appendString:@"{"];
		[jsonString appendString:@"  \"int-key\" : 1, "];
		[jsonString appendString:@"  \"long-key\" : 3000000000, "];
		[jsonString appendString:@"  \"double-key\" : 10.1, "];
		[jsonString appendString:@"  \"boolean-key\" : true, "];
		[jsonString appendString:@"  \"null-key\" : null, "];
		[jsonString appendString:@"  \"string-key\" : \"string\", "];
		[jsonString appendString:@"  \"string-key-empty\" : \"\", "];
		[jsonString appendString:@"  \"char-key\" : \"c\", "];
		[jsonString appendString:@"  \"arr-empty\" : [], "];
		[jsonString appendString:@"  \"int-arr\" : [0,1,2,3,4], "];
		[jsonString appendString:@"  \"string-arr\" : [\"a\",\"b\",\"c\",\"d\",\"e\"] "];
		[jsonString appendString:@"}"];
		
		jsonObject = [self jsonObjectFromString:jsonString];
	});

	return jsonObject;
}

- (void)checkApplyFilterString:(NSString *)filterString expectedResult:(BOOL)expectedResult
{
	[self checkApplyFilterString:filterString jsonObject:[self jsonObject] expectedResult:expectedResult];
}

- (void)checkApplyFilterString:(NSString *)filterString jsonObject:(id)jsonObject expectedResult:(BOOL)expectedResult
{
	NSError		*error = nil;
	SMJFilter	*filter = [SMJFilterCompiler compileFilterString:filterString error:&error];
	
	if (!filter)
	{
		XCTFail("can't compilter filter: %@", error.localizedDescription);
		return;
	}
	
	id <SMJPredicateContext>	predicateContext = [self predicateContextForJsonObject:jsonObject];
	SMJPredicateApply			apply = [filter applyWithContext:predicateContext error:&error];
	
	if (apply == SMJPredicateApplyError)
	{
		XCTFail("can't apply filter to json object: %@", error.localizedDescription);
	}else if (apply == SMJPredicateApplyTrue && expectedResult == false)
		XCTFail("filter returned true while false was expected");
	else if (apply == SMJPredicateApplyFalse && expectedResult == true)
		XCTFail("filter returned false while true was expected");
}


/*
** SMJFilterTest - EQ
*/
#pragma mark - SMJFilterTest - EQ

- (void)test_int_eq_evals
{
	[self checkApplyFilterString:@"[?(@.int-key == 1)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.int-key == 666)]" expectedResult:NO];
}

- (void)test_int_eq_string_evals
{
	[self checkApplyFilterString:@"[?(@.int-key == '1')]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.int-key == '666')]" expectedResult:NO];

	[self checkApplyFilterString:@"[?(1 == '1')]" expectedResult:YES];
	[self checkApplyFilterString:@"[?('1' == 1)]" expectedResult:YES];
	
	[self checkApplyFilterString:@"[?(1 === '1')]" expectedResult:NO];
	[self checkApplyFilterString:@"[?('1' === 1)]" expectedResult:NO];

	[self checkApplyFilterString:@"[?(1 === 1)]" expectedResult:YES];
}

- (void)test_long_eq_evals
{
	[self checkApplyFilterString:@"[?(@.long-key == 3000000000)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.long-key == 666)]" expectedResult:NO];
}

- (void)test_double_eq_evals
{
	[self checkApplyFilterString:@"[?(@.double-key == 10.1)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.double-key == 10.10)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.double-key == 10.11)]" expectedResult:NO];
}

- (void)test_string_eq_evals
{
	[self checkApplyFilterString:@"[?(@.string-key == 'string')]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.string-key == '666')]" expectedResult:NO];
}

- (void)test_boolean_eq_evals
{
	[self checkApplyFilterString:@"[?(@.boolean-key == true)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.boolean-key == false)]" expectedResult:NO];
}

- (void)test_null_eq_evals
{
	[self checkApplyFilterString:@"[?(@.null-key == null)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.null-key == '666')]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.string-key == null)]" expectedResult:NO];
}

- (void)test_arr_eq_evals
{
	[self checkApplyFilterString:@"[?(@.arr-empty == [])]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.int-arr == [0,1,2,3,4])]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.int-arr == [0,1,2,3])]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.int-arr == [0,1,2,3,4,5])]" expectedResult:NO];
}


/*
** SMJFilterTest - NE
*/
#pragma mark - SMJFilterTest - NE

- (void)test_int_ne_evals
{
	[self checkApplyFilterString:@"[?(@.int-key != 1)]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.int-key != 666)]" expectedResult:YES];
}

- (void)test_long_ne_evals
{
	[self checkApplyFilterString:@"[?(@.long-key != 3000000000)]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.long-key != 666)]" expectedResult:YES];
}

- (void)test_double_ne_evals
{
	[self checkApplyFilterString:@"[?(@.double-key != 10.1)]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.double-key != 10.10)]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.double-key != 10.11)]" expectedResult:YES];
}

- (void)test_string_ne_evals
{
	[self checkApplyFilterString:@"[?(@.string-key != 'string')]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.string-key != '666')]" expectedResult:YES];
}

- (void)test_boolean_ne_evals
{
	[self checkApplyFilterString:@"[?(@.boolean-key != true)]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.boolean-key != false)]" expectedResult:YES];
}

- (void)test_null_ne_evals
{
	[self checkApplyFilterString:@"[?(@.null-key != null)]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.null-key != '666')]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.string-key != null)]" expectedResult:YES];
}


/*
** SMJFilterTest - LT
*/
#pragma mark - SMJFilterTest - LT

- (void)test_int_lt_evals
{
	[self checkApplyFilterString:@"[?(@.int-key < 10)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.int-key < 0)]" expectedResult:NO];
}

- (void)test_long_lt_evals
{
	[self checkApplyFilterString:@"[?(@.long-key < 4000000000)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.long-key < 666)]" expectedResult:NO];
}

- (void)test_double_lt_evals
{
	[self checkApplyFilterString:@"[?(@.double-key < 100.1)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.double-key < 1.1)]" expectedResult:NO];
}

- (void)test_string_lt_evals
{
	[self checkApplyFilterString:@"[?(@.char-key < 'x')]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.char-key < 'a')]" expectedResult:NO];
}


/*
** SMJFilterTest - LTE
*/
#pragma mark - SMJFilterTest - LTE

- (void)test_int_lte_evals
{
	[self checkApplyFilterString:@"[?(@.int-key <= 10)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.int-key <= 1)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.int-key <= 0)]" expectedResult:NO];
}

- (void)test_long_lte_evals
{
	[self checkApplyFilterString:@"[?(@.long-key <= 4000000000)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.long-key <= 3000000000)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.long-key <= 666)]" expectedResult:NO];
}

- (void)test_double_lte_evals
{
	[self checkApplyFilterString:@"[?(@.double-key <= 100.1)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.double-key <= 10.1)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.double-key <= 1.1)]" expectedResult:NO];
}


/*
** SMJFilterTest - GT
*/
#pragma mark - SMJFilterTest - GT

- (void)test_int_gt_evals
{
	[self checkApplyFilterString:@"[?(@.int-key > 10)]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.int-key > 0)]" expectedResult:YES];
}

- (void)test_long_gt_evals
{
	[self checkApplyFilterString:@"[?(@.long-key > 4000000000)]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.long-key > 666)]" expectedResult:YES];
}

- (void)test_double_gt_evals
{
	[self checkApplyFilterString:@"[?(@.double-key > 100.1)]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.double-key > 1.1)]" expectedResult:YES];
}

- (void)test_string_gt_evals
{
	[self checkApplyFilterString:@"[?(@.char-key > 'x')]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.char-key > 'a')]" expectedResult:YES];
}


/*
** SMJFilterTest - GTE
*/
#pragma mark - SMJFilterTest - GTE

- (void)test_int_gte_evals
{
	[self checkApplyFilterString:@"[?(@.int-key >= 10)]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.int-key >= 1)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.int-key >= 0)]" expectedResult:YES];
}

- (void)test_long_gte_evals
{
	[self checkApplyFilterString:@"[?(@.long-key >= 4000000000)]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.long-key >= 3000000000)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.long-key >= 666)]" expectedResult:YES];
}

- (void)test_double_gte_evals
{
	[self checkApplyFilterString:@"[?(@.double-key >= 100.1)]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.double-key >= 10.1)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.double-key >= 1.1)]" expectedResult:YES];
}


/*
** SMJFilterTest - Regex
*/
#pragma mark - SMJFilterTest - Regex

- (void)test_string_regex_evals
{
	[self checkApplyFilterString:@"[?(@.string-key =~ /^string$/)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.string-key =~ /^tring$/)]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.null-key =~ /^string$/)]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.int-key =~ /^string$/)]" expectedResult:NO];
}


/*
** SMJFilterTest - JSON equality
*/
#pragma mark - SMJFilterTest - JSON equality

- (void)test_json_evals
{
	NSString	*nest = @"{\"a\":true}";
	NSString	*arr = @"[1,2]";
	NSString	*json = [NSString stringWithFormat:@"{\"foo\":%@, \"bar\":%@}", arr, nest];
	NSString	*filter = [NSString stringWithFormat:@"[?(@.foo == %@)]", arr];
	
	[self checkApplyFilterString:filter jsonObject:[self jsonObjectFromString:json] expectedResult:YES];
}


/*
** SMJFilterTest - IN
*/
#pragma mark - SMJFilterTest - IN

- (void)test_string_in_evals
{
	[self checkApplyFilterString:@"[?(@.string-key IN [\"a\", null, \"string\"])]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.string-key IN [\"a\", null])]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.null-key IN [\"a\", null])]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.null-key IN [\"a\", \"b\"])]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.string-arr IN [\"a\"])]" expectedResult:NO];
}


/*
** SMJFilterTest - NIN
*/
#pragma mark - SMJFilterTest - NIN

- (void)test_string_nin_evals
{
	[self checkApplyFilterString:@"[?(@.string-key NIN [\"a\", null, \"string\"])]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.string-key NIN [\"a\", null])]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.null-key NIN [\"a\", null])]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.null-key NIN [\"a\", \"b\"])]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.string-arr NIN [\"a\"])]" expectedResult:YES];
}


/*
** SMJFilterTest - ALL
*/
#pragma mark - SMJFilterTest - ALL

- (void)test_int_all_evals
{
	[self checkApplyFilterString:@"[?(@.int-arr ALL [0, 1])]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.int-arr ALL [0, 7])]" expectedResult:NO];
}

- (void)test_string_all_evals
{
	[self checkApplyFilterString:@"[?(@.string-arr ALL [\"a\",\"b\"])]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.string-arr ALL [\"a\",\"x\"])]" expectedResult:NO];
}

- (void)test_not_array_all_evals
{
	[self checkApplyFilterString:@"[?(@.string-key ALL [\"a\",\"b\"])]" expectedResult:NO];
}


/*
** SMJFilterTest - SIZE
*/
#pragma mark - SMJFilterTest - SIZE

- (void)test_array_size_evals
{
	[self checkApplyFilterString:@"[?(@.string-arr SIZE 5)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.string-arr SIZE 7)]" expectedResult:NO];
}

- (void)test_string_size_evals
{
	[self checkApplyFilterString:@"[?(@.string-key SIZE 6)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.string-key SIZE 7)]" expectedResult:NO];
}

- (void)test_other_size_evals
{
	[self checkApplyFilterString:@"[?(@.int-key SIZE 6)]" expectedResult:NO];
}

- (void)test_null_size_evals
{
	[self checkApplyFilterString:@"[?(@.null-key SIZE 6)]" expectedResult:NO];
}


/*
** SMJFilterTest - SUBSETOF
*/
#pragma mark - SMJFilterTest - SUBSETOF

- (void)test_array_subsetof_evals
{
	[self checkApplyFilterString:@"[?(@.string-arr SUBSETOF [ \"a\", \"b\", \"c\", \"d\", \"e\", \"f\", \"g\" ])]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.string-arr SUBSETOF [ \"e\", \"d\", \"b\", \"c\", \"a\" ])]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.string-arr SUBSETOF [ \"a\", \"b\", \"c\", \"d\" ])]" expectedResult:NO];
}


/*
** SMJFilterTest - ANYOF
*/
#pragma mark - SMJFilterTest - ANYOF

- (void)test_array_anyof_evals
{
	[self checkApplyFilterString:@"[?(@.string-arr ANYOF [ \"a\", \"z\" ])]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.string-arr ANYOF [ \"z\", \"b\", \"a\" ])]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.string-arr ANYOF [ \"x\", \"y\", \"z\" ])]" expectedResult:NO];
}


/*
** SMJFilterTest - NONEOF
*/
#pragma mark - SMJFilterTest - NONEOF

- (void)test_array_noneof_evals
{
	[self checkApplyFilterString:@"[?(@.string-arr NONEOF [ \"a\", \"z\" ])]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.string-arr NONEOF [ \"z\", \"b\", \"a\" ])]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.string-arr NONEOF [ \"x\", \"y\", \"z\" ])]" expectedResult:YES];
}


/*
** SMJFilterTest - EXISTS
*/
#pragma mark - SMJFilterTest - EXISTS

- (void)test_exists_evals
{
	// SourceMac-Note: we support the "EXISTS" token, event if it's similar (and so redoundant) to don't use operator and right value.

	[self checkApplyFilterString:@"[?(@.string-key EXISTS true)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.string-key EXISTS false)]" expectedResult:NO];
	
	[self checkApplyFilterString:@"[?(@.missing-key EXISTS true)]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.missing-key EXISTS false)]" expectedResult:true];
}


/*
** SMJFilterTest - TYPE
*/
#pragma mark - SMJFilterTest - TYPE

- (void)test_type_evals
{
	[self checkApplyFilterString:@"[?(@.string-key TYPE 'string')]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.string-key TYPE 'number')]" expectedResult:NO];

	[self checkApplyFilterString:@"[?(@.int-key TYPE 'string')]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.int-key TYPE 'number')]" expectedResult:YES];
	
	[self checkApplyFilterString:@"[?(@.int-arr TYPE 'json')]" expectedResult:YES];

	[self checkApplyFilterString:@"[?(@.string-key TYPE @.string-key)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.string-key TYPE @.int-key)]" expectedResult:NO];
}


/*
** SMJFilterTest - EMPTY
*/
#pragma mark - SMJFilterTest - EMPTY

- (void)test_empty_evals
{
	[self checkApplyFilterString:@"[?(@.string-key EMPTY false)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.string-key EMPTY true)]" expectedResult:NO];

	[self checkApplyFilterString:@"[?(@.string-key-empty EMPTY true)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.string-key-empty EMPTY false)]" expectedResult:NO];
	
	[self checkApplyFilterString:@"[?(@.int-arr EMPTY false)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.int-arr EMPTY true)]" expectedResult:NO];

	[self checkApplyFilterString:@"[?(@.arr-empty EMPTY true)]" expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.arr-empty EMPTY false)]" expectedResult:NO];

	[self checkApplyFilterString:@"[?(@.null-key EMPTY true)]" expectedResult:NO];
	[self checkApplyFilterString:@"[?(@.null-key EMPTY false)]" expectedResult:NO];
}


/*
** SMJFilterTest - OR
*/
#pragma mark - SMJFilterTest - OR

- (void)test_or_and_filters_evaluates
{
	NSDictionary *model = @{
		@"foo" : @YES,
		@"bar" : @NO
	};
	
	[self checkApplyFilterString:@"[?(@.foo == true || @.bar == true)]" jsonObject:model expectedResult:YES];
	[self checkApplyFilterString:@"[?(@.foo == true && @.bar == true)]" jsonObject:model expectedResult:NO];
}

- (void)testFilterWithOrShortCircuit1
{
	id json = [self jsonObjectFromString:@"{\"firstname\":\"Bob\",\"surname\":\"Smith\",\"age\":30}"];
	
	[self checkApplyFilterString:@"[?((@.firstname == 'Bob' || @.firstname == 'Jane') && @.surname == 'Doe')]" jsonObject:json expectedResult:NO];
}

- (void)testFilterWithOrShortCircuit2
{
	id json = [self jsonObjectFromString:@"{\"firstname\":\"Bob\",\"surname\":\"Smith\",\"age\":30}"];
	
	[self checkApplyFilterString:@"[?((@.firstname == 'Bob' || @.firstname == 'Jane') && @.surname == 'Smith')]" jsonObject:json expectedResult:YES];
}


/*
** SMJFilterTest - Others
*/
#pragma mark - SMJFilterTest - Others

- (void)test_inline_in_criteria_evaluates
{
	[self checkResultForJSONString:[self jsonDocument]
					jsonPathString:@"$.store.book[?(@.category in [\"reference\", \"fiction\"])]"
					 expectedCount:4];
}

@end


NS_ASSUME_NONNULL_END
