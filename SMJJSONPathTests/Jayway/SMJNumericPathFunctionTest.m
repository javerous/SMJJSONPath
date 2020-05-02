/*
 * SMJNumericPathFunctionTest.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/internal/function/NumericPathFunctionTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseFunctionTest.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJNumericPathFunctionTest
*/
#pragma mark - SMJNumericPathFunctionTest

@interface SMJNumericPathFunctionTest : SMJBaseFunctionTest
@end

@implementation SMJNumericPathFunctionTest

- (void)testAverageOfDoubles
{
	[self checkResultForJSONString:[self jsonNumberSeries] jsonPathString:@"$.numbers.avg()" expectedResult:@5.5];
}

- (void)testAverageOfEmptyListNegative
{
	[self checkResultForJSONString:[self jsonNumberSeries] jsonPathString:@"$.empty.avg()" expectedError:YES];
}

- (void)testSumOfDouble
{
	[self checkResultForJSONString:[self jsonNumberSeries] jsonPathString:@"$.numbers.sum()" expectedResult:@((10.0 * (10.0 + 1.0)) / 2.0)];
}

- (void)testSumOfEmptyListNegative
{
	[self checkResultForJSONString:[self jsonNumberSeries] jsonPathString:@"$.empty.sum()" expectedError:YES];
}

- (void)testMaxOfDouble
{
	[self checkResultForJSONString:[self jsonNumberSeries] jsonPathString:@"$.numbers.max()" expectedResult:@10];
}

- (void)testMaxOfEmptyListNegative
{
	[self checkResultForJSONString:[self jsonNumberSeries] jsonPathString:@"$.empty.max()" expectedError:YES];
}

- (void)testMinOfDouble
{
	[self checkResultForJSONString:[self jsonNumberSeries] jsonPathString:@"$.numbers.min()" expectedResult:@1];
}

- (void)testMinOfEmptyListNegative
{
	[self checkResultForJSONString:[self jsonNumberSeries] jsonPathString:@"$.empty.min()" expectedError:YES];
}

- (void)testStdDevOfDouble
{
	[self checkResultForJSONString:[self jsonNumberSeries] jsonPathString:@"$.numbers.stddev()" expectedResult:@2.8722813232690143];
}

- (void)testStddevOfEmptyListNegative
{
	[self checkResultForJSONString:[self jsonNumberSeries] jsonPathString:@"$.empty.stddev()" expectedError:YES];
}

@end


NS_ASSUME_NONNULL_END
