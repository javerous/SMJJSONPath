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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/internal/filter/PatternFlagTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseTest.h"

#import "SMJPatternFlags.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJPatternFlagTest
*/
#pragma mark - SMJPatternFlagTest

@interface SMJPatternFlagTest : SMJBaseTest
@end

@implementation SMJPatternFlagTest

- (void)testParseFlags
{
	struct {
		NSRegularExpressionOptions options;
		NSString *flags;
	} data[] = {
		{
			.options = NSRegularExpressionUseUnixLineSeparators,
			.flags = @"d"
		},
		{
			.options = NSRegularExpressionCaseInsensitive,
			.flags = @"i"
		},
		{
			.options = NSRegularExpressionAllowCommentsAndWhitespace,
			.flags = @"x"
		},
		{
			.options = NSRegularExpressionAnchorsMatchLines,
			.flags = @"m"
		},
		{
			.options = NSRegularExpressionDotMatchesLineSeparators,
			.flags = @"s"
		},
		{
			.options = (NSRegularExpressionAllowCommentsAndWhitespace | NSRegularExpressionAnchorsMatchLines | NSRegularExpressionDotMatchesLineSeparators),
			.flags = @"xmsU"
		},
		{
			.options = (NSRegularExpressionUseUnixLineSeparators | NSRegularExpressionAllowCommentsAndWhitespace | NSRegularExpressionAnchorsMatchLines),
			.flags = @"dxm"
		},
		{
			.options = (NSRegularExpressionUseUnixLineSeparators | NSRegularExpressionCaseInsensitive | NSRegularExpressionAllowCommentsAndWhitespace),
			.flags = @"dix"
		},
		{
			.options = (NSRegularExpressionAllowCommentsAndWhitespace | NSRegularExpressionDotMatchesLineSeparators),
			.flags = @"xsu"
		},
		{
			.options = (NSRegularExpressionUseUnixLineSeparators | NSRegularExpressionCaseInsensitive | NSRegularExpressionAllowCommentsAndWhitespace | NSRegularExpressionAnchorsMatchLines | NSRegularExpressionDotMatchesLineSeparators),
			.flags = @"dixmsuU"
		},

	};
	
	for (size_t i = 0; i < sizeof(data) / sizeof(data[0]); i++)
		XCTAssertEqual(data[i].options, [SMJPatternFlags parseFlags:data[i].flags]);
}

@end


NS_ASSUME_NONNULL_END
