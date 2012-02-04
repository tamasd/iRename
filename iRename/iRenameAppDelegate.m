//
//  iRenameAppDelegate.m
//  iRename
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "iRenameAppDelegate.h"

@implementation iRenameAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
}

- (IBAction)aboutPanel:(id)sender
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"", @"Credits",
                             @"", @"Copyright",
                             @"", @"Version",
                             nil];
    [[NSApplication sharedApplication] orderFrontStandardAboutPanelWithOptions:options];
}

@end
