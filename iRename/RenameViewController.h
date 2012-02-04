//
//  RenameViewController.h
//  iRename
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Cocoa/Cocoa.h>
#import "AppController.h"

@interface RenameViewController : NSViewController {
    NSManagedObjectContext *managedObjectContext;
    IBOutlet AppController *controller;
}

@property (strong) NSManagedObjectContext *managedObjectContext;

- (IBAction)display:(id)sender;

- (BOOL)beginReplacing:(NSError **)err;
- (NSString *)applyOnString:(NSString *)str;
- (void)endReplacing;

@end
