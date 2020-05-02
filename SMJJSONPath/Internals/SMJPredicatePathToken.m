/*
 * SMJPredicatePathToken.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/path/PredicatePathToken.java */


#import "SMJPredicatePathToken.h"

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
			*(Error) = [NSError errorWithDomain:@"SMJPredicatePathTokenErrorDomain" code:(Code) userInfo:@{ NSLocalizedDescriptionKey : ___message }]; \
		} \
	} while (0)



/*
** SMJPredicatePathToken
*/
#pragma mark - SMJPredicatePathToken

@implementation SMJPredicatePathToken
{
	NSArray <id <SMJPredicate>> *_predicates;
}


/*
** SMJPredicatePathToken - Instance
*/
#pragma mark - SMJPredicatePathToken - Instance

- (instancetype)initWithPredicate:(id <SMJPredicate>)predicate
{
	self = [super init];
	
	if (self)
	{
		_predicates = @[ predicate ];
	}
	
	return self;
}

- (instancetype)initWithPredicates:(NSArray <id <SMJPredicate>> *)predicates
{
	self = [super init];
	
	if (self)
	{
		_predicates = [predicates copy];
	}
	
	return self;
}


/*
** SMJPredicatePathToken - Accept
*/
#pragma mark - SMJPredicatePathToken - Accept

- (BOOL)acceptJsonObject:(id)jsonObject rootJsonObject:(id)rootJsonObject configuration:(SMJConfiguration *)configuration evaluationContext:(SMJEvaluationContextImpl *)evaluationContext
{
	// XXX why "accept" drop predicate error there ?
	
	id <SMJPredicateContext> predicateContext = [[SMJPredicateContextImpl alloc] initWithJsonObject:jsonObject rootJsonObject:rootJsonObject configuration:configuration pathCache:evaluationContext.evaluationCache];
	
	for (id <SMJPredicate> predicate in _predicates)
	{
		SMJPredicateApply result = [predicate applyWithContext:predicateContext error:nil];
		
		if (result == SMJPredicateApplyError || result == SMJPredicateApplyFalse)
			return NO;
	}
	
	return YES;
}


/*
** SMJPredicatePathToken - SMJPathToken
*/
#pragma mark - SMJPredicatePathToken - SMJPathToken

- (SMJEvaluationStatus)evaluateWithCurrentPath:(NSString *)currentPath parentPathRef:(SMJPathRef *)parent jsonObject:(id)jsonObject evaluationContext:(SMJEvaluationContextImpl *)context error:(NSError **)error
{
	if ([jsonObject isKindOfClass:[NSDictionary class]])
	{
		if ([self acceptJsonObject:jsonObject rootJsonObject:context.rootJsonObject configuration:context.configuration evaluationContext:context])
		{
			SMJPathRef *op = context.forUpdate ? parent : [SMJPathRef pathRefNull];
			
			if (self.leaf)
			{
				[context addResult:currentPath operation:op jsonObject:jsonObject];
			}
			else
			{
				SMJEvaluationStatus result = [self.next evaluateWithCurrentPath:currentPath parentPathRef:op jsonObject:jsonObject evaluationContext:context error:error];
				
				if (result == SMJEvaluationStatusError)
					return SMJEvaluationStatusError;
				else if (result == SMJEvaluationStatusAborted)
					return SMJEvaluationStatusAborted;
			}
		}
	}
	else if ([jsonObject isKindOfClass:[NSArray class]])
	{
		NSArray 	*jsonObjects = jsonObject;
		NSUInteger	idx = 0;
		
		for (id idxObject in jsonObjects)
		{
			if ([self acceptJsonObject:idxObject rootJsonObject:context.rootJsonObject configuration:context.configuration evaluationContext:context])
			{
				SMJEvaluationStatus result = [self handleArrayIndex:idx currentPathString:currentPath jsonObject:jsonObject evaluationContext:context error:error];
				
				if (result == SMJEvaluationStatusError)
					return SMJEvaluationStatusError;
				else if (result == SMJEvaluationStatusAborted)
					return SMJEvaluationStatusAborted;
			}
			
			idx++;
		}
	}
	else
	{
		if ([self isUpstreamDefinite])
		{
			SMSetError(error, 1, @"Filter: %@ can not be applied to primitives. Current context is: %@", [self stringValue], jsonObject);
			return SMJEvaluationStatusError;
		}
	}
			 
	 return SMJEvaluationStatusDone;
}

- (BOOL)isTokenDefinite
{
	return NO;
}

- (NSString *)pathFragment
{
	NSMutableString *sb = [[NSMutableString alloc] init];
	
	[sb appendString:@"["];

	for (NSUInteger i = 0; i < _predicates.count; i++)
	{
		if (i != 0)
			[sb appendString:@","];
		
		[sb appendString:@"?"];
	}
	
	[sb appendString:@"]"];

	return sb;
}


@end


NS_ASSUME_NONNULL_END

