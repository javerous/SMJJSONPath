/*
 * SMJArrayIndexOperation.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/filter/PatternFlag.java */


#import "SMJPatternFlags.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJPatternFlags
*/
#pragma mark - SMJPatternFlags

@implementation SMJPatternFlags


+ (NSRegularExpressionOptions)parseFlags:(NSString *)flags
{
	NSUInteger length = flags.length;
	NSRegularExpressionOptions result = 0;
	
	for (NSUInteger i = 0; i < length; i++)
	{
		unichar c = [flags characterAtIndex:i];
		
		result |= [self optionByFlag:c];
	}
	
	return result;
}

+ (NSRegularExpressionOptions)optionByFlag:(unichar)flag
{
	switch (flag)
	{
		case 'd': // UNIX_LINES
			return NSRegularExpressionUseUnixLineSeparators;
			
		case 'i': // CASE_INSENSITIVE
			return NSRegularExpressionCaseInsensitive;
			
		case 'x': // COMMENTS
			return NSRegularExpressionAllowCommentsAndWhitespace;
			
		case 'm': // MULTILINE
			return NSRegularExpressionAnchorsMatchLines;
			
		case 's': // DOTALL
			return NSRegularExpressionDotMatchesLineSeparators;

		case 'u': // UNICODE_CASE
			return 0; // Probably mandatory on macOS.
			
		case 'U': // UNICODE_CHARACTER_CLASS
			return 0; // Not sure if we have an equivalent.
	}
	
	return 0;
}

@end


NS_ASSUME_NONNULL_END
