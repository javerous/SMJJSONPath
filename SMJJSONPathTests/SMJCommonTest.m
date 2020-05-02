/*
 * SMJCommonTest.m
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


#import "SMJCommonTest.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJCommonTest
*/
#pragma mark - SMJCommonTest

@implementation SMJCommonTest

/*
** SMJCommonTest - XCTestCase
*/
#pragma mark - SMJCommonTest - XCTestCase

- (void)setUp
{
    [super setUp];

	self.continueAfterFailure = NO;
}


/*
** SMJCommonTest - Helpers
*/
#pragma mark - SMJCommonTest - Helpers

- (nullable id)jsonObjectFromString:(NSString *)jsonString
{
	return [self jsonObjectFromString:jsonString options:0];
}

- (nullable id)jsonObjectFromString:(NSString *)jsonString options:(NSJSONReadingOptions)opt
{
	NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
	
	if (!data)
	{
		XCTFail(@"can't create data from JSON string");
		return nil;
	}
	
	NSError *error = nil;
	id 		obj = [NSJSONSerialization JSONObjectWithData:data options:(opt | NSJSONReadingAllowFragments) error:&error];
	
	if (!obj)
	{
		XCTFail(@"can't parse JSON string %@ / %@", error.localizedDescription, error.localizedRecoverySuggestion);
		return nil;
	}
	
	return obj;
}

- (nullable id)resultForJSONObject:(id)jsonObject jsonPathString:(NSString *)jsonPathString configuration:(nullable SMJConfiguration *)configuration error:(NSError **)error
{
	// Load JSON path.
	SMJJSONPath	*jsonPath = [[SMJJSONPath alloc] initWithJSONPathString:jsonPathString error:error];
	
	if (!jsonPath)
		return nil;
	
	// Create configuration.
	if (!configuration)
		configuration = [SMJConfiguration defaultConfiguration];
	
	// Load path result.
	return [jsonPath resultForJSONObject:jsonObject configuration:configuration error:error];
}



- (nullable id)checkResultForJSONString:(NSString *)jsonString jsonPathString:(NSString *)jsonPathString expectedResult:(id)expectedResult
{
	return [self checkResultForJSONObject:[self jsonObjectFromString:jsonString] jsonPathString:jsonPathString configuration:nil expectedResult:expectedResult];
}

- (nullable id)checkResultForJSONString:(NSString *)jsonString jsonPathString:(NSString *)jsonPathString configuration:(nullable SMJConfiguration *)configuration expectedResult:(id)expectedResult
{
	return [self checkResultForJSONObject:[self jsonObjectFromString:jsonString] jsonPathString:jsonPathString configuration:configuration expectedResult:expectedResult];
}

- (nullable id)checkResultForJSONString:(NSString *)jsonString jsonPathString:(NSString *)jsonPathString expectedCount:(NSUInteger)exceptCount
{
	return [self checkResultForJSONObject:[self jsonObjectFromString:jsonString] jsonPathString:jsonPathString configuration:nil expectedCount:exceptCount];
}

- (nullable id)checkResultForJSONString:(NSString *)jsonString jsonPathString:(NSString *)jsonPathString configuration:(nullable SMJConfiguration *)configuration expectedCount:(NSUInteger)expectedCount
{
	return [self checkResultForJSONObject:[self jsonObjectFromString:jsonString] jsonPathString:jsonPathString configuration:configuration expectedCount:expectedCount];
}

- (nullable id)checkResultForJSONString:(NSString *)jsonString jsonPathString:(NSString *)jsonPathString expectedError:(BOOL)expectedError
{
	return [self checkResultForJSONObject:[self jsonObjectFromString:jsonString] jsonPathString:jsonPathString configuration:nil expectedError:expectedError];
}

- (nullable id)checkResultForJSONString:(NSString *)jsonString jsonPathString:(NSString *)jsonPathString configuration:(nullable SMJConfiguration *)configuration expectedError:(BOOL)expectedError
{
	return [self checkResultForJSONObject:[self jsonObjectFromString:jsonString] jsonPathString:jsonPathString configuration:configuration expectedError:expectedError];
}



- (nullable id)checkResultForJSONObject:(id)jsonObject jsonPathString:(NSString *)jsonPathString expectedResult:(id)expectedResult
{
	return [self checkResultForJSONObject:jsonObject jsonPathString:jsonPathString configuration:nil expectedResult:expectedResult];
}

- (nullable id)checkResultForJSONObject:(id)jsonObject jsonPathString:(NSString *)jsonPathString configuration:(nullable SMJConfiguration *)configuration expectedResult:(id)expectedResult
{
	NSError	*error;
	id		result = [self resultForJSONObject:jsonObject jsonPathString:jsonPathString configuration:configuration error:&error];
	
	if (result != nil && error != nil)
		XCTFail(@"got a result with an error");
	else if (result == nil && error == nil)
		XCTFail(@"got a nil result with no error");
	
	if (error)
		NSLog(@"<%@>", error.localizedDescription);
	
	XCTAssertEqualObjects(result, expectedResult);
	
	return result;
}

- (nullable id)checkResultForJSONObject:(id)jsonObject jsonPathString:(NSString *)jsonPathString expectedCount:(NSUInteger)expectedCount
{
	return [self checkResultForJSONObject:jsonObject jsonPathString:jsonPathString configuration:nil expectedCount:expectedCount];
}

- (nullable id)checkResultForJSONObject:(id)jsonObject jsonPathString:(NSString *)jsonPathString configuration:(nullable SMJConfiguration *)configuration expectedCount:(NSUInteger)expectedCount
{
	NSError	*error;
	id 		result = [self resultForJSONObject:jsonObject jsonPathString:jsonPathString configuration:nil error:nil];
	
	if (result != nil && error != nil)
		XCTFail(@"got a result with an error: %@", error.localizedDescription);
	else if (result == nil && error == nil)
		XCTFail(@"got a nil result with no error");
	
	if ([result isKindOfClass:[NSArray class]])
		XCTAssertEqual([(NSArray *)result count], expectedCount);
	else if ([result isKindOfClass:[NSDictionary class]])
		XCTAssertEqual([(NSDictionary *)result count], expectedCount);
	else
		XCTFail(@"uncountable result type");
	
	return result;
}

- (nullable id)checkResultForJSONObject:(id)jsonObject jsonPathString:(NSString *)jsonPathString expectedError:(BOOL)expectedError
{
	return [self checkResultForJSONObject:jsonObject jsonPathString:jsonPathString configuration:nil expectedError:expectedError];
}

- (nullable id)checkResultForJSONObject:(id)jsonObject jsonPathString:(NSString *)jsonPathString configuration:(nullable SMJConfiguration *)configuration expectedError:(BOOL)expectedError
{
	NSError	*error = nil;
	id		result = [self resultForJSONObject:jsonObject jsonPathString:jsonPathString configuration:configuration error:&error];
	
	if (result != nil && error != nil)
		XCTFail(@"got a result with an error");
	else if (result == nil && error == nil)
		XCTFail(@"got a nil result with no error");

	if (expectedError && result)
		XCTFail(@"got a result while an error was expected");
	else if (!expectedError && !result)
		XCTFail(@"got an error while a result was expected: %@", error.localizedDescription);
	
	return result;
}



- (nullable id)jsonWithJSONString:(NSString *)jsonString jsonPathString:(NSString *)jsonPathString updater:(id (^)(SMJJSONPath *jsonPath, id jsonObject, NSError **error))updater
{
	return [self jsonWithJSONString:jsonString jsonPathString:jsonPathString expectedError:NO updater:updater];
}

- (nullable id)jsonWithMutableJSONObject:(id)mutableJson jsonPathString:(NSString *)jsonPathString updater:(id (^)(SMJJSONPath *jsonPath, id jsonObject, NSError **error))updater
{
	return [self jsonWithMutableJSONObject:mutableJson jsonPathString:jsonPathString expectedError:NO updater:updater];

}

- (nullable id)jsonWithJSONString:(NSString *)jsonString jsonPathString:(NSString *)jsonPathString expectedError:(BOOL)expectedError updater:(id (^)(SMJJSONPath *jsonPath, id jsonObject, NSError **error))updater
{
	// Parse JSON.
	id mutableJson = [self jsonObjectFromString:jsonString options:NSJSONReadingMutableContainers];
	
	if (!mutableJson)
		return nil;
	
	return [self jsonWithMutableJSONObject:mutableJson jsonPathString:jsonPathString expectedError:expectedError updater:updater];
}

- (nullable id)jsonWithMutableJSONObject:(id)mutableJson jsonPathString:(NSString *)jsonPathString expectedError:(BOOL)expectedError updater:(id (^)(SMJJSONPath *jsonPath, id jsonObject, NSError **error))updater
{
	NSError	*error = nil;

	// Create JSONPath.
	SMJJSONPath *jsonPath = [[SMJJSONPath alloc] initWithJSONPathString:jsonPathString error:&error];
	
	if (!jsonPath)
	{
		XCTFail(@"can't compile jsonpath : %@", error.localizedDescription);
		return nil;
	}
	
	// Update JSON.
	mutableJson = updater(jsonPath, mutableJson, &error);
	
	if (mutableJson != nil && error != nil)
		XCTFail(@"got an update with an error: %@", error.localizedDescription);
	else if (mutableJson == nil && error == nil)
		XCTFail(@"got a nil update with a nil error");
	
	if (expectedError && mutableJson)
		XCTFail(@"got an update while an error was expected");
	else if (!expectedError && !mutableJson)
		XCTFail(@"got an error while an update was expected: %@", error.localizedDescription);
	
	return mutableJson;
}

@end


NS_ASSUME_NONNULL_END
