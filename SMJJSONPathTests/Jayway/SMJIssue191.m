/*
 * SMJIssue191.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/internal/function/Issue191.java */


#import <XCTest/XCTest.h>

#import "SMJBaseTest.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJIssue191
*/
#pragma mark - SMJIssue191

@interface SMJIssue191 : SMJBaseTest
{
	NSString *_jsonString;
}
@end

@implementation SMJIssue191

- (void)setUp
{
	[super setUp];
	
	NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:@"issue_191" ofType:@"json"];
	
	_jsonString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
}

- (void)testResultSetNumericComputation
{
	NSNumber *number = [self checkResultForJSONString:_jsonString jsonPathString:@"$.sum($..timestamp)" expectedError:NO];
	
	XCTAssertEqual(number.longValue, 35679716813);
}

- (void)testResultSetNumericComputationTail
{
	NSNumber *number = [self checkResultForJSONString:_jsonString jsonPathString:@"$..timestamp.sum()" expectedError:NO];
	
	XCTAssertEqual(number.longValue, 35679716813);
}

- (void)testResultSetNumericComputationRecursiveReplacement
{
	NSNumber *number = [self checkResultForJSONString:_jsonString jsonPathString:@"$.max($..timestamp.avg(), $..timestamp.stddev())" expectedError:NO];
	
	XCTAssertEqual(number.longValue, 1427188672);
}

- (void)testMultipleResultSetSums
{
	NSNumber *number = [self checkResultForJSONString:_jsonString jsonPathString:@"$.sum($..timestamp, $..cpus)" expectedError:NO];
		
	XCTAssertEqual(number.longValue, 35679716860);
}

- (void)testConcatResultSet
{
	NSString *concat = [self checkResultForJSONString:_jsonString jsonPathString:@"$.concat($..state)" expectedError:NO];
	
	XCTAssertEqual(concat.length, 806);
}

- (void)testConcatWithNumericValueAsString
{
	NSString *concat = [self checkResultForJSONString:_jsonString jsonPathString:@"$.concat($..cpus)" expectedError:NO];

	XCTAssertEqual(concat.length, 95);
}

@end


NS_ASSUME_NONNULL_END
