//
//  RegexReplace.m
//  iRename
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "RegexReplace.h"

@interface RegexReplace ()

- (void)validateRegex:(NSNotification *)n;
- (NSRegularExpressionOptions)getRegexOptions;

@end

@implementation RegexReplace

- (id)init
{
    self = [super initWithNibName:@"RegexReplace" bundle:nil];
    if (self) {
        [self setTitle:@"Regex replace"];
        regex = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(validateRegex:) 
                                                     name:NSControlTextDidChangeNotification
                                                   object:pattern];
    }
    return self;
}

- (void)validateRegex:(NSNotification *)n
{
    if ([n object] != pattern) {
        return;
    }
    NSString *regexPattern = [pattern stringValue];
    NSRegularExpression *testRegex = [NSRegularExpression regularExpressionWithPattern:regexPattern 
                                                                           options:[self getRegexOptions] 
                                                                             error:NULL];
    if ([regexPattern length] > 0 && testRegex == nil) {
        [controller setTransformationWindowOKButtonEnabled:NO];
        [pattern setTextColor:[NSColor redColor]];
    } else {
        [controller setTransformationWindowOKButtonEnabled:YES];
        [pattern setTextColor:[NSColor blackColor]];
    }
}

- (NSRegularExpressionOptions)getRegexOptions
{
    NSRegularExpressionOptions options = 0;

    if ([caseInsensitive state] == NSOnState) {
        options |= NSRegularExpressionCaseInsensitive;
    }

    if ([literalString state] == NSOnState) {
        options |= NSRegularExpressionIgnoreMetacharacters;
    }

    return options;
}

- (BOOL)beginReplacing:(NSError *__autoreleasing *)err
{
    
    regex = [[NSRegularExpression alloc] initWithPattern:[pattern stringValue]
                                                 options:[self getRegexOptions]
                                                   error:err];
    return regex != nil;
}

- (NSString *)applyOnString:(NSString *)str
{
    NSMutableString *string = [str mutableCopy];
    
    [regex replaceMatchesInString:string 
                          options:0 
                            range:NSMakeRange(0, [str length]) 
                     withTemplate:[tpl stringValue]];
    
    return [NSString stringWithString:string];
}

- (void)endReplacing
{
    regex = nil;
}

- (void)display:(id)sender
{
    [controller displayRenameDialog:self];
}

@end
