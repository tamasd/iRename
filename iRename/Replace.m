//
//  Replace.m
//  iRename
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "Replace.h"

@implementation Replace

- (id)init
{
    self = [super initWithNibName:@"Replace" bundle:nil];
    if (self) {
        [self setTitle:@"Replace"];
    }
    return self;
}

- (NSString *)applyOnString:(NSString *)str
{
    NSStringCompareOptions cmp = 0;
    if ([caseSensitive state] != NSOnState) {
        cmp |= NSCaseInsensitiveSearch;
    }
    return [str stringByReplacingOccurrencesOfString:[from stringValue] withString:[to stringValue] options:cmp range:NSMakeRange(0, [str length])];
}

- (IBAction)display:(id)sender
{
    [controller displayRenameDialog:self];
}

@end
