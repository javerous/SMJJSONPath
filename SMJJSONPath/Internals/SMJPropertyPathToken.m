/*
 * SMJPropertyPathToken.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/path/PropertyPathToken.java */


#import "SMJPropertyPathToken.h"

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
			*(Error) = [NSError errorWithDomain:@"SMJPropertyPathTokenErrorDomain" code:(Code) userInfo:@{ NSLocalizedDescriptionKey : ___message }]; \
		} \
	} while (0) \



/*
** SMJPropertyPathToken
*/
#pragma mark - SMJPropertyPathToken

@implementation SMJPropertyPathToken
{
	NSArray <NSString *>	*_properties;
	NSString 				*_stringDelimiter;
}


/*
** SMJPropertyPathToken - Instance
*/
#pragma mark - SMJPropertyPathToken - Instance

- (nullable instancetype)initWithProperties:(NSArray <NSString *> *)properties delimiter:(unichar)delimiter error:(NSError **)error
{
	self = [super init];
	
	if (self)
	{
		if (properties.count == 0)
		{
			SMSetError(error, 1, @"Empty properties");
			return nil;
		}
		
		_properties = [properties copy];
		_stringDelimiter = [NSString stringWithCharacters:&delimiter length:1];
	}
	
	return self;
}


/*
** SMJPropertyPathToken - Content
*/
#pragma mark - SMJPropertyPathToken - Content

- (NSArray<NSString *> *)properties
{
	return _properties;
}

- (BOOL)singlePropertyCase
{
	return (_properties.count == 1);
}

- (BOOL)multiPropertyMergeCase
{
	return self.leaf && (_properties.count > 1);
}

- (BOOL)multiPropertyIterationCase
{
	// Semantics of this case is the same as semantics of ArrayPathToken with INDEX_SEQUENCE operation.
	return (self.leaf == NO) && (_properties.count > 1);
}


/*
** SMJPropertyPathToken - SMJPathToken
*/
#pragma mark - SMJPropertyPathToken - SMJPathToken

- (SMJEvaluationStatus)evaluateWithCurrentPath:(NSString *)currentPath parentPathRef:(SMJPathRef *)parent jsonObject:(id)jsonObject evaluationContext:(SMJEvaluationContextImpl *)context error:(NSError **)error
{
	// Can't assert it in ctor because isLeaf() could be changed later on.
	//assert onlyOneIsTrueNonThrow(singlePropertyCase(), multiPropertyMergeCase(), multiPropertyIterationCase());
	
	if ([jsonObject isKindOfClass:[NSDictionary class]] == NO)
	{
		if (self.upstreamDefinite == NO)
		{
			return SMJEvaluationStatusDone;
		}
		else
		{
			NSString *m = (jsonObject == nil ? @"null" : [[jsonObject class] description]);
			
			SMSetError(error, 1, @"Expected to find an object with property %@ in path %@ but found '%@'. This is not a json object.", self.pathFragment, currentPath, m);
			
			return SMJEvaluationStatusError;
		}
	}
	
	if (self.singlePropertyCase || self.multiPropertyMergeCase)
	{
		return [self handleObjectPropertyWithCurrentPathString:currentPath jsonObject:jsonObject evaluationContext:context properties:_properties error:error];
	}
	
	if (self.multiPropertyIterationCase == NO)
	{
		SMSetError(error, 2, @"internal error (need to be multi property iteration case)");
		return SMJEvaluationStatusError;
	}
	
	for (NSString *property in _properties)
	{
		SMJEvaluationStatus result = [self handleObjectPropertyWithCurrentPathString:currentPath jsonObject:jsonObject evaluationContext:context properties:@[ property ] error:error];
		
		if (result == SMJEvaluationStatusError)
			return SMJEvaluationStatusError;
		else if (result == SMJEvaluationStatusAborted)
			return SMJEvaluationStatusAborted;
	}

	return SMJEvaluationStatusDone;
}

- (BOOL)isTokenDefinite
{
	// in case of leaf multiprops will be merged, so it's kinda definite
	return self.singlePropertyCase || self.multiPropertyMergeCase;
}

- (NSString *)pathFragment
{
	return [NSString stringWithFormat:@"[%@]", [SMJUtils stringByJoiningStrings:_properties delimiter:@"," wrap:_stringDelimiter]];
}

@end


NS_ASSUME_NONNULL_END
