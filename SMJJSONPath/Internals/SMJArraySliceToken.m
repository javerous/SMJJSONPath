/*
 * SMJArraySliceToken.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/path/ArraySliceToken.java */


#import "SMJArraySliceToken.h"

#import "SMJArraySliceOperation.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJArraySliceToken
*/
#pragma mark - SMJArraySliceToken

@implementation SMJArraySliceToken
{
	SMJArraySliceOperation *_sliceOperation;
}


/*
** SMJArraySliceToken - Instance
*/
#pragma mark - SMJArraySliceToken - Instance

- (instancetype)initWithSliceOperation:(SMJArraySliceOperation *)sliceOperation
{
	self = [super init];
	
	if (self)
	{
		_sliceOperation = sliceOperation;
	}
	
	return self;
}


/*
** SMJArraySliceToken - SMJPathToken
*/
#pragma mark - SMJArraySliceToken - SMJPathToken

- (SMJEvaluationStatus)evaluateWithCurrentPath:(NSString *)currentPath parentPathRef:(SMJPathRef *)parent jsonObject:(id)jsonObject evaluationContext:(SMJEvaluationContextImpl *)context error:(NSError **)error
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
			
		case SMJSliceOperationBetween:
			return [self sliceBetweenWithOperation:_sliceOperation currentPathString:currentPath parentPathRef:parent jsonObject:jsonObject evaluationContext:context error:error];
			
		case SMJSliceOperationTo:
			return [self sliceToWithOperation:_sliceOperation currentPathString:currentPath parentPathRef:parent jsonObject:jsonObject evaluationContext:context error:error];
	}
	
	return SMJEvaluationStatusDone;
}

- (BOOL)isTokenDefinite
{
	return NO;
}

- (NSString *)pathFragment
{
	return [_sliceOperation stringValue];
}


/*
** SMJArraySliceToken - Helpers
*/
#pragma mark - SMJArraySliceToken - Helpers

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

@end


NS_ASSUME_NONNULL_END
