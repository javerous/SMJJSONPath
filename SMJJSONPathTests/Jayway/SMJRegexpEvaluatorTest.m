/*
 * SMJRegexpEvaluatorTest.m
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
	SMJValueNode				 *patternNode = [SMJValueNodes patternNodeWithString:regexp];

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
	
	[self checkRegexp:@"/true|false/" valueNode:[SMJValueNodes stringNodeWithString:@"true" escape:YES] expectedResult:YES];
	[self checkRegexp:@"/9.*9/" valueNode:[SMJValueNodes numberNodeWithString:@"9979"] expectedResult:YES];
	[self checkRegexp:@"/fa.*se/" valueNode:[SMJValueNodes booleanNodeWithString:@"false"] expectedResult:YES];
	[self checkRegexp:@"/JsonNode/" valueNode:[SMJValueNodes jsonNodeWithString:@"{ 'some': 'JsonNode' }"] expectedResult:NO];
	[self checkRegexp:@"/PathNode/" valueNode:[SMJValueNodes pathNodeWithPath:rootPath] expectedResult:NO];
	[self checkRegexp:@"/NullNode/" valueNode:[SMJValueNodes nullNode] expectedResult:NO];
	
	[self checkRegexp:@"/test/i" valueNode:[SMJValueNodes stringNodeWithString:@"tEsT" escape:YES] expectedResult:YES];
	[self checkRegexp:@"/test/" valueNode:[SMJValueNodes stringNodeWithString:@"tEsT" escape:YES] expectedResult:NO];
	[self checkRegexp:@"/\u00de/ui" valueNode:[SMJValueNodes stringNodeWithString:@"\u00fe" escape:YES] expectedResult:YES];
	
	// XXX we don't have this kind of unicode control on macOS (it's implicit and mandatory), so we can't test it's rejected without 'u' option.
	[self checkRegexp:@"/\u00de/" valueNode:[SMJValueNodes stringNodeWithString:@"\u00fe" escape:YES] expectedResult:NO];
	//[self checkRegexp:@"/\u00de/i" valueNode:[SMJValueNodes stringNodeWithString:@"\u00fe" escape:YES] expectedResult:NO];
	
	[self checkRegexp:@"/test# code/" valueNode:[SMJValueNodes stringNodeWithString:@"test" escape:YES] expectedResult:NO];
	[self checkRegexp:@"/test# code/x" valueNode:[SMJValueNodes stringNodeWithString:@"test" escape:YES] expectedResult:YES];
	
	// XXX test from json-path do :
	//  > "my\rtest" & "/.*test.*/d" -> true
	//  > "my\rtest" & "/.*test.*/" -> false
	// by default . doesn't match newline, so :
	//  > with 'd', . can match \r but not \n
	//  > without 'd', . can't match \r or \n
	// but the * mean 0 or more, so even if . doesn't match a newline, the * ignore it
	// the test are fixed by removing *
	[self checkRegexp:@"/.test.*/d" valueNode:[SMJValueNodes stringNodeWithString:@"my\rtest" escape:YES] expectedResult:YES];
	[self checkRegexp:@"/.test.*/" valueNode:[SMJValueNodes stringNodeWithString:@"my\rtest" escape:YES] expectedResult:NO];
	
	// XXX test from json-path do
	//  > "test\ntest" & "/.*tEst.*/is" -> true
	//  > "test\ntest" & "/.*tEst.*/i" -> false
	// the problem is the same than the previous one : even if . doesn't match a new line, the * ignore it.
	// the test are fixed by removing *
	[self checkRegexp:@"/.tEst.*/is" valueNode:[SMJValueNodes stringNodeWithString:@"test\ntest" escape:YES] expectedResult:YES];
	[self checkRegexp:@"/.tEst.*/i" valueNode:[SMJValueNodes stringNodeWithString:@"test\ntest" escape:YES] expectedResult:NO];
	
	// XXX we don't have this kind of unicode control on macOS (it's implicit and mandatory), so we can't test it's rejected without 'U' option.
	[self checkRegexp:@"/^\\w+$/U" valueNode:[SMJValueNodes stringNodeWithString:@"\u00fe" escape:YES] expectedResult:YES];
	//[self checkRegexp:@"/^\\w+$/" valueNode:[SMJValueNodes stringNodeWithString:@"\u00fe" escape:YES] expectedResult:NO];
	[self checkRegexp:@"/^test$\\ntest$/m" valueNode:[SMJValueNodes stringNodeWithString:@"test\ntest" escape:YES] expectedResult:YES];
}

@end


NS_ASSUME_NONNULL_END
