/*
 * SMJBaseTest.h
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/BaseTest.java */


#import <XCTest/XCTest.h>

#import "SMJCommonTest.h"
#import "SMJPredicate.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJBaseTest
*/
#pragma mark - SMJBaseTest

@interface SMJBaseTest : SMJCommonTest

- (NSString *)jsonBookDocument;
- (NSString *)jsonDocument;

- (NSString *)jsonArray;

- (id <SMJPredicateContext>)predicateContextForJsonObject:(id)jsonObject;

@end


NS_ASSUME_NONNULL_END
