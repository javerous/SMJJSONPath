/*
 * SMJConfiguration.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/Configuration.java */


#import "SMJConfiguration.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJConfiguration
*/
#pragma mark - SMJConfiguration

@implementation SMJConfiguration
{
	NSMutableSet *_options;
	NSMutableArray <id <SMJEvaluationListener>> *_listeners;
}


/*
** SMJConfiguration - Instance
*/
#pragma mark - SMJConfiguration - Instance

+ (instancetype)defaultConfiguration
{
	return [[SMJConfiguration alloc] init];
}

+ (instancetype)configurationWithOption:(SMJOption)option
{
	SMJConfiguration *configuration = [[SMJConfiguration alloc] init];
	
	[configuration addOption:option];
	
	return configuration;
}

- (instancetype)init
{
	self = [super init];
	
	if (self)
	{
		_options = [[NSMutableSet alloc] init];
		_listeners = [[NSMutableArray alloc] init];
	}
	
	return self;
}


/*
** SMJConfiguration - NSCopying
*/
#pragma mark - SMJConfiguration - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone
{
	SMJConfiguration *copy = [[SMJConfiguration allocWithZone:zone] init];
	
	copy->_options = [_options mutableCopyWithZone:zone];
	copy->_listeners = [_listeners mutableCopyWithZone:zone];
	
	return copy;
}



/*
** SMJConfiguration - Listeners
*/
#pragma mark - SMJConfiguration - Listeners

- (void)addListener:(id <SMJEvaluationListener>)listener
{
	[_listeners addObject:listener];
}

- (void)removeListener:(id <SMJEvaluationListener>)listener
{
	[_listeners removeObject:listener];
}

- (NSArray <id <SMJEvaluationListener>> *)evaluationListeners
{
	return _listeners;
}

- (void)setEvaluationListeners:(NSArray<id<SMJEvaluationListener>> *)evaluationListeners
{
	_listeners = [evaluationListeners mutableCopy];
}


/*
** SMJConfiguration - Options
*/
#pragma mark - SMJConfiguration - Options

- (BOOL)containsOption:(SMJOption)option
{
	return [_options containsObject:@(option)];
}

- (void)addOption:(SMJOption)option
{
	[_options addObject:@(option)];
}

@end


NS_ASSUME_NONNULL_END
