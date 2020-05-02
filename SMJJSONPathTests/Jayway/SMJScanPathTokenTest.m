/*
 * SMJScanPathTokenTest.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/old/internal/ScanPathTokenTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseTest.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJScanPathTokenTest
*/
#pragma mark - SMJScanPathTokenTest

@interface SMJScanPathTokenTest : SMJBaseTest
{
	NSString *_jsonDocument;
	NSString *_jsonDocument2;
}
@end

@implementation SMJScanPathTokenTest

- (void)setUp
{
    [super setUp];
	
	_jsonDocument = @"{\n"
	@" \"store\":{\n"
	@"  \"book\":[\n"
	@"   {\n"
	@"    \"category\":\"reference\",\n"
	@"    \"author\":\"Nigel Rees\",\n"
	@"    \"title\":\"Sayings of the Century\",\n"
	@"    \"price\":8.95,\n"
	@"    \"address\":{ "
	@"        \"street\":\"fleet street\",\n"
	@"        \"city\":\"London\"\n"
	@"      }\n"
	@"   },\n"
	@"   {\n"
	@"    \"category\":\"fiction\",\n"
	@"    \"author\":\"Evelyn Waugh\",\n"
	@"    \"title\":\"Sword of Honour\",\n"
	@"    \"price\":12.9,\n"
	@"    \"address\":{ \n"
	@"        \"street\":\"Baker street\",\n"
	@"        \"city\":\"London\"\n"
	@"      }\n"
	@"   },\n"
	@"   {\n"
	@"    \"category\":\"fiction\",\n"
	@"    \"author\":\"J. R. R. Tolkien\",\n"
	@"    \"title\":\"The Lord of the Rings\",\n"
	@"    \"isbn\":\"0-395-19395-8\",\n"
	@"    \"price\":22.99,"
	@"    \"address\":{ "
	@"        \"street\":\"Svea gatan\",\n"
	@"        \"city\":\"Stockholm\"\n"
	@"      }\n"
	@"   }\n"
	@"  ],\n"
	@"  \"bicycle\":{\n"
	@"   \"color\":\"red\",\n"
	@"   \"price\":19.95,"
	@"   \"address\":{ "
	@"        \"street\":\"Söder gatan\",\n"
	@"        \"city\":\"Stockholm\"\n"
	@"      },\n"
	@"   \"items\": [[\"A\",\"B\",\"C\"],1,2,3,4,5]\n"
	@"  }\n"
	@" }\n"
	@"}";
	
	_jsonDocument2 = @"{\n"
	@"     \"firstName\": \"John\",\n"
	@"     \"lastName\" : \"doe\",\n"
	@"     \"age\"      : 26,\n"
	@"     \"address\"  :\n"
	@"     {\n"
	@"         \"streetAddress\": \"naist street\",\n"
	@"         \"city\"         : \"Nara\",\n"
	@"         \"postalCode\"   : \"630-0192\"\n"
	@"     },\n"
	@"     \"phoneNumbers\":\n"
	@"     [\n"
	@"         {\n"
	@"           \"type\"  : \"iPhone\",\n"
	@"           \"number\": \"0123-4567-8888\"\n"
	@"         },\n"
	@"         {\n"
	@"           \"type\"  : \"home\",\n"
	@"           \"number\": \"0123-4567-8910\"\n"
	@"         }\n"
	@"     ]\n"
	@" }";
}


- (void)test_a_document_can_be_scanned_for_property
{
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$..author" expectedResult:@[ @"Nigel Rees", @"Evelyn Waugh", @"J. R. R. Tolkien" ]];
}

- (void)test_a_document_can_be_scanned_for_property_path
{
	[self checkResultForJSONString:_jsonDocument jsonPathString:@"$..address.street" expectedResult:@[ @"fleet street", @"Baker street", @"Svea gatan", @"Söder gatan" ]];
}

- (void)test_a_document_can_be_scanned_for_wildcard
{
	SMJConfiguration *configuration = [[SMJConfiguration alloc] init];
	
	[configuration addOption:SMJOptionAsPathList];
	
	NSArray	*result = [self checkResultForJSONString:_jsonDocument jsonPathString:@"$..[*]" configuration:configuration expectedError:NO];
	NSSet	*resultSet = [NSSet setWithArray:result];
	
	NSSet *expectedResultSet = [NSSet setWithArray:@[
		@"$['store']",
		@"$['store']['bicycle']",
		@"$['store']['book']",
		@"$['store']['bicycle']['address']",
		@"$['store']['bicycle']['color']",
		@"$['store']['bicycle']['price']",
		@"$['store']['bicycle']['items']",
		@"$['store']['bicycle']['address']['city']",
		@"$['store']['bicycle']['address']['street']",
		@"$['store']['bicycle']['items'][0]",
		@"$['store']['bicycle']['items'][1]",
		@"$['store']['bicycle']['items'][2]",
		@"$['store']['bicycle']['items'][3]",
		@"$['store']['bicycle']['items'][4]",
		@"$['store']['bicycle']['items'][5]",
		@"$['store']['bicycle']['items'][0][0]",
		@"$['store']['bicycle']['items'][0][1]",
		@"$['store']['bicycle']['items'][0][2]",
		@"$['store']['book'][0]",
		@"$['store']['book'][1]",
		@"$['store']['book'][2]",
		@"$['store']['book'][0]['address']",
		@"$['store']['book'][0]['author']",
		@"$['store']['book'][0]['price']",
		@"$['store']['book'][0]['category']",
		@"$['store']['book'][0]['title']",
		@"$['store']['book'][0]['address']['city']",
		@"$['store']['book'][0]['address']['street']",
		@"$['store']['book'][1]['address']",
		@"$['store']['book'][1]['author']",
		@"$['store']['book'][1]['price']",
		@"$['store']['book'][1]['category']",
		@"$['store']['book'][1]['title']",
		@"$['store']['book'][1]['address']['city']",
		@"$['store']['book'][1]['address']['street']",
		@"$['store']['book'][2]['address']",
		@"$['store']['book'][2]['author']",
		@"$['store']['book'][2]['price']",
		@"$['store']['book'][2]['isbn']",
		@"$['store']['book'][2]['category']",
		@"$['store']['book'][2]['title']",
		@"$['store']['book'][2]['address']['city']",
		@"$['store']['book'][2]['address']['street']"
	]];
	
	XCTAssertEqualObjects(resultSet, expectedResultSet);
}

- (void)test_a_document_can_be_scanned_for_wildcard2
{
	SMJConfiguration *configuration = [[SMJConfiguration alloc] init];
	
	[configuration addOption:SMJOptionAsPathList];
	
	NSArray	*result = [self checkResultForJSONString:_jsonDocument jsonPathString:@"$.store.book[0]..*" configuration:configuration expectedError:NO];
	NSSet	*resultSet = [NSSet setWithArray:result];
	
	NSSet *expectedResultSet = [NSSet setWithArray:@[
		@"$['store']['book'][0]['address']",
		@"$['store']['book'][0]['author']",
		@"$['store']['book'][0]['price']",
		@"$['store']['book'][0]['category']",
		@"$['store']['book'][0]['title']",
		@"$['store']['book'][0]['address']['city']",
		@"$['store']['book'][0]['address']['street']"
	 ]];
	
	XCTAssertEqualObjects(resultSet, expectedResultSet);
}

- (void)test_a_document_can_be_scanned_for_wildcard3
{
	SMJConfiguration *configuration = [[SMJConfiguration alloc] init];
	
	[configuration addOption:SMJOptionAsPathList];
	
	NSArray	*result = [self checkResultForJSONString:_jsonDocument2 jsonPathString:@"$.phoneNumbers[0]..*" configuration:configuration expectedError:NO];
	NSSet	*resultSet = [NSSet setWithArray:result];
	
	NSSet *expectedResultSet = [NSSet setWithArray:@[
		@"$['phoneNumbers'][0]['number']",
		@"$['phoneNumbers'][0]['type']"
	 ]];
	
	XCTAssertEqualObjects(resultSet, expectedResultSet);
}

- (void)test_a_document_can_be_scanned_for_predicate_match
{
	SMJConfiguration *configuration = [[SMJConfiguration alloc] init];
	
	[configuration addOption:SMJOptionAsPathList];
	
	NSArray	*result = [self checkResultForJSONString:_jsonDocument jsonPathString:@"$..[?(@.address.city == 'Stockholm')]" configuration:configuration expectedError:NO];
	NSSet	*resultSet = [NSSet setWithArray:result];
	
	NSSet *expectedResultSet = [NSSet setWithArray:@[
		@"$['store']['bicycle']",
		@"$['store']['book'][2]"
	 ]];
	
	XCTAssertEqualObjects(resultSet, expectedResultSet);
}

- (void)test_a_document_can_be_scanned_for_existence
{
	SMJConfiguration *configuration = [[SMJConfiguration alloc] init];
	
	[configuration addOption:SMJOptionAsPathList];
	
	NSArray	*result = [self checkResultForJSONString:_jsonDocument jsonPathString:@"$..[?(@.isbn)]" configuration:configuration expectedError:NO];
	NSSet	*resultSet = [NSSet setWithArray:result];
	
	NSSet *expectedResultSet = [NSSet setWithArray:@[
		@"$['store']['book'][2]"
	 ]];
	
	XCTAssertEqualObjects(resultSet, expectedResultSet);
}

@end


NS_ASSUME_NONNULL_END
