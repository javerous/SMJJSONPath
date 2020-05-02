/*
 * SMJScanPathToken.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/path/ScanPathToken.java */


#import "SMJScanPathToken.h"

#import "SMJPropertyPathToken.h"
#import "SMJArrayPathToken.h"
#import "SMJWildcardPathToken.h"
#import "SMJPredicatePathToken.h"


NS_ASSUME_NONNULL_BEGIN


/*
** Predicates - Interface
*/
#pragma mark - Predicates - Interface

@protocol SMJScanPredicate <NSObject>
- (BOOL)matchesJsonObject:(id)jsonObject;
@end

@interface SMJPropertyPathTokenPredicate : NSObject <SMJScanPredicate>
- (instancetype)initWithTarget:(SMJPathToken *)target context:(SMJEvaluationContextImpl *)context;
@end

@interface SMJArrayPathTokenPredicate : NSObject <SMJScanPredicate>
@end

@interface SMJWildcardPathTokenPredicate : NSObject <SMJScanPredicate>
@end

@interface SMJFilterPathTokenPredicate : NSObject <SMJScanPredicate>
- (instancetype)initWithTarget:(SMJPathToken *)target context:(SMJEvaluationContextImpl *)context;
@end

@interface SMJFakePredicate : NSObject <SMJScanPredicate>
@end



/*
** SMJScanPathToken
*/
#pragma mark - SMJScanPathToken

@implementation SMJScanPathToken


/*
** SMJScanPathToken - SMJPathToken
*/
#pragma mark - SMJScanPathToken - SMJPathToken

- (SMJEvaluationStatus)evaluateWithCurrentPath:(NSString *)currentPath parentPathRef:(SMJPathRef *)parent jsonObject:(id)jsonObject evaluationContext:(SMJEvaluationContextImpl *)context error:(NSError **)error
{
	SMJPathToken *pt = self.next;
	
	return [self walk:pt currentPath:currentPath parent:parent jsonObject:jsonObject context:context predicate:[self createScanPredicate:pt context:context] error:error];
}

- (BOOL)isTokenDefinite
{
	return NO;
}

- (NSString *)pathFragment
{
	return @"..";
}


/*
** SMJScanPathToken - Helpers
*/
#pragma mark - SMJScanPathToken - Helpers

- (SMJEvaluationStatus)walk:(SMJPathToken *)pt currentPath:(NSString *)currentPath parent:(SMJPathRef *)parent jsonObject:(id)jsonObject context:(SMJEvaluationContextImpl *)context predicate:(id <SMJScanPredicate>)predicate  error:(NSError **)error
{
	if ([jsonObject isKindOfClass:[NSDictionary class]])
		return [self walkObject:pt currentPath:currentPath parent:parent jsonObject:jsonObject context:context predicate:predicate error:error];
	else if ([jsonObject isKindOfClass:[NSArray class]])
		return [self walkArray:pt currentPath:currentPath parent:parent jsonObject:jsonObject context:context predicate:predicate error:error];
	
	return SMJEvaluationStatusDone;
}

- (SMJEvaluationStatus)walkArray:(SMJPathToken *)pt currentPath:(NSString *)currentPath parent:(SMJPathRef *)parent jsonObject:(NSArray *)jsonObject context:(SMJEvaluationContextImpl *)context predicate:(id <SMJScanPredicate>)predicate error:(NSError **)error
{
	// Evaluate.
	if ([predicate matchesJsonObject:jsonObject])
	{
		if (pt.leaf)
		{
			SMJEvaluationStatus result = [pt evaluateWithCurrentPath:currentPath parentPathRef:parent jsonObject:jsonObject evaluationContext:context error:error];
			
			if (result == SMJEvaluationStatusError)
				return SMJEvaluationStatusError;
			else if (result == SMJEvaluationStatusAborted)
				return SMJEvaluationStatusAborted;
		}
		else
		{
			SMJPathToken *next = pt.next;
			NSUInteger	 idx = 0;

			for (id evalObject in jsonObject)
			{
				NSString *evalPath = [NSString stringWithFormat:@"%@[%lu]", currentPath, (unsigned long)idx];
				SMJEvaluationStatus result = [next evaluateWithCurrentPath:evalPath parentPathRef:parent jsonObject:evalObject evaluationContext:context error:error];
				
				if (result == SMJEvaluationStatusError)
					return SMJEvaluationStatusError;
				else if (result == SMJEvaluationStatusAborted)
					return SMJEvaluationStatusAborted;
				
				idx++;
			}
		}
	}
	
	// Recurse.
	NSUInteger idx = 0;

	for (id evalObject in jsonObject)
	{
		NSString *evalPath = [NSString stringWithFormat:@"%@[%lu]", currentPath, (unsigned long)idx];
		SMJEvaluationStatus result = [self walk:pt currentPath:evalPath parent:[SMJPathRef pathRefWithObject:jsonObject item:evalObject]  jsonObject:evalObject context:context predicate:predicate error:error];
		
		if (result == SMJEvaluationStatusError)
			return SMJEvaluationStatusError;
		else if (result == SMJEvaluationStatusAborted)
			return SMJEvaluationStatusAborted;
		
		idx++;
	}
	
	return SMJEvaluationStatusDone;
}

- (SMJEvaluationStatus)walkObject:(SMJPathToken *)pt currentPath:(NSString *)currentPath parent:(SMJPathRef *)parent jsonObject:(NSDictionary *)jsonObject context:(SMJEvaluationContextImpl *)context predicate:(id <SMJScanPredicate>)predicate error:(NSError **)error
{
	// Evaluate.
	if ([predicate matchesJsonObject:jsonObject])
	{
		SMJEvaluationStatus result = [pt evaluateWithCurrentPath:currentPath parentPathRef:parent jsonObject:jsonObject evaluationContext:context error:error];
		
		if (result == SMJEvaluationStatusError)
			return SMJEvaluationStatusError;
		else if (result == SMJEvaluationStatusAborted)
			return SMJEvaluationStatusAborted;
	}
	
	// Recurse.
	for (NSString *property in jsonObject)
	{
		id propertyObject = jsonObject[property];
		
		NSString *evalPath = [NSString stringWithFormat:@"%@['%@']", currentPath, property];
		
		SMJEvaluationStatus result = [self walk:pt currentPath:evalPath parent:[SMJPathRef pathRefWithObject:jsonObject property:property] jsonObject:propertyObject context:context predicate:predicate error:error];
		
		if (result == SMJEvaluationStatusError)
			return SMJEvaluationStatusError;
		else if (result == SMJEvaluationStatusAborted)
			return SMJEvaluationStatusAborted;
	}
	
	return SMJEvaluationStatusDone;
}

- (id <SMJScanPredicate>)createScanPredicate:(SMJPathToken *)target context:(SMJEvaluationContextImpl *)context
{
	if ([target isKindOfClass:[SMJPropertyPathToken class]])
		return [[SMJPropertyPathTokenPredicate alloc] initWithTarget:target context:context];
	else if ([target isKindOfClass:[SMJArrayPathToken class]])
		return [[SMJArrayPathTokenPredicate alloc] init];
	else if ([target isKindOfClass:[SMJWildcardPathToken class]])
		return [[SMJWildcardPathTokenPredicate alloc] init];
	else if ([target isKindOfClass:[SMJPredicatePathToken class]])
		return [[SMJFilterPathTokenPredicate alloc] initWithTarget:target context:context];
	else
		return [[SMJFakePredicate alloc] init];
}

@end



/*
** Predicates
*/
#pragma mark - Predicates

#pragma mark SMJPropertyPathTokenPredicate

@implementation SMJPropertyPathTokenPredicate
{
	SMJEvaluationContextImpl	*_ctx;
	SMJPropertyPathToken		*_propertyPathToken;
}

- (instancetype)initWithTarget:(SMJPathToken *)target context:(SMJEvaluationContextImpl *)context
{
	self = [super init];
	
	if (self)
	{
		_propertyPathToken = (SMJPropertyPathToken *)target;
		_ctx = context;
	}
	
	return self;
}

- (BOOL)matchesJsonObject:(id)jsonObject
{
	if (![jsonObject isKindOfClass:[NSDictionary class]])
		return NO;

	//
	// The commented code below makes it really hard understand, use and predict the result
	// of deep scanning operations. It might be correct but was decided to be
	// left out until the behavior of SMJOptionRequireProperties is more strictly defined
	// in a deep scanning scenario. For details read conversation in commit
	// https://github.com/jayway/JsonPath/commit/1a72fc078deb16995e323442bfb681bd715ce45a#commitcomment-14616092
	//
	//            if (ctx.options().contains(Option.SMJOptionRequireProperties)) {
	//                // Have to require properties defined in path when an indefinite path is evaluated,
	//                // so have to go there and search for it.
	//                return true;
	//            }
	
	if (! [_propertyPathToken isTokenDefinite])
	{
		// It's responsibility of PropertyPathToken code to handle indefinite scenario of properties,
		// so we'll allow it to do its job.
		return YES;
	}
	
	if (_propertyPathToken.leaf && [_ctx.configuration containsOption:SMJOptionDefaultPathLeafToNull])
	{
		// In case of SMJOptionDefaultPathLeafToNull missing properties is not a problem.
		return YES;
	}
	
	NSArray <NSString *> *keys = [(NSDictionary *)jsonObject allKeys];
	NSArray <NSString *> *properties = _propertyPathToken.properties;
	
	for (NSString *property in properties)
	{
		if ([keys containsObject:property] == NO)
			return NO;
	}
	
	return YES;
}

@end


#pragma mark SMJArrayPathTokenPredicate

@implementation SMJArrayPathTokenPredicate

- (BOOL)matchesJsonObject:(id)jsonObject
{
	return [jsonObject isKindOfClass:[NSArray class]];
}

@end


#pragma mark SMJWildcardPathTokenPredicate

@implementation SMJWildcardPathTokenPredicate

- (BOOL)matchesJsonObject:(id)jsonObject
{
	return YES;
}

@end


#pragma mark SMJFilterPathTokenPredicate

@implementation SMJFilterPathTokenPredicate
{
	SMJEvaluationContextImpl *_ctx;
	SMJPredicatePathToken *_predicatePathToken;
}

- (instancetype)initWithTarget:(SMJPathToken *)target context:(SMJEvaluationContextImpl *)context
{
	self = [super init];
	
	if (self)
	{
		_predicatePathToken = (SMJPredicatePathToken *)target;
		_ctx = context;
	}
	
	return self;
}

- (BOOL)matchesJsonObject:(id)jsonObject
{
	return [_predicatePathToken acceptJsonObject:jsonObject rootJsonObject:_ctx.rootJsonObject configuration:_ctx.configuration evaluationContext:_ctx];
}

@end


#pragma mark SMJFakePredicate

@implementation SMJFakePredicate

- (BOOL)matchesJsonObject:(id)jsonObject
{
	return NO;
}

@end


NS_ASSUME_NONNULL_END
