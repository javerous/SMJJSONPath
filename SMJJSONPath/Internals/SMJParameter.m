/*
 * SMJParameter.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/function/Parameter.java */


#import "SMJParameter.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJParameter
*/
#pragma mark - SMJParameter

@implementation SMJParameter
{
	id _value;
}


/*
** SMJParameter - Instance
*/
#pragma mark - SMJParameter - Instance

- (instancetype)initWithJSON:(NSString *)json
{
	self = [super init];
	
	if (self)
	{
		_jsonString = [json copy];
		_type = SMJParamTypeJSON;
	}
	
	return self;
}

- (instancetype)initWithPath:(id <SMJPath>)path
{
	self = [super init];
	
	if (self)
	{
		_path = path;
		_type = SMJParamTypePath;
	}
	
	return self;
}


/*
** SMJParameter - Properties
*/
#pragma mark - SMJParameter - Properties

- (nullable id)valueWithError:(NSError **)error
{
	if (_value)
		return _value;
	
	if (_lateBinding)
		_value = _lateBinding(self, error);
	
	return _value;
}


/*
** SMJParameter - Tools
*/
#pragma mark - SMJParameter - Tools

+ (nullable NSArray *)listWithParameters:(NSArray <SMJParameter *> *)parameters itemsClass:(Class)resultClass error:(NSError **)error
{
	NSMutableArray *values = [NSMutableArray new];
	
	void (^handleValue)(id obj) = ^(id obj) {
		
		if ([obj isKindOfClass:resultClass])
			[values addObject:obj];
		else if ([resultClass isSubclassOfClass:[NSString class]])
		{
			if ([obj respondsToSelector:@selector(stringValue)])
				[values addObject:[obj stringValue]];
			else
				[values addObject:[obj description]];
		}
	};
	
	for (SMJParameter *param in parameters)
	{
		id value = [param valueWithError:error];
		
		if (!value)
			return nil;
		
		if ([value isKindOfClass:[NSArray class]])
		{
			NSArray *array = value;
			
			for (id obj in array)
				handleValue(obj);
		}
		else
		{
			handleValue(value);
		}
	}
	
	return values;
}

@end


NS_ASSUME_NONNULL_END
