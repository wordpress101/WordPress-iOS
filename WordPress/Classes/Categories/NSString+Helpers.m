#import "NSString+Helpers.h"
#import <CommonCrypto/CommonDigest.h>
#import <WordPress-iOS-Shared/NSString+XMLExtensions.h>

static NSString *const Ellipsis =  @"\u2026";

@implementation NSString (Helpers)

#pragma mark Helpers

+ (NSString *)makePlainText:(NSString *)string
{
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [[[string stringByStrippingHTML] stringByDecodingXMLCharacters] stringByTrimmingCharactersInSet:charSet];
}

+ (NSString *)stripShortcodesFromString:(NSString *)string
{
    if (!string) {
        return nil;
    }
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error;
        NSString *pattern = @"\\[[^\\]]+\\]";
        regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        if (error) {
            DDLogError(@"Error parsing regex: %@", error);
        }
    });
    NSRange range = NSMakeRange(0, [string length]);
    return [regex stringByReplacingMatchesInString:string
                                           options:NSMatchingReportCompletion
                                             range:range
                                      withTemplate:@""];
}

// Taken from AFNetworking's AFPercentEscapedQueryStringPairMemberFromStringWithEncoding
- (NSString *)stringByUrlEncoding
{
    static NSString * const kAFCharactersToBeEscaped = @":/?&=;+!@#$()~',*";
    static NSString * const kAFCharactersToLeaveUnescaped = @"[].";

    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)self, (__bridge CFStringRef)kAFCharactersToLeaveUnescaped, (__bridge CFStringRef)kAFCharactersToBeEscaped, kCFStringEncodingUTF8);
}

- (NSString *)md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];

    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);

    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
            ];
}

- (NSMutableDictionary *)dictionaryFromQueryString
{
    if (!self) {
        return nil;
    }

    NSMutableDictionary *result = [NSMutableDictionary dictionary];

    NSArray *pairs = [self componentsSeparatedByString:@"&"];
    for (NSString *pair in pairs) {
        NSRange separator = [pair rangeOfString:@"="];
        NSString *key, *value;
        if (separator.location != NSNotFound) {
            key = [pair substringToIndex:separator.location];
            value = [[pair substringFromIndex:separator.location + 1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        } else {
            key = pair;
            value = @"";
        }

        key = [key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [result setObject:value forKey:key];
    }

    return result;
}

- (NSString *)stringByReplacingHTMLEmoticonsWithEmoji
{
    NSMutableString *result = [NSMutableString stringWithString:self];

    NSDictionary *replacements = @{
                                   @"icon_arrow": @"➡",
                                   @"icon_biggrin": @"😃",
                                   @"icon_confused": @"😕",
                                   @"icon_cool": @"😎",
                                   @"icon_cry": @"😭",
                                   @"icon_eek": @"😮",
                                   @"icon_evil": @"😈",
                                   @"icon_exclaim": @"❗",
                                   @"icon_idea": @"💡",
                                   @"icon_lol": @"😄",
                                   @"icon_mad": @"😠",
                                   @"icon_mrgreen": @"🐸",
                                   @"icon_neutral": @"😐",
                                   @"icon_question": @"❓",
                                   @"icon_razz": @"😛",
                                   @"icon_redface": @"😊",
                                   @"icon_rolleyes": @"😒",
                                   @"icon_sad": @"😞",
                                   @"icon_smile": @"😊",
                                   @"icon_surprised": @"😮",
                                   @"icon_twisted": @"👿",
                                   @"icon_wink": @"😉",
                                   // NOTE: There is not a perfect match for the following four with
                                   // currently supported emoji. We'll try to get as close as we can.
                                   @"frownie":@"😞",
                                   @"mrgreen":@"😊",
                                   @"rolleyes":@"😒",
                                   @"simple-smile":@"😊"
                                   };

    static NSRegularExpression *smiliesRegex;
    static NSRegularExpression *coreEmojiRegex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error;
        smiliesRegex = [NSRegularExpression regularExpressionWithPattern:@"<img.*?src=['\"].*?wp-includes/images/smilies/(.+?)(?:.gif|.png)[^'\"]*['\"].*?class=['\"]wp-smiley['\"].*?/?>" options:NSRegularExpressionCaseInsensitive error:&error];
        coreEmojiRegex = [NSRegularExpression regularExpressionWithPattern:@"<img .*?src=['\"].*?images/core/emoji/[^/]+/(.+?).png['\"].*?class=['\"]wp-smiley['\"][^//]+/?>" options:NSRegularExpressionCaseInsensitive error:&error];
    });

    NSArray *matches = [smiliesRegex matchesInString:result options:0 range:NSMakeRange(0, [result length])];
    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        NSRange range = [match rangeAtIndex:1];
        NSString *icon = [result substringWithRange:range];
        NSString *replacement = [replacements objectForKey:icon];
        if (replacement) {
            [result replaceCharactersInRange:[match range] withString:replacement];
        }
    }

    matches = [coreEmojiRegex matchesInString:result options:0 range:NSMakeRange(0, [result length])];
    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        NSRange range = [match rangeAtIndex:1];
        NSString *filename = [result substringWithRange:range];
        NSString *replacement = [self emojiUnicodeFromCoreEmojiFilename:filename];
        if (replacement) {
            [result replaceCharactersInRange:[match range] withString:replacement];
        }
    }

    return [NSString stringWithString:result];
}

/**
 Pass the hex string for a unicode character and returns that unicode character. 
 Core WordPress emoji images are named after their unicode code point. This makes
 it convenient to scan the filename for its hex value and return the appropriate
 emoji character.
 */
- (NSString *)emojiUnicodeFromCoreEmojiFilename:(NSString *)filename
{
    NSScanner *scanner = [NSScanner scannerWithString:filename];
    unsigned long long hex = 0;
    BOOL success = [scanner scanHexLongLong:&hex];
    if (!success) {
        return nil;
    }
    return [[NSString alloc] initWithBytes:&hex length:4 encoding:NSUTF32LittleEndianStringEncoding];
}

/*
 * Uses a RegEx to strip all HTML tags from a string and unencode entites
 */
- (NSString *)stringByStrippingHTML
{
    return [self stringByReplacingOccurrencesOfString:@"<[^>]+>" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, self.length)];
}

// A method to truncate a string at a predetermined length and append ellipsis to the end

- (NSString *)stringByEllipsizingWithMaxLength:(NSInteger)lengthlimit preserveWords:(BOOL)preserveWords
{
    NSInteger currentLength = [self length];
    NSString *result = @"";
    NSString *temp = @"";

    if (currentLength <= lengthlimit) { //If the string is already within limits
        return self;
    } else if (lengthlimit > 0) { //If the string is longer than the limit, and the limit is larger than 0.

        NSInteger newLimitWithoutEllipsis = lengthlimit - [Ellipsis length];

        if (preserveWords) {

            NSArray *wordsSeperated = [self tokenize];

            if ([wordsSeperated count] == 1) { // If this is a long word then we disregard preserveWords property.
                return [NSString stringWithFormat:@"%@%@", [self substringToIndex:newLimitWithoutEllipsis], Ellipsis];
            }

            for (NSString *word in wordsSeperated) {

                if ([temp isEqualToString:@""]) {
                    temp = word;
                } else {
                    temp = [NSString stringWithFormat:@"%@%@", temp, word];
                }

                if ([temp length] <= newLimitWithoutEllipsis) {
                    result = [temp copy];
                } else {
                    return [NSString stringWithFormat:@"%@%@",result,Ellipsis];
                }
            }
        } else {
            return [NSString stringWithFormat:@"%@%@", [self substringToIndex:newLimitWithoutEllipsis], Ellipsis];
        }

    } else { //if the limit is 0.
        return @"";
    }

    return self;
}

- (NSString *)hostname
{
    return [[[NSURLComponents alloc] initWithString:self] host];
}

- (NSArray *)tokenize
{
    CFLocaleRef locale = CFLocaleCopyCurrent();
    CFRange stringRange = CFRangeMake(0, [self length]);

    CFStringTokenizerRef tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault,
                                                             (CFStringRef)self,
                                                             stringRange,
                                                             kCFStringTokenizerUnitWordBoundary,
                                                             locale);

    CFStringTokenizerTokenType tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer);

    NSMutableArray *tokens = [NSMutableArray new];

    while (tokenType != kCFStringTokenizerTokenNone) {
        stringRange = CFStringTokenizerGetCurrentTokenRange(tokenizer);
        NSString *token = [self substringWithRange:NSMakeRange(stringRange.location, stringRange.length)];
        [tokens addObject:token];
        tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer);
    }

    CFRelease(locale);
    CFRelease(tokenizer);

    return tokens;
}

- (BOOL)isWordPressComPath
{
    NSString *const dotcomDomain    = @"wordpress.com";
    NSString *const dotcomSuffix    = [@"." stringByAppendingString:dotcomDomain];
    NSArray *const validProtocols   = @[ @"http", @"https" ];
    
    // NOTE: Whenever the protocol is not specified, the host will be actually found in the Path getter
    NSURLComponents *components     = [NSURLComponents componentsWithString:self];
    NSString *lowercaseHostname     = components.host ?: components.path.pathComponents.firstObject;
    lowercaseHostname               = lowercaseHostname.lowercaseString;
    
    // Valid Domain names can be:
    //  -   wordpress.com
    //  -   *.wordpress.com
    //  -   http(s)://wordpress.com
    //  -   http(s):*.wordpress.com

    BOOL isDotcom                   = [lowercaseHostname hasSuffix:dotcomSuffix] ||
                                      [lowercaseHostname isEqualToString:dotcomDomain];
    
    BOOL isProtocolValid            = components.scheme == nil || [validProtocols containsObject:components.scheme];
    
    return isDotcom && isProtocolValid;
}

- (NSUInteger)wordCount
{
    // This word counting algorithm is from : http://stackoverflow.com/a/13367063
    __block NSUInteger wordCount = 0;
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length])
                                                   options:NSStringEnumerationByWords | NSStringEnumerationLocalized
                                                usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
                                                    wordCount++;
                                                }];
    return wordCount;
}

@end
