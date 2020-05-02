/*
 * SMJCommonTest.h
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


#import <XCTest/XCTest.h>

#import "SMJJSONPath.h"
#import "SMJConfiguration.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJCommonTest
*/
#pragma mark - SMJCommonTest

@interface SMJCommonTest : XCTestCase

// -- Helpers --
// > JSON.
- (nullable id)jsonObjectFromString:(NSString *)jsonString;
- (nullable id)jsonObjectFromString:(NSString *)jsonString options:(NSJSONReadingOptions)opt;

// > Query.
- (nullable id)checkResultForJSONString:(NSString *)jsonString jsonPathString:(NSString *)jsonPathString expectedResult:(id)expectedResult;
- (nullable id)checkResultForJSONString:(NSString *)jsonString jsonPathString:(NSString *)jsonPathString configuration:(nullable SMJConfiguration *)configuration expectedResult:(id)expectedResult;

- (nullable id)checkResultForJSONString:(NSString *)jsonString jsonPathString:(NSString *)jsonPathString expectedCount:(NSUInteger)exceptCount;
- (nullable id)checkResultForJSONString:(NSString *)jsonString jsonPathString:(NSString *)jsonPathString configuration:(nullable SMJConfiguration *)configuration expectedCount:(NSUInteger)expectedCount;

- (nullable id)checkResultForJSONString:(NSString *)jsonString jsonPathString:(NSString *)jsonPathString expectedError:(BOOL)expectedError;
- (nullable id)checkResultForJSONString:(NSString *)jsonString jsonPathString:(NSString *)jsonPathString configuration:(nullable SMJConfiguration *)configuration expectedError:(BOOL)expectedError;


- (nullable id)checkResultForJSONObject:(id)jsonObject jsonPathString:(NSString *)jsonPathString expectedResult:(id)expectedResult;
- (nullable id)checkResultForJSONObject:(id)jsonObject jsonPathString:(NSString *)jsonPathString configuration:(nullable SMJConfiguration *)configuration expectedResult:(id)expectedResult;

- (nullable id)checkResultForJSONObject:(id)jsonObject jsonPathString:(NSString *)jsonPathString expectedCount:(NSUInteger)exceptCount;
- (nullable id)checkResultForJSONObject:(id)jsonObject jsonPathString:(NSString *)jsonPathString configuration:(nullable SMJConfiguration *)configuration expectedCount:(NSUInteger)expectedCount;

- (nullable id)checkResultForJSONObject:(id)jsonObject jsonPathString:(NSString *)jsonPathString expectedError:(BOOL)expectedError;
- (nullable id)checkResultForJSONObject:(id)jsonObject jsonPathString:(NSString *)jsonPathString configuration:(nullable SMJConfiguration *)configuration expectedError:(BOOL)expectedError;

// > Updates.
- (nullable id)jsonWithJSONString:(NSString *)jsonString jsonPathString:(NSString *)jsonPathString updater:(id (^)(SMJJSONPath *jsonPath, id jsonObject, NSError **error))updater;
- (nullable id)jsonWithJSONString:(NSString *)jsonString jsonPathString:(NSString *)jsonPathString expectedError:(BOOL)expectedError updater:(id (^)(SMJJSONPath *jsonPath, id jsonObject, NSError **error))updater;

- (nullable id)jsonWithMutableJSONObject:(id)mutableJson jsonPathString:(NSString *)jsonPathString updater:(id (^)(SMJJSONPath *jsonPath, id jsonObject, NSError **error))updater;
- (nullable id)jsonWithMutableJSONObject:(id)mutableJson jsonPathString:(NSString *)jsonPathString expectedError:(BOOL)expectedError updater:(id (^)(SMJJSONPath *jsonPath, id jsonObject, NSError **error))updater;

@end

NS_ASSUME_NONNULL_END
