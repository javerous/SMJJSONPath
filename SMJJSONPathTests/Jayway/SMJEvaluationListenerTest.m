/*
 * SMJEvaluationListenerTest.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/EvaluationListenerTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseTest.h"

#import "SMJEvaluationListener.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJEvaluationListenerGeneric
*/

@interface SMJEvaluationListenerGeneric : NSObject <SMJEvaluationListener>
+ (instancetype)listenerWithBlock:(SMJEvaluationContinuation (^)(id <SMJFoundResult>))block;
@end

@implementation SMJEvaluationListenerGeneric
{
	SMJEvaluationContinuation (^_block)(id <SMJFoundResult>);
}

+ (instancetype)listenerWithBlock:(SMJEvaluationContinuation (^)(id <SMJFoundResult>))block
{
	SMJEvaluationListenerGeneric *result = [SMJEvaluationListenerGeneric new];
	
	result->_block = block;
	
	return result;
}

- (SMJEvaluationContinuation)resultFound:(id <SMJFoundResult>)found
{
	return _block(found);
}

@end


/*
** SMJEvaluationListenerTest
*/
@interface SMJEvaluationListenerTest : SMJBaseTest

@end

@implementation SMJEvaluationListenerTest

- (void)test_an_evaluation_listener_can_abort_after_one_result_using_configuration
{
	SMJEvaluationListenerGeneric *firstResultListener = [SMJEvaluationListenerGeneric listenerWithBlock:^SMJEvaluationContinuation(id<SMJFoundResult> result) {
		return SMJEvaluationContinuationAbort;
	}];
	
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];
	
	[configuration addListener:firstResultListener];

	[self checkResultForJSONString:[self jsonDocument] jsonPathString:@"$..title" configuration:configuration expectedResult:@[ @"Sayings of the Century" ]];
}

- (void)test_an_evaluation_lister_can_continue
{
	NSMutableArray *idxs = [[NSMutableArray alloc] init];
	
	SMJEvaluationListenerGeneric *firstResultListener = [SMJEvaluationListenerGeneric listenerWithBlock:^SMJEvaluationContinuation(id<SMJFoundResult> result) {
		[idxs addObject:@(result.index)];
		return SMJEvaluationContinuationContinue;
	}];
	
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];
	
	[configuration addListener:firstResultListener];
	
	[self checkResultForJSONString:[self jsonDocument]
					jsonPathString:@"$..title"
					 configuration:configuration
					expectedResult:@[ @"Sayings of the Century", @"Sword of Honour", @"Moby Dick", @"The Lord of the Rings" ]];

	id expectedIdxs = @[ @0, @1, @2, @3 ];
	
	XCTAssertEqualObjects(idxs, expectedIdxs);
}

- (void)test_multiple_evaluation_listeners_can_be_added
{
	NSMutableArray *idxs1 = [[NSMutableArray alloc] init];
	NSMutableArray *idxs2 = [[NSMutableArray alloc] init];

	SMJEvaluationListenerGeneric *listener1 = [SMJEvaluationListenerGeneric listenerWithBlock:^SMJEvaluationContinuation(id<SMJFoundResult> result) {
		[idxs1 addObject:@(result.index)];
		return SMJEvaluationContinuationContinue;
	}];
	
	SMJEvaluationListenerGeneric *listener2 = [SMJEvaluationListenerGeneric listenerWithBlock:^SMJEvaluationContinuation(id<SMJFoundResult> result) {
		[idxs2 addObject:@(result.index)];
		return SMJEvaluationContinuationContinue;
	}];
	
	SMJConfiguration *configuration = [SMJConfiguration defaultConfiguration];
	
	[configuration addListener:listener1];
	[configuration addListener:listener2];

	[self checkResultForJSONString:[self jsonDocument]
					jsonPathString:@"$..title"
					 configuration:configuration
					expectedResult:@[ @"Sayings of the Century", @"Sword of Honour", @"Moby Dick", @"The Lord of the Rings" ]];

	id expectedIdxs = @[ @0, @1, @2, @3 ];

	XCTAssertEqualObjects(idxs1, expectedIdxs);
	XCTAssertEqualObjects(idxs2, expectedIdxs);
}

- (void)test_evaluation_listeners_can_be_cleared
{
	SMJEvaluationListenerGeneric *listener = [SMJEvaluationListenerGeneric listenerWithBlock:^SMJEvaluationContinuation(id<SMJFoundResult> result) {
		return SMJEvaluationContinuationContinue;
	}];
	
	SMJConfiguration *configuration1 = [SMJConfiguration defaultConfiguration];
	
	[configuration1 addListener:listener];
	
	SMJConfiguration *configuration2 = [configuration1 copy];

	XCTAssertEqual(configuration1.evaluationListeners.count, 1);
	XCTAssertEqual(configuration2.evaluationListeners.count, 1);

	configuration1.evaluationListeners = @[ ];
	
	XCTAssertEqual(configuration1.evaluationListeners.count, 0);
	XCTAssertEqual(configuration2.evaluationListeners.count, 1);
	
	[configuration2 addListener:listener];
	
	XCTAssertEqual(configuration1.evaluationListeners.count, 0);
	XCTAssertEqual(configuration2.evaluationListeners.count, 2);
}

@end


NS_ASSUME_NONNULL_END
