/*
 * SMJUseCaseUUIDTest.m
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

#import "SMJCommonTest.h"


NS_ASSUME_NONNULL_BEGIN


@interface SMJUseCaseUUIDTest : SMJCommonTest
{
	NSString *_jsonString;
}

@end

@implementation SMJUseCaseUUIDTest

- (void)setUp
{
	[super setUp];
	
	NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:@"uuid-test" ofType:@"json"];
	
	_jsonString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
}

- (void)test_fetch_parent_uuid_1
{
	[self checkResultForJSONString:_jsonString
					jsonPathString:@"$[?('it is the first name' IN @.items.*.name)].uuid"
					expectedResult:@[ @"8A9DEB2-D822-479D-AEF6-54A4F3FF128B" ]];
	
}

- (void)test_fetch_parent_uuid_2
{
	[self checkResultForJSONString:_jsonString
					jsonPathString:@"$[ ?( @.items[?(@.name == 'it is the first name')] SIZE 1 ) ].uuid"
					expectedResult:@[ @"8A9DEB2-D822-479D-AEF6-54A4F3FF128B" ]];
}

- (void)test_fetch_parent_uuid_3
{
	[self checkResultForJSONString:_jsonString
					jsonPathString:@"$[ ?( @.items[?(@.name =~ /second/)] SIZE 1 ) ].uuid"
					expectedResult:@[ @"8A9DEB2-D822-479D-AEF6-54A4F3FF128B" ]];
}

- (void)test_fetch_parent_uuid_4
{
	[self checkResultForJSONString:_jsonString
					jsonPathString:@"$[ ?( @.items[?(@.name =~ /second/)] EMPTY false ) ].uuid"
					expectedResult:@[ @"8A9DEB2-D822-479D-AEF6-54A4F3FF128B" ]];
}

- (void)test_fetch_all_parent_uuid
{
	[self checkResultForJSONString:_jsonString
					jsonPathString:@"$.[*].uuid"
					expectedResult:@[ @"8A9DEB2-D822-479D-AEF6-54A4F3FF128B", @"A101C1BC-C2AB-4E34-818B-AA5465EA0D90" ]];
}

- (void)test_fetch_all_child_uuid
{
	[self checkResultForJSONString:_jsonString
					jsonPathString:@"$..items..uuid"
					expectedResult:@[ @"FBECEBAF-8C62-4564-88E0-EEEA9F232459", @"F5EEB425-1B51-4AFE-92A6-0D8688AD3074", @"C3791FBE-690B-4104-8E48-E0961BB3C5F6" ]];
}

@end


NS_ASSUME_NONNULL_END
