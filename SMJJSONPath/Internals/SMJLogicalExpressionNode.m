/*
 * SMJLogicalExpressionNode.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/filter/LogicalExpressionNode.java */


#import "SMJLogicalExpressionNode.h"

#import "SMJLogicalOperator.h"

#import "SMJUtils.h"


NS_ASSUME_NONNULL_BEGIN


/*
** SMJLogicalExpressionNode
*/
#pragma mark - SMJLogicalExpressionNode

@implementation SMJLogicalExpressionNode
{
	NSMutableArray <SMJExpressionNode *> *_chain;
	SMJLogicalOperator *_operator;
}


/*
** SMJLogicalExpressionNode - Instance
*/
#pragma mark - SMJLogicalExpressionNode - Instance

- (instancetype)initWithOperator:(SMJLogicalOperator *)operator nodes:(NSArray <SMJExpressionNode *> *)nodes
{
	self = [super init];
	
	if (self)
	{
		_operator = operator;
		
		_chain = [NSMutableArray array];
		
		if (nodes.count)
			[_chain addObjectsFromArray:nodes];
	}
	
	return self;
}

+ (instancetype)logicalNotWithExpressionNode:(SMJExpressionNode *)node
{
	return [[SMJLogicalExpressionNode alloc] initWithOperator:[SMJLogicalOperator logicalOperatorNOT] nodes:@[ node ]];
}

+ (instancetype)logicalOrWithLeftExpressionNode:(SMJExpressionNode *)leftNode rightExpressionNode:(SMJExpressionNode *)rigthNode
{
	return [[SMJLogicalExpressionNode alloc] initWithOperator:[SMJLogicalOperator logicalOperatorOR] nodes:@[ leftNode, rigthNode ]];

}

+ (instancetype)logicalOrWithExpressionNodes:(NSArray <SMJExpressionNode *> *)nodes
{
	return [[SMJLogicalExpressionNode alloc] initWithOperator:[SMJLogicalOperator logicalOperatorOR] nodes:nodes];

}

+ (instancetype)logicalAndWithLeftExpressionNode:(SMJExpressionNode *)leftNode rightExpressionNode:(SMJExpressionNode *)rigthNode
{
	return [[SMJLogicalExpressionNode alloc] initWithOperator:[SMJLogicalOperator logicalOperatorAND] nodes:@[ leftNode, rigthNode ]];

}

+ (instancetype)logicalAndWithExpressionNodes:(NSArray <SMJExpressionNode *> *)nodes
{
	return [[SMJLogicalExpressionNode alloc] initWithOperator:[SMJLogicalOperator logicalOperatorAND] nodes:nodes];
}


/*
** SMJLogicalExpressionNode - SMJPredicate
*/
#pragma mark - SMJLogicalExpressionNode - SMJPredicate

- (SMJPredicateApply)applyWithContext:(id <SMJPredicateContext>)context error:(NSError **)error
{
	if (_operator == [SMJLogicalOperator logicalOperatorOR])
	{
		for (SMJExpressionNode *expression in _chain)
		{
			SMJPredicateApply result = [expression applyWithContext:context error:error];
			
			if (result == SMJPredicateApplyError)
				return SMJPredicateApplyError;
			else if (result == SMJPredicateApplyTrue)
				return SMJPredicateApplyTrue;
		}
		
		return SMJPredicateApplyFalse;
	}
	else if (_operator == [SMJLogicalOperator logicalOperatorAND])
	{
		for (SMJExpressionNode *expression in _chain)
		{
			SMJPredicateApply result = [expression applyWithContext:context error:error];

			if (result == SMJPredicateApplyError)
				return SMJPredicateApplyError;
			else if (result == SMJPredicateApplyFalse)
				return SMJPredicateApplyFalse;
		}
		
		return SMJPredicateApplyTrue;
	}
	else
	{
		SMJExpressionNode *expression = _chain[0];
		SMJPredicateApply result = [expression applyWithContext:context error:error];

		if (result == SMJPredicateApplyError)
			return SMJPredicateApplyError;
		
		if (result == SMJPredicateApplyFalse)
			return SMJPredicateApplyTrue;
		else
			return SMJPredicateApplyFalse;
	}
}

- (NSString *)stringValue
{
	NSMutableString		*result = [[NSMutableString alloc] init];
	NSString			*delimiter = [NSString stringWithFormat:@" %@ ", _operator.stringOperator];
	
	[result appendString:@"("];
	
	[_chain enumerateObjectsUsingBlock:^(SMJExpressionNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		
		if (idx > 0)
			[result appendString:delimiter];
		
		[result appendString:[obj stringValue]];
	}];
	
	[result appendString:@")"];

	return result;
}

@end


NS_ASSUME_NONNULL_END
