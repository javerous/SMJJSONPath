/*
 * SMJLogicalOperator.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/filter/LogicalOperator.java */


#import "SMJLogicalOperator.h"


NS_ASSUME_NONNULL_BEGIN


/*
** Types
*/
#pragma mark - Types

typedef enum SMJLogicalOperatorIndex
{
	SMJLogicalOperatorIndexAND,
	SMJLogicalOperatorIndexOR,
	SMJLogicalOperatorIndexNOT,
} SMJLogicalOperatorIndex;



/*
** Globals
*/
#pragma mark - Globals

static struct {
	CFStringRef		name;
	dispatch_once_t	token;
	void			*value;
} gOperators[] = {
	{ .name = (__bridge CFStringRef)SMJLogicalOperatorAND },
	{ .name = (__bridge CFStringRef)SMJLogicalOperatorOR },
	{ .name = (__bridge CFStringRef)SMJLogicalOperatorNOT },
};



/*
** SMJLogicalOperator
*/
#pragma mark - SMJLogicalOperator

@implementation SMJLogicalOperator


/*
** SMJLogicalOperator - Instance
*/
#pragma mark - SMJLogicalOperator - Instance

+ (instancetype)instanceForOperator:(SMJLogicalOperatorIndex)operator
{
	dispatch_once(&(gOperators[operator].token), ^{
		gOperators[operator].value = (__bridge_retained void *)[[SMJLogicalOperator alloc] initWithOperatorString:(__bridge NSString *)(gOperators[operator].name)];
	});
	
	return (__bridge SMJLogicalOperator *)(gOperators[operator].value);
}

+ (SMJLogicalOperator *)logicalOperatorAND
{
	return [self instanceForOperator:SMJLogicalOperatorIndexAND];
}

+ (SMJLogicalOperator *)logicalOperatorNOT
{
	return [self instanceForOperator:SMJLogicalOperatorIndexNOT];
}

+ (SMJLogicalOperator *)logicalOperatorOR
{
	return [self instanceForOperator:SMJLogicalOperatorIndexOR];
}

+ (nullable instancetype)logicalOperatorFromString:(NSString *)string error:(NSError **)error
{
	static dispatch_once_t		onceToken;
	static NSMutableDictionary	*map;
	
	dispatch_once(&onceToken, ^{
		
		map = [[NSMutableDictionary alloc] init];
		
		for (NSUInteger i = 0; i < sizeof(gOperators) / sizeof(gOperators[0]); i++)
		{
			NSString *name = (__bridge NSString *)(gOperators[i].name);
			
			map[name] = @(i);
		}
	});
	
	NSNumber *operator = map[string];
	
	if (!operator)
	{
		if (error)
			*error = [NSError errorWithDomain:@"SMJLogicalOperatorErrorDomain" code:1 userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Failed to parse operator %@", string] }];
		
		return nil;
	}
	
	return [self instanceForOperator:(SMJLogicalOperatorIndex)(operator.unsignedIntegerValue)];
}

- (instancetype)initWithOperatorString:(NSString *)operatorString
{
	self = [super init];
	
	if (self)
	{
		_stringOperator = [operatorString copy];
	}
	
	return self;
}

@end


NS_ASSUME_NONNULL_END
