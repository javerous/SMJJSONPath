/*
 * SMJJsonPathTest.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/old/JsonPathTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseTest.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJJsonPathTest
*/
#pragma mark - SMJJsonPathTest

@interface SMJJsonPathTest : SMJBaseTest
{
	NSString *_jsonArray;
	NSString *_jsonDocument;
	NSString *_jsonProduct;
	NSString *_jsonArrayExpand;
}
@end

@implementation SMJJsonPathTest

- (void)setUp
{
    [super setUp];
	
	_jsonArray = @"[{\"value\": 1},{\"value\": 2}, {\"value\": 3},{\"value\": 4}]";
	
	_jsonDocument = @"{ \"store\": {\n"
	@"    \"book\": [ \n"
	@"      { \"category\": \"reference\",\n"
	@"        \"author\": \"Nigel Rees\",\n"
	@"        \"title\": \"Sayings of the Century\",\n"
	@"        \"display-price\": 8.95\n"
	@"      },\n"
	@"      { \"category\": \"fiction\",\n"
	@"        \"author\": \"Evelyn Waugh\",\n"
	@"        \"title\": \"Sword of Honour\",\n"
	@"        \"display-price\": 12.99\n"
	@"      },\n"
	@"      { \"category\": \"fiction\",\n"
	@"        \"author\": \"Herman Melville\",\n"
	@"        \"title\": \"Moby Dick\",\n"
	@"        \"isbn\": \"0-553-21311-3\",\n"
	@"        \"display-price\": 8.99\n"
	@"      },\n"
	@"      { \"category\": \"fiction\",\n"
	@"        \"author\": \"J. R. R. Tolkien\",\n"
	@"        \"title\": \"The Lord of the Rings\",\n"
	@"        \"isbn\": \"0-395-19395-8\",\n"
	@"        \"display-price\": 22.99\n"
	@"      }\n"
	@"    ],\n"
	@"    \"bicycle\": {\n"
	@"      \"color\": \"red\",\n"
	@"      \"display-price\": 19.95,\n"
	@"      \"foo:bar\": \"fooBar\",\n"
	@"      \"dot.notation\": \"new\",\n"
	@"      \"dash-notation\": \"dashes\"\n"
	@"    }\n"
	@"  }\n"
	@"}";
	
	_jsonProduct = @"{\n"
	@"\t\"product\": [ {\n"
	@"\t    \"version\": \"A\", \n"
	@"\t    \"codename\": \"Seattle\", \n"
	@"\t    \"attr.with.dot\": \"A\"\n"
	@"\t},\n"
	@"\t{\n"
	@"\t    \"version\": \"4.0\", \n"
	@"\t    \"codename\": \"Montreal\", \n"
	@"\t    \"attr.with.dot\": \"B\"\n"
	@"\t}]\n"
	@"}";
	
	_jsonArrayExpand = @"[{\"parent\": \"ONE\", \"child\": {\"name\": \"NAME_ONE\"}}, [{\"parent\": \"TWO\", \"child\": {\"name\": \"NAME_TWO\"}}]]";
}

- (void)test_missing_prop
{
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$.store.book[*].fooBar.not" configuration:[SMJConfiguration configurationWithOption:SMJOptionRequireProperties] expectedError:YES];
}

- (void)test_bracket_notation_with_dots
{
	NSString *json = @"{\n"
	@"    \"store\": {\n"
	@"        \"book\": [\n"
	@"            {\n"
	@"                \"author.name\": \"Nigel Rees\", \n"
	@"                \"category\": \"reference\", \n"
	@"                \"price\": 8.95, \n"
	@"                \"title\": \"Sayings of the Century\"\n"
	@"            }\n"
	@"        ]\n"
	@"    }\n"
	@"}";
	
	[self checkResultForJSONString:json jsonPathString:@"$.store.book[0]['author.name']" expectedResult:@"Nigel Rees"];
}

- (void)test_null_object_in_path
{
	NSString *json = @"{\n"
	@"  \"success\": true,\n"
	@"  \"data\": {\n"
	@"    \"user\": 3,\n"
	@"    \"own\": null,\n"
	@"    \"passes\": null,\n"
	@"    \"completed\": null\n"
	@"  },\n"
	@"  \"data2\": {\n"
	@"    \"user\": 3,\n"
	@"    \"own\": null,\n"
	@"    \"passes\": [{\"id\":\"1\"}],\n"
	@"    \"completed\": null\n"
	@"  },\n"
	@"  \"version\": 1371160528774\n"
	@"}";
	
	[self checkResultForJSONString:json jsonPathString:@"$.data.passes[0].id" expectedError:YES];

	[self checkResultForJSONString:json jsonPathString:@"$.data2.passes[0].id" expectedResult:@"1"];
}

- (void)test_array_start_expands
{
	[self checkResultForJSONString:_jsonArrayExpand jsonPathString:@"$[?(@['parent'] == 'ONE')].child.name" expectedResult:@[ @"NAME_ONE" ]];
}

- (void)test_bracket_notation_can_be_used_in_path
{
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$.['store'].bicycle.['dot.notation']" expectedResult:@"new"];
	
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$['store']['bicycle']['dot.notation']" expectedResult:@"new"];
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$.['store']['bicycle']['dot.notation']" expectedResult:@"new"];
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$.['store'].['bicycle'].['dot.notation']" expectedResult:@"new"];
	
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$.['store'].bicycle.['dash-notation']" expectedResult:@"dashes"];
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$['store']['bicycle']['dash-notation']" expectedResult:@"dashes"];
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$.['store']['bicycle']['dash-notation']" expectedResult:@"dashes"];
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$.['store'].['bicycle'].['dash-notation']" expectedResult:@"dashes"];
}

- (void)test_filter_an_array
{
	[self checkResultForJSONString:_jsonArray jsonPathString:@"$.[?(@.value == 1)]" expectedCount:1];
}

- (void)test_filter_an_array_on_index
{
	[self checkResultForJSONString:_jsonArray jsonPathString:@"$.[1].value" expectedResult:@2];
}

- (void)test_read_path_with_colon
{
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$['store']['bicycle']['foo:bar']" expectedResult:@"fooBar"];
}

- (void)test_read_document_from_root
{
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$.store" expectedCount:2];
}

- (void)test_read_store_book_1
{
	NSDictionary *result = [self checkResultForJSONString:_jsonDocument jsonPathString:@"$.store.book[1]" expectedError:NO];
	
	XCTAssertEqualObjects(result[@"author"], @"Evelyn Waugh");
}

- (void)test_read_store_book_wildcard
{
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$.store.book[*]" expectedCount:4];
}

- (void)test_read_store_book_author
{
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$.store.book[0,1].author" expectedResult:@[ @"Nigel Rees", @"Evelyn Waugh" ]];
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$.store.book[*].author" expectedResult:@[ @"Nigel Rees", @"Evelyn Waugh", @"Herman Melville", @"J. R. R. Tolkien" ]];
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$.['store'].['book'][*].['author']" expectedResult:@[ @"Nigel Rees", @"Evelyn Waugh", @"Herman Melville", @"J. R. R. Tolkien" ]];
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$['store']['book'][*]['author']" expectedResult:@[ @"Nigel Rees", @"Evelyn Waugh", @"Herman Melville", @"J. R. R. Tolkien" ]];
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$['store'].book[*]['author']" expectedResult:@[ @"Nigel Rees", @"Evelyn Waugh", @"Herman Melville", @"J. R. R. Tolkien" ]];
}

- (void)test_all_authors
{
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$..author" expectedResult:@[ @"Nigel Rees", @"Evelyn Waugh", @"Herman Melville", @"J. R. R. Tolkien" ]];
}

- (void)test_all_store_properties
{
	NSArray *result = [self checkResultForJSONString:_jsonDocument jsonPathString:@"$.store.*" configuration:[SMJConfiguration configurationWithOption:SMJOptionAsPathList] expectedError:NO];
	NSSet	*resultSet = [NSSet setWithArray:result];
	NSSet	*expectedSet = [NSSet setWithArray:@[ @"$['store']['bicycle']", @"$['store']['book']" ]];
	
	XCTAssertEqualObjects(resultSet, expectedSet);
}

- (void)test_all_prices_in_store
{
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$.store..['display-price']" expectedResult:@[ @8.95, @12.99, @8.99, @22.99, @19.95 ]];
}

- (void)test_access_array_by_index_from_tail
{
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$..book[1:].author" expectedResult:@[ @"Evelyn Waugh", @"Herman Melville", @"J. R. R. Tolkien" ]];
}

- (void)test_read_store_book_index_0_and_1
{
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$.store.book[0,1].author" expectedResult:@[ @"Nigel Rees", @"Evelyn Waugh" ]];
}

- (void)test_read_store_book_pull_first_2
{
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$.store.book[:2].author" expectedResult:@[ @"Nigel Rees", @"Evelyn Waugh" ]];
}

- (void)test_read_store_book_filter_by_isbn
{
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$.store.book[?(@.isbn)].isbn" expectedResult:@[ @"0-553-21311-3", @"0-395-19395-8" ]];
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$.store.book[?(@['isbn'])].isbn" expectedCount:2];
}

- (void)test_all_books_cheaper_than_10
{
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$..book[?(@['display-price'] < 10)].title" expectedResult:@[ @"Sayings of the Century", @"Moby Dick" ]];
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$..book[?(@.display-price < 10)].title" expectedResult:@[ @"Sayings of the Century", @"Moby Dick" ]];
}

- (void)test_all_books
{
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$..book" expectedCount:1];
}

- (void)test_dot_in_predicate_works
{
	[self checkResultForJSONString:_jsonProduct jsonPathString:@"$.product[?(@.version=='4.0')].codename" expectedResult:@[ @"Montreal" ]];
}

- (void)test_dots_in_predicate_works
{
	[self checkResultForJSONString:_jsonProduct jsonPathString:@"$.product[?(@.['attr.with.dot']=='A')].codename" expectedResult:@[ @"Seattle" ]];
}

- (void)test_all_books_with_category_reference
{
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$..book[?(@.category=='reference')].title" expectedResult:@[ @"Sayings of the Century" ]];
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$.store.book[?(@.category=='reference')].title" expectedResult:@[ @"Sayings of the Century" ]];
}

- (void)test_all_members_of_all_documents
{
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$..*" expectedError:NO];
}

- (void)test_access_index_out_of_bounds_does_not_throw_exception
{
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$.store.book[100].author" expectedError:YES];
}

- (void)test_exists_filter_with_nested_path
{
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$..[?(@.bicycle.color)]" expectedCount:1];
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$..[?(@.bicycle.numberOfGears)]" expectedCount:0];
}

- (void)test_prevent_stack_overflow_error_when_unclosed_property
{
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$['boo','foo][?(@ =~ /bar/)]" expectedError:YES];

}

@end


NS_ASSUME_NONNULL_END
