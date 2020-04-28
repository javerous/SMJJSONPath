/*
 * SMJArrayIndexOperation.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/path/ArrayIndexOperation.java */


#import "SMJArrayIndexOperation.h"

#import "SMJUtils.h"


NS_ASSUME_NONNULL_BEGIN


/*
** Macros
*/
#pragma mark - Macros

#define SMSetError(Error, Code, Message, ...) \
	do { \
		if ((Error) && *(Error) == nil) {\
			NSString *___message = [NSString stringWithFormat:(Message), ## __VA_ARGS__];\
			*(Error) = [NSError errorWithDomain:@"SMJArrayIndexOperationErrorDomain" code:(Code) userInfo:@{ NSLocalizedDescriptionKey : ___message }]; \
		} \
	} while (0) \



/*
** SMJArrayIndexOperation
*/
#pragma mark - SMJArrayIndexOperation

@implementation SMJArrayIndexOperation


/*
** SMJArrayIndexOperation - Instance
*/
#pragma mark - SMJArrayIndexOperation - Instance

+ (nullable instancetype)arrayIndexOperation:(NSString *)operation error:(NSError **)error
{
	//check valid chars
	for (NSInteger i = 0; i < operation.length; i++)
	{
		unichar c = [operation characterAtIndex:i];
		
		if (!(c >= '0' && c <= '9') && c != ',' && c != ' ' && c != '-')
		{
			SMSetError(error, 1, @"Failed to parse ArrayIndexOperation: %@", operation);
			return nil;
		}
	}
	
	NSArray			*tokens = [operation componentsSeparatedByString:@","];
	NSMutableArray	*tempIndexes = [[NSMutableArray alloc] init];
	
	for (NSString *token in tokens)
	{
		NSScanner *scanner = [NSScanner scannerWithString:[token stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
		NSInteger index = 0;
		
		if ([scanner scanInteger:&index] && scanner.isAtEnd)
			[tempIndexes addObject:@(index)];
		else
		{
			SMSetError(error, 1, @"Failed to parse token in ArrayIndexOperation: %@", token);
			return nil;
		}
	}
	
	return [[SMJArrayIndexOperation alloc] initWithIndexes:tempIndexes];
}

- (instancetype)initWithIndexes:(NSMutableArray *)indexes
{
	self = [super init];
	
	if (self)
	{
		_indexes = indexes;
	}
	
	return self;
}

- (BOOL)isSingleIndexOperation
{
	return (_indexes.count == 1);
}

- (NSString *)stringValue
{
	NSMutableString	*sb = [NSMutableString string];
	
	[sb appendString:@"["];
	
	[_indexes enumerateObjectsUsingBlock:^(NSNumber *index, NSUInteger idx, BOOL * stop) {
		
		if (idx > 0)
			[sb appendString:@","];
		
		[sb appendFormat:@"%@", [index stringValue]];
	}];
	
	[sb appendString:@"]"];
	
	return sb;
}

@end


NS_ASSUME_NONNULL_END
