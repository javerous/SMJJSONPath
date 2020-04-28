/*
 * SMJUtils.m
 *
 * Copyright 2019 Avérous Julien-Pierre
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/Utils.java */


#import "SMJUtils.h"


NS_ASSUME_NONNULL_BEGIN


/*
** Prototypes
*/
#pragma mark - Prototypes

static NSString * hexadecimal(uint16_t value);


/*
** SMJUtils
*/
#pragma mark - SMJUtils

@implementation SMJUtils

+ (NSString *)stringByConcatenatingStrings:(NSArray <NSString *> *)strings
{
	if (strings.count == 0)
		return @"";
	
	if (strings.count == 1)
		return [strings[0] copy];
	
	NSInteger length = 0;
	// -1 = no result, -2 = multiple results
	NSInteger indexOfSingleNonEmptyString = -1;
	
	for (NSInteger i = 0; i < strings.count; i++)
	{
		NSString *charSequence = strings[i];
		NSInteger len = charSequence.length;
		
		length += len;
		
		if (indexOfSingleNonEmptyString != -2 && len > 0)
		{
			if (indexOfSingleNonEmptyString == -1)
				indexOfSingleNonEmptyString = i;
			else
				indexOfSingleNonEmptyString = -2;
		}
	}
	
	if (length == 0)
		return @"";
	
	if (indexOfSingleNonEmptyString > 0) {
		return [strings[indexOfSingleNonEmptyString] copy];
	}
	
	NSMutableString *sb = [[NSMutableString alloc] init];

	for (NSString *charSequence in strings)
		[sb appendString:charSequence];
	
	return sb;
}


+ (NSString *)stringByJoiningStrings:(NSArray <NSString *> *)strings delimiter:(NSString *)delimiter wrap:(NSString *)wrap
{
	if (strings.count == 0)
		return @"";

	NSMutableString *buffer = [[NSMutableString alloc] init];
	
	[strings enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		
		if (idx > 0)
			[buffer appendString:delimiter];
		
		[buffer appendString:wrap];
		[buffer appendString:obj];
		[buffer appendString:wrap];
	}];

	return buffer;
}

+ (NSString *)stringByEscapingString:(NSString *)str escapeSingleQuote:(BOOL)escapeSingleQuote
{
	NSInteger len = str.length;
	NSMutableString *writer = [NSMutableString string];
	
	for (NSInteger i = 0; i < len; i++)
	{
		unichar ch = [str characterAtIndex:i];
		
		// handle unicode
		if (ch > 0xfff)
			[writer appendFormat:@"\\u%@", hexadecimal(ch)];
		else if (ch > 0xff)
			[writer appendFormat:@"\\u0%@", hexadecimal(ch)];
		else if (ch > 0x7f)
			[writer appendFormat:@"\\u00%@", hexadecimal(ch)];
		else if (ch < 32)
		{
			switch (ch)
			{
				case '\b':
					[writer appendString:@"\\b"];
					break;
					
				case '\n':
					[writer appendString:@"\\n"];
					break;
					
				case '\t':
					[writer appendString:@"\\t"];
					break;
					
				case '\f':
					[writer appendString:@"\\f"];
					break;
					
				case '\r':
					[writer appendString:@"\\r"];
					break;
					
				default :
					if (ch > 0xf)
						[writer appendFormat:@"\\u00%@", hexadecimal(ch)];
					else
						[writer appendFormat:@"\\u000%@", hexadecimal(ch)];
					break;
			}
		}
		else
		{
			switch (ch)
			{
				case '\'':
					if (escapeSingleQuote)
						[writer appendString:@"\\"];
					[writer appendString:@"'"];
					break;
					
				case '"':
					[writer appendString:@"\\\""];
					break;
					
				case '\\':
					[writer appendString:@"\\\\"];
					break;
					
				case '/':
					[writer appendString:@"\\/"];
					break;
					
				default :
					[writer appendString:[NSString stringWithCharacters:&ch length:1]];
					break;
			}
		}
	}
	
	return writer;
}

+ (NSString *)stringByUnescapingString:(NSString *)str
{
	if (!str)
		return nil;
	
	NSInteger len = str.length;
	
	NSMutableString *writer = [NSMutableString string];
	NSMutableString *unicode = [NSMutableString string];

	BOOL hadSlash = false;
	BOOL inUnicode = false;
	
	for (NSInteger i = 0; i < len; i++)
	{
		unichar ch = [str characterAtIndex:i];
		
		if (inUnicode)
		{
			[unicode appendString:[NSString stringWithCharacters:&ch length:1]];
			
			if (unicode.length == 4)
			{
				unichar value = (unichar)[unicode integerValue];
				
				[unicode setString:@""];
				
				inUnicode = NO;
				hadSlash = NO;
				
				[writer appendString:[NSString stringWithCharacters:&value length:1]];
			}
			
			continue;
		}
		
		if (hadSlash)
		{
			unichar final = -1;
			
			hadSlash = NO;
			
			switch (ch)
			{
				case '\\':
					final = '\\';
					break;
				case '\'':
					final = '\'';
					break;
				case '\"':
					final = '"';
					break;
				case 'r':
					final = '\r';
					break;
				case 'f':
					final = '\f';
					break;
				case 't':
					final = '\t';
					break;
				case 'n':
					final = '\n';
					break;
				case 'b':
					final = '\b';
					break;
				case 'u':
				{
					inUnicode = true;
					break;
				}
				default :
					final = ch;
					break;
			}
			
			if (!inUnicode)
				[writer appendString:[NSString stringWithCharacters:&final length:1]];
			
			continue;
		}
		else if (ch == '\\')
		{
			hadSlash = YES;
			continue;
		}
		
		[writer appendString:[NSString stringWithCharacters:&ch length:1]];
	}
	
	if (hadSlash)
		[writer appendString:@"\\"];
	
	return writer;
}

+ (nullable NSNumber *)numberWithString:(NSString *)string
{
	NSScanner *scanner;

#if TARGET_OS_OSX // scanUnsignedLongLong is not available in GNUstep yet

	// Test unsigned long long int.
	unsigned long long unsignedLongLong = 0;

	scanner = [NSScanner scannerWithString:string];
	
	scanner.charactersToBeSkipped = [NSCharacterSet whitespaceCharacterSet];
	
	if ([scanner scanUnsignedLongLong:&unsignedLongLong] && scanner.isAtEnd)
		return @(unsignedLongLong);

#endif /* TARGET_OS_OSX */

	// Test signed long long int.
	long long signedLongLong = 0;
	
	scanner = [NSScanner scannerWithString:string];

	scanner.charactersToBeSkipped = [NSCharacterSet whitespaceCharacterSet];

	if ([scanner scanLongLong:&signedLongLong] && scanner.isAtEnd)
		return @(signedLongLong);

	
	// Test double.
	double doubleValue = 0.0;
	
	scanner = [NSScanner scannerWithString:string];

	scanner.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
	scanner.charactersToBeSkipped = [NSCharacterSet whitespaceCharacterSet];
	
	if ([scanner scanDouble:&doubleValue] && scanner.isAtEnd)
		return @(doubleValue);
	
	return nil;
}

@end



/*
** C Tools
*/
#pragma mark - C Tools

static NSString * hexadecimal(uint16_t value)
{
	const char	hexTable[] = "0123456789ABCDEF";
	char 		buffer[50];
	NSUInteger	index = sizeof(buffer) - 1;
	
	do
	{
		buffer[index] = hexTable[value % 16];
		value /= 16;
		index--;
	} while (value != 0 && index > 0);
	
	return [[NSString alloc] initWithBytes:buffer + index + 1 length:sizeof(buffer) - index - 1 encoding:NSASCIIStringEncoding];
}

NS_ASSUME_NONNULL_END
