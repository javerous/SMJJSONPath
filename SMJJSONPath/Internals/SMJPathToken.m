/*
 * SMJPathToken.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/path/PathToken.java */


#import "SMJPathToken.h"

#import "SMJUtils.h"
#import "SMJPathRef.h"


NS_ASSUME_NONNULL_BEGIN


/*
** Macros
*/
#pragma mark - Macros

#define SMSetError(Error, Code, Message, ...) \
	do { \
		if (Error) {\
			NSString *___message = [NSString stringWithFormat:(Message), ## __VA_ARGS__];\
			*(Error) = [NSError errorWithDomain:@"SMJPathTokenErrorDomain" code:(Code) userInfo:@{ NSLocalizedDescriptionKey : ___message }]; \
		} \
	} while (0) \



/*
** SMJPathToken
*/
#pragma mark - SMJPathToken

@implementation SMJPathToken
{
	__weak SMJPathToken	*_prev;
	SMJPathToken		*_next;
	
	NSNumber *_definite;
	NSNumber *_upstreamDefinite;
}

- (SMJPathToken *)appendTailToken:(SMJPathToken *)token
{
	_next = token;
	_next->_prev = self;
	
	return token;
}

- (SMJEvaluationStatus)handleObjectPropertyWithCurrentPathString:(NSString *)currentPath jsonObject:(id)jsonObject evaluationContext:(SMJEvaluationContextImpl *)context properties:(NSArray <NSString *> *)properties error:(NSError **)error
{
	if (properties.count == 1)
	{
		NSString *property = properties[0];
		NSString *evalPath = [SMJUtils stringByConcatenatingStrings:@[ currentPath, @"['", property, @"']" ]];
		
		id propertyVal = [self readObjectProperty:property jsonObject:jsonObject context:context];
		
		if (propertyVal == nil)
		{
			// Conditions below heavily depend on current token type (and its logic) and are not "universal",
			// so this code is quite dangerous (I'd rather rewrite it & move to PropertyPathToken and implemented
			// WildcardPathToken as a dynamic multi prop case of PropertyPathToken).
			// Better safe than sorry.
			//assert this instanceof PropertyPathToken : "only PropertyPathToken is supported";
			
			if (self.leaf)
			{
				if ([context.configuration containsOption:SMJOptionDefaultPathLeafToNull])
				{
					propertyVal = [NSNull null];
				}
				else
				{
					if ([context.configuration containsOption:SMJOptionRequireProperties] == NO)
						return SMJEvaluationStatusDone;
					else
					{
						SMSetError(error, 1, @"No results for property path: %@", evalPath);
						return SMJEvaluationStatusError;
					}
				}
			}
			else
			{
				if (!(self.upstreamDefinite && self.tokenDefinite) && ([context.configuration containsOption:SMJOptionRequireProperties] == NO))
				{
					// If there is some indefiniteness in the path and properties are not required - we'll ignore
					// absent property.
					return SMJEvaluationStatusDone;
				}
				else
				{
					SMSetError(error, 2, @"Missing property in path %@", evalPath);
					return SMJEvaluationStatusError;
				}
			}
		}
		
		SMJPathRef *pathRef = context.forUpdate ? [SMJPathRef pathRefWithObject:jsonObject property:property] : [SMJPathRef pathRefNull];
		
		if (self.leaf)
		{
			if ([context addResult:evalPath operation:pathRef jsonObject:propertyVal] == SMJEvaluationContextStatusAborted)
				return SMJEvaluationStatusAborted;
		}
		else
		{
			SMJEvaluationStatus result = [self.next evaluateWithCurrentPath:evalPath parentPathRef:pathRef jsonObject:propertyVal evaluationContext:context error:error];
			
			if (result == SMJEvaluationStatusError)
				return SMJEvaluationStatusError;
			else if (result == SMJEvaluationStatusAborted)
				return SMJEvaluationStatusAborted;
		}
	}
	else
	{
		NSString *evalPath = [NSString stringWithFormat:@"%@[%@]", currentPath, [SMJUtils stringByJoiningStrings:properties delimiter:@", " wrap:@"'"]];
		
		//assert isLeaf() : "non-leaf multi props handled elsewhere";
		
		NSMutableDictionary *merged = [NSMutableDictionary dictionary];
		
		for (NSString *property in properties)
		{
			id propertyVal;
			
			if ([self hasProperty:property jsonObject:jsonObject context:context])
			{
				propertyVal = [self readObjectProperty:property jsonObject:jsonObject context:context];
				
				if (propertyVal == nil)
				{
					if ([context.configuration containsOption:SMJOptionDefaultPathLeafToNull])
						propertyVal = [NSNull null];
					else
						continue;
				}
			}
			else
			{
				if ([context.configuration containsOption:SMJOptionDefaultPathLeafToNull])
				{
					propertyVal = [NSNull null];
				}
				else if ([context.configuration containsOption:SMJOptionRequireProperties])
				{
					SMSetError(error, 3, @"Missing property in path %@", evalPath);
					return SMJEvaluationStatusError;
				}
				else
				{
					continue;
				}
			}
			
			merged[property] = propertyVal;
		}
		
		SMJPathRef *pathRef = context.forUpdate ?  [SMJPathRef pathRefWithObject:jsonObject properties:properties] : [SMJPathRef pathRefNull];
		
		if ([context addResult:evalPath operation:pathRef jsonObject:merged] == SMJEvaluationContextStatusAborted)
			return SMJEvaluationStatusAborted;
	}
	
	return SMJEvaluationStatusDone;
}

- (BOOL)hasProperty:(NSString *)property jsonObject:(id)jsonObject context:(SMJEvaluationContextImpl *)context
{
	return ([self readObjectProperty:property jsonObject:jsonObject context:context] != nil);
}

- (id)readObjectProperty:(NSString *)property jsonObject:(id)jsonObject context:(SMJEvaluationContextImpl *)context
{
	if ([jsonObject isKindOfClass:[NSDictionary class]])
	{
		NSDictionary *obj = jsonObject;
		
		return [obj objectForKey:property];
	}
	else if ([jsonObject isKindOfClass:[NSArray class]])
	{
		NSArray *obj = jsonObject;
		
		if (property.length == 0)
			return nil;
		
		NSCharacterSet *invalidSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
		
		if ([property rangeOfCharacterFromSet:invalidSet].location != NSNotFound)
			return nil;
		
		NSInteger index = [property integerValue];
		
		if (index < 0 || index >= obj.count)
			return nil;
		
		return obj[index];
	}
	
	return nil;
}

- (SMJEvaluationStatus)handleArrayIndex:(NSInteger)index currentPathString:(NSString *)currentPath jsonObject:(id)jsonObject evaluationContext:(SMJEvaluationContextImpl *)context error:(NSError **)error
{
	if ([jsonObject isKindOfClass:[NSArray class]] == NO)
		return SMJEvaluationStatusDone;
	
	NSArray *obj = jsonObject;
	
	NSString 	*evalPath = [SMJUtils stringByConcatenatingStrings:@[ currentPath, @"[", [NSString stringWithFormat:@"%ld", (long)index], @"]" ]];
	SMJPathRef	*pathRef = context.forUpdate ? [SMJPathRef pathRefWithObject:jsonObject item:obj[index]] : [SMJPathRef pathRefNull];
	
	NSInteger effectiveIndex = index < 0 ? obj.count + index : index;
	
	if (effectiveIndex < 0 || effectiveIndex >= obj.count)
		return SMJEvaluationStatusDone;

	id evalHit = obj[effectiveIndex];
	
	if (self.leaf)
	{
		if ([context addResult:evalPath operation:pathRef jsonObject:evalHit] == SMJEvaluationContextStatusAborted)
			return SMJEvaluationStatusAborted;
		
		return SMJEvaluationStatusDone;
	}
	else
	{
		return [self.next evaluateWithCurrentPath:evalPath parentPathRef:pathRef jsonObject:evalHit evaluationContext:context error:error];
	}
}

- (nullable SMJPathToken *)next
{
	if (self.leaf)
	{
		NSLog(@"Current path token is a leaf");
		return nil;
	}
	
	return _next;
}

- (void)setNext:(nullable SMJPathToken *)next
{
	_next = next;
}

- (BOOL)isLeaf
{
	return (_next == nil);
}

- (BOOL)isRoot
{
	return (_prev == nil);
}

- (BOOL)isUpstreamDefinite
{
	if (_upstreamDefinite == nil)
	{
		_upstreamDefinite = @([self isRoot] || (_prev.tokenDefinite && _prev.upstreamDefinite));
	}
	
	return [_upstreamDefinite boolValue];
}

- (NSInteger)tokenCount
{
	NSInteger		cnt = 1;
	SMJPathToken	*token = self;
	
	while (token.leaf == NO)
	{
		token = token.next;
		cnt++;
	}
	
	return cnt;
}

- (BOOL)isPathDefinite
{
	if (_definite)
		return [_definite boolValue];
	
	BOOL isDefinite = self.tokenDefinite;
	
	if (isDefinite && self.leaf == NO)
		isDefinite = _next.pathDefinite;
	
	_definite = @(isDefinite);
	
	return isDefinite;
}


- (NSString *)stringValue
{
	if (self.leaf)
		return self.pathFragment;
	else
		return [self.pathFragment stringByAppendingString:[_next stringValue]];
}


// Overwrite
- (SMJEvaluationStatus)evaluateWithCurrentPath:(NSString *)currentPath parentPathRef:(SMJPathRef *)parent jsonObject:(id)jsonObject evaluationContext:(SMJEvaluationContextImpl *)context error:(NSError **)error
{
	NSAssert(NO, @"need to be overwritten");
	return SMJEvaluationStatusError;
}

- (BOOL)isTokenDefinite
{
	NSAssert(NO, @"need to be overwritten");
	return NO;
}

- (NSString *)pathFragment
{
	NSAssert(NO, @"need to be overwritten");
	return (NSString *)nil;
}

@end


NS_ASSUME_NONNULL_END
