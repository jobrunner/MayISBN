//
// Copyright © 2016 Jo Brunner <jo@mett.io>
// This work is free. You can redistribute it and/or modify it under the
// terms of the Do What The Fuck You Want To Public License, Version 2,
// as published by Sam Hocevar. See the LICENSE file for more details.
//
@import Foundation;

#define kMayISBNFormatterErrorDomain         @"MayISBNFormatterErrorDomain"

typedef enum MayISBNFormatterError : NSUInteger {

    MayISBNFormatterErrorISBN10Representation,
    MayISBNFormatterErrorGroupNumber,
    MayISBNFormatterErrorPublisherNumber,
    MayISBNFormatterErrorErrorCheckingNumber

} MayISBNFormatterError;

typedef enum MayISBNFormatterType : NSUInteger {
    // supress ISBN
    MayISBNFormatterTypeNone,
    // format as descripted in the object
    MayISBNFormatterTypeFromObject,
    // enforces ISBN10
    MayISBNFormatterTypeISBN10,
    // enforces ISBN13
    MayISBNFormatterTypeISBN13
} MayISBNFormatterType;

typedef enum MayISBNFormatterSeparators : NSUInteger {
    // only digits
    MayISBNFormatterFormatSeparatorsNone,
    // digits and white spaces between groups
    MayISBNFormatterFormatSeparatorsWhiteSpace,
    // digits and hyphens (standard)
    MayISBNFormatterFormatSeparatorsHyphen
} MayISBNFormatterSeparators;

@interface MayISBNFormatter : NSFormatter

@property (nonatomic, readwrite) MayISBNFormatterType isbnType;
@property (nonatomic,readwrite) MayISBNFormatterSeparators isbnSeparators;
@property (nonatomic,readwrite) BOOL isbnLabeled;

+ (NSString *)stringFromISBN:(MayISBN *)isbn;
- (NSString *)stringFromISBN:(MayISBN *)isbn;

@end
