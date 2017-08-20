/*
 * SMJValueNode.m
 *
 * Copyright 2017 Avérous Julien-Pierre
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/filter/ValueNode.java */


#import "SMJValueNode.h"

#import "SMJUtils.h"

#import "SMJPathCompiler.h"
#import "SMJPredicateContextImpl.h"


NS_ASSUME_NONNULL_BEGIN


/*
** Macros
*/
#pragma mark - Macros

#define SMSetError(Error, Code, Message, ...) \
	do { \
		if ((Error) && *(Error) == nil) {\
			NSString *___message = [NSString stringWithFormat:(Message), ## __VA_ARGS__];\
			*(Error) = [NSError errorWithDomain:@"SMJValueNodeErrorNode" code:(Code) userInfo:@{ NSLocalizedDescriptionKey : ___message }]; \
		} \
	} while (0) \


/*
** Subnodes - Private
*/
#pragma mark - Subnodes - Private

@interface SMJPathNode ()
- (nullable instancetype)initWithPathString:(NSString *)pathString existsCheck:(BOOL)existsCheck shouldExists:(BOOL)shouldExists error:(NSError **)error;
- (instancetype)initWithPath:(id <SMJPath>)path;
@end

@interface SMJJsonNode ()
- (instancetype)initWithString:(NSString *)string;
- (instancetype)initWithJsonObject:(id)jsonObject;
@end

@interface SMJPatternNode ()
- (instancetype)initWithString:(NSString *)string;
@end

@interface SMJStringNode ()
- (instancetype)initWithString:(NSString *)string escape:(BOOL)escape;
- (instancetype)initWithString:(NSString *)rawString;
@end

@interface SMJNumberNode ()
- (instancetype)initWithString:(NSString *)string;
- (instancetype)initWithNumber:(NSNumber *)number;
@end


@interface SMJBooleanNode ()
- (instancetype)initWithString:(NSString *)string;
- (instancetype)initWithBoolean:(BOOL)boolean;
@end





/*
** SMJValueNode
*/
#pragma mark - SMJValueNode

@implementation SMJValueNode

+ (SMJBooleanNode *)valueNodeTRUE
{
	static dispatch_once_t onceToken;
	static SMJBooleanNode *trueNode;
	
	dispatch_once(&onceToken, ^{
		trueNode = [[SMJBooleanNode alloc] initWithString:@"true"];
	});
	
	return trueNode;
}

+ (SMJBooleanNode *)valueNodeFALSE
{
	static dispatch_once_t onceToken;
	static SMJBooleanNode *falseNode;
	
	dispatch_once(&onceToken, ^{
		falseNode = [[SMJBooleanNode alloc] initWithString:@"false"];
	});
	
	return falseNode;
}

+ (SMJNullNode *)nullNode
{
	static dispatch_once_t onceToken;
	static SMJNullNode *nullNode;
	
	dispatch_once(&onceToken, ^{
		nullNode = [SMJNullNode new];
	});
	
	return nullNode;
}

+ (SMJJsonNode *)jsonNodeWithString:(NSString *)string
{
	return [[SMJJsonNode alloc] initWithString:string];
}

+ (SMJPatternNode *)patternNodeWithString:(NSString *)string
{
	return [[SMJPatternNode alloc] initWithString:string];
}

+ (SMJStringNode *)stringNodeWithString:(NSString *)string escape:(BOOL)escape
{
	return [[SMJStringNode alloc] initWithString:string escape:escape];
}

+ (SMJNumberNode *)numberNodeWithString:(NSString *)string
{
	return [[SMJNumberNode alloc] initWithString:string];
}

+ (SMJBooleanNode *)booleanNodeWithString:(NSString *)string
{
	if ([string isEqualToString:@"true"])
		return [self valueNodeTRUE];
	else
		return [self valueNodeFALSE];
}

+ (nullable SMJPathNode *)pathNodeWithPathString:(NSString *)pathString existsCheck:(BOOL)existsCheck shouldExists:(BOOL)shouldExists error:(NSError **)error
{
	return [[SMJPathNode alloc] initWithPathString:pathString existsCheck:existsCheck shouldExists:shouldExists error:error];
}

+ (SMJPathNode *)pathNodeWithPath:(id <SMJPath>)path
{
	return [[SMJPathNode alloc] initWithPath:path];
}

- (SMJComparisonResult)convertComparison:(NSComparisonResult)result
{
	switch (result)
	{
		case NSOrderedAscending:
			return SMJComparisonDifferLessThan;
			
		case NSOrderedSame:
			return SMJComparisonSame;
			
		case NSOrderedDescending:
			return SMJComparisonDifferGreaterThan;
	}
}

- (NSString *)stringValue
{
	NSAssert(NO, @"need to be overwritten");
	return nil;
}

- (nullable NSString *)literalValue
{
	return nil;
}

- (NSString *)typeName
{
	NSAssert(NO, @"need to be overwritten");
	return nil;
}

- (BOOL)isEqual:(SMJValueNode *)node
{
	NSAssert(NO, @"need to be overwritten");
	return NO;
}

- (SMJComparisonResult)compare:(SMJValueNode *)node
{
	NSAssert(NO, @"need to be overwritten");
	return SMJComparisonDiffer;
}

- (nullable id)underlayingObjectWithError:(NSError **)error
{
	NSAssert(NO, @"need to be overwritten");
	return nil;
}

@end




/*
** Subnodes
*/
#pragma mark - Subnodes


#pragma mark SMJPathNode

@implementation SMJPathNode
{
	NSString		*_pathString;
	id <SMJPath>	_path;
	
	BOOL _existsCheck;
	BOOL _shouldExists;
}

- (nullable instancetype)initWithPathString:(NSString *)pathString existsCheck:(BOOL)existsCheck shouldExists:(BOOL)shouldExists error:(NSError **)error
{
	self = [super init];
	
	if (self)
	{
		_path = [SMJPathCompiler compilePathString:pathString error:error];
		
		if (!_path)
			return nil;
		
		_pathString = [pathString copy];
		_existsCheck = existsCheck;
		_shouldExists = shouldExists;
	}
	
	return self;
}

- (instancetype)initWithPath:(id <SMJPath>)path
{
	self = [super init];
	
	if (self)
	{
		_path = path;
		_pathString = [path stringValue];
	}
	
	return self;
}


- (instancetype)initWithPathString:(NSString *)pathString prebuiltPath:(id <SMJPath>)path existsCheck:(BOOL)existsCheck shouldExists:(BOOL)shouldExists
{
	self = [super init];
	
	if (self)
	{
		_pathString = [pathString copy];
		_path = path;
		_existsCheck = existsCheck;
		_shouldExists = shouldExists;
	}
	
	return self;
}

- (instancetype)copyWithExistsCheckAndShouldExists:(BOOL)shouldExists
{
	return [[SMJPathNode alloc] initWithPathString:_pathString prebuiltPath:_path existsCheck:YES shouldExists:shouldExists];
}

- (BOOL)shouldExists
{
	return _shouldExists;
}

- (BOOL)isExistsCheck
{
	return _existsCheck;
}

- (nullable SMJPathNode *)pathNodeWithError:(NSError **)error
{
	return self;
}

- (nullable SMJValueNode *)evaluate:(id <SMJPredicateContext>)context error:(NSError **)error
{
	if (self.existsCheck)
	{
		SMJConfiguration *configuration = [context.configuration copy];
		
		[configuration addOption:SMJOptionRequireProperties];
		
		id <SMJEvaluationContext> evaluationContext = [_path evaluateJsonObject:context.jsonObject rootJsonObject:context.rootJsonObject configuration:configuration error:nil];
		
		if (!evaluationContext)
			return [SMJValueNode valueNodeFALSE];
		
		id value = [evaluationContext jsonObjectWithError:nil];
		
		if (value)
			return [SMJValueNode valueNodeTRUE];
		else
			return [SMJValueNode valueNodeFALSE];
	}
	else
	{
		id object = nil;
		
		if ([context isKindOfClass:[SMJPredicateContextImpl class]])
		{
			//This will use cache for root ($) queries
			SMJPredicateContextImpl *ctxi = (SMJPredicateContextImpl *)context;
			
			object = [ctxi evaluatePath:_path error:error];
		}
		else
		{
			id doc = _path.rootPath ? context.rootJsonObject : context.jsonObject;
			id <SMJEvaluationContext> evaluationContext = [_path evaluateJsonObject:doc rootJsonObject:context.rootJsonObject configuration:context.configuration error:error];
			
			object = [evaluationContext jsonObjectWithError: error];
		}
		
		if (!object)
			return nil;
		
		if ([object isKindOfClass:[NSNumber class]])
		{
			NSNumber *number = object;
			
			if (strcmp([number objCType], @encode(BOOL)) == 0)
				return [[SMJBooleanNode alloc] initWithBoolean:[number boolValue]];
			else
				return [[SMJNumberNode alloc] initWithNumber:number];
		}
		else if ([object isKindOfClass:[NSString class]])
		{
			return [[SMJStringNode alloc] initWithString:object];
		}
		else if ([object isKindOfClass:[NSNull class]])
		{
			return [SMJNullNode new];
		}
		else if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]])
		{
			return [[SMJJsonNode alloc] initWithJsonObject:object];
		}
		else
		{
			SMSetError(error, 1, @"Could not convert %@ to a ValueNode", [object class]);
			return nil;
		}
	}
	
	return nil;
}

- (NSString *)stringValue
{
	if (_existsCheck && !_shouldExists)
		return [SMJUtils stringByConcatenatingStrings:@[ @"!", [_path stringValue] ]];
	else
		return [_path stringValue];
}

- (NSString *)typeName
{
	return @"path";
}

- (BOOL)isEqual:(SMJPathNode *)node
{
	if ([node isKindOfClass:[SMJPathNode class]] == NO)
		return NO;
	
	return [_pathString isEqual:node->_pathString];
}

- (SMJComparisonResult)compare:(SMJValueNode *)node
{
	if ([node isKindOfClass:[SMJPathNode class]] == NO)
		return SMJComparisonDiffer;
	
	if ([_pathString isEqual:((SMJPathNode *)node)->_pathString])
		return SMJComparisonSame;
	else
		return SMJComparisonDiffer;
}

- (id <SMJPath>)underlayingObjectWithError:(NSError **)error
{
	return _path;
}

@end


#pragma mark SMJNullNode

@implementation SMJNullNode

- (NSString *)stringValue
{
	return @"null";
}

- (NSString *)typeName
{
	return @"null";
}

- (BOOL)isEqual:(SMJNullNode *)node
{
	return ([node isKindOfClass:[SMJNullNode class]]);
		return NO;
}

- (SMJComparisonResult)compare:(SMJValueNode *)node
{
	if ([node isKindOfClass:[SMJNullNode class]] == NO)
		return SMJComparisonDiffer;
	
	return SMJComparisonSame;
}

- (NSNull *)underlayingObjectWithError:(NSError **)error
{
	return [NSNull null];
}

@end


#pragma mark SMJJsonNode

@implementation SMJJsonNode
{
	NSString *_jsonString;
	
	BOOL	_done;
	id		_json;
	NSError	*_error;
}

- (instancetype)initWithString:(NSString *)string
{
	self = [super init];
	
	if (self)
	{
		_jsonString = [string copy];
	}
	
	return self;
}

- (instancetype)initWithJsonObject:(id)jsonObject
{
	self = [super init];
	
	if (self)
	{
		_json = jsonObject;
		_done = YES;
	}
	
	return self;
}

- (NSString *)stringValue
{
	if (!_jsonString)
	{
		NSError	*lerror = nil;
		NSData	*jsonData = [NSJSONSerialization dataWithJSONObject:_json options:NSJSONWritingPrettyPrinted error:&lerror];
		
		if (jsonData)
			_jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	}
	
	if (!_jsonString)
		return @"null";
	
	return _jsonString;
}

- (NSString *)typeName
{
	return @"json";
}

- (BOOL)isEqual:(SMJJsonNode *)node
{
	if ([node isKindOfClass:[SMJJsonNode class]] == NO)
		return NO;
	
	id selfObject = [self underlayingObjectWithError:nil];
	id nodeObject = [node underlayingObjectWithError:nil];
	
	if (!selfObject || !nodeObject)
		return NO;
	
	return [selfObject isEqual:nodeObject];
}

- (SMJComparisonResult)compare:(SMJValueNode *)node
{
	if ([node isKindOfClass:[SMJJsonNode class]] == NO)
		return SMJComparisonDiffer;
	
	id jsonObject1 = [self underlayingObjectWithError:nil];
	id jsonObject2 = [node underlayingObjectWithError:nil];
	
	if ([jsonObject1 respondsToSelector:@selector(compare:)])
	{
		NSComparisonResult result = [(NSNumber *)jsonObject1 compare:jsonObject2]; // NSNumber is just to shut down clang++
		
		return [self convertComparison:result];
	}
	else
	{
		if ([jsonObject1 isEqual:jsonObject2])
			return SMJComparisonSame;
		else
			return SMJComparisonDiffer;
	}
}

- (nullable id)underlayingObjectWithError:(NSError **)error
{
	if (!_done)
	{
		NSError *lerror = nil;
		
		_json = [NSJSONSerialization JSONObjectWithData:[_jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&lerror];
		_error = lerror;
		_done = YES;
	}
	
	if (error)
		*error = _error;
		
	return _json;
}

@end


#pragma mark SMJPatternNode

@implementation SMJPatternNode
{
	NSString *_string;
	NSString *_pattern;
	NSRegularExpression *_compiledPattern;
}

- (instancetype)initWithString:(NSString *)string
{
	self = [super init];
	
	if (self)
	{
		NSUInteger begin = [string rangeOfString:@"/"].location;
		NSUInteger end =  [string rangeOfString:@"/" options:NSBackwardsSearch].location;
		
		if (begin == NSNotFound)
			begin = 0;
		
		if (end == NSNotFound)
			end = string.length - 1;
		
		NSRegularExpressionOptions options = 0;
		
		options |= [string hasSuffix:@"/i"] ? NSRegularExpressionCaseInsensitive : 0;
		
		_string = [string copy];
		_pattern = [string substringWithRange:NSMakeRange(begin + 1, end - begin - 1)];
		_compiledPattern = [NSRegularExpression regularExpressionWithPattern:_pattern options:options error:nil];
	}
	
	return self;
}

- (NSString *)stringValue;
{
	return _string;
}

- (NSString *)typeName
{
	return @"pattern";
}

- (BOOL)isEqual:(SMJPatternNode *)node
{
	if ([node isKindOfClass:[SMJPatternNode class]] == NO)
		return NO;
	
	return [_string isEqual:node->_string];
}

- (SMJComparisonResult)compare:(SMJValueNode *)node
{
	if ([node isKindOfClass:[SMJPatternNode class]] == NO)
		return SMJComparisonDiffer;
	
	NSRegularExpression *regExp1 = [self underlayingObjectWithError:nil];
	NSRegularExpression *regExp2 = [node underlayingObjectWithError:nil];
	
	if ([regExp1 isEqual:regExp2])
		return SMJComparisonSame;
	else
		return SMJComparisonDiffer;
}

- (NSRegularExpression *)underlayingObjectWithError:(NSError **)error
{
	return _compiledPattern;
}

@end


#pragma mark SMJStringNode

@implementation SMJStringNode
{
	NSString *_string;
	BOOL _useSingleQuote;
}

- (instancetype)initWithString:(NSString *)string escape:(BOOL)escape
{
	self = [super init];
	
	if (self)
	{
		_useSingleQuote = YES;
		
		if (string.length > 1)
		{
			unichar open = [string characterAtIndex:0];
			unichar close = [string characterAtIndex:string.length - 1];
			
			if (open == '\'' && close == '\'')
			{
				string = [string substringWithRange:NSMakeRange(1, string.length - 2)];
			}
			else if (open == '"' && close == '"')
			{
				string = [string substringWithRange:NSMakeRange(1, string.length - 2)];
				_useSingleQuote = NO;
			}
		}
		
		_string = escape ? [SMJUtils stringByUnescapingString:string] : [string copy];
	}
	
	return self;
}

- (instancetype)initWithString:(NSString *)rawString
{
	self = [super init];
	
	if (self)
	{
		_string = [rawString copy];
	}
	
	return self;
}

- (NSString *)stringValue
{
	NSString *quote = _useSingleQuote ? @"'" : @"\"";
	
	return [NSString stringWithFormat:@"%@%@%@", quote, [SMJUtils stringByEscapingString:_string escapeSingleQuote:YES], quote];
}

- (nullable NSString *)literalValue
{
	return _string;
}

- (NSString *)typeName
{
	return @"string";
}

- (BOOL)isEqual:(SMJStringNode *)node
{
	if ([node isKindOfClass:[SMJStringNode class]] == NO)
		return NO;
	
	return [_string isEqual:node->_string];
}

- (SMJComparisonResult)compare:(SMJValueNode *)node
{
	NSString *string1 = [self underlayingObjectWithError:nil];
	
	if ([node isKindOfClass:[SMJNumberNode class]])
	{
		NSNumber *number1 = [SMJUtils numberWithString:string1];
		NSNumber *number2 = [(SMJNumberNode *)node underlayingObjectWithError:nil];
		
		if (number1)
			return [self convertComparison:[number1 compare:number2]];
		else
			return [self convertComparison:[string1 compare:[number2 stringValue]]];
	}
	else if ([node isKindOfClass:[SMJStringNode class]])
	{
		NSNumber *number1 = [SMJUtils numberWithString:string1];
		
		NSString *string2 = [(SMJStringNode *)node underlayingObjectWithError:nil];
		NSNumber *number2 = [SMJUtils numberWithString:string2];
		
		if (number1 && number2)
			return [self convertComparison:[number1 compare:number2]];
		else
			return [self convertComparison:[string1 compare:string2]];
	}
	
	return SMJComparisonDiffer;
}

- (NSString *)underlayingObjectWithError:(NSError **)error
{
	return _string;
}

@end


#pragma mark SMJNumberNode

@implementation SMJNumberNode
{
	NSNumber *_value;
}

- (instancetype)initWithString:(NSString *)string
{
	self = [super init];
	
	if (self)
	{
		_value = [SMJUtils numberWithString:string];
		
		if (!_value)
			_value = @0;
	}
	
	return self;
}

- (instancetype)initWithNumber:(NSNumber *)number
{
	self = [super init];
	
	if (self)
	{
		_value = number;
	}
	
	return self;
}

- (NSString *)stringValue
{
	return [_value stringValue];
}

- (nullable NSString *)literalValue
{
	return [self stringValue];
}

- (NSString *)typeName
{
	return @"number";
}

- (BOOL)isEqual:(SMJNumberNode *)node
{
	if ([node isKindOfClass:[SMJNumberNode class]] == NO)
		return NO;
	
	return [_value isEqual:node->_value];
}

- (SMJComparisonResult)compare:(SMJValueNode *)node
{
	NSNumber *number1 = [(SMJNumberNode *)self underlayingObjectWithError:nil];
	
	if ([node isKindOfClass:[SMJNumberNode class]])
	{
		NSNumber *number2 = [(SMJNumberNode *)node underlayingObjectWithError:nil];
		
		return [self convertComparison:[number1 compare:number2]];
	}
	else if ([node isKindOfClass:[SMJStringNode class]])
	{
		NSString *string2 = [(SMJStringNode *)node underlayingObjectWithError:nil];
		NSNumber *number2 = [SMJUtils numberWithString:string2];
		
		if (number2)
			return [self convertComparison:[number1 compare:number2]];
		else
			return [self convertComparison:[[number1 stringValue] compare:string2]];
	}
	
	return SMJComparisonDiffer;
}

- (NSNumber *)underlayingObjectWithError:(NSError **)error
{
	return _value;
}

@end


#pragma mark SMJBooleanNode

@implementation SMJBooleanNode
{
	BOOL _value;
}

- (instancetype)initWithString:(NSString *)string
{
	self = [super init];
	
	if (self)
	{
		_value = [string isEqualToString:@"true"];
	}
	
	return self;
}

- (instancetype)initWithBoolean:(BOOL)boolean
{
	self = [super init];
	
	if (self)
	{
		_value = boolean;
	}
	
	return self;
}

- (NSString *)stringValue;
{
	if (_value)
		return @"true";
	else
		return @"false";
}

- (nullable NSString *)literalValue
{
	return [self stringValue];
}

- (NSString *)typeName
{
	return @"bool";
}

- (BOOL)isEqual:(SMJBooleanNode *)node
{
	if ([node isKindOfClass:[SMJBooleanNode class]] == NO)
		return NO;
	
	return _value == node->_value;
}

- (SMJComparisonResult)compare:(SMJValueNode *)node
{
	NSNumber *bool1 = [self underlayingObjectWithError:nil];
	NSNumber *bool2 = [node underlayingObjectWithError:nil];
	
	if (bool1.boolValue == bool2.boolValue)
		return SMJComparisonSame;
	else
		return SMJComparisonDiffer;
}

- (NSNumber *)underlayingObjectWithError:(NSError **)error
{
	return @(_value);
}

@end


NS_ASSUME_NONNULL_END

