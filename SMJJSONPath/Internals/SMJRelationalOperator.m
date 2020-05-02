/*
 * SMJRelationalOperator.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/filter/RelationalOperator.java */


#import "SMJRelationalOperator.h"


NS_ASSUME_NONNULL_BEGIN


/*
** Types
*/
#pragma mark - Types

typedef enum SMJRelationalOperatorIndex
{
	SMJRelationalOperatorIndexGTE,
	SMJRelationalOperatorIndexLTE,
	SMJRelationalOperatorIndexEQ,

	SMJRelationalOperatorIndexTSEQ,
	SMJRelationalOperatorIndexNE,
	
	SMJRelationalOperatorIndexTSNE,
	SMJRelationalOperatorIndexLT,
	SMJRelationalOperatorIndexGT,
	SMJRelationalOperatorIndexREGEX,
	SMJRelationalOperatorIndexNIN,
	SMJRelationalOperatorIndexIN,
	SMJRelationalOperatorIndexCONTAINS,
	SMJRelationalOperatorIndexALL,
	SMJRelationalOperatorIndexSIZE,
	SMJRelationalOperatorIndexEXISTS,
	SMJRelationalOperatorIndexTYPE,
	//SMJRelationalOperatorIndexMATCHES,
	SMJRelationalOperatorIndexEMPTY,
	SMJRelationalOperatorIndexSUBSETOF,
} SMJRelationalOperatorIndex;



/*
** Globals
*/
#pragma mark - Globals

static struct {
	CFStringRef		name;
	dispatch_once_t	token;
	void			*value;
} gOperators[] = {
	{ .name = (__bridge CFStringRef)SMJRelationalOperatorGTE },
	{ .name = (__bridge CFStringRef)SMJRelationalOperatorLTE },
	{ .name = (__bridge CFStringRef)SMJRelationalOperatorEQ },
	
	{ .name = (__bridge CFStringRef)SMJRelationalOperatorTSEQ },
	{ .name = (__bridge CFStringRef)SMJRelationalOperatorNE },
	
	{ .name = (__bridge CFStringRef)SMJRelationalOperatorTSNE },
	{ .name = (__bridge CFStringRef)SMJRelationalOperatorLT },
	{ .name = (__bridge CFStringRef)SMJRelationalOperatorGT },
	{ .name = (__bridge CFStringRef)SMJRelationalOperatorREGEX },
	{ .name = (__bridge CFStringRef)SMJRelationalOperatorNIN },
	{ .name = (__bridge CFStringRef)SMJRelationalOperatorIN },
	{ .name = (__bridge CFStringRef)SMJRelationalOperatorCONTAINS },
	{ .name = (__bridge CFStringRef)SMJRelationalOperatorALL },
	{ .name = (__bridge CFStringRef)SMJRelationalOperatorSIZE },
	{ .name = (__bridge CFStringRef)SMJRelationalOperatorEXISTS },
	{ .name = (__bridge CFStringRef)SMJRelationalOperatorTYPE },
	//{ .name = (__bridge CFStringRef)SMJRelationalOperatorMATCHES },
	{ .name = (__bridge CFStringRef)SMJRelationalOperatorEMPTY },
	{ .name = (__bridge CFStringRef)SMJRelationalOperatorSUBSETOF },
	{ .name = (__bridge CFStringRef)SMJRelationalOperatorANYOF },
	{ .name = (__bridge CFStringRef)SMJRelationalOperatorNONEOF },
};
	


/*
** SMJRelationalOperator
*/
#pragma mark - SMJRelationalOperator

@implementation SMJRelationalOperator


/*
** SMJRelationalOperator - Instance
*/
#pragma mark - SMJRelationalOperator - Instance

+ (instancetype)instanceForOperator:(SMJRelationalOperatorIndex)operator
{
	dispatch_once(&(gOperators[operator].token), ^{
		gOperators[operator].value = (__bridge_retained void *)[[SMJRelationalOperator alloc] initWithOperatorString:(__bridge NSString *)(gOperators[operator].name)];
	});
	
	return (__bridge SMJRelationalOperator *)(gOperators[operator].value);
}

+ (instancetype)relationalOperatorEXISTS
{
	return [self instanceForOperator:SMJRelationalOperatorIndexEXISTS];
}

+ (nullable instancetype)relationalOperatorFromString:(NSString *)string error:(NSError **)error
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
	
	NSNumber *operator = map[string.uppercaseString];
	
	if (!operator)
	{
		if (error)
			*error = [NSError errorWithDomain:@"SMJRelationalOperatorErrorDomain" code:1 userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Filter operator %@ is not supported!", string] }];
		
		return nil;
	}
	
	return [self instanceForOperator:(SMJRelationalOperatorIndex)(operator.unsignedIntegerValue)];
	
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

- (NSString *)getOperatorString
{
	return _stringOperator;
}

@end


NS_ASSUME_NONNULL_END
