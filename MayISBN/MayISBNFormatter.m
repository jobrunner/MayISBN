//
// Copyright © 2016 Jo Brunner <jo@mett.io>
// This work is free. You can redistribute it and/or modify it under the
// terms of the Do What The Fuck You Want To Public License, Version 2,
// as published by Sam Hocevar. See the LICENSE file for more details.
//
#import "MayISBN.h"
#import "MayISBNFormatter.h"
#import "MayISBNRangeDictionary.h"

static MayISBNFormatter *MayISBNFormatterReusableInstance;

@interface MayISBNFormatter()

/**
 * Internal state of ISBN representation
 */
@property (nonatomic, strong) NSString *prefix;
@property (nonatomic, strong) NSString *groupNumber;
@property (nonatomic, strong) NSString *publishingNumber;
@property (nonatomic, strong) NSString *titleNumber;
@property (nonatomic, strong) NSString *errorCheckingNumber;

@end

@implementation MayISBNFormatter

+ (NSString *)stringFromISBN:(MayISBN *)isbn {

    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        MayISBNFormatterReusableInstance = [[MayISBNFormatter alloc] init];
    });
    
    return [MayISBNFormatterReusableInstance stringForObjectValue:isbn];
}

- (instancetype)init {
    
    if (self = [super init]) {
        _isbnSeparators = YES;
        _isbnType = MayISBNFormatterTypeISBN13;
    }
    
    return self;
}

- (NSString *)stringFromISBN:(MayISBN *)value {

    return [self stringForObjectValue:value];
}

- (NSString *)stringForObjectValue:(id)value {

    if (![value isKindOfClass:[MayISBN class]]) {
    
        return nil;
    }
    
    MayISBN *isbn = (MayISBN *)value;
    NSError *error = nil;
    
    [self parseISBNParts:[isbn.isbnCode stringValue]
                   error:&error];
    
    if (error != nil) {
        
        return nil;
    }
    
    switch (_isbnType) {
        case MayISBNFormatterTypeISBN10:
            return [self formatISBN10:isbn
                                error:&error];
            
        case MayISBNFormatterTypeISBN13:
        default:
            return [self formatISBN13:isbn];
    }
}

- (NSString *)formatISBN10:(MayISBN *)isbn error:(NSError **)error {
    
    if (![self isPossibleISBN10Representation]) {

        NSDictionary * userInfo = @{
          NSLocalizedDescriptionKey:NSLocalizedString(@"ISBN-10 representation not possible.", nil),
          NSLocalizedFailureReasonErrorKey:NSLocalizedString(@"Only ISBN-13 that start with 978 can be represented in ISBN-10.", nil),
          NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"Use ISBN-13 instead.", nil)
          };
         *error = [NSError errorWithDomain:kMayISBNFormatterErrorDomain
                                     code:MayISBNFormatterErrorISBN10Representation
                                 userInfo:userInfo];
        return nil;
    }
    
    NSString *format = (_isbnSeparators == YES) ? @"%@-%@-%@-%@" : @"%@%@%@%@";
    
    NSUInteger checkSum = [MayISBN calculateErrorCheckingNumberISBN10:[isbn.isbnCode stringValue]];
    
    NSString *checkSumString = (checkSum == 10) ? @"X" : [@(checkSum) stringValue];
    
    return [NSString stringWithFormat:format,
            _groupNumber,
            _publishingNumber,
            _titleNumber,
            checkSumString];
}

- (NSString *)formatISBN13:(MayISBN *)isbn {
    
    NSString *format = (_isbnSeparators == YES) ? @"%@-%@-%@-%@-%@" : @"%@%@%@%@%@";
    
    return [NSString stringWithFormat:format,
            _prefix,
            _groupNumber,
            _publishingNumber,
            _titleNumber,
            _errorCheckingNumber];
}

- (void)parseISBNParts:(NSString *)code
                 error:(NSError **)error{

    [self findPrefix:code];
    
    [self findGroupNumber:code
                    error:error];
    
    if (*error != nil) {
        return;
    }
    
    [self findPublishingNumber:code
                         error:error];
    
    if (*error != nil) {
        return;
    }
    [self findTitleNumber:code];
    
    [self findCheckSum:code
                 error:error];
}

- (void)findPrefix:(NSString *)code {
    
    _prefix = [code substringToIndex:3];
}

- (void)findGroupNumber:(NSString *)code
                  error:(NSError **)error {
    
    NSDictionary *dict = [MayISBNRangeDictionary rangeDictionary];
    
    NSArray *allKeys = [dict allKeys];
    
    for (NSInteger len = 3; len < 13; len++) {
        NSString *searchKey = [code substringToIndex:len];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@", searchKey];
        NSArray *filteredData = [allKeys filteredArrayUsingPredicate:predicate];
        
        if ([filteredData count] == 1) {
            _groupNumber = [searchKey substringFromIndex:3];
            *error = nil;
            
            return;
        }
        
        if ([filteredData count] == 0) {
            NSDictionary * userInfo = @{
                                        NSLocalizedDescriptionKey:NSLocalizedString(@"Invalid ISBN.", nil),
                                        NSLocalizedFailureReasonErrorKey:NSLocalizedString(@"Could not detected correct group number.", nil)
                                        };
            *error = [NSError errorWithDomain:kMayISBNFormatterErrorDomain
                                         code:MayISBNFormatterErrorGroupNumber
                                     userInfo:userInfo];
            return;
        }
        
        allKeys = filteredData;
    }
}

- (void)findPublishingNumber:(NSString *)code
                       error:(NSError **)error {
    
    NSString *key = [NSString stringWithFormat:@"%@%@", _prefix, _groupNumber];
    
    NSArray *rules = [[MayISBNRangeDictionary rangeDictionary] objectForKey:key];
    NSUInteger startPosition = [key length];
    NSString *heystack = [code substringFromIndex:(startPosition)];
    
    for (NSDictionary *rule in rules) {
        
        NSUInteger length   = [[rule objectForKey:@"len"] integerValue];
        NSUInteger lower = [[rule objectForKey:@"lo"] integerValue];
        NSUInteger upper = [[rule objectForKey:@"hi"] integerValue];
        
        NSUInteger publishingNumber = [[heystack substringWithRange:NSMakeRange(0, length)] integerValue];
        
        if ((publishingNumber >= lower) && (publishingNumber <= upper)) {
            _publishingNumber = [NSString stringWithFormat:@"%@", @(publishingNumber)];
            *error = nil;
            return;
        }
    }
    
    // ??? NSError
    NSLog(@"Failed publisher number not valid");
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey:NSLocalizedString(@"Invalid ISBN.", nil),
                               NSLocalizedFailureReasonErrorKey:NSLocalizedString(@"Could not detected correct publisher number.", nil)
                               };
    *error = [NSError errorWithDomain:kMayISBNFormatterErrorDomain
                                 code:MayISBNFormatterErrorPublisherNumber
                             userInfo:userInfo];
}

- (void)findTitleNumber:(NSString *)code {
    
    NSUInteger startPosition = [[NSString stringWithFormat:@"%@%@%@",
                                 _prefix,
                                 _groupNumber,
                                 _publishingNumber] length];
    
    _titleNumber = [code substringWithRange:NSMakeRange(startPosition, (13 - startPosition - 1))];
}

- (void)findCheckSum:(NSString *)code
               error:(NSError **)error {
    
    NSUInteger checkSum = [[code substringFromIndex:12] integerValue];
    
    if (checkSum == [MayISBN calculcateErrorCheckingNumberISBN13:code]) {
        _errorCheckingNumber = [NSString stringWithFormat:@"%@", @(checkSum)];
        *error = nil;

        return;
    }
    
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey:NSLocalizedString(@"Invalid ISBN.", nil),
                               NSLocalizedFailureReasonErrorKey:NSLocalizedString(@"Checksum of ISBN is not correct.", nil)
                               };
    *error = [NSError errorWithDomain:kMayISBNFormatterErrorDomain
                                 code:MayISBNFormatterErrorErrorCheckingNumber
                             userInfo:userInfo];
}

- (BOOL)isPossibleISBN10Representation {
    
    return ([_prefix integerValue] == 978);
}

@end
