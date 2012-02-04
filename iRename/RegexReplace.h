//
//  RegexReplace.h
//  iRename
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "RenameViewController.h"

@interface RegexReplace : RenameViewController {
    IBOutlet NSButton *caseInsensitive;
    IBOutlet NSButton *literalString;
    IBOutlet NSTextField *pattern;
    IBOutlet NSTextField *tpl;
    
    NSRegularExpression *regex;
}

@end
