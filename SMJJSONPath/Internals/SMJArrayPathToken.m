/*
 * SMJArrayPathToken.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/path/ArrayPathToken.java */


#import "SMJArrayPathToken.h"


NS_ASSUME_NONNULL_BEGIN


/*
** Macros
*/
#pragma mark - Macros

#define SMSetError(Error, Code, Message, ...) \
	do { \
		if ((Error) && *(Error) == nil) {\
			NSString *___message = [NSString stringWithFormat:(Message), ## __VA_ARGS__];\
			*(Error) = [NSError errorWithDomain:@"SMJArrayPathTokenErrorDomain" code:(Code) userInfo:@{ NSLocalizedDescriptionKey : ___message }]; \
		} \
	} while (0)


/*
** SMJArrayPathToken
*/
#pragma mark - SMJArrayPathToken

@implementation SMJArrayPathToken


/**
 * Check if object is non-null and array.
 * @return false if current evaluation call must be skipped, true otherwise
 * @throws PathNotFoundException if object is null and evaluation must be interrupted
 * @throws InvalidPathException if object is not an array and evaluation must be interrupted
 */
- (SMJArrayPathCheck)checkArrayWithCurrentPathString:(NSString *)currentPath jsonObject:(id)jsonObject evaluationContext:(SMJEvaluationContextImpl *)context error:(NSError **)error
{
	if (jsonObject == nil)
	{
		if (self.upstreamDefinite == NO)
		{
			return SMJArrayPathCheckSkip;
		}
		else
		{
			SMSetError(error, 1, @"The path %@ is null", currentPath);
			return SMJArrayPathCheckError;
		}
	}
	
	if ([jsonObject isKindOfClass:[NSArray class]] == NO)
	{
		if (self.upstreamDefinite == NO)
		{
			return SMJArrayPathCheckSkip;
		}
		else
		{
			SMSetError(error, 2, @"Filter: %@ can only be applied to arrays. Current context is: %@", [self stringValue], jsonObject);
			return SMJArrayPathCheckError;
		}
	}
	
	return SMJArrayPathCheckHandle;
}

@end


NS_ASSUME_NONNULL_END
