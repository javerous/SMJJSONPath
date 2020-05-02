/*
 * SMJValueNode.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/filter/ValueNode.java */


#import "SMJValueNode.h"

#import "SMJUtils.h"

#import "SMJPathCompiler.h"
#import "SMJPredicateContextImpl.h"


NS_ASSUME_NONNULL_BEGIN


/*
** Prototypes
*/
#pragma mark - Prototypes

static SMJComparisonResult convertComparison(NSComparisonResult result);



/*
** Macros
*/
#pragma mark - Macros

#define SMSetError(Error, Code, Message, ...) \
	do { \
		if ((Error) && *(Error) == nil) {\
			NSString *___message = [NSString stringWithFormat:(Message), ## __VA_ARGS__];\
			*(Error) = [NSError errorWithDomain:@"SMJValueNodeErrorNode" code:(Code) userInfo:@{ NSLocalizedDescriptionKey : ___message }]; \
		} \
	} while (0) \


/*
** SMJValueNode
*/
#pragma mark - SMJValueNode

@implementation SMJValueNode

- (NSString *)stringValue
{
	NSAssert(NO, @"need to be overwritten");
	return nil;
}

- (nullable NSString *)literalValue
{
	return nil;
}

- (NSString *)typeName
{
	NSAssert(NO, @"need to be overwritten");
	return nil;
}

- (SMJEqualityResult)isEqual:(SMJValueNode *)node withError:(NSError **)error
{
	if ([[self class] isEqual:[node class]] == NO)
		return SMJEqualityDiffer;
		
	id obj1 = [self comparableUnderlayingObjectWithError:error];
	id obj2 = [node comparableUnderlayingObjectWithError:error];
	
	if (!obj1 || !obj2)
		return SMJEqualityError;
	
	return ([obj1 isEqual:obj2] ? SMJEqualitySame : SMJEqualityDiffer);
}

- (SMJComparisonResult)compare:(SMJValueNode *)node withError:(NSError **)error
{
	id obj1 = [self comparableUnderlayingObjectWithError:error];
	id obj2 = [node comparableUnderlayingObjectWithError:error];
	
	if (!obj1 || !obj2)
		return SMJComparisonError;

	if ([obj1 isKindOfClass:[NSString class]] && [obj2 isKindOfClass:[NSString class]])
	{
		NSNumber *number1 = [SMJUtils numberWithString:obj1];
		NSNumber *number2 = [SMJUtils numberWithString:obj2];

		if (number1 && number2)
			return convertComparison([number1 compare:number2]);
		else
			return convertComparison([(NSString *)obj1 compare:(NSString *)obj2]);
	}
	else if ([obj1 isKindOfClass:[NSString class]] && [obj2 isKindOfClass:[NSNumber class]])
	{
		NSNumber *number1 = [SMJUtils numberWithString:obj1];
		
		if (number1)
			return convertComparison([number1 compare:(NSNumber *)obj2]);
		else
			return convertComparison([obj1 compare:[(NSNumber *)obj2 stringValue]]);
	}
	else if ([obj1 isKindOfClass:[NSNumber class]] && [obj2 isKindOfClass:[NSString class]])
	{
		NSNumber *number2 = [SMJUtils numberWithString:obj2];
		
		if (number2)
			return convertComparison([(NSNumber *)obj1 compare:number2]);
		else
			return convertComparison([[(NSNumber *)obj1 stringValue] compare:obj2]);
	}
	else if ([obj1 isKindOfClass:[NSNumber class]] && [obj2 isKindOfClass:[NSNumber class]])
	{
		return convertComparison([(NSNumber *)obj1 compare:(NSNumber *)obj2]);
	}
	else
	{
		return ([obj1 isEqual:obj2] ? SMJComparisonSame : SMJComparisonDiffer);
	}
}

- (nullable id)underlayingObjectWithError:(NSError **)error
{
	NSAssert(NO, @"need to be overwritten");
	return nil;
}

- (nullable id)comparableUnderlayingObjectWithError:(NSError **)error
{
	return [self underlayingObjectWithError:error];
}

@end



/*
** C-Tools
*/
#pragma mark - C Tools

static SMJComparisonResult convertComparison(NSComparisonResult result)
{
	switch (result)
	{
		case NSOrderedAscending:
			return SMJComparisonDifferLessThan;
			
		case NSOrderedSame:
			return SMJComparisonSame;
			
		case NSOrderedDescending:
			return SMJComparisonDifferGreaterThan;
	}
}


NS_ASSUME_NONNULL_END
