/*
 * SMJComplianceTest.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/test/java/com/jayway/jsonpath/old/ComplianceTest.java */


#import <XCTest/XCTest.h>

#import "SMJBaseTest.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJComplianceTest
*/
#pragma mark - SMJComplianceTest

@interface SMJComplianceTest : SMJBaseTest
@end

@implementation SMJComplianceTest

- (void)test_one
{
	NSString *json = @"{ \"a\": \"a\",\n"
	@"           \"b\": \"b\",\n"
	@"           \"c d\": \"e\" \n"
	@"         }";
	
	[self checkResultForJSONString:json jsonPathString:@"$.a" expectedResult:@"a"];
	[self checkResultForJSONString:json jsonPathString:@"$.*" expectedResult:@[ @"a", @"b", @"e" ]];
	[self checkResultForJSONString:json jsonPathString:@"$[*]" expectedResult:@[ @"a", @"b", @"e" ]];
	[self checkResultForJSONString:json jsonPathString:@"$['a']" expectedResult:@"a"];
	[self checkResultForJSONString:json jsonPathString:@"$.['c d']" expectedResult:@"e"];
	[self checkResultForJSONString:json jsonPathString:@"$[*]" expectedResult:@[ @"a", @"b", @"e" ]];
}

- (void)test_two
{
	NSString *json = @"[ 1, \"2\", 3.14, true, null ]";
	
	[self checkResultForJSONString:json jsonPathString:@"$[0]" expectedResult:@1];
	[self checkResultForJSONString:json jsonPathString:@"$[4]" expectedResult:[NSNull null]];
	[self checkResultForJSONString:json jsonPathString:@"$[*]" expectedResult:@[ @1, @"2", @3.14, @YES, [NSNull null] ]];

	[self checkResultForJSONString:json jsonPathString:@"$[-1:]" expectedResult:@[ [NSNull null] ]];
}

- (void)test_three
{
	NSString *json = @"{ \"points\": [\n"
	@"             { \"id\": \"i1\", \"x\":  4, \"y\": -5 },\n"
	@"             { \"id\": \"i2\", \"x\": -2, \"y\":  2, \"z\": 1 },\n"
	@"             { \"id\": \"i3\", \"x\":  8, \"y\":  3 },\n"
	@"             { \"id\": \"i4\", \"x\": -6, \"y\": -1 },\n"
	@"             { \"id\": \"i5\", \"x\":  0, \"y\":  2, \"z\": 1 },\n"
	@"             { \"id\": \"i6\", \"x\":  1, \"y\":  4 }\n"
	@"           ]\n"
	@"         }";
	
	[self checkResultForJSONString:json
					jsonPathString:@"$.points[1]"
					expectedResult:@{ @"id" : @"i2", @"x" : @-2, @"y" : @2, @"z" : @1 }
	 ];
	
	[self checkResultForJSONString:json jsonPathString:@"$.points[4].x" expectedResult:@0];
	[self checkResultForJSONString:json jsonPathString:@"$.points[?(@.id == 'i4')].x" expectedResult:@[ @-6 ]];
	[self checkResultForJSONString:json jsonPathString:@"$.points[*].x" expectedResult:@[ @4, @-2, @8, @-6, @0, @1 ]];
	[self checkResultForJSONString:json jsonPathString:@"$.points[?(@.z)].id" expectedResult:@[ @"i2", @"i5" ]];
}

- (void)test_four
{
	NSString *json = @"{ \"menu\": {\n"
	@"                 \"header\": \"SVG Viewer\",\n"
	@"                 \"items\": [\n"
	@"                     {\"id\": \"Open\"},\n"
	@"                     {\"id\": \"OpenNew\", \"label\": \"Open New\"},\n"
	@"                     null,\n"
	@"                     {\"id\": \"ZoomIn\", \"label\": \"Zoom In\"},\n"
	@"                     {\"id\": \"ZoomOut\", \"label\": \"Zoom Out\"},\n"
	@"                     {\"id\": \"OriginalView\", \"label\": \"Original View\"},\n"
	@"                     null,\n"
	@"                     {\"id\": \"Quality\"},\n"
	@"                     {\"id\": \"Pause\"},\n"
	@"                     {\"id\": \"Mute\"},\n"
	@"                     null,\n"
	@"                     {\"id\": \"Find\", \"label\": \"Find...\"},\n"
	@"                     {\"id\": \"FindAgain\", \"label\": \"Find Again\"},\n"
	@"                     {\"id\": \"Copy\"},\n"
	@"                     {\"id\": \"CopyAgain\", \"label\": \"Copy Again\"},\n"
	@"                     {\"id\": \"CopySVG\", \"label\": \"Copy SVG\"},\n"
	@"                     {\"id\": \"ViewSVG\", \"label\": \"View SVG\"},\n"
	@"                     {\"id\": \"ViewSource\", \"label\": \"View Source\"},\n"
	@"                     {\"id\": \"SaveAs\", \"label\": \"Save As\"},\n"
	@"                     null,\n"
	@"                     {\"id\": \"Help\"},\n"
	@"                     {\"id\": \"About\", \"label\": \"About Adobe CVG Viewer...\"}\n"
	@"                 ]\n"
	@"               }\n"
	@"             }";
	
	[self checkResultForJSONString:json jsonPathString:@"$.menu.items[?(@)]" expectedError:NO];
	
	[self checkResultForJSONString:json jsonPathString:@"$.menu.items[?(@.id == 'ViewSVG')].id" expectedResult:@[ @"ViewSVG" ]];

	[self checkResultForJSONString:json jsonPathString:@"$.menu.items[?(@ && @.id == 'ViewSVG')].id" expectedResult:@[ @"ViewSVG" ]];

	[self checkResultForJSONString:json jsonPathString:@"$.menu.items[?(@ && @.id && !@.label)].id" expectedResult:@[ @"Open", @"Quality", @"Pause", @"Mute", @"Copy", @"Help" ]];
}

@end


NS_ASSUME_NONNULL_END
