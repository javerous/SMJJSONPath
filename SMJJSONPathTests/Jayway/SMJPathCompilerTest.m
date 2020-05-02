/*
 * SMJPathCompilerTest.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/PathCompilerTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseTest.h"
#import "SMJPathCompiler.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJPathCompilerTest
*/
#pragma mark - SMJPathCompilerTest

@interface SMJPathCompilerTest : SMJBaseTest
@end

@implementation SMJPathCompilerTest

- (void)test_a_root_path_must_be_followed_by_period_or_bracket
{
	NSError			*error = nil;
	id <SMJPath>	path = [SMJPathCompiler compilePathString:@"$X" error:&error];
	
	XCTAssertNil(path);
	XCTAssertNotNil(error);
}

- (void)test_a_root_path_can_be_compiled
{
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$" error:nil] stringValue], @"$");
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"@" error:nil] stringValue], @"@");
}

- (void)test_a_path_may_not_end_with_period
{
	NSError			*error = nil;
	id <SMJPath>	path = [SMJPathCompiler compilePathString:@"$." error:&error];
	
	XCTAssertNil(path);
	XCTAssertNotNil(error);
}

- (void)test_a_path_may_not_end_with_period_2
{
	NSError			*error = nil;
	id <SMJPath>	path = [SMJPathCompiler compilePathString:@"$.prop." error:&error];
	
	XCTAssertNil(path);
	XCTAssertNotNil(error);
}

- (void)test_a_path_may_not_end_with_scan
{
	NSError			*error = nil;
	id <SMJPath>	path = [SMJPathCompiler compilePathString:@"$.." error:&error];
	
	XCTAssertNil(path);
	XCTAssertNotNil(error);
}

- (void)test_a_path_may_not_end_with_scan_2
{
	NSError			*error = nil;
	id <SMJPath>	path = [SMJPathCompiler compilePathString:@"$.prop.." error:&error];
	
	XCTAssertNil(path);
	XCTAssertNotNil(error);
}

- (void)test_a_property_token_can_be_compiled
{
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$.prop" error:nil] stringValue], @"$['prop']");
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$.1prop" error:nil] stringValue], @"$['1prop']");
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$.@prop" error:nil] stringValue], @"$['@prop']");
}

- (void)test_a_bracket_notation_property_token_can_be_compiled
{
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$['prop']" error:nil] stringValue], @"$['prop']");
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$['1prop']" error:nil] stringValue], @"$['1prop']");
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$['@prop']" error:nil] stringValue], @"$['@prop']");
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$[  '@prop'  ]" error:nil] stringValue], @"$['@prop']");
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$[\"prop\"]" error:nil] stringValue], @"$[\"prop\"]");
}

- (void)test_a_multi_property_token_can_be_compiled
{
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$['prop0', 'prop1']" error:nil] stringValue], @"$['prop0','prop1']");
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$[  'prop0'  , 'prop1'  ]" error:nil] stringValue], @"$['prop0','prop1']");
}

- (void)test_a_property_chain_can_be_compiled
{
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$.abc" error:nil] stringValue], @"$['abc']");
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$.aaa.bbb" error:nil] stringValue], @"$['aaa']['bbb']");
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$.aaa.bbb.ccc" error:nil] stringValue], @"$['aaa']['bbb']['ccc']");
}

- (void)test_a_property_may_not_contain_blanks
{
	XCTAssertNil([SMJPathCompiler compilePathString:@"$.foo bar" error:nil]);
}

- (void)test_a_wildcard_can_be_compiled
{
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$.*" error:nil] stringValue], @"$[*]");
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$[*]" error:nil] stringValue], @"$[*]");
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$[ * ]" error:nil] stringValue], @"$[*]");
}

- (void)test_a_wildcard_can_follow_a_property
{
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$.prop[*]" error:nil] stringValue], @"$['prop'][*]");
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$['prop'][*]" error:nil] stringValue], @"$['prop'][*]");
}

- (void)test_an_array_index_path_can_be_compiled
{
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$[1]" error:nil] stringValue], @"$[1]");
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$[1,2,3]" error:nil] stringValue], @"$[1,2,3]");
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$[ 1 , 2 , 3 ]" error:nil] stringValue], @"$[1,2,3]");
}

- (void)test_an_array_slice_path_can_be_compiled
{
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$[-1:]" error:nil] stringValue], @"$[-1:]");
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$[1:2]" error:nil] stringValue], @"$[1:2]");
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$[:2]" error:nil] stringValue], @"$[:2]");
}

- (void)test_an_inline_criteria_can_be_parsed
{
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$[?(@.foo == 'bar')]" error:nil] stringValue], @"$[?]");
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$[?(@.foo == \"bar\")]" error:nil] stringValue], @"$[?]");
}

- (void)test_a_scan_token_can_be_parsed
{
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$..['prop']..[*]" error:nil] stringValue], @"$..['prop']..[*]");
}

- (void)test_issue_predicate_can_have_escaped_backslash_in_prop
{
	NSString *json = @"{\n"
	@"    \"logs\": [\n"
	@"        {\n"
	@"            \"message\": \"it\\\\\",\n"
	@"            \"id\": 2\n"
	@"        }\n"
	@"    ]\n"
	@"}";
	
	[self checkResultForJSONString:json jsonPathString:@"$.logs[?(@.message == 'it\\\\')].message" expectedResult:@[ @"it\\" ]];
}

- (void)test_issue_predicate_can_have_bracket_in_regex
{
	NSString *json = @"{\n"
	"    \"logs\": [\n"
	"        {\n"
	"            \"message\": \"(it\",\n"
	"            \"id\": 2\n"
	"        }\n"
	"    ]\n"
	"}";
	
	[self checkResultForJSONString:json jsonPathString:@"$.logs[?(@.message =~ /\\(it/)].message" expectedResult:@[ @"(it" ]];
}

- (void)test_issue_predicate_can_have_and_in_regex
{
	NSString *json = @"{\n"
	"    \"logs\": [\n"
	"        {\n"
	"            \"message\": \"it\",\n"
	"            \"id\": 2\n"
	"        }\n"
	"    ]\n"
	"}";
	
	[self checkResultForJSONString:json jsonPathString:@"$.logs[?(@.message =~ /&&|it/)].message" expectedResult:@[ @"it" ]];
}

- (void)test_issue_predicate_can_have_and_in_prop
{
	NSString *json = @"{\n"
	"    \"logs\": [\n"
	"        {\n"
	"            \"message\": \"&& it\",\n"
	"            \"id\": 2\n"
	"        }\n"
	"    ]\n"
	"}";
	
	[self checkResultForJSONString:json jsonPathString:@"$.logs[?(@.message == '&& it')].message" expectedResult:@[ @"&& it" ]];
}

- (void)test_issue_predicate_brackets_must_change_priorities
{
	NSString *json = @"{\n"
	"    \"logs\": [\n"
	"        {\n"
	"            \"id\": 2\n"
	"        }\n"
	"    ]\n"
	"}";
	
	[self checkResultForJSONString:json jsonPathString:@"$.logs[?(@.message && (@.id == 1 || @.id == 2))].id" expectedResult:@[ ]];
	
	[self checkResultForJSONString:json jsonPathString:@"$.logs[?((@.id == 2 || @.id == 1) && @.message)].id" expectedResult:@[ ]];
}

- (void)test_issue_predicate_or_has_lower_priority_than_and
{
	NSString *json = @"{\n"
	"    \"logs\": [\n"
	"        {\n"
	"            \"id\": 2\n"
	"        }\n"
	"    ]\n"
	"}";
	
	[self checkResultForJSONString:json jsonPathString:@"$.logs[?(@.x && @.y || @.id)]" expectedCount:1];
}

- (void)test_issue_predicate_can_have_double_quotes
{
	NSString *json = @"{\n"
	"    \"logs\": [\n"
	"        {\n"
	"            \"message\": \"\\\"it\\\"\",\n"
	"        }\n"
	"    ]\n"
	"}";
	
	[self checkResultForJSONString:json jsonPathString:@"$.logs[?(@.message == '\"it\"')].message" expectedResult:@[ @"\"it\"" ]];
}

- (void)test_issue_predicate_can_have_single_quotes
{
	NSString *json = @"{\n"
	"    \"logs\": [\n"
	"        {\n"
	"            \"message\": \"'it'\",\n"
	"        }\n"
	"    ]\n"
	"}";
	
	[self checkResultForJSONString:json jsonPathString:@"$.logs[?(@.message == \"'it'\")].message" expectedResult:@[ @"'it'" ]];
}

- (void)test_issue_predicate_can_have_single_quotes_escaped
{
	NSString *json = @"{\n"
	"    \"logs\": [\n"
	"        {\n"
	"            \"message\": \"'it'\",\n"
	"        }\n"
	"    ]\n"
	"}";
	
	[self checkResultForJSONString:json jsonPathString:@"$.logs[?(@.message == '\\'it\\'')].message" expectedResult:@[ @"'it'" ]];
}

- (void)test_issue_predicate_can_have_square_bracket_in_prop
{
	NSString *json  = @"{\n"
	"    \"logs\": [\n"
	"        {\n"
	"            \"message\": \"] it\",\n"
	"            \"id\": 2\n"
	"        }\n"
	"    ]\n"
	"}";
	
	[self checkResultForJSONString:json jsonPathString:@"$.logs[?(@.message == '] it')].message" expectedResult:@[ @"] it" ]];
}

- (void)test_a_function_can_be_compiled
{
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$.aaa.foo()" error:nil] stringValue], @"$['aaa'].foo()");
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$.aaa.foo(5)" error:nil] stringValue], @"$['aaa'].foo(...)");
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$.aaa.foo($.bar)" error:nil] stringValue], @"$['aaa'].foo(...)");
	XCTAssertEqualObjects([[SMJPathCompiler compilePathString:@"$.aaa.foo(5,10,15)" error:nil] stringValue], @"$['aaa'].foo(...)");
}

- (void)test_array_indexes_must_be_separated_by_commas
{
	NSError			*error = nil;
	id <SMJPath>	path = [SMJPathCompiler compilePathString:@"$[0, 1, 2 4]" error:&error];
	
	XCTAssertNil(path);
	XCTAssertNotNil(error);
}

- (void)test_trailing_comma_after_list_is_not_accepted
{
	NSError			*error = nil;
	id <SMJPath>	path = [SMJPathCompiler compilePathString:@"$['1','2',]" error:&error];
	
	XCTAssertNil(path);
	XCTAssertNotNil(error);
}

- (void)test_accept_only_a_single_comma_between_indexes
{
	NSError			*error = nil;
	id <SMJPath>	path = [SMJPathCompiler compilePathString:@"$['1', ,'3']" error:&error];
	
	XCTAssertNil(path);
	XCTAssertNotNil(error);
}

- (void)test_property_must_be_separated_by_commas
{
	NSError			*error = nil;
	id <SMJPath>	path = [SMJPathCompiler compilePathString:@"$['aaa'}'bbb']" error:&error];
	
	XCTAssertNil(path);
	XCTAssertNotNil(error);
}

@end


NS_ASSUME_NONNULL_END
