/*
 * SMJArrayPathToken.m
 *
 * Copyright 2017 Avérous Julien-Pierre
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
			*(Error) = [NSError errorWithDomain:@"SMJArrayPathTokenrrorDomain" code:(Code) userInfo:@{ NSLocalizedDescriptionKey : ___message }]; \
		} \
	} while (0) \



/*
** Types
*/
#pragma mark - Types

typedef enum SMJArrayPathCheck
{
	SMJArrayPathCheckHandle,
	SMJArrayPathCheckSkip,
	SMJArrayPathCheckError
} SMJArrayPathCheck;



/*
** SMJArrayPathToken
*/
#pragma mark - SMJArrayPathToken

@implementation SMJArrayPathToken
{
	SMJArraySliceOperation *_sliceOperation;
	SMJArrayIndexOperation *_indexOperation;
}


/*
** SMJArrayPathToken - Instance
*/
#pragma mark - SMJArrayPathToken - Instance

- (instancetype)initWithSliceOperation:(SMJArraySliceOperation *)sliceOperation
{
	self = [super init];
	
	if (self)
	{
		_sliceOperation = sliceOperation;
	}
	
	return self;
}

- (instancetype)initWithIndexOperation:(SMJArrayIndexOperation *)indexOperation
{
	self = [super init];
	
	if (self)
	{
		_indexOperation = indexOperation;
	}
	
	return self;
}


/*
** SMJArrayPathToken - Helpers
*/
#pragma mark - SMJArrayPathToken - Helpers

- (SMJEvaluationStatus)evaluateIndexOperationWithCurrentPathString:(NSString *)currentPath parentPathRef:(SMJPathRef *)parent jsonObject:(id)jsonObject evaluationContext:(SMJEvaluationContextImpl *)context error:(NSError **)error
{
	SMJArrayPathCheck checkResult = [self checkArrayWithCurrentPathString:currentPath jsonObject:jsonObject evaluationContext:context error:error];
	
	if (checkResult == SMJArrayPathCheckSkip)
		return SMJEvaluationStatusDone;
	else if (checkResult == SMJArrayPathCheckError)
		return SMJEvaluationStatusError;
	
	
	if (_indexOperation.singleIndexOperation)
	{
		NSArray <NSNumber *> *indexSet = _indexOperation.indexes;
		SMJEvaluationStatus result = [self handleArrayIndex:indexSet.firstObject.integerValue currentPathString:currentPath jsonObject:jsonObject evaluationContext:context error:error];
		
		if (result == SMJEvaluationStatusError)
			return SMJEvaluationStatusError;
		else if (result == SMJEvaluationStatusAborted)
			return SMJEvaluationStatusAborted;
	}
	else
	{
		NSArray <NSNumber *> *indexSet = _indexOperation.indexes;
		
		for (NSNumber *index in indexSet)
		{
			SMJEvaluationStatus result = [self handleArrayIndex:index.integerValue currentPathString:currentPath jsonObject:jsonObject evaluationContext:context error:error];
			
			if (result == SMJEvaluationStatusError)
				return SMJEvaluationStatusError;
			else if (result == SMJEvaluationStatusAborted)
				return SMJEvaluationStatusAborted;
		}
	}
	
	return SMJEvaluationStatusDone;
}

- (SMJEvaluationStatus)evaluateSliceOperationWithCurrentPathString:(NSString *)currentPath parentPathRef:(SMJPathRef *)parent jsonObject:(id)jsonObject evaluationContext:(SMJEvaluationContextImpl *)context error:(NSError **)error
{
	SMJArrayPathCheck checkResult = [self checkArrayWithCurrentPathString:currentPath jsonObject:jsonObject evaluationContext:context error:error];
	
	if (checkResult == SMJArrayPathCheckSkip)
		return SMJEvaluationStatusDone;
	else if (checkResult == SMJArrayPathCheckError)
		return SMJEvaluationStatusError;
	
	
	switch (_sliceOperation.operation)
	{
		case SMJSliceOperationFrom:
			return [self sliceFromWithOperation:_sliceOperation currentPathString:currentPath parentPathRef:parent jsonObject:jsonObject evaluationContext:context error:error];
			break;
			
		case SMJSliceOperationBetween:
			return [self sliceBetweenWithOperation:_sliceOperation currentPathString:currentPath parentPathRef:parent jsonObject:jsonObject evaluationContext:context error:error];
			break;
			
		case SMJSliceOperationTo:
			return [self sliceToWithOperation:_sliceOperation currentPathString:currentPath parentPathRef:parent jsonObject:jsonObject evaluationContext:context error:error];
			break;
	}
	
	return SMJEvaluationStatusDone;
}

- (SMJEvaluationStatus)sliceFromWithOperation:(SMJArraySliceOperation *)operation currentPathString:(NSString *)currentPath parentPathRef:(SMJPathRef *)parent jsonObject:(id)jsonObject evaluationContext:(SMJEvaluationContextImpl *)context error:(NSError **)error
{
	NSArray *array = jsonObject;
	NSInteger length = array.count;
	NSInteger from = operation.fromIndex;
	
	//calculate slice start from array length
	if (from < 0)
		from = length + from;
	
	from = MAX(0, from);
	
	//logger.debug("Slice from index on array with length: {}. From index: {} to: {}. Input: {}", length, from, length - 1, toString());
	
	if (length == 0 || from >= length)
		return SMJEvaluationStatusDone;
	
	for (NSInteger i = from; i < length; i++)
	{
		SMJEvaluationStatus result = [self handleArrayIndex:i currentPathString:currentPath jsonObject:jsonObject evaluationContext:context error:error];
		
		if (result == SMJEvaluationStatusError)
			return SMJEvaluationStatusError;
		else if (result == SMJEvaluationStatusAborted)
			return SMJEvaluationStatusAborted;
	}
	
	return SMJEvaluationStatusDone;
}

- (SMJEvaluationStatus)sliceBetweenWithOperation:(SMJArraySliceOperation *)operation currentPathString:(NSString *)currentPath parentPathRef:(SMJPathRef *)parent jsonObject:(id)jsonObject evaluationContext:(SMJEvaluationContextImpl *)context error:(NSError **)error
{
	NSArray *array = jsonObject;
	NSInteger length = array.count;
	NSInteger from = operation.fromIndex;
	NSInteger to = operation.toIndex;
	
	to = MIN(length, to);
	
	if (from >= to || length == 0)
	{
		return SMJEvaluationStatusDone;
	}
	
	//logger.debug("Slice between indexes on array with length: {}. From index: {} to: {}. Input: {}", length, from, to, toString());
	
	for (NSInteger i = from; i < to; i++)
	{
		SMJEvaluationStatus result = [self handleArrayIndex:i currentPathString:currentPath jsonObject:jsonObject evaluationContext:context error:error];
		
		if (result == SMJEvaluationStatusError)
			return SMJEvaluationStatusError;
		else if (result == SMJEvaluationStatusAborted)
			return SMJEvaluationStatusAborted;
	}
	
	return SMJEvaluationStatusDone;
}

- (SMJEvaluationStatus)sliceToWithOperation:(SMJArraySliceOperation *)operation currentPathString:(NSString *)currentPath parentPathRef:(SMJPathRef *)parent jsonObject:(id)jsonObject evaluationContext:(SMJEvaluationContextImpl *)context error:(NSError **)error
{
	NSArray		*array = jsonObject;
	NSInteger	length = array.count;
	
	if (length == 0)
		return SMJEvaluationStatusDone;
	
	NSInteger to = operation.toIndex;
	
	//calculate slice end from array length
	if (to < 0)
		to = length + to;

	to = MIN(length, to);
	
	//logger.debug("Slice to index on array with length: {}. From index: 0 to: {}. Input: {}", length, to, toString());
	
	for (NSInteger i = 0; i < to; i++)
	{
		SMJEvaluationStatus result = [self handleArrayIndex:i currentPathString:currentPath jsonObject:jsonObject evaluationContext:context error:error];
		
		if (result == SMJEvaluationStatusError)
			return SMJEvaluationStatusError;
		else if (result == SMJEvaluationStatusAborted)
			return SMJEvaluationStatusAborted;
	}
	
	return SMJEvaluationStatusDone;
}


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


/*
** SMJArrayPathToken - SMJPathToken
*/
#pragma mark - SMJArrayPathToken - SMJPathToken

- (SMJEvaluationStatus)evaluateWithCurrentPath:(NSString *)currentPath parentPathRef:(SMJPathRef *)parent jsonObject:(id)jsonObject evaluationContext:(SMJEvaluationContextImpl *)context error:(NSError **)error
{
	SMJArrayPathCheck checkResult = [self checkArrayWithCurrentPathString:currentPath jsonObject:jsonObject evaluationContext:context error:error];
	
	if (checkResult == SMJArrayPathCheckSkip)
		return SMJEvaluationStatusDone;
	else if (checkResult == SMJArrayPathCheckError)
		return SMJEvaluationStatusError;
	
	if (_sliceOperation)
		return [self evaluateSliceOperationWithCurrentPathString:currentPath parentPathRef:parent jsonObject:jsonObject evaluationContext:context error:error];
	else
		return [self evaluateIndexOperationWithCurrentPathString:currentPath parentPathRef:parent jsonObject:jsonObject evaluationContext:context error:error];
}

- (BOOL)isTokenDefinite
{
	if (_indexOperation)
		return _indexOperation.singleIndexOperation;
	else
		return NO;
}

- (NSString *)pathFragment
{
	if (_indexOperation)
		return [_indexOperation stringValue];
	else
		return [_sliceOperation stringValue];
}

@end


NS_ASSUME_NONNULL_END
