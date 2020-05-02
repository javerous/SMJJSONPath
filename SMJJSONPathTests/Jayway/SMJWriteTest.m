/*
 * SMJWriteTest.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/WriteTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseTest.h"

#import "SMJJSONPath.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJWriteTest
*/
#pragma mark - SMJWriteTest

@interface SMJWriteTest : SMJBaseTest
@end

@implementation SMJWriteTest


- (void)test_an_array_child_property_can_be_updated
{
	id json = [self jsonWithJSONString:[self jsonDocument] jsonPathString:@"$.store.book[*].display-price" updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject setObject:@1 configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	[self checkResultForJSONObject:json jsonPathString:@"$.store.book[*].display-price" expectedResult:@[ @1, @1, @1, @1 ]];
}

- (void)test_an_root_property_can_be_updated
{
	id json = [self jsonWithJSONString:[self jsonDocument] jsonPathString:@"$.int-max-property" updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject setObject:@1 configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	[self checkResultForJSONObject:json jsonPathString:@"$.int-max-property" expectedResult:@1];
}

- (void)test_an_deep_scan_can_update
{
	id json = [self jsonWithJSONString:[self jsonDocument] jsonPathString:@"$..display-price" updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject setObject:@1 configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	[self checkResultForJSONObject:json jsonPathString:@"$..display-price" expectedResult:@[ @1, @1, @1, @1, @1 ]];
}

- (void)test_an_filter_can_update
{
	id json = [self jsonWithJSONString:[self jsonDocument] jsonPathString:@"$.store.book[?(@.display-price)].display-price" updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject setObject:@1 configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	[self checkResultForJSONObject:json jsonPathString:@"$.store.book[?(@.display-price)].display-price" expectedResult:@[ @1, @1, @1, @1 ]];
}

- (void)test_a_path_can_be_deleted
{
	id json = [self jsonWithJSONString:[self jsonDocument] jsonPathString:@"$.store.book[*].display-price" updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject deleteWithConfiguration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	[self checkResultForJSONObject:json jsonPathString:@"$.store.book[*].display-price" expectedResult:@[ ]];
}

- (void)test_an_array_can_be_updated
{
	id json = [self jsonWithJSONString:@"[0,1,2,3]" jsonPathString:@"$[?(@ == 1)]" updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject setObject:@9 configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	NSArray *expectedResult = @[ @0, @9, @2, @3 ];
	
	XCTAssertEqualObjects(json, expectedResult);
}

- (void)test_an_array_index_can_be_updated
{
	id json = [self jsonWithJSONString:[self jsonDocument] jsonPathString:@"$.store.book[0]" updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject setObject:@"a" configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	[self checkResultForJSONObject:json jsonPathString:@"$.store.book[0]" expectedResult:@"a"];
}

- (void)test_an_array_slice_can_be_updated
{
	id json = [self jsonWithJSONString:[self jsonDocument] jsonPathString:@"$.store.book[0:2]" updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject setObject:@"a" configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	[self checkResultForJSONObject:json jsonPathString:@"$.store.book[0:2]" expectedResult:@[ @"a", @"a" ]];
}

- (void)test_an_array_criteria_can_be_updated
{
	id json = [self jsonWithJSONString:[self jsonDocument] jsonPathString:@"$.store.book[?(@.category == 'fiction')]" updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject setObject:@"a" configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	[self checkResultForJSONObject:json jsonPathString:@"$.store.book[?(@ == 'a')]" expectedResult:@[ @"a", @"a", @"a" ]];
}

- (void)test_an_array_criteria_can_be_deleted
{
	id json = [self jsonWithJSONString:[self jsonDocument] jsonPathString:@"$.store.book[?(@.category == 'fiction')]" updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject deleteWithConfiguration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	[self checkResultForJSONObject:json jsonPathString:@"$.store.book[*].category" expectedResult:@[ @"reference" ]];
}

- (void)test_an_array_criteria_with_multiple_results_can_be_deleted
{
	NSString	*path = [[NSBundle bundleForClass:self.class] pathForResource:@"json_array_multiple_delete" ofType:@"json"];
	NSString	*jsonString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	
	id json = [self jsonWithJSONString:jsonString jsonPathString:@"$._embedded.mandates[?(@.count=~/0/)]" updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject deleteWithConfiguration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	[self checkResultForJSONObject:json jsonPathString:@"$._embedded.mandates[?(@.count=~/0/)]" expectedResult:@[ ]];
}

- (void)test_multi_prop_delete
{
	id json = [self jsonWithJSONString:[self jsonDocument] jsonPathString:@"$.store.book[*]['author', 'category']" updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject deleteWithConfiguration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	[self checkResultForJSONObject:json jsonPathString:@"$.store.book[*]['author', 'category']" expectedResult:@[ @{ }, @{ }, @{ }, @{ } ]];
}

- (void)test_multi_prop_update_not_all_defined
{
	NSDictionary *expected = @{
	   @"author" : @"a",
	   @"isbn" : @"a"
   };
	
	id json = [self jsonWithJSONString:[self jsonDocument] jsonPathString:@"$.store.book[*]['author', 'isbn']" updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject setObject:@"a" configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	[self checkResultForJSONObject:json jsonPathString:@"$.store.book[*]['author', 'isbn']" expectedResult:@[ expected, expected, expected, expected ]];
}

- (void)test_add_to_array
{
	id json = [self jsonWithJSONString:[self jsonDocument] jsonPathString:@"$.store.book" updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject addObject:@1 configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	[self checkResultForJSONObject:json jsonPathString:@"$.store.book[4]" expectedResult:@1];
}

- (void)test_add_to_object
{
	id json = [self jsonWithJSONString:[self jsonDocument] jsonPathString:@"$.store.book[0]" updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject putObject:@"new-value" key:@"new-key" configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	[self checkResultForJSONObject:json jsonPathString:@"$.store.book[0].new-key" expectedResult:@"new-value"];
}

- (void)test_item_can_be_added_to_root_array
{
	NSString *jsonString = @"[ 1, 2 ]";
	
	id json = [self jsonWithJSONString:jsonString jsonPathString:@"$" updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject addObject:@3 configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	[self checkResultForJSONObject:json jsonPathString:@"$" expectedResult:@[ @1, @2, @3 ]];
}

- (void)test_key_val_can_be_added_to_root_object
{
	NSString *jsonString = @"{ \"a\" : \"a-val\" }";
	
	id json = [self jsonWithJSONString:jsonString jsonPathString:@"$" updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject putObject:@"new-val" key:@"new-key" configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	[self checkResultForJSONObject:json jsonPathString:@"$.new-key" expectedResult:@"new-val"];
}

- (void)test_add_to_object_on_array
{
	[self jsonWithJSONString:[self jsonDocument] jsonPathString:@"$.store.book" expectedError:YES updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject putObject:@"new-value" key:@"new-key" configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
}

- (void)test_add_to_array_on_object
{
	[self jsonWithJSONString:[self jsonDocument] jsonPathString:@"$.store.book[0]" expectedError:YES updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject addObject:@"new-value" configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
}

- (void)test_root_object_can_not_be_updated
{
	NSString *jsonString = @"{ \"a\" : \"a-val\" }";
	
	[self jsonWithJSONString:jsonString jsonPathString:@"$[?(@.a == 'a-val')]" expectedError:YES updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject setObject:@1 configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
}

- (void)test_a_path_can_be_renamed
{
	id json = [self jsonWithJSONString:[self jsonDocument] jsonPathString:@"$.store" updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject renameKey:@"book" toKey:@"updated-book" configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	id result = [self checkResultForJSONObject:json jsonPathString:@"$.store.updated-book" expectedError:NO];

	XCTAssertTrue([(NSArray *)result count] > 0);
}

- (void)test_keys_in_root_containing_map_can_be_renamed
{
	id json = [self jsonWithJSONString:[self jsonDocument] jsonPathString:@"$" updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject renameKey:@"store" toKey:@"new-store" configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	id result = [self checkResultForJSONObject:json jsonPathString:@"$.new-store[*]" expectedError:NO];
	
	XCTAssertTrue([(NSArray *)result count] > 0);
}

- (void)test_map_array_items_can_be_renamed
{
	id json = [self jsonWithJSONString:[self jsonDocument] jsonPathString:@"$.store.book[*]" updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject renameKey:@"category" toKey:@"renamed-category" configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	id result = [self checkResultForJSONObject:json jsonPathString:@"$.store.book[*].renamed-category" expectedError:NO];
	
	XCTAssertTrue([(NSArray *)result count] > 0);
}

- (void)test_non_map_array_items_cannot_be_renamed
{
	NSString *jsonString = @"[ 1, 2 ]";
	
	[self jsonWithJSONString:jsonString jsonPathString:@"$[*]" expectedError:YES updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject renameKey:@"oldKey" toKey:@"newKey" configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
}

- (void)test_multiple_properties_cannot_be_renamed
{
	[self jsonWithJSONString:[self jsonDocument] jsonPathString:@"$.store.book[*]['author', 'category']" expectedError:YES updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject renameKey:@"old-key" toKey:@"new-key" configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
}

- (void)test_non_existent_key_rename_not_allowed
{
	[self jsonWithJSONString:[self jsonDocument] jsonPathString:@"$" expectedError:YES updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject renameKey:@"fake" toKey:@"new-fake" configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
}

- (void)test_rootCannotBeMapped
{
	[self jsonWithJSONString:[self jsonDocument] jsonPathString:@"$" expectedError:YES updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		
		SMJJSONPathMapper mapper = ^id (id object, SMJConfiguration *configuration) {
			return [NSString stringWithFormat:@"%@converted", object];
		};
		
		return [jsonPath updateMutableJSONObject:jsonObject mapObjects:mapper configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
}

- (void)test_single_match_value_can_be_mapped
{
	id json = [self jsonWithJSONString:[self jsonDocument] jsonPathString:@"$.string-property" updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		
		SMJJSONPathMapper mapper = ^id (id object, SMJConfiguration *configuration) {
			return [NSString stringWithFormat:@"%@converted", object];
		};
		
		return [jsonPath updateMutableJSONObject:jsonObject mapObjects:mapper configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	id result = [self checkResultForJSONObject:json jsonPathString:@"$.string-property" expectedError:NO];
	
	XCTAssertTrue([(NSString *)result hasSuffix:@"converted"]);
}

- (void)test_object_can_be_mapped
{
	id json = [self jsonWithJSONString:[self jsonDocument] jsonPathString:@"$..book" updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		
		SMJJSONPathMapper mapper = ^id (id object, SMJConfiguration *configuration) {
			return [NSString stringWithFormat:@"%@converted", object];
		};
		
		return [jsonPath updateMutableJSONObject:jsonObject mapObjects:mapper configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	NSArray *result = [self checkResultForJSONObject:json jsonPathString:@"$..book" expectedError:NO];
	
	XCTAssertTrue([(NSString *)(result[0]) hasSuffix:@"converted"]);
}

- (void)test_multi_match_path_can_be_mapped
{
	id json = [self jsonWithJSONString:[self jsonDocument] jsonPathString:@"$..display-price" updater:^ id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		
		SMJJSONPathMapper mapper = ^id (id object, SMJConfiguration *configuration) {
			return [NSString stringWithFormat:@"%@converted", object];
		};
		
		return [jsonPath updateMutableJSONObject:jsonObject mapObjects:mapper configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	NSArray *result = [self checkResultForJSONObject:json jsonPathString:@"$..display-price" expectedError:NO];

	for (NSString *str in result)
		XCTAssertTrue([str hasSuffix:@"converted"]);
}

@end


NS_ASSUME_NONNULL_END
