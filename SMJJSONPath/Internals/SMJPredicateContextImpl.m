/*
 * SMJPredicateContextImpl.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/path/PredicateContextImpl.java */


#import "SMJPredicateContextImpl.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJPredicateContextImpl
*/
#pragma mark - SMJPredicateContextImpl

@implementation SMJPredicateContextImpl
{
	id _jsonObject;
	id _rootJsonObject;
	SMJConfiguration *_configuration;
	NSMutableDictionary<NSString *, id> *_pathCache;
}

- (instancetype)initWithJsonObject:(id)jsonObject rootJsonObject:(id)rootJsonObject configuration:(SMJConfiguration *)configuration pathCache:(NSMutableDictionary <NSString *, id> *)pathCache
{
	self = [super init];
	
	if (self)
	{
		_jsonObject = jsonObject;
		_rootJsonObject = rootJsonObject;
		_configuration = configuration;
		_pathCache = pathCache;
	}
	
	return self;
}

- (nullable id)evaluatePath:(id <SMJPath>)path error:(NSError **)error
{
	id result;
	
	if (path.rootPath)
	{
		NSString	*pathString = [path stringValue];
		id			obj = _pathCache[pathString];
		
		if (obj)
		{
			//logger.debug("Using cached result for root path: " + path.toString());
			result = obj;
		}
		else
		{
			id <SMJEvaluationContext> evaluationContext = [path evaluateJsonObject:_rootJsonObject rootJsonObject:_rootJsonObject configuration:_configuration error:error];
			
			if (!evaluationContext)
				return nil;
			
			result = [evaluationContext jsonObjectWithError:error];
			
			if (result)
				_pathCache[pathString] = result;
		}
	}
	else
	{
		id <SMJEvaluationContext> evaluationContext = [path evaluateJsonObject:_jsonObject rootJsonObject:_rootJsonObject configuration:_configuration error:error];
		
		if (!evaluationContext)
			return nil;
		
		result = [evaluationContext jsonObjectWithError:error];
	}
	
	return result;
}

// SMJPredicateContext
- (id)jsonObject
{
	return _jsonObject;
}

- (id)rootJsonObject
{
	return _rootJsonObject;
}

- (SMJConfiguration *)configuration
{
	return _configuration;
}

@end


NS_ASSUME_NONNULL_END
