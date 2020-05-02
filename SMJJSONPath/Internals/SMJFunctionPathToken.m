/*
 * SMJFunctionPathToken.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/path/FunctionPathToken.java */


#import "SMJFunctionPathToken.h"

#import "SMJPathFunctionFactory.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJFunctionPathToken
*/
#pragma mark - SMJFunctionPathToken

@implementation SMJFunctionPathToken
{
	NSString *_functionName;
	NSString *_pathFragment;
}


/*
** SMJFunctionPathToken - Instance
*/
#pragma mark - SMJFunctionPathToken - Instance

- (instancetype)initWithPathFragment:(NSString *)pathFragment parameters:(NSArray <SMJParameter *> *)parameters
{
	self = [super init];
	
	if (self)
	{
		_pathFragment = [pathFragment stringByAppendingString:(parameters.count > 0 ? @"(...)" : @"()")];
		
		if (_pathFragment != nil)
		{
			_functionName = [pathFragment copy];
			_functionParams = [parameters copy];
		}
	}
	
	return self;
}


/*
** SMJFunctionPathToken - SMJPathToken
*/
#pragma mark - SMJFunctionPathToken - SMJPathToken

- (SMJEvaluationStatus)evaluateWithCurrentPath:(NSString *)currentPath parentPathRef:(SMJPathRef *)parent jsonObject:(id)jsonObject evaluationContext:(SMJEvaluationContextImpl *)context error:(NSError **)error
{
	id <SMJPathFunction> pathFunction = [SMJPathFunctionFactory pathFunctionForName:_functionName error:error];
	
	if (!pathFunction)
		return SMJEvaluationStatusError;
	
	[self evaluateParametersWithCurrentPathString:currentPath parentPathRef:parent jsonObject:jsonObject context:context];
	
	id result = [pathFunction invokeWithCurrentPathString:currentPath parentPath:parent jsonObject:jsonObject evaluationContext:context parameters:_functionParams error:error];
	
	if (!result)
		return SMJEvaluationStatusError;
	
	if ([context addResult:[NSString stringWithFormat:@"%@.%@", currentPath, _functionName] operation:parent jsonObject:result] == SMJEvaluationContextStatusAborted)
		return SMJEvaluationStatusAborted;
	
	if (self.leaf == NO)
		return [self.next evaluateWithCurrentPath:currentPath parentPathRef:parent jsonObject:result evaluationContext:context error:error];
	
	return SMJEvaluationStatusDone;
}

- (void)evaluateParametersWithCurrentPathString:(NSString *)currentPath parentPathRef:(SMJPathRef *)parent jsonObject:(id)jsonObject context:(SMJEvaluationContextImpl *)context
{
	if (!_functionParams)
		return;
	
	for (SMJParameter *param in _functionParams)
	{
		if (param.evaluated)
			continue;
		
		switch (param.type)
		{
			case SMJParamTypePath:
			{
				SMJParamLateBinding lateBinding = ^ id _Nullable (SMJParameter *parameter, NSError **lateError) {
					
					id <SMJPath> path = parameter.path;
					id <SMJEvaluationContext> evaluationContext = [path evaluateJsonObject:context.rootJsonObject rootJsonObject:context.rootJsonObject configuration:context.configuration error:lateError];
					
					if (!evaluationContext)
						return nil;
					
					return [evaluationContext jsonObjectWithError:lateError];
				};
				
				param.lateBinding = lateBinding;
				param.evaluated = YES;
				
				break;
			}
			
			case SMJParamTypeJSON:
			{
				SMJParamLateBinding lateBinding = ^ id _Nullable (SMJParameter *parameter, NSError **lateError) {
					NSString	*jsonString = parameter.jsonString;
					NSData		*jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
					
					if (!jsonData)
						return nil;
					
					return [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:lateError];
				};

				param.lateBinding = lateBinding;
				param.evaluated = YES;
				
				break;
			}
		}
	}
}


/**
 * Return the actual value by indicating true. If this return was false then we'd return the value in an array which
 * isn't what is desired - true indicates the raw value is returned.
 *
 */
- (BOOL)isTokenDefinite
{
	return YES;
}

- (NSString *)pathFragment
{
	return [@"." stringByAppendingString:_pathFragment];
}

@end


NS_ASSUME_NONNULL_END
