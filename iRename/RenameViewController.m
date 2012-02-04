//
//  RenameViewController.m
//  iRename
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "RenameViewController.h"

@implementation RenameViewController

@synthesize managedObjectContext;

- (NSString *)applyOnString:(NSString *)str
{
    return str;
}

- (IBAction)display:(id)sender
{
    [NSAlert alertWithMessageText:@"Not implemented" 
                    defaultButton:@"OK" 
                  alternateButton:nil 
                      otherButton:nil 
        informativeTextWithFormat:@"This method is not implemented."];
}

- (BOOL)beginReplacing:(NSError *__autoreleasing *)err
{
    return YES;
}

- (void)endReplacing
{
}

@end
