/*
 * SMJPathTokenTest.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/internal/path/PathTokenTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseTest.h"

#import "SMJPathToken.h"
#import "SMJPropertyPathToken.h"
#import "SMJWildcardPathToken.h"
#import "SMJScanPathToken.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJPathTokenTest
*/
#pragma mark - SMJPathTokenTest

@interface SMJPathTokenTest : SMJBaseTest
@end

@implementation SMJPathTokenTest

- (SMJPathToken *)makePathReturningTail:(NSArray <SMJPathToken *> *)tokens
{
	SMJPathToken *last = nil;
	
	for (SMJPathToken *token in tokens)
	{
		if (last != nil)
			[last appendTailToken:token];
		
		last = token;
	}

	return last;
}

- (SMJPathToken *)makePTT:(NSArray <NSString *> *)properties
{
	return [[SMJPropertyPathToken alloc] initWithProperties:properties delimiter:'\'' error:nil];
}

- (void)test_is_upstream_definite_in_simple_case
{
	BOOL result;
	
	result = [[self makePathReturningTail:@[ [self makePTT:@[ @"foo" ]] ]] isUpstreamDefinite];
	XCTAssertTrue(result);
	
	result = [[self makePathReturningTail:@[ [self makePTT:@[ @"foo" ]], [self makePTT:@[ @"bar" ]] ]] isUpstreamDefinite];
	XCTAssertTrue(result);
	
	result = [[self makePathReturningTail:@[ [self makePTT:@[ @"foo", @"foo2" ]], [self makePTT:@[ @"bar" ]] ]] isUpstreamDefinite];
	XCTAssertFalse(result);
	
	result = [[self makePathReturningTail:@[ [[SMJWildcardPathToken alloc] init], [self makePTT:@[ @"bar" ]] ]] isUpstreamDefinite];
	XCTAssertFalse(result);
	
	result = [[self makePathReturningTail:@[ [[SMJScanPathToken alloc] init], [self makePTT:@[ @"bar" ]] ]] isUpstreamDefinite];
	XCTAssertFalse(result);
}

- (void)test_is_upstream_definite_in_complex_case
{
	BOOL result;
	
	result = [[self makePathReturningTail:@[ [self makePTT:@[ @"foo" ]], [self makePTT:@[ @"bar" ]], [self makePTT:@[ @"baz" ]] ]] isUpstreamDefinite];
	XCTAssertTrue(result);
	
	result = [[self makePathReturningTail:@[ [self makePTT:@[ @"foo" ]], [[SMJWildcardPathToken alloc] init] ]] isUpstreamDefinite];
	XCTAssertTrue(result);
	
	result = [[self makePathReturningTail:@[ [[SMJWildcardPathToken alloc] init], [self makePTT:@[ @"bar" ]], [self makePTT:@[ @"baz" ]] ]] isUpstreamDefinite];
	XCTAssertFalse(result);
}

@end


NS_ASSUME_NONNULL_END
