//
//  AppController.h
//  iRename
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>

#define SELECTED_FILES_TAG      1
#define ALL_FILES_TAG           0
#define ONLY_IN_FILENAME_TAG    0
#define FULL_PATH_TAG           1

@class RenameViewController;
@class ErrorAggregator;

@interface AppController : NSObject {
    IBOutlet NSWindow *parentWindow;
    IBOutlet NSWindow *transformationWindow;
    IBOutlet NSWindow *progressWindow;
    IBOutlet NSArrayController *arrayController;
    IBOutlet NSBox *container;
    IBOutlet NSMatrix *fileListOption;
    IBOutlet NSMatrix *replaceRangeOption;
    IBOutlet NSProgressIndicator *progressIndicator;
    
    RenameViewController *rvc;
    
    ErrorAggregator *errors;
    
    NSOperationQueue *readQueue;
    NSOperationQueue *renameQueue;
    NSOperationQueue *waitQueue;
    
    BOOL transformationWindowOKButtonEnabled;
}

@property (nonatomic, assign) BOOL transformationWindowOKButtonEnabled;

- (IBAction)addDirectoryRecursive:(id)sender;
- (IBAction)clear:(id)sender;
- (IBAction)doRename:(id)sender;
- (IBAction)cancelRename:(id)sender;
- (IBAction)executeRename:(id)sender;

- (void)displayRenameDialog:(RenameViewController *)rvc;

@end
