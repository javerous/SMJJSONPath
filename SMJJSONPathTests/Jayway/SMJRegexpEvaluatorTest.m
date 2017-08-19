/*
 * SMJRegexpEvaluatorTest.m
 *
 * Copyright 2017 Avérous Julien-Pierre
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/internal/filter/RegexpEvaluatorTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseTest.h"

#import "SMJEvaluatorFactory.h"
#import "SMJRootPathToken.h"
#import "SMJCompiledPath.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJRegexpEvaluatorTest
*/
#pragma mark - SMJRegexpEvaluatorTest

@interface SMJRegexpEvaluatorTest : SMJBaseTest
@end

@implementation SMJRegexpEvaluatorTest

- (void)checkRegexp:(NSString *)regexp valueNode:(SMJValueNode *)valueNode expectedResult:(BOOL)expectedResult
{
	NSError *error = nil;
	
	// > Operator.
	SMJRelationalOperator *operator = [SMJRelationalOperator relationalOperatorFromString:SMJRelationalOperatorREGEX error:&error];
	
	if (!operator)
	{
		XCTFail(@"can't create REGEXP operator: %@", error.localizedDescription);
		return;
	}
	
	// > Evaluator.
	id <SMJEvaluator> evaluator = [SMJEvaluatorFactory createEvaluatorForRelationalOperator:operator error:&error];
	
	if (!evaluator)
	{
		XCTFail(@"can't create evaluator: %@", error.localizedDescription);
		return;
	}
	
	// >
	id <SMJPredicateContext>	context = [self predicateContextForJsonObject:@{}];
	SMJValueNode				 *patternNode = [SMJValueNode patternNodeWithString:regexp];

	SMJEvaluatorEvaluate evaluate = [evaluator evaluateLeftNode:patternNode rightNode:valueNode predicateContext:context error:&error];
	
	if (evaluate == SMJEvaluatorEvaluateError)
		XCTFail(@"evaluation error: %@", error.localizedDescription);
	else if (evaluate == SMJEvaluatorEvaluateTrue && expectedResult == NO)
		XCTFail(@"evaluation returned true while expected false");
	else if (evaluate == SMJEvaluatorEvaluateFalse && expectedResult == YES)
		XCTFail(@"evaluation returned false while expected true");
}

- (void)test_should_evaluate_regular_expression
{
	SMJRootPathToken	*rootPathToken = [[SMJRootPathToken alloc] initWithRootToken:'$'];
	SMJCompiledPath		*rootPath = [[SMJCompiledPath alloc] initWithRootPathToken:rootPathToken isRootPath:YES];
	
	[self checkRegexp:@"/true|false/" valueNode:[SMJValueNode stringNodeWithString:@"true" escape:YES] expectedResult:YES];
	[self checkRegexp:@"/9.*9/" valueNode:[SMJValueNode numberNodeWithString:@"9979"] expectedResult:YES];
	[self checkRegexp:@"/fa.*se/" valueNode:[SMJValueNode booleanNodeWithString:@"false"] expectedResult:YES];
	[self checkRegexp:@"/JsonNode/" valueNode:[SMJValueNode jsonNodeWithString:@"{ 'some': 'JsonNode' }"] expectedResult:NO];
	[self checkRegexp:@"/PathNode/" valueNode:[SMJValueNode pathNodeWithPath:rootPath] expectedResult:NO];
	[self checkRegexp:@"/NullNode/" valueNode:[SMJValueNode nullNode] expectedResult:NO];
}

@end


NS_ASSUME_NONNULL_END
