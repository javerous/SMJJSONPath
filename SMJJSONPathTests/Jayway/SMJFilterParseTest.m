/*
 * SMJFilterParseTest.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/FilterParseTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseTest.h"

#import "SMJFilterCompiler.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJFilterParseTest
*/
@interface SMJFilterParseTest : SMJBaseTest
@end

@implementation SMJFilterParseTest

- (void)checkCompileJSONPathString:(NSString *)jsonPathString expectedError:(BOOL)expectedError
{
	NSError		*error = nil;
	SMJFilter	*filter = [SMJFilterCompiler compileFilterString:jsonPathString error:&error];
	
	if (filter && expectedError)
		XCTFail(@"got a filter while an error was expected");
	else if (!filter && !expectedError)
		XCTFail(@"got an error while a result was expected: %@", error.localizedDescription);
}

- (void)test_a_filter_can_be_parsed
{
	[self checkCompileJSONPathString:@"[?(@.foo)]" expectedError:NO];
	[self checkCompileJSONPathString:@"[?(@.foo == 1)]" expectedError:NO];
	[self checkCompileJSONPathString:@"[?(@.foo == 1 || @['bar'])]" expectedError:NO];
	[self checkCompileJSONPathString:@"[?(@.foo == 1 && @['bar'])]" expectedError:NO];
}

- (void)test_an_invalid_filter_can_not_be_parsed
{
	[self checkCompileJSONPathString:@"[?(@.foo == 1)" expectedError:YES];
	[self checkCompileJSONPathString:@"[?(@.foo == 1) ||]" expectedError:YES];
	[self checkCompileJSONPathString:@"[(@.foo == 1)]" expectedError:YES];
	[self checkCompileJSONPathString:@"[?@.foo == 1)]" expectedError:YES];
}

@end


NS_ASSUME_NONNULL_END
