/*
 * SMJCharacterIndex.h
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


/* Adapted from https://github.com/json-path/JsonPath/blob/master/json-path/src/main/java/com/jayway/jsonpath/internal/CharacterIndex.java */


#import <Foundation/Foundation.h>
#import <CoreFoundation/CFBase.h>


NS_ASSUME_NONNULL_BEGIN


/*
** SMJCharacterIndex
*/
#pragma mark - SMJCharacterIndex

@interface SMJCharacterIndex : NSObject

- (instancetype)initWithString:(NSString *)string;

@property (readonly) NSInteger length;

@property (nonatomic) NSInteger position;
@property (nonatomic) NSInteger endPosition;

@property (nonatomic) BOOL positionAtEnd;

@property (nonatomic) BOOL hasMoreCharacters;

@property (nonatomic) BOOL inBounds;

- (BOOL)isInBoundsIndex:(NSInteger)idx;
- (BOOL)isOutOfBoundsIndex:(NSInteger)idx;

- (unichar)characterAtIndex:(NSInteger)index;
- (unichar)characterAtIndex:(NSInteger)position defaultCharacter:(unichar)defaultChar;

@property (readonly) unichar currentCharacter;

- (BOOL)currentCharacterIsEqualTo:(unichar)character;
- (BOOL)lastCharacterIsEqualTo:(unichar)character;
- (BOOL)nextCharacterIsEqualTo:(unichar)character;

- (NSInteger)incrementPositionBy:(NSInteger)charCount;
- (NSInteger)decrementEndPositionBy:(NSInteger)charCount;

- (NSInteger)indexOfClosingSquareBracketFromIndex:(NSInteger)startPosition;
- (NSInteger)indexOfMatchingCloseCharacterFromIndex:(NSInteger)startPosition openCharacter:(unichar)openChar closeCharacter:(unichar)closeChar skipStrings:(BOOL)skipStrings skipRegex:(BOOL)skipRegex error:(NSError **)error;
- (NSInteger)indexOfClosingBracketFromIndex:(NSInteger)startPosition skipStrings:(BOOL)skipStrings skipRegex:(BOOL)skipRegex error:(NSError **)error;

- (NSInteger)indexOfNextSignificantCharacter:(unichar)character;
- (NSInteger)indexOfNextSignificantCharacter:(unichar)character fromIndex:(NSInteger)startPosition;

- (NSInteger)nextIndexOfCharacter:(unichar)character;
- (NSInteger)nextIndexOfCharacter:(unichar)character fromIndex:(NSInteger)startPosition;

- (NSInteger)nextIndexOfUnescapedCharacter:(unichar)character;
- (NSInteger)nextIndexOfUnescapedCharacter:(unichar)character fromIndex:(NSInteger)startPosition;

- (BOOL)nextSignificantCharacterIsEqualTo:(unichar)character;
- (BOOL)nextSignificantCharacterIsEqualTo:(unichar)character fromIndex:(NSInteger)startPosition;

- (unichar)nextSignificantCharacter;
- (unichar)nextSignificantCharacterFromIndex:(NSInteger)startPosition;

- (BOOL)readSignificantCharacter:(unichar)c error:(NSError **)error;
- (BOOL)hasSignificantString:(NSString *)string;

- (NSInteger)indexOfPreviousSignificantCharacter;
- (NSInteger)indexOfPreviousSignificantCharacterFromIndex:(NSInteger)startPosition;

- (unichar)previousSignificantCharacter;
- (unichar)previousSignificantCharacterFromIndex:(NSInteger)startPosition;

- (NSString *)stringFromIndex:(NSInteger)start toIndex:(NSInteger)end; // [start; end[

- (NSString *)stringValue;

- (BOOL)isNumberCharacterAtIndex:(NSInteger)readPosition;

- (SMJCharacterIndex *)skipBlanks;
- (SMJCharacterIndex *)skipBlanksAtEnd;

- (SMJCharacterIndex *)trim;

@end


NS_ASSUME_NONNULL_END

