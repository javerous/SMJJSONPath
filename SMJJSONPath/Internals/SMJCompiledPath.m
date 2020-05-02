/*
 * SMJCompiledPath.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/path/CompiledPath.java */


#import "SMJCompiledPath.h"

#import "SMJFunctionPathToken.h"
#import "SMJScanPathToken.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJCompiledPath
*/
#pragma mark - SMJCompiledPath

@implementation SMJCompiledPath
{
	SMJRootPathToken *_root;
	
	BOOL _isRootPath;
}


/*
** SMJCompiledPath - Instance
*/
#pragma mark - SMJCompiledPath - Instance

- (instancetype)initWithRootPathToken:(SMJRootPathToken *)root isRootPath:(BOOL)isRootPath
{
	self = [super init];
	
	if (self)
	{
		_root = [self invertScannerFunctionRelationshipWithToken:root];
		_isRootPath = isRootPath;
	}
	
	return self;
}


/*
** SMJCompiledPath - Helpers
*/
#pragma mark - SMJCompiledPath - Helpers

/**
 * In the event the writer of the path referenced a function at the tail end of a scanner, augment the query such
 * that the root node is the function and the parameter to the function is the scanner.   This way we maintain
 * relative sanity in the path expression, functions either evaluate scalar values or arrays, they're
 * not re-entrant nor should they maintain state, they do however take parameters.
 *
 * @param path
 *      this is our old root path which will become a parameter (assuming there's a scanner terminated by a function
 *
 * @return
 *      A function with the scanner as input, or if this situation doesn't exist just the input path
 */
- (SMJRootPathToken *)invertScannerFunctionRelationshipWithToken:(SMJRootPathToken *)path
{
	if (path.functionPath && [path.next isKindOfClass:[SMJScanPathToken class]])
	{
		SMJPathToken *token = path;
		SMJPathToken *prior = nil;
		
		while (((token = token.next) != nil) && ([token isKindOfClass:[SMJFunctionPathToken class]] == NO))
			prior = token;
		
		// Invert the relationship $..path.function() to $.function($..path)
		if ([token isKindOfClass:[SMJFunctionPathToken class]])
		{
			prior.next = nil;
			path.tail = prior;
			
			// Now generate a new parameter from our path
			SMJCompiledPath *newPath = [[SMJCompiledPath alloc] initWithRootPathToken:path isRootPath:YES];
			SMJParameter	*newParameter = [[SMJParameter alloc] initWithPath:newPath];
			
			[(SMJFunctionPathToken *)token setFunctionParams:@[ newParameter ]];
			
			SMJRootPathToken *functionRoot = [[SMJRootPathToken alloc] initWithRootToken:'$'];
			
			functionRoot.tail = token;
			functionRoot.next = token;
			
			return functionRoot;
		}
	}
	
	return path;
}



/*
** SMJCompiledPath - SMJPath
*/
#pragma mark - SMJCompiledPath - SMJPath

- (NSString *)stringValue
{
	return [_root stringValue];
}

- (nullable id <SMJEvaluationContext>)evaluateJsonObject:(id)jsonObject rootJsonObject:(id)rootJsonObject configuration:(SMJConfiguration *)configuration error:(NSError **)error
{
	return [self evaluateJsonObject:jsonObject rootJsonObject:rootJsonObject configuration:configuration forUpdate:NO error:error];
}

- (nullable id <SMJEvaluationContext>)evaluateJsonObject:(id)jsonObject rootJsonObject:(id)rootJsonObject configuration:(SMJConfiguration *)configuration forUpdate:(BOOL)forUpdate error:(NSError **)error
{
	//if (logger.isDebugEnabled()) {
	//	logger.debug("Evaluating path: {}", toString());
	//}
	
	SMJEvaluationContextImpl *context = [[SMJEvaluationContextImpl alloc] initWithPath:self rootJsonObject:rootJsonObject configuration:configuration forUpdate:forUpdate];
	SMJPathRef				 *op = context.forUpdate ?  [SMJPathRef pathRefWithRootObject:rootJsonObject] : [SMJPathRef pathRefNull];

	SMJEvaluationStatus result = [_root evaluateWithCurrentPath:@"" parentPathRef:op jsonObject:jsonObject evaluationContext:context error:error];
	
	if (result == SMJEvaluationStatusError)
		return nil;
	
	return context;
}

- (BOOL)isDefinite
{
	return _root.pathDefinite;
}

- (BOOL)isFunctionPath
{
	return _root.functionPath;
}

- (BOOL)isRootPath
{
	 return _isRootPath;
}

@end


NS_ASSUME_NONNULL_END
