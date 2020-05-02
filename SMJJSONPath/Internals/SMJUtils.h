/*
 * SMJUtils.h
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/Utils.java */


#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


/*
** SMJUtils
*/
#pragma mark - SMJUtils

@interface SMJUtils : NSObject

+ (NSString *)stringByConcatenatingStrings:(NSArray <NSString *> *)strings;

+ (NSString *)stringByJoiningStrings:(NSArray <NSString *> *)strings delimiter:(NSString *)delimiter wrap:(NSString *)wrap;

+ (NSString *)stringByEscapingString:(NSString *)string escapeSingleQuote:(BOOL)escapeSingleQuote;
+ (NSString *)stringByUnescapingString:(NSString *)str;

+ (nullable NSNumber *)numberWithString:(NSString *)string;

@end


NS_ASSUME_NONNULL_END
