/*
 * SMJArrayIndexToken.h
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


#import <Foundation/Foundation.h>

#import "SMJArrayPathToken.h"
#import "SMJArrayIndexOperation.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJArrayIndexToken
*/
#pragma mark - SMJArrayIndexToken

@interface SMJArrayIndexToken : SMJArrayPathToken

- (instancetype)initWithIndexOperation:(SMJArrayIndexOperation *)indexOperation;

@end


NS_ASSUME_NONNULL_END
