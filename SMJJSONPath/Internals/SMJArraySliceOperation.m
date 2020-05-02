/*
 * SMJArraySliceOperation.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/path/ArraySliceOperation.java */


#import "SMJArraySliceOperation.h"


NS_ASSUME_NONNULL_BEGIN


/*
** Macros
*/
#pragma mark - Macros

#define SMSetError(Error, Code, Message, ...) \
	do { \
		if ((Error) && *(Error) == nil) {\
			NSString *___message = [NSString stringWithFormat:(Message), ## __VA_ARGS__];\
			*(Error) = [NSError errorWithDomain:@"SMJArraySliceOperationErrorDomain" code:(Code) userInfo:@{ NSLocalizedDescriptionKey : ___message }]; \
		} \
	} while (0) \


/*
** SMJArraySliceOperation
*/
#pragma mark - SMJArraySliceOperation

@implementation SMJArraySliceOperation


/*
** SMJArraySliceOperation - Instance
*/
#pragma mark - SMJArraySliceOperation - Instance

+ (nullable instancetype)arraySliceOperationByParsing:(NSString *)operation error:(NSError **)error
{
	//check valid chars
	for (NSInteger i = 0; i < operation.length; i++)
	{
		unichar c = [operation characterAtIndex:i];
		
		if (!(c >= '0' && c <= '9') && c != '-' && c != ':')
		{
			SMSetError(error, 1, @"Failed to parse SliceOperation: %@", operation);
			return nil;
		}
	}
	
	NSArray <NSString *> *tokens = [operation componentsSeparatedByString:@":"];
	
	NSInteger tempFrom = [self tryRead:tokens index:0];
	NSInteger tempTo = [self tryRead:tokens index:1];
	SMJSliceOperation tempOperation;
	
	if (tempFrom != NSNotFound && tempTo == NSNotFound)
		tempOperation  = SMJSliceOperationFrom;
	else if (tempFrom != NSNotFound && tempTo != NSNotFound)
		tempOperation  = SMJSliceOperationBetween;
	else if (tempFrom == NSNotFound && tempTo != NSNotFound)
		tempOperation  = SMJSliceOperationTo;
	else
	{
		SMSetError(error, 1, @"Failed to parse SliceOperation: %@", operation);
		return nil;
	}
	
	return [[SMJArraySliceOperation alloc] initWithFromIndex:tempFrom toIndex:tempTo operation:tempOperation];
}

- (instancetype)initWithFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex operation:(SMJSliceOperation)operation
{
	self = [super init];
	
	if (self)
	{
		_fromIndex = fromIndex;
		_toIndex = toIndex;
		_operation = operation;
	}
	
	return self;
}

- (NSString *)stringValue
{
	NSMutableString *sb = [NSMutableString string];
	
	[sb appendString:@"["];
	[sb appendString:(_fromIndex == NSNotFound ? @"" : [NSString stringWithFormat:@"%ld", (long)_fromIndex])];
	[sb appendString:@":"];
	[sb appendString:(_toIndex == NSNotFound ? @"" : [NSString stringWithFormat:@"%ld", (long)_toIndex])];
	[sb appendString:@"]"];
	
	return sb;
}

+ (NSInteger)tryRead:(NSArray <NSString *> *)tokens index:(NSInteger)idx
{
	if (idx < tokens.count)
	{
		if ([tokens[idx] isEqualToString:@""])
		{
			return NSNotFound;
		}
		
		NSScanner *scanner = [NSScanner scannerWithString:tokens[idx]];
		NSInteger result = 0;
		
		if ([scanner scanInteger:&result])
			return result;
		
		return NSNotFound;
	}
	else
	{
		return NSNotFound;
	}
}



@end


NS_ASSUME_NONNULL_END
