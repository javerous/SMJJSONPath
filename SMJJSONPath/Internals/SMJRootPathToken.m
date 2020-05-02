/*
 * SMJRootPathToken.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/path/RootPathToken.java */


#import "SMJRootPathToken.h"

#import "SMJPathRef.h"

#import "SMJFunctionPathToken.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJRootPathToken - Private
*/
#pragma mark - SMJRootPathToken - Private

@interface SMJRootPathToken () <SMJPathTokenAppender>

@end


/*
** SMJRootPathToken
*/
#pragma mark - SMJRootPathToken

@implementation SMJRootPathToken
{
	__weak SMJPathToken	*_tail;
	NSInteger 		_tokenCount;
	NSString 		*_rootToken;
}


/*
** SMJRootPathToken - Instance
*/
#pragma mark - SMJRootPathToken - Instance

- (instancetype)initWithRootToken:(unichar)rootToken
{
	self = [super init];
	
	if (self)
	{
		_rootToken = [NSString stringWithCharacters:&rootToken length:1];
		_tokenCount = 1;
		_tail = self;
	}
	
	return self;
}


/*
** SMJRootPathToken - Content
*/
#pragma mark - SMJRootPathToken - Content

- (id <SMJPathTokenAppender>)appendPathToken:(SMJPathToken *)token
{
	_tail = [_tail appendTailToken:token];
	
	_tokenCount++;
	
	return self;
}

- (id <SMJPathTokenAppender>)pathTokenAppender
{
	return self;
}

- (SMJPathToken *)tail
{
	return _tail;
}

- (void)setTail:(SMJPathToken *)tail
{
	_tail = tail;
}


/*
** SMJRootPathToken - Properties
*/
#pragma mark - SMJRootPathToken - Properties

- (BOOL)isFunctionPath
{
	return [_tail isKindOfClass:[SMJFunctionPathToken class]];
}


/*
** SMJRootPathToken - SMJPathToken
*/
#pragma mark - SMJRootPathToken - SMJPathToken

- (SMJEvaluationStatus)evaluateWithCurrentPath:(NSString *)currentPath parentPathRef:(SMJPathRef *)pathRef jsonObject:(id)jsonObject evaluationContext:(SMJEvaluationContextImpl *)context error:(NSError **)error
{
	if (self.leaf)
	{
		SMJPathRef *op = context.forUpdate ? pathRef : [SMJPathRef pathRefNull];
		
		if ([context addResult:_rootToken operation:op jsonObject:jsonObject] == SMJEvaluationContextStatusAborted)
			return SMJEvaluationStatusAborted;
		
		return SMJEvaluationStatusDone;
	}
	else
	{
		return [self.next evaluateWithCurrentPath:_rootToken parentPathRef:pathRef jsonObject:jsonObject evaluationContext:context error:error];
	}
}

- (NSInteger)tokenCount
{
	return _tokenCount;
}

- (BOOL)isTokenDefinite
{
	return YES;
}

- (NSString *)pathFragment
{
	return _rootToken;
}

@end


NS_ASSUME_NONNULL_END
