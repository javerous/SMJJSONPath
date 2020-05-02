/*
 * SMJNestedFunctionTest.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/internal/function/NestedFunctionTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseFunctionTest.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJNestedFunctionTest
*/
#pragma mark - SMJNestedFunctionTest

@interface SMJNestedFunctionTest : SMJBaseFunctionTest
@end

@implementation SMJNestedFunctionTest

- (void)testParameterAverageFunctionCall
{
	[self checkResultForJSONString:[self jsonNumberSeries] jsonPathString:@"$.avg($.numbers.min(), $.numbers.max())" expectedResult:@5.5];
}

- (void)testArrayAverageFunctionCall
{
	[self checkResultForJSONString:[self jsonNumberSeries] jsonPathString:@"$.numbers.avg()" expectedResult:@5.5];
}


/**
 * This test calculates the following:
 *
 * For each number in $.numbers 1 -> 10 add each number up,
 * then add 1 (min), 10 (max)
 *
 * Alternatively 1+2+3+4+5+6+7+8+9+10+1+10 == 66
 */
- (void)testArrayAverageFunctionCallWithParameters
{
	[self checkResultForJSONString:[self jsonNumberSeries] jsonPathString:@"$.numbers.sum($.numbers.min(), $.numbers.max())" expectedResult:@66.0];
}

- (void)testJsonInnerArgumentArray
{
	[self checkResultForJSONString:[self jsonNumberSeries] jsonPathString:@"$.sum(5, 3, $.numbers.max(), 2)" expectedResult:@20.0];
}

- (void)testSimpleLiteralArgument
{
	[self checkResultForJSONString:[self jsonNumberSeries] jsonPathString:@"$.sum(5)" expectedResult:@5.0];
	[self checkResultForJSONString:[self jsonNumberSeries] jsonPathString:@"$.sum(50)" expectedResult:@50.0];

}

- (void)testStringConcat
{
	[self checkResultForJSONString:[self jsonTextSeries] jsonPathString:@"$.text.concat()" expectedResult:@"abcdef"];
}

- (void)testStringConcatWithJSONParameter
{
	[self checkResultForJSONString:[self jsonTextSeries] jsonPathString:@"$.text.concat(\"-\", \"ghijk\")" expectedResult:@"abcdef-ghijk"];
}

- (void)testAppendNumber
{
	[self checkResultForJSONString:[self jsonNumberSeries] jsonPathString:@"$.numbers.append(11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 0).avg()" expectedResult:@10.0];
}


/**
 * Aggregation function should ignore text values // SourceMac-Note: why ?
 */

- (void)testAppendTextAndNumberThenSum
{
	[self checkResultForJSONString:[self jsonNumberSeries] jsonPathString:@"$.numbers.append(\"0\", \"11\").sum()" expectedResult:@55.0];
}

- (void)testErrantCloseBraceNegative
{
	[self checkResultForJSONString:[self jsonNumberSeries] jsonPathString:@"$.numbers.append(0, 1, 2}).avg()" expectedError:YES];
}

- (void)testErrantCloseBracketNegative
{
	[self checkResultForJSONString:[self jsonNumberSeries] jsonPathString:@"$.numbers.append(0, 1, 2]).avg()" expectedError:YES];
}

- (void)testUnclosedFunctionCallNegative
{
	[self checkResultForJSONString:[self jsonNumberSeries] jsonPathString:@"$.numbers.append(0, 1, 2" expectedError:YES];
}

@end


NS_ASSUME_NONNULL_END
