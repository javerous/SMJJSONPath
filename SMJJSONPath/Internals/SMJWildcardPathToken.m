/*
 * SMJWildcardPathToken.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/path/WildcardPathToken.java */


#import "SMJWildcardPathToken.h"


/*
** SMJWildcardPathToken
*/
#pragma mark - SMJWildcardPathToken

@implementation SMJWildcardPathToken


/*
** SMJWildcardPathToken - SMJPathToken
*/
#pragma mark - SMJWildcardPathToken - SMJPathToken

- (SMJEvaluationStatus)evaluateWithCurrentPath:(NSString *)currentPath parentPathRef:(SMJPathRef *)parent jsonObject:(id)jsonObject evaluationContext:(SMJEvaluationContextImpl *)context error:(NSError **)error
{
	if ([jsonObject isKindOfClass:[NSDictionary class]])
	{
		NSDictionary	*dictionary = jsonObject;
		NSArray 		*keys = dictionary.allKeys;
		
		for (NSString *propery in keys)
		{
			SMJEvaluationStatus result = [self handleObjectPropertyWithCurrentPathString:currentPath jsonObject:jsonObject evaluationContext:context properties:@[ propery ] error:error];
			
			if (result == SMJEvaluationStatusError)
				return SMJEvaluationStatusError;
			else if (result == SMJEvaluationStatusAborted)
				return SMJEvaluationStatusAborted;
		}
	}
	else if ([jsonObject isKindOfClass:[NSArray class]])
	{
		NSArray *array = jsonObject;
		
		for (NSInteger idx = 0; idx < array.count; idx++)
		{
			SMJEvaluationStatus result = [self handleArrayIndex:idx currentPathString:currentPath jsonObject:jsonObject evaluationContext:context error:error];
			
			if (result == SMJEvaluationStatusError)
			{
				if ([context.configuration containsOption:SMJOptionRequireProperties])
					return SMJEvaluationStatusError;
			}
			else if (result == SMJEvaluationStatusAborted)
				return SMJEvaluationStatusAborted;
		}
	}
	
	return SMJEvaluationStatusDone;
}

- (BOOL)isTokenDefinite
{
	 return NO;
}

- (NSString *)pathFragment
{
	return @"[*]";
}

@end
