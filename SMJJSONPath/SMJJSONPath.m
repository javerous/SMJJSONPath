/*
 * SMJJSONPath.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/JsonPath.java */


#import "SMJJSONPath.h"

#import "SMJPathCompiler.h"


NS_ASSUME_NONNULL_BEGIN


/*
** Macros
*/
#pragma mark - Macros

#define SMSetError(Error, Code, Message) \
	do { \
		if (Error)\
			*(Error) = [NSError errorWithDomain:@"SMJJSONPathErrorDomain" code:(Code) userInfo:@{ NSLocalizedDescriptionKey : (Message) }]; \
	} while (0) \



/*
** SMJJSONPath
*/
#pragma mark - SMJJSONPath

@implementation SMJJSONPath
{
	id <SMJPath> _path;
}


/*
** SMJJSONPath - Instance
*/
#pragma mark - SMJJSONPath - Instance

- (nullable instancetype)initWithJSONPathString:(NSString *)jsonPathString error:(NSError **)error
{
	self = [super init];
	
	if (self)
	{
		// Trim path.
		NSString *pathString = [jsonPathString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		
		if (pathString.length == 0)
		{
			SMSetError(error, 1, @"path can't be nil or empty");
			return nil;
		}
		
		// Compile path.
		id <SMJPath> path = [SMJPathCompiler compilePathString:pathString error:error];
		
		if (!path)
			return nil;
		
		// Store path.
		_path = path;
	}
	
	return self;
}


/*
** SMJJSONPath - Query
*/
#pragma mark - SMJJSONPath - Query

- (nullable id)resultForJSONData:(NSData *)data configuration:(nullable SMJConfiguration *)configuration error:(NSError **)error
{
	id rootJsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
	
	if (!rootJsonObject)
		return nil;
	
	return [self resultForJSONObject:rootJsonObject configuration:configuration error:error];
}

- (nullable id)resultForJSONFile:(NSURL *)url configuration:(nullable SMJConfiguration *)configuration error:(NSError **)error
{
	NSInputStream *inputStream = [NSInputStream inputStreamWithURL:url];
	
	[inputStream open];
	
	if ([inputStream streamStatus] == NSStreamStatusError)
	{
		if (error)
			*error = [inputStream streamError];
		
		return nil;
	}
	
	id rootJsonObject = [NSJSONSerialization JSONObjectWithStream:inputStream options:NSJSONReadingAllowFragments error:error];
	
	if (!rootJsonObject)
		return nil;

	return [self resultForJSONObject:rootJsonObject configuration:configuration error:error];
}

- (nullable id)resultForJSONObject:(id)jsonObject configuration:(nullable SMJConfiguration *)configuration error:(NSError **)error
{
	if (!configuration)
		configuration = [SMJConfiguration defaultConfiguration];
	
	BOOL optAsPathList = [configuration containsOption:SMJOptionAsPathList];
	BOOL optAlwaysReturnList = [configuration containsOption:SMJOptionAlwaysReturnList];
	
	if ([_path isFunctionPath])
	{
		if (optAsPathList || optAlwaysReturnList)
		{
			SMSetError(error, 1, @"Options SMJOptionAsPathList and SMJOptionAlwaysReturnList are not allowed when using path functions");
			return nil;
		}
		
		id <SMJEvaluationContext> evaluationContex = [_path evaluateJsonObject:jsonObject rootJsonObject:jsonObject configuration:configuration error:error];
		
		if (!evaluationContex)
			return nil;
		
		return [evaluationContex jsonObjectWithError:error];
		
	}
	else if (optAsPathList)
	{
		id <SMJEvaluationContext> evaluationContex = [_path evaluateJsonObject:jsonObject rootJsonObject:jsonObject configuration:configuration error:error];

		if (!evaluationContex)
			return nil;
		
		return evaluationContex.pathList;
	}
	else
	{
		id <SMJEvaluationContext> evaluationContex = [_path evaluateJsonObject:jsonObject rootJsonObject:jsonObject configuration:configuration error:error];

		if (!evaluationContex)
			return nil;
		
		id value = [evaluationContex jsonObjectWithError:error];
		
		if (!value)
			return nil;
		
		if (optAlwaysReturnList && _path.definite)
			return @[ value ];
		else
			return value;
	}
}


/*
** SMJJSONPath - Update
*/
#pragma mark - SMJJSONPath - Update

- (nullable id)updateMutableJSONObject:(id)jsonObject setObject:(id)object configuration:(nullable SMJConfiguration *)configuration error:(NSError **)error
{
	if (!configuration)
		configuration = [SMJConfiguration defaultConfiguration];
	
	id <SMJEvaluationContext> evaluationContext = [_path evaluateJsonObject:jsonObject rootJsonObject:jsonObject configuration:configuration forUpdate:YES error:error];
	
	if (!evaluationContext)
		return nil;
	
	NSArray <SMJPathRef *> *updateOperations = evaluationContext.updateOperations;
	
	for (SMJPathRef *pathRef in updateOperations)
	{
		if ([pathRef setObject:object configuration:configuration error:error] == NO)
			return nil;
	}
	
	return [self resultForJSONObject:jsonObject evaluationContext:evaluationContext configuration:configuration];
}

- (nullable id)updateMutableJSONObject:(id)jsonObject mapObjects:(SMJJSONPathMapper)mapper configuration:(nullable SMJConfiguration *)configuration error:(NSError **)error
{
	if (!configuration)
		configuration = [SMJConfiguration defaultConfiguration];
	
	id <SMJEvaluationContext> evaluationContext = [_path evaluateJsonObject:jsonObject rootJsonObject:jsonObject configuration:configuration forUpdate:YES error:error];

	if (!evaluationContext)
		return nil;
	
	NSArray <SMJPathRef *> *updateOperations = [evaluationContext updateOperations];

	for (SMJPathRef *pathRef in updateOperations)
	{
		if ([pathRef convertWithMapper:mapper configuration:configuration error:error] == NO)
			return nil;
	}
	
	return [self resultForJSONObject:jsonObject evaluationContext:evaluationContext configuration:configuration];
}

- (nullable id)updateMutableJSONObject:(id)jsonObject deleteWithConfiguration:(nullable SMJConfiguration *)configuration error:(NSError **)error
{
	if (!configuration)
		configuration = [SMJConfiguration defaultConfiguration];
	
	id <SMJEvaluationContext> evaluationContext = [_path evaluateJsonObject:jsonObject rootJsonObject:jsonObject configuration:configuration forUpdate:YES error:error];
	
	if (!evaluationContext)
		return nil;
	
	NSArray <SMJPathRef *> *updateOperations = evaluationContext.updateOperations;
	
	for (SMJPathRef *pathRef in updateOperations)
	{
		if ([pathRef deleteWithConfiguration:configuration error:error] == NO)
			return nil;
	}
	
	return [self resultForJSONObject:jsonObject evaluationContext:evaluationContext configuration:configuration];
}

- (nullable id)updateMutableJSONObject:(id)jsonObject addObject:(id)object configuration:(nullable SMJConfiguration *)configuration error:(NSError **)error
{
	if (!configuration)
		configuration = [SMJConfiguration defaultConfiguration];
	
	id <SMJEvaluationContext> evaluationContext = [_path evaluateJsonObject:jsonObject rootJsonObject:jsonObject configuration:configuration forUpdate:YES error:error];
	
	if (!evaluationContext)
		return nil;
	
	NSArray <SMJPathRef *> *updateOperations = evaluationContext.updateOperations;
	
	for (SMJPathRef *pathRef in updateOperations)
	{
		if ([pathRef addObject:object configuration:configuration error:error] == NO)
			return nil;
	}
	
	return [self resultForJSONObject:jsonObject evaluationContext:evaluationContext configuration:configuration];
}

- (nullable id)updateMutableJSONObject:(id)jsonObject putObject:(id)object key:(NSString *)key configuration:(nullable SMJConfiguration *)configuration error:(NSError **)error
{
	if (!configuration)
		configuration = [SMJConfiguration defaultConfiguration];
	
	id <SMJEvaluationContext> evaluationContext = [_path evaluateJsonObject:jsonObject rootJsonObject:jsonObject configuration:configuration forUpdate:YES error:error];
	
	if (!evaluationContext)
		return nil;
	
	NSArray <SMJPathRef *> *updateOperations = evaluationContext.updateOperations;
	
	for (SMJPathRef *pathRef in updateOperations)
	{
		if ([pathRef putObject:object forKey:key configuration:configuration error:error] == NO)
			return nil;
	}
	
	return [self resultForJSONObject:jsonObject evaluationContext:evaluationContext configuration:configuration];
}

- (nullable id)updateMutableJSONObject:(id)jsonObject renameKey:(NSString *)oldKey toKey:(NSString *)newKey configuration:(nullable SMJConfiguration *)configuration error:(NSError **)error
{
	if (!configuration)
		configuration = [SMJConfiguration defaultConfiguration];
	
	id <SMJEvaluationContext> evaluationContext = [_path evaluateJsonObject:jsonObject rootJsonObject:jsonObject configuration:configuration forUpdate:YES error:error];
	
	if (!evaluationContext)
		return nil;
	
	NSArray <SMJPathRef *> *updateOperations = evaluationContext.updateOperations;
	
	for (SMJPathRef *pathRef in updateOperations)
	{
		if ([pathRef renameKey:oldKey toKey:newKey configuration:configuration error:error] == NO)
			return nil;
	}
	
	return [self resultForJSONObject:jsonObject evaluationContext:evaluationContext configuration:configuration];
}


/*
** SMJJSONPath - Helpers
*/
#pragma mark - SMJJSONPath - Helpers

- (id)resultForJSONObject:(id)jsonObject evaluationContext:(id <SMJEvaluationContext>)evaluationContext configuration:(SMJConfiguration *)configuration
{
	if ([configuration containsOption:SMJOptionAsPathList])
		return evaluationContext.pathList;
	else
		return jsonObject;
}

@end


NS_ASSUME_NONNULL_END

