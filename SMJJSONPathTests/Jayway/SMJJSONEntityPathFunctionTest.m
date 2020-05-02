/*
 * SMJJSONEntityPathFunctionTest.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/internal/function/JSONEntityPathFunctionTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseFunctionTest.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJJSONEntityPathFunctionTest
*/
#pragma mark - SMJJSONEntityPathFunctionTest

@interface SMJJSONEntityPathFunctionTest : SMJBaseFunctionTest
@end

@implementation SMJJSONEntityPathFunctionTest

- (NSString *)jsonBatch
{
	return @"{\n"
	@"  \"batches\": {\n"
	@"    \"minBatchSize\": 10,\n"
	@"    \"results\": [\n"
	@"      {\n"
	@"        \"productId\": 23,\n"
	@"        \"values\": [\n"
	@"          2,\n"
	@"          45,\n"
	@"          34,\n"
	@"          23,\n"
	@"          3,\n"
	@"          5,\n"
	@"          4,\n"
	@"          3,\n"
	@"          2,\n"
	@"          1,\n"
	@"        ]\n"
	@"      },\n"
	@"      {\n"
	@"        \"productId\": 23,\n"
	@"        \"values\": [\n"
	@"          52,\n"
	@"          3,\n"
	@"          12,\n"
	@"          11,\n"
	@"          18,\n"
	@"          22,\n"
	@"          1\n"
	@"        ]\n"
	@"      }\n"
	@"    ]\n"
	@"  }\n"
	@"}";
}

- (void)testLengthOfTextArray
{
	// The length of JSONArray is an integer
	[self checkResultForJSONString:[self jsonTextSeries] jsonPathString:@"$['text'].length()" expectedResult:@6];
	[self checkResultForJSONString:[self jsonTextSeries] jsonPathString:@"$['text'].size()" expectedResult:@6];
}

- (void)testLengthOfNumberArray
{
	// The length of JSONArray is an integer
	[self checkResultForJSONString:[self jsonNumberSeries] jsonPathString:@"$.numbers.length()" expectedResult:@10];
	[self checkResultForJSONString:[self jsonNumberSeries] jsonPathString:@"$.numbers.size()" expectedResult:@10];
}

- (void)testLengthOfStructure
{
	[self checkResultForJSONString:[self jsonBatch] jsonPathString:@"$.batches.length()" expectedResult:@2];
}

/**
 * The fictitious use-case/story - is we have a collection of batches with values indicating some quality metric.
 * We want to determine the average of the values for only the batch's values where the number of items in the batch
 * is greater than the min batch size which is encoded in the JSON document.
 *
 * We use the length function in the predicate to determine the number of values in each batch and then for those
 * batches where the count is greater than min we calculate the average batch value.
 *
 * Its completely contrived example, however, this test exercises functions within predicates.
 */
- (void)testPredicateWithFunctionCallSingleMatch
{
	NSString *path = @"$.batches.results[?(@.values.length() >= $.batches.minBatchSize)].values.avg()";
	
	// Its an array because in some use-cases the min size might match more than one batch and thus we'll get
	// the average out for each collection
	[self checkResultForJSONString:[self jsonBatch] jsonPathString:path expectedResult:@[ @12.2 ]];
}

- (void)testPredicateWithFunctionCallTwoMatches
{
	NSString *path = @"$.batches.results[?(@.values.length() >= 3)].values.avg()";
	
	// Its an array because in some use-cases the min size might match more than one batch and thus we'll get
	// the average out for each collection
	[self checkResultForJSONString:[self jsonBatch] jsonPathString:path expectedResult:@[ @12.2, @17 ]];
}

@end


NS_ASSUME_NONNULL_END
