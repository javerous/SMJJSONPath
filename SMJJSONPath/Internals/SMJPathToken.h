/*
 * SMJPathToken.h
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/path/PathToken.java */


#import <Foundation/Foundation.h>

#import "SMJEvaluationContextImpl.h"


NS_ASSUME_NONNULL_BEGIN


/*
** Types
*/
#pragma mark - Types

typedef enum SMJEvaluationStatus
{
	SMJEvaluationStatusDone,
	SMJEvaluationStatusError,
	SMJEvaluationStatusAborted
} SMJEvaluationStatus;



/*
** SMJPathToken
*/
#pragma mark - SMJPathToken

@interface SMJPathToken : NSObject

- (SMJPathToken *)appendTailToken:(SMJPathToken *)token;

- (SMJEvaluationStatus)handleObjectPropertyWithCurrentPathString:(NSString *)currentPath jsonObject:(id)jsonObject evaluationContext:(SMJEvaluationContextImpl *)context properties:(NSArray <NSString *> *)properties error:(NSError **)error;

- (SMJEvaluationStatus)handleArrayIndex:(NSInteger)index currentPathString:(NSString *)currentPath jsonObject:(id)jsonObject evaluationContext:(SMJEvaluationContextImpl *)context error:(NSError **)error;


@property (nullable) SMJPathToken *next;

@property (readonly, getter=isLeaf) BOOL leaf;

@property (readonly, getter=isUpstreamDefinite) BOOL upstreamDefinite;

@property (readonly, getter=isPathDefinite) BOOL pathDefinite;

@property (readonly) NSInteger tokenCount;

- (NSString *)stringValue;

// Overwrite.
- (SMJEvaluationStatus)evaluateWithCurrentPath:(NSString *)currentPath parentPathRef:(SMJPathRef *)parent jsonObject:(id)jsonObject evaluationContext:(SMJEvaluationContextImpl *)context error:(NSError **)error;

@property (readonly, getter=isTokenDefinite) BOOL tokenDefinite;

@property (readonly) NSString *pathFragment;

@end


NS_ASSUME_NONNULL_END
