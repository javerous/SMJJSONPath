/*
 * SMJPathFunctionFactory.m
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/function/PathFunctionFactory.java */


#import "SMJPathFunctionFactory.h"

#import "SMJUtils.h"


NS_ASSUME_NONNULL_BEGIN


/*
** Macros
*/
#pragma mark - Macros

#define SMSetError(Error, Code, Message, ...) \
	do { \
		if ((Error) && *(Error) == nil) {\
			NSString *___message = [NSString stringWithFormat:(Message), ## __VA_ARGS__];\
			*(Error) = [NSError errorWithDomain:@"SMJPathFunctionErrorDomain" code:(Code) userInfo:@{ NSLocalizedDescriptionKey : ___message }]; \
		} \
	} while (0) \



/*
** SMJAbstractAggregation - Interface
*/
#pragma mark - SMJAbstractAggregation - Interface

@interface SMJAbstractAggregation : NSObject <SMJPathFunction>

/**
 * Defines the next value in the array to the mathmatical function
 *
 * @param value
 *      The numerical value to process next
 */

- (void)handleNumber:(NSNumber *)value; // To be overwritten

/**
 * Obtains the value generated via the series of next value calls
 *
 * @return
 *      A numerical answer based on the input value provided
 */
@property (readonly) NSNumber *result; // To be overwritten

@end



/*
** Functions - Interface
*/
#pragma mark - Functions - Interface

@interface SMJAverageFunction : SMJAbstractAggregation
@end

@interface SMJStandardDeviationFunction : SMJAbstractAggregation
@end

@interface SMJSumFunction : SMJAbstractAggregation
@end

@interface SMJMinFunction : SMJAbstractAggregation
@end

@interface SMJMaxFunction : SMJAbstractAggregation
@end

@interface SMJConcatenateFunction : NSObject <SMJPathFunction>
@end

@interface SMJLengthFunction : NSObject <SMJPathFunction>
@end

@interface SMJAppendFunction : NSObject <SMJPathFunction>
@end



/*
** SMJPathFunctionFactory
*/
#pragma mark - SMJPathFunctionFactory

@implementation SMJPathFunctionFactory

+ (nullable id <SMJPathFunction>)pathFunctionForName:(NSString *)name error:(NSError **)error
{
	// Functions list.
	static dispatch_once_t onceToken;
	static NSDictionary <NSString *, Class> *functions;
	
	dispatch_once(&onceToken, ^{
		functions = @{
		  // Math Functions
		  @"avg" 	: SMJAverageFunction.class,
		  @"stddev"	: SMJStandardDeviationFunction.class,
		  @"sum" 	: SMJSumFunction.class,
		  @"min" 	: SMJMinFunction.class,
		  @"max" 	: SMJMaxFunction.class,
		  
		  // Text Functions
		  @"concat" : SMJConcatenateFunction.class,
		  
		  // JSON Entity Functions
		  @"length" : SMJLengthFunction.class,
		  @"size" 	: SMJLengthFunction.class,
		  @"append" : SMJAppendFunction.class
	  };
	});
	
	// Search request functions.
	Class class = functions[name];
	
	if (!class)
	{
		SMSetError(error, 1, @"Function with name: %@ does not exist.", name);
		return nil;
	}
	
	// Return instance.
	return [class new];
}

@end



/*
** SMJAbstractAggregation
*/
#pragma mark - SMJAbstractAggregation

@implementation SMJAbstractAggregation

- (void)handleNumber:(NSNumber *)value
{
	NSAssert(NO, @"need to be overwritten");
}

- (NSNumber *)result
{
	NSAssert(NO, @"need to be overwritten");
	return (NSNumber *)nil;
}

- (nullable id)invokeWithCurrentPathString:(NSString *)currentPath parentPath:(SMJPathRef *)parent jsonObject:(id)jsonObject evaluationContext:(id <SMJEvaluationContext>)ctx parameters:(nullable NSArray <SMJParameter *> *)parameters error:(NSError **)error
{
	// Helper.
	__block NSUInteger count = 0;
	
	void (^handleEntry)(id) = ^(id entry) {
		
		if ([entry isKindOfClass:[NSNumber class]] == NO)
			return;
		
		[self handleNumber:entry];
		count++;
	};
	
	// Enumerate object.
	if ([jsonObject isKindOfClass:[NSArray class]])
	{
		NSArray *array = jsonObject;
		
		[array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			handleEntry(obj);
		}];
	}

	// Enumerate parameters.
	NSArray *list = [SMJParameter listWithParameters:parameters itemsClass:[NSNumber class] error:error];
	
	if (!list)
		return nil;
	
	for (NSNumber *number in list)
		handleEntry(number);

	if (count != 0)
		return self.result;
	
	// Fall back.
	SMSetError(error, 2, @"Aggregation function attempted to calculate value using empty array");
	return nil;
}

@end



/*
** Functions
*/
#pragma mark - Functions

#pragma mark SMJAverageFunction

@implementation SMJAverageFunction
{
	double _summation;
	double _count;
}

- (void)handleNumber:(NSNumber *)value
{
	_count++;
	_summation += value.doubleValue;
}

- (NSNumber *)result
{
	if (_count != 0.0)
		return @(_summation / _count);

	return @(0.0);
}

@end


#pragma mark SMJStandardDeviationFunction

@implementation SMJStandardDeviationFunction
{
	double _sumSq;
	double _sum;
	double _count;
}

- (void)handleNumber:(NSNumber *)value
{
	_sum += value.doubleValue;
	_sumSq += value.doubleValue * value.doubleValue;
	_count++;
}

- (NSNumber *)result
{
	 return @(sqrt((_sumSq / _count) - (_sum * _sum / _count / _count)));
}

@end


#pragma mark SMJSumFunction

@implementation SMJSumFunction
{
	double _summation;
}

- (void)handleNumber:(NSNumber *)value
{
	_summation += value.doubleValue;
}

- (NSNumber *)result
{
	return @(_summation);
}

@end


#pragma mark SMJMinFunction

@implementation SMJMinFunction
{
	BOOL	_set;
	double	_min;
}

- (void)handleNumber:(NSNumber *)value
{
	if (!_set)
	{
		_min = value.doubleValue;
		_set = YES;
	}
	else
	{
		if (value.doubleValue < _min)
			_min = value.doubleValue;
	}
}

- (NSNumber *)result
{
	return @(_min);
}

@end


#pragma mark SMJMaxFunction

@implementation SMJMaxFunction
{
	BOOL	_set;
	double	_max;
}

- (void)handleNumber:(NSNumber *)value
{
	if (!_set)
	{
		_max = value.doubleValue;
		_set = YES;
	}
	else
	{
		if (value.doubleValue > _max)
			_max = value.doubleValue;
	}
}

- (NSNumber *)result
{
	return @(_max);
}

@end


#pragma mark SMJConcatenateFunction

@implementation SMJConcatenateFunction

- (nullable id)invokeWithCurrentPathString:(NSString *)currentPath parentPath:(SMJPathRef *)parent jsonObject:(id)jsonObject evaluationContext:(id <SMJEvaluationContext>)ctx parameters:(nullable NSArray <SMJParameter *> *)parameters error:(NSError **)error
{
	NSMutableString *result = [NSMutableString string];

	// Helper.
	void (^handleEntry)(id) = ^(id entry) {
		
		if ([entry isKindOfClass:[NSString class]] == NO)
			return;
		
		[result appendString:entry];
	};
	
	// Enumerate object.
	if ([jsonObject isKindOfClass:[NSArray class]])
	{
		NSArray *array = jsonObject;

		[array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			handleEntry(obj);
		}];
	}
	
	// Enumerate parameters.
	NSArray *list = [SMJParameter listWithParameters:parameters itemsClass:[NSString class] error:error];
	
	if (!list)
		return nil;
	
	for (NSString *str in list)
		handleEntry(str);
	
	return result;
}

@end


#pragma mark SMJLengthFunction

@implementation SMJLengthFunction

- (nullable id)invokeWithCurrentPathString:(NSString *)currentPath parentPath:(SMJPathRef *)parent jsonObject:(id)jsonObject evaluationContext:(id <SMJEvaluationContext>)ctx parameters:(nullable NSArray <SMJParameter *> *)parameters error:(NSError **)error
{	
	if ([jsonObject isKindOfClass:[NSArray class]])
		return @([(NSArray *)jsonObject count]);
	else if ([jsonObject isKindOfClass:[NSDictionary class]])
		return @([(NSDictionary *)jsonObject count]);
	else if ([jsonObject isKindOfClass:[NSString class]])
		return @([(NSString *)jsonObject length]);
	else if ([jsonObject isKindOfClass:[NSNumber class]])
		return @([(NSNumber *)jsonObject stringValue].length);
	
	return nil;
}

@end


#pragma mark SMJAppendFunction

@implementation SMJAppendFunction

- (nullable id)invokeWithCurrentPathString:(NSString *)currentPath parentPath:(SMJPathRef *)parent jsonObject:(id)jsonObject evaluationContext:(id <SMJEvaluationContext>)ctx parameters:(nullable NSArray <SMJParameter *> *)parameters error:(NSError **)error
{
	if ([jsonObject isKindOfClass:[NSArray class]] == NO)
		return jsonObject;
	
	NSMutableArray *result = [[NSMutableArray alloc] initWithArray:jsonObject];
	
	for (SMJParameter *parameter in parameters)
	{
		id value = [parameter valueWithError:error];

		if (!value)
			return nil;
		
		[result addObject:value];
	}
	
	return result;
}

@end


NS_ASSUME_NONNULL_END
