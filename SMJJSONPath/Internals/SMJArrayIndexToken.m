/*
 * SMJArrayIndexToken.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/path/ArrayIndexToken.java */


#import "SMJArrayIndexToken.h"

#import "SMJArrayIndexOperation.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJArrayIndexToken
*/
#pragma mark - SMJArrayIndexToken

@implementation SMJArrayIndexToken
{
	SMJArrayIndexOperation *_indexOperation;
}


/*
** SMJArrayIndexToken - Instance
*/
#pragma mark - SMJArrayIndexToken - Instance

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
** SMJArrayIndexToken - SMJPathToken
*/
#pragma mark - SMJArrayIndexToken - SMJPathToken

- (SMJEvaluationStatus)evaluateWithCurrentPath:(NSString *)currentPath parentPathRef:(SMJPathRef *)parent jsonObject:(id)jsonObject evaluationContext:(SMJEvaluationContextImpl *)context error:(NSError **)error
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

- (BOOL)isTokenDefinite
{
	return _indexOperation.singleIndexOperation;
}

- (NSString *)pathFragment
{
	return [_indexOperation stringValue];
}

@end


NS_ASSUME_NONNULL_END
