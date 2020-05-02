/*
 * SMJEvaluationContextImpl.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/path/EvaluationContextImpl.java */


#import "SMJEvaluationContextImpl.h"


NS_ASSUME_NONNULL_BEGIN


/*
** Macros
*/
#pragma mark Macros

#define SMSetError(Error, Code, Message, ...) \
	do { \
		if ((Error) && *(Error) == nil) {\
			NSString *___message = [NSString stringWithFormat:(Message), ## __VA_ARGS__];\
			*(Error) = [NSError errorWithDomain:@"SMJFoundResultImplErrorDomain" code:(Code) userInfo:@{ NSLocalizedDescriptionKey : ___message }]; \
		} \
	} while (0) \


/*
** SMJFoundResultImpl
*/
#pragma mark FoundResultImpl

@interface FoundResultImpl : NSObject <SMJFoundResult>

@end


@implementation FoundResultImpl

@synthesize index, path, result;

+ (instancetype)foundResultWithIndex:(NSInteger)index path:(NSString *)path result:(id)result
{
	FoundResultImpl *obj = [FoundResultImpl new];
	
	obj->index = index;
	obj->path = path;
	obj->result = result;

	return obj;
}

@end


/*
** SMJEvaluationContextImpl
*/
#pragma mark - SMJEvaluationContextImpl

@implementation SMJEvaluationContextImpl
{
	SMJConfiguration *_configuration;
	NSMutableArray *_valueResult;
	NSMutableArray *_pathResult;
	id <SMJPath> _path;
	id _rootJsonObject;
	NSMutableArray <SMJPathRef *> *_updateOperations;
	NSInteger _resultIndex;
}

/*
** SMJEvaluationContextImpl - Instance
*/
#pragma mark - SMJEvaluationContextImpl - Instance

- (instancetype)initWithPath:(id <SMJPath>)path rootJsonObject:(id)rootJsonObject configuration:(SMJConfiguration *)configuration forUpdate:(BOOL)forUpdate
{
	self = [super init];
	
	if (self)
	{
		//notNull(path, "path can not be null");
		//notNull(rootJsonObject, "root can not be null");
		//notNull(configuration, "configuration can not be null");
		
		_evaluationCache = [[NSMutableDictionary alloc] init];
		
		_forUpdate = forUpdate;
		_path = path;
		_rootJsonObject = rootJsonObject;
		_configuration = configuration;
		_valueResult = [NSMutableArray array];
		_pathResult = [NSMutableArray array];
		_updateOperations = [NSMutableArray array];
	}
	
	return self;
}


/*
** SMJEvaluationContextImpl - Result
*/
#pragma mark - SMJEvaluationContextImpl - Result

- (SMJEvaluationContextStatus)addResult:(NSString *)path operation:(SMJPathRef *)operation jsonObject:(id)jsonObject
{
	if (_forUpdate)
		[_updateOperations addObject:operation];
	
	[_valueResult addObject:jsonObject];
	[_pathResult addObject:[path copy]];
	
	_resultIndex++;
	
	NSArray 	*evaluationListeners = _configuration.evaluationListeners;
	NSInteger	idx = _resultIndex - 1;
	
	for (id <SMJEvaluationListener> listener in evaluationListeners)
	{
		SMJEvaluationContinuation continuation = [listener resultFound:[FoundResultImpl foundResultWithIndex:idx path:path result:jsonObject]];
		
		if (continuation == SMJEvaluationContinuationAbort)
			return SMJEvaluationContextStatusAborted;
	}
	
	return SMJEvaluationContextStatusDone;
}


/*
** SMJEvaluationContextImpl - SMJEvaluationContext
*/
#pragma mark - SMJEvaluationContextImpl - SMJEvaluationContext

- (SMJConfiguration *)configuration
{
	return _configuration;
}

- (NSArray <NSString *> *)pathList
{
	return [_pathResult copy];
}

- (NSArray <SMJPathRef *> *)updateOperations
{
	return [_updateOperations copy];
}

- (nullable id)jsonObjectWithError:(NSError **)error
{
	if (_path.definite)
	{
		if (_resultIndex == 0 || _valueResult.count == 0)
		{
			SMSetError(error, 1, @"No results for path: %@", [_path stringValue]);
			return nil;
		}
		
		return _valueResult.lastObject;
	}
	
	if (_valueResult == nil)
		return [NSNull null];
	
	return [_valueResult copy];
}

- (id)rootJsonObject
{
	return _rootJsonObject;
}

@end


NS_ASSUME_NONNULL_END
