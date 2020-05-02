/*
 * SMJIssuesTest.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/old/IssuesTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseTest.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJIssuesTest
*/
#pragma mark - SMJIssuesTest

@interface SMJIssuesTest : SMJBaseTest
@end

@implementation SMJIssuesTest

- (void)setUp
{
    [super setUp];

}

- (void)test_issue_143
{
	NSString *json = @"{ \"foo\": { \"bar\" : \"val\" }, \"moo\": { \"cow\" : \"val\" } }";
	
	[self checkResultForJSONString:json jsonPathString:@"$.*.bar" configuration:[SMJConfiguration configurationWithOption:SMJOptionAsPathList] expectedResult:@[ @"$['foo']['bar']" ]];
}

- (void)test_issue_114_a
{
	NSString *json = @"{ \"p\":{\n"
	@"\"s\": { \"u\": \"su\" }, \n"
	@"\"t\": { \"u\": \"tu\" }\n"
	@"}}";
	
	[self checkResultForJSONString:json jsonPathString:@"$.p.['s', 't'].u" expectedResult:@[ @"su", @"tu" ]];
}

- (void)test_issue_114_b
{
	NSString *json = @"{ \"p\": [\"valp\", \"valq\", \"valr\"] }";
	
	[self checkResultForJSONString:json jsonPathString:@"$.p[?(@ == 'valp')]" expectedResult:@[ @"valp" ]];
}

- (void)test_issue_114_c
{
	NSString *json = @"{ \"p\": [\"valp\", \"valq\", \"valr\"] }";
	
	[self checkResultForJSONString:json jsonPathString:@"$.p[?(@[0] == 'valp')]" expectedResult:@[ ]];
}

- (void)test_issue_114_d
{
	[self checkResultForJSONString:[self jsonBookDocument] jsonPathString:@"$..book[(@.length-1)] " expectedError:YES];
}

- (void)test_issue_151
{
	NSString *json = @"{\n"
	@"\"datas\": {\n"
	@"    \"selling\": {\n"
	@"        \"3\": [\n"
	@"            26452067,\n"
	@"            31625950\n"
	@"        ],\n"
	@"        \"206\": [\n"
	@"            32381852,\n"
	@"            32489262\n"
	@"        ],\n"
	@"        \"208\": [\n"
	@"            458\n"
	@"        ],\n"
	@"        \"217\": [\n"
	@"            27364892\n"
	@"        ],\n"
	@"        \"226\": [\n"
	@"            30474109\n"
	@"        ]\n"
	@"    }\n"
	@"},\n"
	@"\"status\": 0\n"
	@"}";
	
	[self checkResultForJSONString:json jsonPathString:@"$.datas.selling['3','206'].*" expectedResult:@[ @26452067, @31625950, @32381852, @32489262 ]];
}

- (void)test_full_ones_can_be_filtered
{
	NSString *json = @"[\n"
	@" {\"kind\" : \"full\"},\n"
	@" {\"kind\" : \"empty\"}\n"
	@"]";
	
	[self checkResultForJSONString:json jsonPathString:@"$[?(@.kind == 'full')]" expectedResult:@[@{ @"kind" : @"full" }]];
}

- (void)test_issue_36
{
	NSString *json = @"{\n"
	@"\n"
	@" \"arrayOfObjectsAndArrays\" : [ { \"k\" : [\"json\"] }, { \"k\":[\"path\"] }, { \"k\" : [\"is\"] }, { \"k\" : [\"cool\"] } ],\n"
	@"\n"
	@"  \"arrayOfObjects\" : [{\"k\" : \"json\"}, {\"k\":\"path\"}, {\"k\" : \"is\"}, {\"k\" : \"cool\"}]\n"
	@"\n"
	@" }";
	
	[self checkResultForJSONString:json
					jsonPathString:@"$.arrayOfObjectsAndArrays..k "
					expectedResult:@[@[@"json"],@[@"path"],@[@"is"],@[@"cool"]]];
	
	[self checkResultForJSONString:json
					jsonPathString:@"$.arrayOfObjects..k "
					expectedResult:@[@"json",@"path",@"is",@"cool"]];
}

- (void)test_issue_11
{
	NSString *json = @"{ \"foo\" : [] }";
	
	[self checkResultForJSONString:json jsonPathString:@"$.foo[?(@.rel == 'item')][0].uri" expectedResult:@[]];
}

- (void)test_issue_11b
{
	NSString *json = @"{ \"foo\" : [] }";
	
	[self checkResultForJSONString:json jsonPathString:@"$.foo[0].uri" expectedError:YES];
}

- (void)test_issue_15
{
	NSString *json = @"{ \"store\": {\n"
	@"    \"book\": [ \n"
	@"      { \"category\": \"reference\",\n"
	@"        \"author\": \"Nigel Rees\",\n"
	@"        \"title\": \"Sayings of the Century\",\n"
	@"        \"price\": 8.95\n"
	@"      },\n"
	@"      { \"category\": \"fiction\",\n"
	@"        \"author\": \"Herman Melville\",\n"
	@"        \"title\": \"Moby Dick\",\n"
	@"        \"isbn\": \"0-553-21311-3\",\n"
	@"        \"price\": 8.99,\n"
	@"        \"retailer\": null, \n"
	@"        \"children\": true,\n"
	@"        \"number\": -2.99\n"
	@"      },\n"
	@"      { \"category\": \"fiction\",\n"
	@"        \"author\": \"J. R. R. Tolkien\",\n"
	@"        \"title\": \"The Lord of the Rings\",\n"
	@"        \"isbn\": \"0-395-19395-8\",\n"
	@"        \"price\": 22.99,\n"
	@"        \"number\":0,\n"
	@"        \"children\": false\n"
	@"      }\n"
	@"    ]\n"
	@"  }\n"
	@"}";
	
	[self checkResultForJSONString:json jsonPathString:@"$.store.book[?(@.children==true)].title" expectedResult:@[ @"Moby Dick" ]];
}

- (void)test_issue_24
{
	NSString	*path = [[NSBundle bundleForClass:self.class] pathForResource:@"issue_24" ofType:@"json"];
	NSString	*jsonString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	
	[self checkResultForJSONString:jsonString jsonPathString:@"$.project.field[*].@key" expectedError:NO];
}

- (void)test_issue_28_string
{
	NSString *json = @"{\"contents\": [\"one\",\"two\",\"three\"]}";
	
	[self checkResultForJSONString:json jsonPathString:@"$.contents[?(@  == 'two')]" expectedResult:@[ @"two" ]];
}

- (void)test_issue_37
{
	NSString *json = @"[\n"
	@"    {\n"
	@"        \"id\": \"9\",\n"
	@"        \"sku\": \"SKU-001\",\n"
	@"        \"compatible\": false\n"
	@"    },\n"
	@"    {\n"
	@"        \"id\": \"13\",\n"
	@"        \"sku\": \"SKU-005\",\n"
	@"        \"compatible\": true\n"
	@"    },\n"
	@"    {\n"
	@"        \"id\": \"11\",\n"
	@"        \"sku\": \"SKU-003\",\n"
	@"        \"compatible\": true\n"
	@"    }\n"
	@"]";
	
	[self checkResultForJSONString:json jsonPathString:@"$[?(@.compatible == true)].sku" expectedResult:@[ @"SKU-005", @"SKU-003" ]];
}

- (void)test_issue_38
{
	NSString *json = @"{\n"
	@"   \"datapoints\":[\n"
	@"      [\n"
	@"         10.1,\n"
	@"         13.0\n"
	@"      ],\n"
	@"      [\n"
	@"         21.0,\n"
	@"         22.0\n"
	@"      ]\n"
	@"   ]\n"
	@"}";
	
	[self checkResultForJSONString:json jsonPathString:@"$.datapoints.[*].[0]" expectedResult:@[ @10.1, @21.0 ]];
}

- (void)test_issue_39
{
	NSString *json = @"{\n"
	@"    \"obj1\": {\n"
	@"        \"arr\": [\"1\", \"2\"]\n"
	@"    },\n"
	@"    \"obj2\": {\n"
	@"       \"arr\": [\"3\", \"4\"]\n"
	@"    }\n"
	@"}\n";
	
	[self checkResultForJSONString:json jsonPathString:@"$..arr" expectedCount:2];
}

- (void)test_issue_28_int
{
	NSString *json = @"{\"contents\": [1,2,3]}";
	
	[self checkResultForJSONString:json jsonPathString:@"$.contents[?(@ == 2)]" expectedResult:@[ @2 ]];
}

- (void)test_issue_28_boolean
{
	NSString *json = @"{\"contents\": [true, true, false]}";
	
	[self checkResultForJSONString:json jsonPathString:@"$.contents[?(@  == true)]" expectedResult:@[ @YES, @YES ]];
}

- (void)test_issue_22
{
	NSString *json = @"{\"a\":{\"b\":1,\"c\":2}}";
	
	[self checkResultForJSONString:json jsonPathString:@"a.d" expectedError:YES];
}

- (void)test_issue_22b
{
	NSString *json = @"{\"a\":[{\"b\":1,\"c\":2},{\"b\":5,\"c\":2}]}";
	
	[self checkResultForJSONString:json jsonPathString:@"a[?(@.b==5)].d" configuration:[SMJConfiguration configurationWithOption:SMJOptionDefaultPathLeafToNull] expectedResult:@[ [NSNull null] ]];
}

- (void)test_issue_26
{
	NSString *json = @"[{\"a\":[{\"b\":1,\"c\":2}]}]";
	
	[self checkResultForJSONString:json jsonPathString:@"$.a" expectedError:YES];
}

- (void)test_issue_29_a
{
	NSString *json = @"{\"list\": [ { \"a\":\"atext\", \"b.b-a\":\"batext2\", \"b\":{ \"b-a\":\"batext\", \"b-b\":\"bbtext\" } }, { \"a\":\"atext2\", \"b\":{ \"b-a\":\"batext2\", \"b-b\":\"bbtext2\" } } ] }";

	NSArray *result1 = [self checkResultForJSONString:json jsonPathString:@"$.list[?(@['b.b-a']=='batext2')]" expectedCount:1];
	XCTAssertEqualObjects([result1[0] objectForKey:@"a"], @"atext");
	
	NSArray *result2 = [self checkResultForJSONString:json jsonPathString:@"$.list[?(@.b.b-a=='batext2')]" expectedCount:1];
	XCTAssertEqualObjects([result2[0] objectForKey:@"a"], @"atext2");
}

- (void)test_issue_30
{
	NSString *json = @"{\"foo\" : {\"@id\" : \"123\", \"$\" : \"hello\"}}";
	
	[self checkResultForJSONString:json jsonPathString:@"foo.@id" expectedResult:@"123"];
	[self checkResultForJSONString:json jsonPathString:@"foo.$" expectedResult:@"hello"];
}

- (void)test_issue_32
{
	NSString *json = @"{\"text\" : \"skill: \\\"Heuristic Evaluation\\\"\", \"country\" : \"\"}";
	
	[self checkResultForJSONString:json jsonPathString:@"$.text" expectedResult:@"skill: \"Heuristic Evaluation\""];
}

- (void)test_issue_33
{
	NSString *json = @"{ \"store\": {\n"
	@"    \"book\": [ \n"
	@"      { \"category\": \"reference\",\n"
	@"        \"author\": {\n"
	@"          \"name\": \"Author Name\",\n"
	@"          \"age\": 36\n"
	@"        },\n"
	@"        \"title\": \"Sayings of the Century\",\n"
	@"        \"price\": 8.95\n"
	@"      },\n"
	@"      { \"category\": \"fiction\",\n"
	@"        \"author\": \"Evelyn Waugh\",\n"
	@"        \"title\": \"Sword of Honour\",\n"
	@"        \"price\": 12.99,\n"
	@"        \"isbn\": \"0-553-21311-3\"\n"
	@"      }\n"
	@"    ],\n"
	@"    \"bicycle\": {\n"
	@"      \"color\": \"red\",\n"
	@"      \"price\": 19.95\n"
	@"    }\n"
	@"  }\n"
	@"}";
	
	NSArray *result = [self checkResultForJSONString:json jsonPathString:@"$.store.book[?(@.author.age == 36)]" expectedCount:1];
	
	XCTAssertEqualObjects([result[0] objectForKey:@"title"], @"Sayings of the Century");
}

- (void)test_array_root
{
	NSString *json = @"[\n"
	@"    {\n"
	@"        \"a\": 1,\n"
	@"        \"b\": 2,\n"
	@"        \"c\": 3\n"
	@"    }\n"
	@"]";
	
	[self checkResultForJSONString:json jsonPathString:@"$[0].a" expectedResult:@1];
}

- (void)test_a_test
{
	NSString *json = @"{\n"
	@"  \"success\": true,\n"
	@"  \"data\": {\n"
	@"    \"user\": 3,\n"
	@"    \"own\": null,\n"
	@"    \"passes\": null,\n"
	@"    \"completed\": null\n"
	@"  },\n"
	@"  \"version\": 1371160528774\n"
	@"}";
	
	[self checkResultForJSONString:json jsonPathString:@"$.data.passes[0].id" expectedError:YES];
}

- (void)test_issue_42
{
	NSString *json = @"{"
	@"        \"list\": [{"
	@"            \"name\": \"My (String)\" "
	@"        }] "
	@"    }";
	
	[self checkResultForJSONString:json jsonPathString:@"$.list[?(@.name == 'My (String)')]" expectedResult:@[ @{ @"name" : @"My (String)" } ]];
}

- (void)test_issue_45
{
	NSString *json = @"{\"rootkey\":{\"sub.key\":\"value\"}}";
	
	[self checkResultForJSONString:json jsonPathString:@"rootkey['sub.key']" expectedResult:@"value"];
}

- (void)test_issue_x
{
	NSString *json = @"{\n"
	@" \"a\" : [\n"
	@"   {},\n"
	@"   { \"b\" : [ { \"c\" : \"foo\"} ] }\n"
	@" ]\n"
	@"}\n";
	
	[self checkResultForJSONString:json jsonPathString:@"$.a.*.b.*.c" expectedResult:@[ @"foo" ]];
}

- (void)test_issue_60
{
	NSString *json = @"[\n"
	@"{\n"
	@"  \"mpTransactionId\": \"542986eae4b001fd500fdc5b-coreDisc_50-title\",\n"
	@"  \"resultType\": \"FAIL\",\n"
	@"  \"narratives\": [\n"
	@"    {\n"
	@"      \"ruleProcessingDate\": \"Nov 2, 2014 7:30:20 AM\",\n"
	@"      \"area\": \"Discovery\",\n"
	@"      \"phase\": \"Validation\",\n"
	@"      \"message\": \"Chain does not have a discovery event. Possible it was cut by the date that was picked\",\n"
	@"      \"ruleName\": \"Validate chain\\u0027s discovery event existence\",\n"
	@"      \"lastRule\": true\n"
	@"    }\n"
	@"  ]\n"
	@"},\n"
	@"{\n"
	@"  \"mpTransactionId\": \"54298649e4b001fd500fda3e-fixCoreDiscovery_3-title\",\n"
	@"  \"resultType\": \"FAIL\",\n"
	@"  \"narratives\": [\n"
	@"    {\n"
	@"      \"ruleProcessingDate\": \"Nov 2, 2014 7:30:20 AM\",\n"
	@"      \"area\": \"Discovery\",\n"
	@"      \"phase\": \"Validation\",\n"
	@"      \"message\": \"There is one and only discovery event ContentDiscoveredEvent(230) found.\",\n"
	@"      \"ruleName\": \"Marks existence of discovery event (230)\",\n"
	@"      \"lastRule\": false\n"
	@"    },\n"
	@"    {\n"
	@"      \"ruleProcessingDate\": \"Nov 2, 2014 7:30:20 AM\",\n"
	@"      \"area\": \"Discovery/Processing\",\n"
	@"      \"phase\": \"Validation\",\n"
	@"      \"message\": \"Chain does not have SLA start event (204) in Discovery or Processing. \",\n"
	@"      \"ruleName\": \"Check if SLA start event is not present (204). \",\n"
	@"      \"lastRule\": false\n"
	@"    },\n"
	@"    {\n"
	@"      \"ruleProcessingDate\": \"Nov 2, 2014 7:30:20 AM\",\n"
	@"      \"area\": \"Processing\",\n"
	@"      \"phase\": \"Transcode\",\n"
	@"      \"message\": \"No start transcoding events found\",\n"
	@"      \"ruleName\": \"Start transcoding events missing (240)\",\n"
	@"      \"lastRule\": true\n"
	@"    }\n"
	@"  ]\n"
	@"}]";
	
	[self checkResultForJSONString:json
					jsonPathString:@"$..narratives[?(@.lastRule==true)].message"
					expectedResult:@[ @"Chain does not have a discovery event. Possible it was cut by the date that was picked", @"No start transcoding events found" ]];

}

- (void)test_stack_overflow_question_1
{
	// http://stackoverflow.com/questions/28596324/jsonpath-filtering-api
	
	NSString *json = @"{\n"
	@"\"store\": {\n"
	@"    \"book\": [\n"
	@"        {\n"
	@"            \"category\": \"reference\",\n"
	@"            \"authors\" : [\n"
	@"                 {\n"
	@"                     \"firstName\" : \"Nigel\",\n"
	@"                     \"lastName\" :  \"Rees\"\n"
	@"                  }\n"
	@"            ],\n"
	@"            \"title\": \"Sayings of the Century\",\n"
	@"            \"price\": 8.95\n"
	@"        },\n"
	@"        {\n"
	@"            \"category\": \"fiction\",\n"
	@"            \"authors\": [\n"
	@"                 {\n"
	@"                     \"firstName\" : \"Evelyn\",\n"
	@"                     \"lastName\" :  \"Waugh\"\n"
	@"                  },\n"
	@"                 {\n"
	@"                     \"firstName\" : \"Another\",\n"
	@"                     \"lastName\" :  \"Author\"\n"
	@"                  }\n"
	@"            ],\n"
	@"            \"title\": \"Sword of Honour\",\n"
	@"            \"price\": 12.99\n"
	@"        }\n"
	@"    ]\n"
	@"  }\n"
	@"}";
	
	[self checkResultForJSONString:json
					jsonPathString:@"$.store.book[?(@.authors[*].lastName CONTAINS 'Waugh')]"
					 expectedError:NO];
}

- (void)test_issue_71
{
	NSString *json = @"{\n"
	@"    \"logs\": [\n"
	@"        {\n"
	@"            \"message\": \"it's here\",\n"
	@"            \"id\": 2\n"
	@"        }\n"
	@"    ]\n"
	@"}";
	
	[self checkResultForJSONString:json jsonPathString:@"$.logs[?(@.message == 'it\\'s here')].message" expectedResult:@[ @"it's here" ]];
}

- (void)test_issue_79
{
	NSString *json = @"{ \n"
	@"  \"c\": {\n"
	@"    \"d1\": {\n"
	@"      \"url\": [ \"url1\", \"url2\" ]\n"
	@"    },\n"
	@"    \"d2\": {\n"
	@"      \"url\": [ \"url3\", \"url4\",\"url5\" ]\n"
	@"    }\n"
	@"  }\n"
	@"}";
	
	[self checkResultForJSONString:json jsonPathString:@"$.c.*.url[2]" expectedResult:@[ @"url5" ]];
}

- (void)test_issue_97
{
	NSString *json = @"{ \"books\": [ "
	@"{ \"category\": \"fiction\" }, "
	@"{ \"category\": \"reference\" }, "
	@"{ \"category\": \"fiction\" }, "
	@"{ \"category\": \"fiction\" }, "
	@"{ \"category\": \"reference\" }, "
	@"{ \"category\": \"fiction\" }, "
	@"{ \"category\": \"reference\" }, "
	@"{ \"category\": \"reference\" }, "
	@"{ \"category\": \"reference\" }, "
	@"{ \"category\": \"reference\" }, "
	@"{ \"category\": \"reference\" } ]  }";
	
	
	id jsonObject = [self jsonWithJSONString:json jsonPathString:@"$.books[?(@.category == 'reference')]" updater:^id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject deleteWithConfiguration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	NSArray *result = [self checkResultForJSONObject:jsonObject jsonPathString:@"$..category" expectedError:NO];

	for (NSString *item in result)
		XCTAssertEqualObjects(item, @"fiction");
}

- (void)test_issue_99
{
	NSString *json = @"{\n"
	@"    \"array1\": [\n"
	@"        {\n"
	@"            \"array2\": []\n"
	@"        },\n"
	@"        {\n"
	@"            \"array2\": [\n"
	@"                {\n"
	@"                    \"key\": \"test_key\"\n"
	@"                }\n"
	@"            ]\n"
	@"        }\n"
	@"    ]\n"
	@"}";
	
	
	[self checkResultForJSONString:json
					jsonPathString:@"$.array1[*].array2[0].key"
					 configuration:[SMJConfiguration configurationWithOption:SMJOptionDefaultPathLeafToNull]
					 expectedError:NO];
}

- (void)test_issue_131
{
	NSString *json = @"[\n"
	@"    {\n"
	@"        \"foo\": \"1\"\n"
	@"    },\n"
	@"    {\n"
	@"        \"foo\": null\n"
	@"    },\n"
	@"    {\n"
	@"        \"xxx\": null\n"
	"    }\n"
	@"]";
	
	[self checkResultForJSONString:json jsonPathString:@"$[?(@.foo)]" expectedResult:@[ @{ @"foo" : @"1" }, @{ @"foo" : [NSNull null] } ]];
}

- (void)test_issue_131_2
{
	NSString *json = @"[\n"
	@"    {\n"
	@"        \"foo\": { \"bar\" : \"0\"}\n"
	@"    },\n"
	@"    {\n"
	@"        \"foo\": null\n"
	@"    },\n"
	@"    {\n"
	@"        \"xxx\": null\n"
	@"    }\n"
	@"]";
	
	[self checkResultForJSONString:json jsonPathString:@"$[?(@.foo != null)].foo.bar" expectedResult:@[ @"0" ]];
	
	[self checkResultForJSONString:json jsonPathString:@"$[?(@.foo.bar)].foo.bar" expectedResult:@[ @"0" ]];
}

- (void)test_issue_131_3
{
	NSString *json = @"[\n"
	@"    1,\n"
	@"    2,\n"
	@"    {\n"
	@"        \"d\": {\n"
	@"            \"random\": null,\n"
	@"            \"date\": 1234\n"
	@"        },\n"
	@"        \"l\": \"filler\"\n"
	@"    }\n"
	@"]";
	
	[self checkResultForJSONString:json jsonPathString:@"$[2]['d'][?(@.random)]['date']" expectedResult:@[ @1234 ]];
}

- (void)test_using_square_bracket_literal_path
{
	//https://groups.google.com/forum/#!topic/jsonpath/Ojv8XF6LgqM
	
	NSString *json = @"{ \"valid key[@num = 2]\" : \"value\" }";
	
	[self checkResultForJSONString:json jsonPathString:@"$['valid key[@num = 2]']" expectedResult:@"value"];
}

- (void)test_issue_90
{
	NSString *json = @"{\n"
	@"    \"store\": {\n"
	@"        \"book\": [\n"
	@"            {\n"
	@"                \"price\": \"120\"\n"
	@"            },\n"
	@"            {\n"
	@"                \"price\": 8.95\n"
	@"            },\n"
	@"            {\n"
	@"                \"price\": 12.99\n"
	@"            },\n"
	@"            {\n"
	@"                \"price\": 8.99\n"
	@"            },\n"
	@"            {\n"
	@"                \"price\": 22.99\n"
	@"            }\n"
	@"        ]\n"
	@"    },\n"
	@"    \"expensive\": 10\n"
	@"}";
	
	[self checkResultForJSONString:json jsonPathString:@"$.store.book[?(@.price <= 90)].price" expectedResult:@[ @8.95, @12.99, @8.99, @22.99 ]];
}

- (void)test_issue_170
{
	NSString *json = @"{\n"
	@"  \"array\": [\n"
	@"    0,\n"
	@"    1,\n"
	@"    2\n"
	@"  ]\n"
	@"}";
	
	id result = [self jsonWithJSONString:json jsonPathString:@"$.array[0]" updater:^id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject setObject:[NSNull null] configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	result = [self jsonWithMutableJSONObject:result jsonPathString:@"$.array[2]" updater:^id (SMJJSONPath * jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject setObject:[NSNull null] configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	[self checkResultForJSONObject:result jsonPathString:@"$.array" expectedResult:@[ [NSNull null], @1, [NSNull null] ]];
}

- (void)test_issue_171
{
	NSString *json = @"{\n"
	@"  \"can delete\": \"this\",\n"
	@"  \"can't delete\": \"this\"\n"
	@"}";
	
	id result = [self jsonWithJSONString:json jsonPathString:@"$.['can delete']" updater:^id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject setObject:[NSNull null] configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	result = [self jsonWithMutableJSONObject:result jsonPathString:@"$.['can\\'t delete']" updater:^id (SMJJSONPath * jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject setObject:[NSNull null] configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	[self checkResultForJSONObject:result jsonPathString:@"$" expectedResult:@{ @"can delete" : [NSNull null], @"can't delete" : [NSNull null] }];
}

- (void)test_issue_309
{
	NSString *json = @"{\n"
	@"\"jsonArr\": [\n"
	@"   {\n"
	@"       \"name\":\"nOne\"\n"
	@"   },\n"
	@"   {\n"
	@"       \"name\":\"nTwo\"\n"
	@"   }\n"
	@"   ]\n"
	@"}";
	
	id result = [self jsonWithJSONString:json jsonPathString:@"$.jsonArr[1].name" updater:^id (SMJJSONPath *jsonPath, id jsonObject, NSError **error) {
		return [jsonPath updateMutableJSONObject:jsonObject setObject:@"Jayway" configuration:[SMJConfiguration defaultConfiguration] error:error];
	}];
	
	[self checkResultForJSONObject:result jsonPathString:@"$.jsonArr[0].name" expectedResult:@"nOne"];
	[self checkResultForJSONObject:result jsonPathString:@"$.jsonArr[1].name" expectedResult:@"Jayway"];
}

- (void)test_issue_378
{
	NSString *json = @"{\n"
	@"    \"nodes\": {\n"
	@"        \"unnamed1\": {\n"
	@"            \"ntpServers\": [\n"
	@"                \"1.2.3.4\"\n"
	@"            ]\n"
	@"        }\n"
	@"    }\n"
	@"}";
	
	[self checkResultForJSONString:json jsonPathString:@"$.nodes[*][?(!([\"1.2.3.4\"] subsetof @.ntpServers))].ntpServers" expectedError:NO];
}

@end


NS_ASSUME_NONNULL_END
