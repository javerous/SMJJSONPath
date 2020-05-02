/*
 * SMJPathCompiler.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/path/PathCompiler.java */


#import "SMJPathCompiler.h"

#import "SMJUtils.h"

#import "SMJCharacterIndex.h"

#import "SMJCompiledPath.h"

#import "SMJFilterCompiler.h"

#import "SMJPath.h"
#import "SMJRootPathToken.h"
#import "SMJScanPathToken.h"
#import "SMJFunctionPathToken.h"
#import "SMJPropertyPathToken.h"
#import "SMJPredicatePathToken.h"
#import "SMJArraySliceToken.h"
#import "SMJArrayIndexToken.h"
#import "SMJWildcardPathToken.h"


#import "SMJParameter.h"

#import "SMJArrayIndexOperation.h"
#import "SMJArraySliceOperation.h"



NS_ASSUME_NONNULL_BEGIN


/*
** Defines
*/
#pragma mark - Defines

#define kDocContextChar			'$'
#define kEvalContextChar		'@'

#define kOpenSquareBracketChar	'['
#define kCloseSquareBracketChar	']'
#define kOpenParenthesisChar	'('
#define kCloseParenthesisChar	')'
#define kOpenBraceChar			'{'
#define kCloseBraceChar			'}'

#define kWildcardChar 			'*'
#define kPeriodChar				'.'
#define kSpaceChar 				' '
#define kTabChar				'\t'
#define kCarriageReturnChar 	'\r'
#define kLineFeedChar			'\n'
#define kBeginFilterChar		'?'
#define kCommaChar				','
#define kSplitChar				':'
#define kMinusChar				'-'
#define kSingleQuoteChar		'\''
#define kDoubleQuote			'"'


/*
** Macros
*/
#pragma mark - Macros

#define SMSetError(Error, Code, Message, ...) \
	do { \
		if ((Error) && *(Error) == nil) {\
			NSString *___message = [NSString stringWithFormat:(Message), ## __VA_ARGS__];\
			*(Error) = [NSError errorWithDomain:@"SMJPathCompilerErrorDomain" code:(Code) userInfo:@{ NSLocalizedDescriptionKey : ___message }]; \
		} \
	} while (0) \



/*
** SMJPathCompiler
*/
#pragma mark - SMJPathCompiler

@implementation SMJPathCompiler
{
	SMJCharacterIndex *_path;
}


/*
** SMJPathCompiler - Instance
*/
#pragma mark - SMJPathCompiler - Instance

- (instancetype)initWithPath:(SMJCharacterIndex *)path
{
	self = [super init];
	
	if (self)
	{
		_path = path;
	}
	
	return self;
}


/*
** SMJPathCompiler - Compile
*/
#pragma mark - SMJPathCompiler - Compile

+ (nullable id <SMJPath>)compilePathString:(NSString *)path error:(NSError **)error
{
	SMJCharacterIndex *ci = [[SMJCharacterIndex alloc] initWithString:path];
	
	[ci trim];

	if (!([ci characterAtIndex:0] == kDocContextChar) && !([ci characterAtIndex:0] == kEvalContextChar))
	{
		ci =  [[SMJCharacterIndex alloc] initWithString:[@"$." stringByAppendingString:path]];
		
		[ci trim];
	}
	
	if ([ci lastCharacterIsEqualTo:'.'])
	{
		SMSetError(error, 1, @"Path must not end with a '.' or '..'");
		return nil;
	}
	
	return [[[SMJPathCompiler alloc] initWithPath:ci] compileWithError:error];
}

- (nullable id <SMJPath>)compileWithError:(NSError **)error
{
	SMJRootPathToken *root = [self readContextTokenWithError:error];
	
	if (!root)
		return nil;
	
	return [[SMJCompiledPath alloc] initWithRootPathToken:root isRootPath:[root.pathFragment isEqualToString:@"$"]];
}

- (BOOL)isWhitespace:(unichar)c
{
	return (c == kSpaceChar || c == kTabChar || c == kLineFeedChar || c == kCarriageReturnChar);
}

- (BOOL)isPathContext:(unichar)c
{
	return (c == kDocContextChar || c == kEvalContextChar);
}

- (void)readWhitespace
{
	while ([_path inBounds])
	{
		unichar c = _path.currentCharacter;
		
		if (![self isWhitespace:c])
			break;
		
		[_path incrementPositionBy:1];
	}
}


//[$ | @]
- (SMJRootPathToken *)readContextTokenWithError:(NSError **)error
{
	
	[self readWhitespace];
	
	if (![self isPathContext:_path.currentCharacter])
	{
		SMSetError(error, 1, @"Path must start with '$' or '@'");
		return nil;
	}
	
	SMJRootPathToken *pathToken =  [[SMJRootPathToken alloc] initWithRootToken:_path.currentCharacter];
	
	if (_path.positionAtEnd)
		return pathToken;
	
	[_path incrementPositionBy:1];
	
	if (_path.currentCharacter != kPeriodChar && _path .currentCharacter != kOpenSquareBracketChar)
	{
		SMSetError(error, 2, @"Illegal character at position %ld expected '.' or '['", (long)_path.position);
		return nil;
	}
	
	id <SMJPathTokenAppender> appender = [pathToken pathTokenAppender];
	
	if ([self readNextToken:appender error:error] == NO)
		return nil;
	
	return pathToken;
}


//
//
//
- (BOOL)readNextToken:(id <SMJPathTokenAppender>)appender error:(NSError **)error
{
	unichar c = _path.currentCharacter;
	
	switch (c)
	{
		case kOpenSquareBracketChar:
		{
			BOOL result = NO;
			
			result = result || [self readBracketPropertyToken:appender error:error];
			result = result || [self readArrayToken:appender error:error];
			result = result || [self readWildCardToken:appender error:error];
			result = result || [self readFilterToken:appender error:error];
			
			if (result)
				return YES;
			
			SMSetError(error, 1, @"Could not parse token starting at position %ld . Expected ?, ', 0-9, * ", (long)_path .position);
			return NO;
		}
			
		case kPeriodChar:
		{
			BOOL result = NO;

			result = result || [self readDotToken:appender error:error];

			if (result)
				return YES;
			
			SMSetError(error, 2, @"Could not parse token starting at position %ld", (long)_path.position);
			return NO;
		}
			
		case kWildcardChar:
		{
			BOOL result = NO;
			
			result = result || [self readWildCardToken:appender error:error];
			
			if (result)
				return YES;
			
			SMSetError(error, 3, @"Could not parse token starting at position %ld", (long)_path.position);
			return NO;
		}
			
		default:
		{
			BOOL result = NO;
			
			result = result || [self readPropertyOrFunctionToken:appender error:error];
			
			if (result)
				return YES;
			
			SMSetError(error, 4, @"Could not parse token starting at position %ld", (long)_path.position);
			return NO;
		}
	}
}


//
// . and ..
//
- (BOOL)readDotToken:(id <SMJPathTokenAppender>)appender error:(NSError **)error
{
	if ([_path currentCharacterIsEqualTo:kPeriodChar] && [_path nextCharacterIsEqualTo:kPeriodChar])
	{
		[appender appendPathToken:[[SMJScanPathToken alloc] init]];
		[_path incrementPositionBy:2];
	}
	else if (_path.hasMoreCharacters == NO)
	{
		SMSetError(error, 1, @"Path must not end with a '.'");
		return NO;
	}
	else
	{
		[_path incrementPositionBy:1];
	}
	
	if ([_path currentCharacterIsEqualTo:kPeriodChar])
	{
		SMSetError(error, 1, @"Character '.' on position  %ld is not valid.", (long)_path.position);
		return NO;
	}
	
	return [self readNextToken:appender error:error];
}


//
// fooBar or fooBar()
//
- (BOOL)readPropertyOrFunctionToken:(id <SMJPathTokenAppender>)appender error:(NSError **)error
{
	if ([_path currentCharacterIsEqualTo:kOpenSquareBracketChar] || [_path currentCharacterIsEqualTo:kWildcardChar] || [_path currentCharacterIsEqualTo:kPeriodChar] || [_path currentCharacterIsEqualTo:kSpaceChar])
		return NO;
	
	NSInteger startPosition = _path.position;
	NSInteger readPosition = startPosition;
	NSInteger endPosition = 0;
	
	BOOL isFunction = NO;
	
	while ([_path isInBoundsIndex:readPosition])
	{
		unichar c = [_path characterAtIndex:readPosition];
		
		if (c == kSpaceChar)
		{
			SMSetError(error, 1, @"Use bracket notion ['my prop'] if your property contains blank characters. position: %ld", (long)readPosition);
			return NO;
		}
		else if (c == kPeriodChar || c == kOpenSquareBracketChar)
		{
			endPosition = readPosition;
			break;
		}
		else if (c == kOpenParenthesisChar)
		{
			isFunction = YES;
			endPosition = readPosition;
			break;
		}
		
		readPosition++;
	}
	
	if (endPosition == 0)
		endPosition = _path.length;
	
	NSArray <SMJParameter *> *functionParameters = nil;
	
	if (isFunction)
	{
		if ([_path isInBoundsIndex:readPosition + 1])
		{
			// read the next token to determine if we have a simple no-args function call
			unichar c = [_path characterAtIndex:readPosition + 1];
			
			if (c != kCloseParenthesisChar)
			{
				[_path setPosition:endPosition + 1];
				
				// parse the arguments of the function - arguments that are inner queries or JSON objet(s)
				NSString *functionName = [_path stringFromIndex:startPosition toIndex:endPosition];
				
				functionParameters = [self parseFunctionParameters:functionName error:error];
				
				if (!functionParameters)
					return NO;
			}
			else
			{
				[_path setPosition:readPosition + 1];
			}
		}
		else
		{
			[_path setPosition:readPosition];
		}
	}
	else
	{
		[_path setPosition:endPosition];
	}
	
	NSString *property = [_path stringFromIndex:startPosition toIndex:endPosition];
	
	if (isFunction)
	{
		[appender appendPathToken:[[SMJFunctionPathToken alloc] initWithPathFragment:property parameters:functionParameters]];
	}
	else
	{
		SMJPropertyPathToken *pathToken = [[SMJPropertyPathToken alloc] initWithProperties:@[property] delimiter:kSingleQuoteChar error:error];
		
		if (!pathToken)
			return NO;
		
		[appender appendPathToken:pathToken];
	}
	
	return _path.positionAtEnd || [self readNextToken:appender error:error];
}


/**
 * Parse the parameters of a function call, either the caller has supplied JSON data, or the caller has supplied
 * another path expression which must be evaluated and in turn invoked against the root json object.  In this tokenizer
 * we're only concerned with parsing the path thus the output of this function is a list of parameters with the Path
 * set if the parameter is an expression.  If the parameter is a JSON object then the value of the cachedValue is
 * set on the object.
 *
 * Sequence for parsing out the parameters:
 *
 * This code has its own tokenizer - it does some rudimentary level of lexing in that it can distinguish between JSON block parameters
 * and sub-JSON blocks - it effectively regex's out the parameters into string blocks that can then be passed along to the appropriate parser.
 * Since sub-jsonpath expressions can themselves contain other function calls this routine needs to be sensitive to token counting to
 * determine the boundaries.  Since the Path parser isn't aware of JSON processing this uber routine is needed.
 *
 * Parameters are separated by kCommaChars ','
 *
 * <pre>
 * doc = {"numbers": [1,2,3,4,5,6,7,8,9,10]}
 *
 * $.sum({10}, $.numbers.avg())
 * </pre>
 *
 * The above is a valid function call, we're first summing 10 + avg of 1...10 (5.5) so the total should be 15.5
 *
 * @return
 *      An ordered list of parameters that are to processed via the function.  Typically functions either process
 *      an array of values and/or can consume parameters in addition to the values provided from the consumption of
 *      an array.
 */
- (NSArray <SMJParameter *>*)parseFunctionParameters:(NSString *)funcName error:(NSError **)error
{
	NSNumber *type = nil; // SMJParamType
	
	// Parenthesis starts at 1 since we're marking the start of a function call, the close paren will denote the
	// last parameter boundary
	NSInteger	groupParen = 1, groupBracket = 0, groupBrace = 0, groupQuote = 0;
	BOOL 		endOfStream = NO;
	unichar 	priorChar = 0;
	
	NSMutableArray <SMJParameter *> *parameters = [[NSMutableArray alloc] init];
	NSMutableString *parameter = [[NSMutableString alloc] init];
	
	while ([_path inBounds] && !endOfStream)
	{
		unichar c = _path.currentCharacter;
		
		[_path incrementPositionBy:1];
		
		// we're at the start of the stream, and don't know what type of parameter we have
		if (type == nil)
		{
			if ([self isWhitespace:c])
				continue;
			
			if (c == kOpenBraceChar || (c >= '0' && c <= '9') || kDoubleQuote == c)
				type = @(SMJParamTypeJSON);
			else if ([self isPathContext:c])
				type = @(SMJParamTypePath); // read until we reach a terminating comma and we've reset grouping to zero
		}
		
		switch (c)
		{
			case kDoubleQuote:
			{
				if (priorChar != '\\' && groupQuote > 0)
				{
					if (groupQuote == 0)
					{
						SMSetError(error, 1, @"Unexpected quote '\"' at character position: %ld", (long)_path.position);
						return nil;
					}
					
					groupQuote--;
				}
				else
				{
					groupQuote++;
				}
				
				break;
			}
				
			case kOpenParenthesisChar:
			{
				groupParen++;
				break;
			}
				
			case kOpenBraceChar:
			{
				groupBrace++;
				break;
			}
				
			case kOpenSquareBracketChar:
			{
				groupBracket++;
				break;
			}
				
			case kCloseBraceChar:
			{
				if (groupBrace == 0)
				{
					SMSetError(error, 2, @"Unexpected close brace '}' at character position: %ld", (long)_path.position);
					return nil;
				}
				groupBrace--;
				break;
			}
				
			case kCloseSquareBracketChar:
			{
				if (groupBracket == 0)
				{
					SMSetError(error, 3, @"Unexpected close bracket ']' at character position: %ld", (long)_path.position);
					return nil;
				}
				groupBracket--;
				break;
			}
				
			// In either the close paren case where we have zero paren groups left, capture the parameter, or where
			// we've encountered a kCommaChar do the same
			case kCloseParenthesisChar:
			{
				groupParen--;
				
				if (groupParen != 0)
					[parameter appendString:[NSString stringWithCharacters:&c length:1]];
				
				// No break.
			}
				
			case kCommaChar:
			{
				// In this state we've reach the end of a function parameter and we can pass along the parameter string
				// to the parser
				if ((groupQuote == 0 && groupBrace == 0 && groupBracket == 0 && ((groupParen == 0 && c == kCloseParenthesisChar) || groupParen == 1)))
				{
					endOfStream = (0 == groupParen);
					
					if (type != nil)
					{
						SMJParameter *param = nil;
						
						switch (type.intValue)
						{
							case SMJParamTypeJSON:
							{
								// parse the json and set the value
								param = [[SMJParameter alloc] initWithJSON:parameter];
								break;
							}
								
							case SMJParamTypePath:
							{
								id <SMJPath> path = [SMJPathCompiler compilePathString:parameter error:error];
								
								if (!path)
									return nil;
								
								param = [[SMJParameter alloc] initWithPath:path];
								
								break;
							}
						}
						
						if (param != nil)
							[parameters addObject:param];
						
						[parameter deleteCharactersInRange:NSMakeRange(0, parameter.length)];
						type = nil;
					}
				}
				break;
			}
		}
		
		if (type != nil && !(c == kCommaChar && groupBrace == 0 && groupBracket == 0 && groupParen == 1))
			[parameter appendString:[NSString stringWithCharacters:&c length:1]];
		
		priorChar = c;
	}
	
	if (groupBrace != 0 || groupParen != 0 || groupBracket != 0)
	{
		SMSetError(error, 4, @"Arguments to function: '%@' are not closed properly.", funcName);
		return nil;
	}
	
	return parameters;
}


//
// [?(...)]
//
- (BOOL)readFilterToken:(id <SMJPathTokenAppender>)appender error:(NSError **)error
{
	if (![_path currentCharacterIsEqualTo:kOpenSquareBracketChar] && ![_path nextSignificantCharacterIsEqualTo:kBeginFilterChar])
	{
		return NO;
	}
	
	NSInteger openStatementBracketIndex = _path.position;
	NSInteger questionMarkIndex = [_path indexOfNextSignificantCharacter:kBeginFilterChar];
	
	if (questionMarkIndex == NSNotFound)
	{
		return NO;
	}
	
	NSInteger openBracketIndex = [_path indexOfNextSignificantCharacter:kOpenParenthesisChar fromIndex:questionMarkIndex];
	
	if (openBracketIndex == NSNotFound)
	{
		return NO;
	}
	
	NSInteger closeBracketIndex = [_path indexOfClosingBracketFromIndex:openBracketIndex skipStrings:YES skipRegex:YES error:error];
	
	if (closeBracketIndex == NSNotFound)
	{
		return NO;
	}
	
	if (![_path nextSignificantCharacterIsEqualTo:kCloseSquareBracketChar fromIndex:closeBracketIndex])
	{
		return NO;
	}
	
	NSInteger closeStatementBracketIndex = [_path indexOfNextSignificantCharacter:kCloseSquareBracketChar fromIndex:closeBracketIndex];
	
	NSString *criteria = [_path stringFromIndex:openStatementBracketIndex toIndex:closeStatementBracketIndex + 1];
	
	id <SMJPredicate> predicate = [SMJFilterCompiler compileFilterString:criteria error:error];
	
	if (!predicate)
		return NO;
	
	[appender appendPathToken:[[SMJPredicatePathToken alloc] initWithPredicate:predicate]];
	
	[_path setPosition:closeStatementBracketIndex + 1];
	
	return _path.positionAtEnd || [self readNextToken:appender error:error];
}


//
// [*]
// *
//
- (BOOL)readWildCardToken:(id <SMJPathTokenAppender>)appender error:(NSError **)error
{
	BOOL inBracket = [_path currentCharacterIsEqualTo:kOpenSquareBracketChar];
	
	if (inBracket && ![_path nextSignificantCharacterIsEqualTo:kWildcardChar])
	{
		return false;
	}
	
	if (![_path currentCharacterIsEqualTo:kWildcardChar] && [_path isOutOfBoundsIndex:_path.position + 1])
	{
		return false;
	}
	
	if (inBracket)
	{
		NSInteger wildCardIndex = [_path indexOfNextSignificantCharacter:kWildcardChar];
		
		if (![_path nextSignificantCharacterIsEqualTo:kCloseSquareBracketChar fromIndex:wildCardIndex])
		{
			SMSetError(error, 4, @"Expected wildcard token to end with ']' on position %ld", (long)wildCardIndex + 1);
			return NO;
		}
		
		NSInteger bracketCloseIndex = [_path indexOfNextSignificantCharacter:kCloseSquareBracketChar fromIndex:wildCardIndex];
		
		[_path setPosition:bracketCloseIndex + 1];
	}
	else
	{
		[_path incrementPositionBy:1];
	}
	
	[appender appendPathToken:[[SMJWildcardPathToken alloc] init]];
	
	return _path.positionAtEnd || [self readNextToken:appender error:error];
}


//
// [1], [1,2, n], [1:], [1:2], [:2]
//
- (BOOL)readArrayToken:(id <SMJPathTokenAppender>)appender error:(NSError **)error
{
	if (![_path currentCharacterIsEqualTo:kOpenSquareBracketChar])
		return NO;
	
	unichar nextSignificantChar = [_path nextSignificantCharacter];
	
	if (!(nextSignificantChar >= '0' && nextSignificantChar <= '9') && nextSignificantChar != kMinusChar && nextSignificantChar != kSplitChar)
		return NO;
	
	NSInteger expressionBeginIndex = _path.position + 1;
	NSInteger expressionEndIndex = [_path nextIndexOfCharacter:kCloseSquareBracketChar fromIndex:expressionBeginIndex];
	
	if (expressionEndIndex == NSNotFound)
		return NO;
	
	NSString *expression = [[_path stringFromIndex:expressionBeginIndex toIndex:expressionEndIndex] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	if ([expression isEqualToString:@"*"])
		return NO;
	
	//check valid chars
	for (NSInteger i = 0; i < expression.length; i++)
	{
		unichar c = [expression characterAtIndex:i];
				
		if (!(c >= '0' && c <= '9') && c != kCommaChar && c != kMinusChar && c != kSplitChar && c != kSpaceChar)
			return NO;
	}
	
	BOOL isSliceOperation = ([expression rangeOfString:@":"].location != NSNotFound);
	
	if (isSliceOperation)
	{
		SMJArraySliceOperation *arraySliceOperation = [SMJArraySliceOperation arraySliceOperationByParsing:expression error:error];
		
		if (!arraySliceOperation)
			return NO;
		
		[appender appendPathToken:[[SMJArraySliceToken alloc] initWithSliceOperation:arraySliceOperation]];
	}
	else
	{
		SMJArrayIndexOperation *arrayIndexOperation = [SMJArrayIndexOperation arrayIndexOperation:expression error:error];
		
		if (!arrayIndexOperation)
			return NO;
		
		[appender appendPathToken:[[SMJArrayIndexToken alloc] initWithIndexOperation:arrayIndexOperation]];
	}
	
	[_path setPosition:expressionEndIndex + 1];
	
	return _path.positionAtEnd || [self readNextToken:appender error:error];
}


//
// ['foo']
//
- (BOOL)readBracketPropertyToken:(id <SMJPathTokenAppender>)appender error:(NSError **)error
{
	if (![_path currentCharacterIsEqualTo:kOpenSquareBracketChar])
	{
		return NO;
	}
	
	unichar potentialStringDelimiter = [_path nextSignificantCharacter];
	
	if (potentialStringDelimiter != kSingleQuoteChar && potentialStringDelimiter != kDoubleQuote)
	{
		return false;
	}
	
	NSMutableArray <NSString *> *properties = [NSMutableArray array];
	
	NSInteger startPosition = _path.position + 1;
	NSInteger readPosition = startPosition;
	NSInteger endPosition = 0;
	BOOL inProperty = NO;
	BOOL inEscape = NO;
	BOOL lastSignificantWasComma = NO;
	
	while ([_path isInBoundsIndex:readPosition])
	{
		unichar c = [_path characterAtIndex:readPosition];
		
		if (inEscape)
		{
			inEscape = NO;
		}
		else if (c == '\\')
		{
			inEscape = YES;
		}
		else if (c == kCloseSquareBracketChar && !inProperty)
		{
			if (lastSignificantWasComma)
			{
				SMSetError(error, 1, @"Found empty property at index %ld", (long)readPosition);
				return NO;
			}
			break;
		}
		else if (c == potentialStringDelimiter)
		{
			if (inProperty)
			{
				unichar nextSignificantChar = [_path nextSignificantCharacterFromIndex:readPosition];
				
				if (nextSignificantChar != kCloseSquareBracketChar && nextSignificantChar != kCommaChar)
				{
					SMSetError(error, 2, @"Property must be separated by comma or Property must be terminated close square bracket at index %ld", (long)readPosition);
					return NO;
				}
				
				endPosition = readPosition;
				
				NSString *prop = [_path stringFromIndex:startPosition toIndex:endPosition];
				
				[properties addObject:[SMJUtils stringByUnescapingString:prop]];
				
				inProperty = NO;
			}
			else
			{
				startPosition = readPosition + 1;
				inProperty = YES;
				lastSignificantWasComma = NO;
			}
		}
		else if (c == kCommaChar)
		{
			if (lastSignificantWasComma)
			{
				SMSetError(error, 2, @"Found empty property at index %ld", (long)readPosition);
				return NO;
			}
			
			lastSignificantWasComma = YES;
		}
		
		readPosition++;
	}
	
	if (inProperty)
	{
		SMSetError(error, 2, @"Property has not been closed - missing closing %c", (char)potentialStringDelimiter);
		return NO;
	}
	
	NSInteger endBracketIndex = [_path indexOfNextSignificantCharacter:kCloseSquareBracketChar fromIndex:endPosition] + 1;
	
	[_path setPosition:endBracketIndex];
	
	SMJPropertyPathToken *pathToken = [[SMJPropertyPathToken alloc] initWithProperties:properties delimiter:potentialStringDelimiter error:error];
	
	if (!pathToken)
		return NO;
	
	[appender appendPathToken:pathToken];
	
	return _path.positionAtEnd || [self readNextToken:appender error:error];
}

@end


NS_ASSUME_NONNULL_END
