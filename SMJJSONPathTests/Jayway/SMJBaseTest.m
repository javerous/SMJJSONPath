/*
 * SMJBaseTest.m
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


#import "SMJBaseTest.h"

#import "SMJPredicateContextImpl.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJBaseTest
*/
#pragma mark - SMJBaseTest

@implementation SMJBaseTest

- (NSString *)jsonBookDocument
{
	return @"{ "
	@"   \"category\" : \"reference\",\n"
	@"   \"author\" : \"Nigel Rees\",\n"
	@"   \"title\" : \"Sayings of the Century\",\n"
	@"   \"display-price\" : 8.95\n"
	@"}";
}

- (NSString *)jsonDocument
{
	static NSMutableString *result;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		result = [[NSMutableString alloc] init];
		
		[result appendString:@"{\n"];
		[result appendString:@"   \"string-property\" : \"string-value\", \n"];
		[result appendFormat:@"   \"int-max-property\" : %llu, \n", UINT64_MAX];
		[result appendFormat:@"   \"long-max-property\" : %lld, \n", INT64_MIN];
		[result appendString:@"   \"boolean-property\" : true, \n"];
		[result appendString:@"   \"null-property\" : null, \n"];
		[result appendString:@"   \"int-small-property\" : 1, \n"];
		[result appendString:@"   \"max-price\" : 10, \n"];
		[result appendString:@"   \"store\" : {\n"];
		[result appendString:@"      \"book\" : [\n"];
		[result appendString:@"         {\n"];
		[result appendString:@"            \"category\" : \"reference\",\n"];
		[result appendString:@"            \"author\" : \"Nigel Rees\",\n"];
		[result appendString:@"            \"title\" : \"Sayings of the Century\",\n"];
		[result appendString:@"            \"display-price\" : 8.95\n"];
		[result appendString:@"         },\n"];
		[result appendString:@"         {\n"];
		[result appendString:@"            \"category\" : \"fiction\",\n"];
		[result appendString:@"            \"author\" : \"Evelyn Waugh\",\n"];
		[result appendString:@"            \"title\" : \"Sword of Honour\",\n"];
		[result appendString:@"            \"display-price\" : 12.99\n"];
		[result appendString:@"         },\n"];
		[result appendString:@"         {\n"];
		[result appendString:@"            \"category\" : \"fiction\",\n"];
		[result appendString:@"            \"author\" : \"Herman Melville\",\n"];
		[result appendString:@"            \"title\" : \"Moby Dick\",\n"];
		[result appendString:@"            \"isbn\" : \"0-553-21311-3\",\n"];
		[result appendString:@"            \"display-price\" : 8.99\n"];
		[result appendString:@"         },\n"];
		[result appendString:@"         {\n"];
		[result appendString:@"            \"category\" : \"fiction\",\n"];
		[result appendString:@"            \"author\" : \"J. R. R. Tolkien\",\n"];
		[result appendString:@"            \"title\" : \"The Lord of the Rings\",\n"];
		[result appendString:@"            \"isbn\" : \"0-395-19395-8\",\n"];
		[result appendString:@"            \"display-price\" : 22.99\n"];
		[result appendString:@"         }\n"];
		[result appendString:@"      ],\n"];
		[result appendString:@"      \"bicycle\" : {\n"];
		[result appendString:@"         \"foo\" : \"baz\",\n"];
		[result appendString:@"         \"escape\" : \"Esc\\b\\f\\n\\r\\t\\n\\t\\u002A\",\n"];
		[result appendString:@"         \"color\" : \"red\",\n"];
		[result appendString:@"         \"display-price\" : 19.95,\n"];
		[result appendString:@"         \"foo:bar\" : \"fooBar\",\n"];
		[result appendString:@"         \"dot.notation\" : \"new\",\n"];
		[result appendString:@"         \"dash-notation\" : \"dashes\"\n"];
		[result appendString:@"      }\n"];
		[result appendString:@"   },\n"];
		[result appendString:@"   \"foo\" : \"bar\",\n"];
		[result appendString:@"   \"@id\" : \"ID\"\n"];
		[result appendString:@"}"];
	});
	
	return result;
}

- (NSString *)jsonArray
{
	return @"["
	@"{\n"
	@"   \"foo\" : \"foo-val-0\"\n"
	@"},"
	@"{\n"
	@"   \"foo\" : \"foo-val-1\"\n"
	@"},"
	@"{\n"
	@"   \"foo\" : \"foo-val-2\"\n"
	@"},"
	@"{\n"
	@"   \"foo\" : \"foo-val-3\"\n"
	@"},"
	@"{\n"
	@"   \"foo\" : \"foo-val-4\"\n"
	@"},"
	@"{\n"
	@"   \"foo\" : \"foo-val-5\"\n"
	@"},"
	@"{\n"
	@"   \"foo\" : \"foo-val-6\"\n"
	@"}"
	@"]";
}

- (id <SMJPredicateContext>)predicateContextForJsonObject:(id)jsonObject
{
	return [[SMJPredicateContextImpl alloc] initWithJsonObject:jsonObject rootJsonObject:jsonObject configuration:[SMJConfiguration defaultConfiguration] pathCache:[NSMutableDictionary new]];
}

@end


NS_ASSUME_NONNULL_END
