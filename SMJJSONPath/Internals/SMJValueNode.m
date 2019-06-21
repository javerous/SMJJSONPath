/*
 * SMJValueNode.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/filter/ValueNode.java */


#import "SMJValueNode.h"

#import "SMJUtils.h"

#import "SMJPathCompiler.h"
#import "SMJPredicateContextImpl.h"


NS_ASSUME_NONNULL_BEGIN


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

- (BOOL)isEqual:(SMJValueNode *)node
{
	NSAssert(NO, @"need to be overwritten");
	return NO;
}

- (SMJComparisonResult)compare:(SMJValueNode *)node
{
	NSAssert(NO, @"need to be overwritten");
	return SMJComparisonDiffer;
}

- (nullable id)underlayingObjectWithError:(NSError **)error
{
	NSAssert(NO, @"need to be overwritten");
	return nil;
}

@end


NS_ASSUME_NONNULL_END
