/*
 * SMJRelationalOperator.h
 *
 * Copyright 2019 Avérous Julien-Pierre
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


#import <Foundation/Foundation.h>
#import <CoreFoundation/CFString.h>
#import <dispatch/dispatch.h>


NS_ASSUME_NONNULL_BEGIN


/*
** Defines
*/
#pragma mark - Defines

#define SMJRelationalOperatorGTE 		@">="
#define SMJRelationalOperatorLTE		@"<="
#define SMJRelationalOperatorEQ			@"=="

/**
 * Type safe equals
 */
#define SMJRelationalOperatorTSEQ		@"==="
#define SMJRelationalOperatorNE			@"!="

/**
 * Type safe not equals
 */
#define SMJRelationalOperatorTSNE		@"!=="
#define SMJRelationalOperatorLT			@"<"
#define SMJRelationalOperatorGT			@">"
#define SMJRelationalOperatorREGEX		@"=~"
#define SMJRelationalOperatorNIN		@"NIN"
#define SMJRelationalOperatorIN			@"IN"
#define SMJRelationalOperatorCONTAINS	@"CONTAINS"
#define SMJRelationalOperatorALL		@"ALL"
#define SMJRelationalOperatorSIZE		@"SIZE"
#define SMJRelationalOperatorEXISTS		@"EXISTS"
#define SMJRelationalOperatorTYPE		@"TYPE"
//#define SMJRelationalOperatorMATCHES	@"MATCHES"
#define SMJRelationalOperatorEMPTY		@"EMPTY"
#define SMJRelationalOperatorSUBSETOF	@"SUBSETOF"
#define SMJRelationalOperatorANYOF		@"ANYOF"
#define SMJRelationalOperatorNONEOF		@"NONEOF"



/*
** SMJRelationalOperator
*/
#pragma mark - SMJRelationalOperator

@interface SMJRelationalOperator : NSObject

// -- Instance --
+ (instancetype)relationalOperatorEXISTS;

+ (nullable instancetype)relationalOperatorFromString:(NSString *)string error:(NSError **)error;

// -- Content --
@property (readonly) NSString *stringOperator;

@end


NS_ASSUME_NONNULL_END
