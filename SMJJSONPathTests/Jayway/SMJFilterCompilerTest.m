/*
 * SMJFilterCompilerTest.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/FilterCompilerTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseTest.h"

#import "SMJFilterCompiler.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJFilterCompilerTest
*/
@interface SMJFilterCompilerTest : SMJBaseTest
@end

@implementation SMJFilterCompilerTest

- (void)checkCompileJSONPathString:(NSString *)jsonPathString expectedError:(BOOL)expectedError
{
	NSError		*error = nil;
	SMJFilter	*filter = [SMJFilterCompiler compileFilterString:jsonPathString error:&error];

	if (filter && expectedError)
		XCTFail(@"got a filter while an error was expected");
	else if (!filter && !expectedError)
		XCTFail(@"got an error while a result was expected: %@", error.localizedDescription);
}

- (void)checkCompiledJSONPathString:(NSString *)jsonPathString1 withJSONPathString:(NSString *)jsonPathString2
{
	SMJFilter *filter = [SMJFilterCompiler compileFilterString:jsonPathString1 error:nil];
	
	XCTAssertNotNil(filter);
	XCTAssertEqualObjects([filter stringValue], jsonPathString2);
}

- (void)test_valid_filters_compile
{
	[self checkCompiledJSONPathString:@"[?(@)]" withJSONPathString:@"[?(@)]"];
	[self checkCompiledJSONPathString:@"[?(@.firstname)]" withJSONPathString:@"[?(@['firstname'])]"];
	[self checkCompiledJSONPathString:@"[?($.firstname)]" withJSONPathString:@"[?($['firstname'])]"];
	[self checkCompiledJSONPathString:@"[?(@['firstname'])]" withJSONPathString:@"[?(@['firstname'])]"];
	[self checkCompiledJSONPathString:@"[?($['firstname'].lastname)]" withJSONPathString:@"[?($['firstname']['lastname'])]"];
	[self checkCompiledJSONPathString:@"[?($['firstname']['lastname'])]" withJSONPathString:@"[?($['firstname']['lastname'])]"];
	[self checkCompiledJSONPathString:@"[?($['firstname']['lastname'].*)]" withJSONPathString:@"[?($['firstname']['lastname'][*])]"];
	[self checkCompiledJSONPathString:@"[?($['firstname']['num_eq'] == 1)]" withJSONPathString:@"[?($['firstname']['num_eq'] == 1)]"];
	[self checkCompiledJSONPathString:@"[?($['firstname']['num_gt'] > 1.1)]" withJSONPathString:@"[?($['firstname']['num_gt'] > 1.1)]"];
	[self checkCompiledJSONPathString:@"[?($['firstname']['num_lt'] < 11.11)]" withJSONPathString:@"[?($['firstname']['num_lt'] < 11.11)]"];
	[self checkCompiledJSONPathString:@"[?($['firstname']['str_eq'] == 'hej')]" withJSONPathString:@"[?($['firstname']['str_eq'] == 'hej')]"];
	[self checkCompiledJSONPathString:@"[?($['firstname']['str_eq'] == '')]" withJSONPathString:@"[?($['firstname']['str_eq'] == '')]"];
	[self checkCompiledJSONPathString:@"[?($['firstname']['str_eq'] == null)]" withJSONPathString:@"[?($['firstname']['str_eq'] == null)]"];
	[self checkCompiledJSONPathString:@"[?($['firstname']['str_eq'] == true)]" withJSONPathString:@"[?($['firstname']['str_eq'] == true)]"];
	[self checkCompiledJSONPathString:@"[?($['firstname']['str_eq'] == false)]" withJSONPathString:@"[?($['firstname']['str_eq'] == false)]"];
	[self checkCompiledJSONPathString:@"[?(@.firstname && @.lastname)]" withJSONPathString:@"[?(@['firstname'] && @['lastname'])]"];
	[self checkCompiledJSONPathString:@"[?((@.firstname || @.lastname) && @.and)]" withJSONPathString:@"[?((@['firstname'] || @['lastname']) && @['and'])]"];
	[self checkCompiledJSONPathString:@"[?((@.a || @.b || @.c) && @.x)]" withJSONPathString:@"[?((@['a'] || @['b'] || @['c']) && @['x'])]"];
	[self checkCompiledJSONPathString:@"[?((@.a && @.b && @.c) || @.x)]" withJSONPathString:@"[?((@['a'] && @['b'] && @['c']) || @['x'])]"];
	[self checkCompiledJSONPathString:@"[?((@.a && @.b || @.c) || @.x)]" withJSONPathString:@"[?(((@['a'] && @['b']) || @['c']) || @['x'])]"];
	[self checkCompiledJSONPathString:@"[?((@.a && @.b) || (@.c && @.d))]" withJSONPathString:@"[?((@['a'] && @['b']) || (@['c'] && @['d']))]"];
	[self checkCompiledJSONPathString:@"[?(@.a IN [1,2,3])]" withJSONPathString:@"[?(@['a'] IN [1,2,3])]"];
	[self checkCompiledJSONPathString:@"[?(@.a IN {'foo':'bar'})]" withJSONPathString:@"[?(@['a'] IN {'foo':'bar'})]"];
	[self checkCompiledJSONPathString:@"[?(@.value<'7')]" withJSONPathString:@"[?(@['value'] < '7')]"];
	[self checkCompiledJSONPathString:@"[?(@.message == 'it\\\\')]" withJSONPathString:@"[?(@['message'] == 'it\\\\')]"];
	[self checkCompiledJSONPathString:@"[?(@.message.min() > 10)]" withJSONPathString:@"[?(@['message'].min() > 10)]"];
	[self checkCompiledJSONPathString:@"[?(@.message.min()==10)]" withJSONPathString:@"[?(@['message'].min() == 10)]"];
	[self checkCompiledJSONPathString:@"[?(10 == @.message.min())]" withJSONPathString:@"[?(10 == @['message'].min())]"];
	[self checkCompiledJSONPathString:@"[?(((@)))]" withJSONPathString:@"[?(@)]"];
	[self checkCompiledJSONPathString:@"[?(@.name =~ /.*?/i)]" withJSONPathString:@"[?(@['name'] =~ /.*?/i)]"];
	[self checkCompiledJSONPathString:@"[?(@.name =~ /.*?/)]" withJSONPathString:@"[?(@['name'] =~ /.*?/)]"];
	[self checkCompiledJSONPathString:@"[?($[\"firstname\"][\"lastname\"])]" withJSONPathString:@"[?($[\"firstname\"][\"lastname\"])]"];
	[self checkCompiledJSONPathString:@"[?($[\"firstname\"].lastname)]" withJSONPathString:@"[?($[\"firstname\"]['lastname'])]"];
	[self checkCompiledJSONPathString:@"[?($[\"firstname\", \"lastname\"])]" withJSONPathString:@"[?($[\"firstname\",\"lastname\"])]"];
	[self checkCompiledJSONPathString:@"[?(((@.a && @.b || @.c)) || @.x)]" withJSONPathString:@"[?(((@['a'] && @['b']) || @['c']) || @['x'])]"];
}

- (void)test_string_quote_style_is_serialized
{
	[self checkCompiledJSONPathString:@"[?('apa' == 'apa')]" withJSONPathString:@"[?('apa' == 'apa')]"];
	[self checkCompiledJSONPathString:@"[?('apa' == \"apa\")]" withJSONPathString:@"[?('apa' == \"apa\")]"];
}

- (void)test_string_can_contain_path_chars
{
	[self checkCompiledJSONPathString:@"[?(@[')]@$)]'] == ')]@$)]')]" withJSONPathString:@"[?(@[')]@$)]'] == ')]@$)]')]"];
	[self checkCompiledJSONPathString:@"[?(@[\")]@$)]\"] == \")]@$)]\")]" withJSONPathString:@"[?(@[\")]@$)]\"] == \")]@$)]\")]"];
}

- (void)test_invalid_path_when_string_literal_is_unquoted
{
	[self checkCompileJSONPathString:@"[?(@.foo == x)]" expectedError:YES];
}

- (void)test_or_has_lower_priority_than_and
{
	[self checkCompiledJSONPathString:@"[?(@.category == 'fiction' && @.author == 'Evelyn Waugh' || @.price > 15)]"
					 withJSONPathString:@"[?((@['category'] == 'fiction' && @['author'] == 'Evelyn Waugh') || @['price'] > 15)]"];
}

- (void)test_invalid_filters_does_not_compile
{
	[self checkCompileJSONPathString:@"[?(@))]" expectedError:YES];
	[self checkCompileJSONPathString:@"[?(@ FOO 1)]" expectedError:YES];
	[self checkCompileJSONPathString:@"[?(@ || )]" expectedError:YES];
	[self checkCompileJSONPathString:@"[?(@ == 'foo )]" expectedError:YES];
	[self checkCompileJSONPathString:@"[?(@ == 1' )]" expectedError:YES];
	[self checkCompileJSONPathString:@"[?(@.foo bar == 1)]" expectedError:YES];
	[self checkCompileJSONPathString:@"[?(@.i == 5 @.i == 8)]" expectedError:YES];
	[self checkCompileJSONPathString:@"[?(!5)]" expectedError:YES];
	[self checkCompileJSONPathString:@"[?(!'foo')]" expectedError:YES];
}

- (void)test_not_exists_filter
{
	[self checkCompiledJSONPathString:@"[?(!@.foo)]" withJSONPathString:@"[?(!@['foo'])]"];
}

@end


NS_ASSUME_NONNULL_END
