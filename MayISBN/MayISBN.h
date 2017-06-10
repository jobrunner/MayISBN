@import Foundation;

//! Project version number for MayISBN.
FOUNDATION_EXPORT double MayISBNVersionNumber;

//! Project version string for MayISBN.
FOUNDATION_EXPORT const unsigned char MayISBNVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <MayISBN/PublicHeader.h>

#define kMayISBNErrorDomain         @"MayISBNErrorDomain"

typedef NS_ENUM(NSUInteger, MayISBNErrorNumber) {
    MayISBNErrorOk = 0,
    MayISBNErrorISBNDetection
};

@interface MayISBN : NSObject

@property (nonatomic, strong) NSNumber *isbnCode;

+ (instancetype)ISBNFromString:(NSString *)isbnString;
+ (instancetype)ISBNFromString:(NSString *)isbnString error:(NSError **)error;
+ (NSUInteger)decimalDigitValue:(NSString *)string atPosition:(NSUInteger)index;
+ (NSUInteger)calculateErrorCheckingNumberISBN10:(NSString *)code;
+ (NSUInteger)calculcateErrorCheckingNumberISBN13:(NSString *)code;
+ (NSString *)convertISBN10ToISBN13:(NSString *)isbn10Code;
- (instancetype)initWithISBNFromString:(NSString *)isbnString;
- (instancetype)initWithISBNFromString:(NSString *)isbnString error:(NSError **)error;
- (NSString *)filterDigitCharacters:(NSString *)code;
- (NSNumber *)numberWithString:(NSString *)code;
- (BOOL)validateISBN10:(NSString *)code;
- (BOOL)validateISBN13:(NSString *)code;

@end
