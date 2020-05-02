/*
 * SMJParameter.h
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/function/Parameter.java */


#import <Foundation/Foundation.h>

#import "SMJPath.h"


NS_ASSUME_NONNULL_BEGIN


/*
** Forward
*/
#pragma mark Forward

@class SMJParameter;



/*
** Types
*/
#pragma mark - Types

typedef enum SMJParamType
{
	SMJParamTypeJSON,
	SMJParamTypePath
} SMJParamType;


typedef id _Nullable (^SMJParamLateBinding)(SMJParameter *parameter, NSError **error);



/*
** SMJParameter
*/
#pragma mark - SMJParameter

@interface SMJParameter : NSObject

// -- Instance --
- (instancetype)initWithJSON:(NSString *)json;
- (instancetype)initWithPath:(id <SMJPath>)path;

// -- Properties --
@property (nonatomic) BOOL evaluated;
@property (nonatomic) SMJParamLateBinding lateBinding;

@property (readonly) SMJParamType type;
@property (readonly) id <SMJPath> path;
@property (readonly) NSString *jsonString;

- (nullable id)valueWithError:(NSError **)error;

// -- Tools --
+ (nullable NSArray *)listWithParameters:(NSArray <SMJParameter *> *)parameters itemsClass:(Class)resultClass error:(NSError **)error;

@end


NS_ASSUME_NONNULL_END
